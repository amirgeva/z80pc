#pragma once

typedef unsigned char byte;
typedef unsigned short word;
/**************************************
* Input buffer has to be 0x100, to allow a single byte
* read/write position variables
***************************************/
#define INPUT_BUFFER_SIZE 0x100
#define CMD_BUFFER_SIZE 0x20

typedef struct global_data
{
        byte		input_buffer[INPUT_BUFFER_SIZE];
        byte		cmd_buffer[CMD_BUFFER_SIZE];
        byte		in_write,in_read,cmd_pos,reserved;
		word		timer;
} GlobalData;

/* (0x1000 + sizeof(GlobalData)) */
#define USER_AREA_ADDR 0x1200
typedef char address_check[USER_AREA_ADDR-(0x1000+sizeof(GlobalData))];
#define USER_AREA ((byte*)USER_AREA_ADDR)
