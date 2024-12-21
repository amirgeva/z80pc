// #include "consts.h"
#include <stdio.h>
#include "filesys.h"
#include "sdcard.h"
// #include "ff.h"
#include "diskio.h"
#include "dbg.h"
#include "gpu.h"


char msg[64];
static SDCard card;
static DRESULT disk_state=RES_NOTRDY;

void strcpy(char* dst, const char* src)
{
	do 
	{
		*dst++=*src;
	} while (*src++);
}

extern "C"
{
	DRESULT disk_read (BYTE pdrv, BYTE* buff, LBA_t sector, UINT count)
	{
		uint8_t token;
		if (card.read_sector(sector,buff,&token))
		{
			return RES_OK;
		}
		return RES_ERROR;
	}
	
	DRESULT disk_write (BYTE pdrv, const BYTE* buff, LBA_t sector, UINT count)
	{
		return RES_WRPRT;
	}
	
	DSTATUS disk_status (BYTE pdrv)
	{
		return disk_state;
	}
	
	DSTATUS disk_initialize (BYTE pdrv)
	{
		return disk_state;
	}
	
	DRESULT disk_ioctl (BYTE pdrv, BYTE cmd, void* buff)
	{
		return RES_ERROR;
	}
};

static bool			dir_opened=false;
static FATFS		fs;
static DIR			dir;
static FILINFO		finfo;
constexpr uint8_t MAX_OPEN_FILES=4;
static bool			opened_flags[MAX_OPEN_FILES];
static FIL			open_files[MAX_OPEN_FILES];

bool FileSystem::init(ispi::SPI* s)
{
	if (disk_state==RES_OK) return true;
	if (disk_state==RES_ERROR) return false;
	for(uint8_t i=0;i<MAX_OPEN_FILES;++i)
	{
		opened_flags[i]=false;
	}
	if (!card.init(s))
	{
		debug_print("card.init failed\r\n");
		disk_state=RES_ERROR;
		return false;
	}
	disk_state=RES_OK;
	debug_print("Card init done\r\n");
	FRESULT rc=f_mount(&fs,"",1);
	debug_print("Mount done\r\n");
	return rc==FR_OK;
}

bool FileSystem::chdir(const char* dirpath)
{
	return false;
}

bool FileSystem::pwd(char* dirpath)
{
	return false;
}

bool FileSystem::list(const char* dirpath, char* filename, uint16_t* filesize)
{
	DBG(sprintf(msg,"List '%s'",dirpath); debug_print(msg));
	if (dir_opened)
	{
		f_closedir(&dir);
		dir_opened=false;
	}
	
	FRESULT rc = f_opendir(&dir, dirpath);
	if (rc != FR_OK) 
	{
		DBG(debug_print("Failed to open dir"));
		return false;
	}
	dir_opened=true;
	return list_next(filename,filesize);
}

bool FileSystem::list_next(char* filename, uint16_t* filesize)
{
	if (!dir_opened) return false;
	FRESULT rc = f_readdir(&dir, &finfo);
	if (rc != FR_OK || !finfo.fname[0])
	{
		DBG(debug_print("Failed to read dir"));
		f_closedir(&dir);
		dir_opened=false;
		return false;
	}
	DBG(sprintf(msg,"%s %d",finfo.fname,finfo.fsize);debug_print(msg));
	strcpy(filename,finfo.fname);
	*filesize = uint16_t(finfo.fsize);
	return true;
}
	
uint8_t FileSystem::open_file(const char* filename, bool write)
{
	for(uint8_t i=0;i<MAX_OPEN_FILES;++i)
	{
		if (!opened_flags[i])
		{
			uint8_t flag=write?(FA_WRITE|FA_CREATE_ALWAYS|FA_CREATE_NEW):(FA_READ);
			FRESULT rc = f_open(&open_files[i],filename,flag);
			if (rc==FR_OK)
			{
				opened_flags[i]=true;
				return i;
			}
			break;
		}
	}
	return 0xFF;
}

uint16_t FileSystem::read_file(uint8_t handle, uint8_t* buffer, uint16_t size)
{
	if (handle>=MAX_OPEN_FILES) return 0;
	if (!opened_flags[handle])	return 0;
	UINT br;
	FRESULT rc = f_read(&open_files[handle],buffer,size,&br);
	if (rc!=FR_OK) return 0;
	return br;
}

uint16_t FileSystem::write_file(uint8_t handle, const uint8_t* buffer, uint16_t size)
{
	if (handle>=MAX_OPEN_FILES) return 0;
	if (!opened_flags[handle])	return 0;
	UINT br;
	FRESULT rc = f_write(&open_files[handle],buffer,size,&br);
	if (rc!=FR_OK) return 0;
	return br;
}

bool FileSystem::close_file(uint8_t handle)
{
	if (handle>=MAX_OPEN_FILES) return false;
	if (!opened_flags[handle])	return false;
	FRESULT rc = f_close(&open_files[handle]);
	if (rc==FR_OK)
	{
		opened_flags[handle]=false;
		return true;
	}
	return false;
}

bool FileSystem::load_sprites(const char* filename, uint8_t index)
{
	uint8_t h = open_file(filename,false);
	if (h==0xFF) return false;
	uint16_t count=0;
	uint8_t sprite[256];
	while (read_file(h,sprite,256)==256)
	{
		++count;
		gpu_set_sprite(index++,sprite);
	}
	close_file(h);
	return count>0;
}
