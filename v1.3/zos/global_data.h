#pragma once

typedef unsigned char byte;

typedef struct global_data
{
        byte input_buffer[0x100];
        byte cmd_buffer[0X20];
        byte in_write,in_read,cmd_pos;
} GlobalData;

