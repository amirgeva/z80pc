#include "filesystem/filesys.h"
#include "bus_access.h"
#include "MCP23S17/ISPI.h"

constexpr uint16_t IO_BUFFER = 0x0C00;
DiskTransaction dt;
extern ispi::SPI* sd_inst;
static bool filesystem_valid=false;

void init_filesys()
{
	filesystem_valid = FileSystem::init(sd_inst);
}

void process_disk_transaction()
{
	if (!is_bus_acquired()) return;
	if (!filesystem_valid)
	{
		write_byte(IO_BUFFER,DiskTransaction::FAILED);
		return;
	}

	if (read_byte(IO_BUFFER-1)!=0xFF || read_byte(IO_BUFFER-2)!=0xFF)
	{
		// No disk transaction
		return;
	}
	uint8_t* ptr=reinterpret_cast<uint8_t*>(&dt);
	uint16_t addr=IO_BUFFER;
	for(uint16_t i=0;i<sizeof(DiskTransaction);++i)
		*ptr++ = read_byte(addr++);
	uint16_t copy_size=6;
	switch (dt.command_and_result)
	{
		case DiskTransaction::INIT:
			dt.command_and_result = FileSystem::init(sd_inst) ? DiskTransaction::OK : DiskTransaction::FAILED; break;
		case DiskTransaction::LIST:
			dt.command_and_result = FileSystem::list(dt.data,dt.data,&dt.arg2) ? DiskTransaction::OK : DiskTransaction::FAILED; 
			copy_size=20;
			break;
		case DiskTransaction::NEXT:
			dt.command_and_result = FileSystem::list_next(dt.data,&dt.arg2) ? DiskTransaction::OK : DiskTransaction::FAILED;
			copy_size=20;
			break;
		case DiskTransaction::CHDIR:
			dt.command_and_result = FileSystem::chdir(dt.data) ? DiskTransaction::OK : DiskTransaction::FAILED; break;
		case DiskTransaction::PWDIR:
			dt.command_and_result = FileSystem::pwd(dt.data) ? DiskTransaction::OK : DiskTransaction::FAILED; break;
		case DiskTransaction::OPENFILE:
			dt.arg1 = FileSystem::open_file(dt.data, dt.arg1);
			dt.command_and_result = (dt.arg1!=0xFF) ? DiskTransaction::OK : DiskTransaction::FAILED; break;
		case DiskTransaction::CLOSE:
			dt.command_and_result = FileSystem::close_file(dt.arg1) ? DiskTransaction::OK : DiskTransaction::FAILED; break;
		case DiskTransaction::READ:
		{
			uint16_t left=dt.arg2;
			uint16_t addr=dt.arg3;
			dt.arg2=0;
			while (left>0)
			{
				uint16_t cur = (left>DT_BUFFER_SIZE)?DT_BUFFER_SIZE:left;
				uint16_t act = FileSystem::read_file(dt.arg1, (uint8_t*)dt.data, cur);
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
		case DiskTransaction::LOAD_SPRITES:
			dt.command_and_result=FileSystem::load_sprites(dt.data, dt.arg1) ? DiskTransaction::OK : DiskTransaction::FAILED; break;
	}
	ptr=reinterpret_cast<uint8_t*>(&dt);
	addr=IO_BUFFER;
	for(uint16_t i=0;i<copy_size;++i)
		write_byte(addr++, *ptr++);
}

