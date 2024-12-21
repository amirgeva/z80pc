#pragma once

#include <stdint.h>
#include "../MCP23S17/ISPI.h"

constexpr uint8_t DT_BUFFER_SIZE=250;

struct DiskTransaction
{
	enum Commands { INIT, LIST, NEXT, CHDIR, PWDIR, OPENFILE, READ, WRITE, CLOSE, LOAD_SPRITES };
	enum Results  { OK=200, FAILED=201 };
	uint8_t		command_and_result;
	uint8_t		arg1;
	uint16_t	arg2;
	uint16_t	arg3;
	char		data[DT_BUFFER_SIZE];
};

class FileSystem
{
public:
	static bool init(ispi::SPI* s);
	static bool chdir(const char* dirpath);
	static bool pwd(char* dirpath);
	static bool list(const char* dirpath, char* filename, uint16_t* filesize);
	static bool list_next(char* filename, uint16_t* filesize);
	
	static uint8_t open_file(const char* filename, bool write);
	static uint16_t read_file(uint8_t handle, uint8_t* buffer, uint16_t size);
	static uint16_t write_file(uint8_t handle, const uint8_t* buffer, uint16_t size);
	static bool close_file(uint8_t handle);

	static bool load_sprites(const char* filename, uint8_t index);
};