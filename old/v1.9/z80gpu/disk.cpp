#include <stdio.h>
#include "bus_access.h"
#include "debug_protocol.h"

const uint8_t disk_table[] = {
#include "disk_table.inl"
};

constexpr uint32_t DT_SIZE=sizeof(disk_table);
constexpr uint8_t DT_BUFFER_SIZE=250;

struct DiskTransaction
{
	enum Commands { INIT, LIST, NEXT, CHDIR, PWDIR, OPENFILE, READ, WRITE, CLOSE };
	enum Results  { OK=200, FAILED=201 };
	uint8_t		command_and_result;
	uint8_t		arg1;
	uint16_t	arg2;
	uint16_t	arg3;
	char		data[DT_BUFFER_SIZE];
};

static_assert(sizeof(DiskTransaction)==256);

class FileSystem
{
    uint32_t m_ListPos=0;
    uint32_t m_ReadPos=0;
    uint32_t m_ReadEnd=0;
public:
	bool init();
	bool chdir(const char* dirpath);
	bool pwd(char* dirpath);
	bool list(const char* dirpath, char* filename, uint16_t& filesize);
	bool list_next(char* filename, uint16_t& filesize);
	
	uint8_t open_file(const char* filename, bool write);
	uint16_t read_file(uint8_t handle, uint8_t* buffer, uint16_t size);
	uint16_t write_file(uint8_t handle, const uint8_t* buffer, uint16_t size);
	bool close_file(uint8_t handle);
} file_system;

void process_disk_transaction()
{
    DiskTransaction dt;
    uint8_t* const ptr=reinterpret_cast<uint8_t*>(&dt);
    const uint16_t addr=0x0C00;
    for(uint16_t i=0;i<sizeof(DiskTransaction);++i)
        ptr[i]=read_byte(addr+i);
	switch (dt.command_and_result)
	{
		case DiskTransaction::INIT:
			dt.command_and_result = file_system.init() ? DiskTransaction::OK : DiskTransaction::FAILED; break;
		case DiskTransaction::LIST:
			dt.command_and_result = file_system.list(dt.data,dt.data,dt.arg2) ? DiskTransaction::OK : DiskTransaction::FAILED; break;
		case DiskTransaction::NEXT:
			dt.command_and_result = file_system.list_next(dt.data,dt.arg2) ? DiskTransaction::OK : DiskTransaction::FAILED; break;
		case DiskTransaction::CHDIR:
			dt.command_and_result = file_system.chdir(dt.data) ? DiskTransaction::OK : DiskTransaction::FAILED; break;
		case DiskTransaction::PWDIR:
			dt.command_and_result = file_system.pwd(dt.data) ? DiskTransaction::OK : DiskTransaction::FAILED; break;
		case DiskTransaction::OPENFILE:
			dt.arg1 = file_system.open_file(dt.data, dt.arg1);
			dt.command_and_result = (dt.arg1!=0xFF) ? DiskTransaction::OK : DiskTransaction::FAILED; break;
		case DiskTransaction::CLOSE:
			dt.command_and_result = file_system.close_file(dt.arg1) ? DiskTransaction::OK : DiskTransaction::FAILED; break;
		case DiskTransaction::READ:
		{
			uint16_t left=dt.arg2;
			uint16_t addr=dt.arg3;
			dt.arg2=0;
			while (left>0)
			{
				uint16_t cur = (left>DT_BUFFER_SIZE)?DT_BUFFER_SIZE:left;
				uint16_t act = file_system.read_file(dt.arg1, (uint8_t*)dt.data, cur);
				if (act==0) break;
				for(uint8_t i=0;act>0;--act,++addr,++i)
					write_byte(addr,dt.data[i]);
				left-=act;
				dt.arg2+=act;
			}
			dt.command_and_result = (dt.arg2>0) ? DiskTransaction::OK : DiskTransaction::FAILED;
			break;
		}
		case DiskTransaction::WRITE:
			dt.command_and_result=DiskTransaction::FAILED;
			break;
	}
	for(uint16_t i=0;i<sizeof(DiskTransaction);++i)
		write_byte(addr+i, ptr[i]);
}


/*

bool FileSystem::init()
{
    return true;
}

bool FileSystem::chdir(const char* dirpath)
{
    return false;
}

bool FileSystem::pwd(char* dirpath)
{
    return false;
}

bool FileSystem::list(const char* dirpath, char* filename, uint16_t& filesize)
{
    m_ListPos=0;
    return list_next(filename, filesize);
}

uint16_t min(uint16_t a, uint16_t b) { return a<b?a:b;}

void copy_n(uint8_t* target, const uint8_t* source, uint16_t size)
{
    for(;size>0;--size,++target,++source)
        *target=*source;
}

void strcpy(char* dst, const char* src)
{
	do 
	{
		*dst++=*src;
	} while (*src++);
}

int strcmp(const char* s1, const char* s2)
{
    while (*s1 && *s2)
    {
        if (*s1 == *s2)
        {
            ++s1;
            ++s2;
        }
        else
        {
            if (*s1 < *s2) return -1;
            return 1;
        }
    }
    if (*s1==0 && *s2==0) return 0;
    if (*s2==0) return -1;
    return 1;
}

bool FileSystem::list_next(char* filename, uint16_t& filesize)
{
    if (m_ListPos>=DT_SIZE) return false;
    strcpy(filename, (const char*)&disk_table[m_ListPos]);
	g_DebugProtocol.print_text(filename);
	filesize = disk_table[m_ListPos+15];
	filesize = (filesize << 8) | disk_table[m_ListPos+14];
    m_ListPos+=(16 + filesize);
    return true;
}
	
uint8_t FileSystem::open_file(const char* filename, bool write)
{
    if (write) return 0xFF;
    m_ReadPos=0;
    while (m_ReadPos<(DT_SIZE-16))
    {
		uint16_t size = disk_table[m_ReadPos+15];
		size = (size<<8) | disk_table[m_ReadPos+14];
        if (strcmp(filename, (const char*)&disk_table[m_ReadPos]) == 0)
        {
			g_DebugProtocol.print_text("Opening file");
            m_ReadPos+=16;
            m_ReadEnd=m_ReadPos+size;
            return 1;
        }
		else
		{
			m_ReadPos+=16+size;
		}
    }
    return 0xFF;
}

uint16_t FileSystem::read_file(uint8_t handle, uint8_t* buffer, uint16_t size)
{
    uint16_t total=0;
    if (m_ReadPos < m_ReadEnd)
    {
        uint16_t act = min(m_ReadEnd-m_ReadPos, size);
		char msg[32];
		sprintf(msg, "Reading %hd",act);
		g_DebugProtocol.print_text(msg);
        copy_n(buffer, &disk_table[m_ReadPos], act);
        m_ReadPos+=act;
        total+=act;
    }
    return total;
}


uint16_t FileSystem::write_file(uint8_t handle, const uint8_t* buffer, uint16_t size)
{
    return 0;
}

bool FileSystem::close_file(uint8_t handle)
{
    m_ReadEnd=0;
    return true;
}
*/
