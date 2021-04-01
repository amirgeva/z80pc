#include <Arduino.h>
#include "iface.h"
#include "message.h"
#include "zboard.h"

Message msg;

#define COMMAND_PROGRAM      1
#define COMMAND_READ         2
#define COMMAND_RESET        3
#define COMMAND_CLOCK        4
#define COMMAND_AUTO_CLOCK   5

#define STATUS_ACK           0
#define STATUS_LEN_ERROR     1
#define STATUS_DATA          2

void iface_init()
{}

void send_status(uint8_t status)
{
  msg.payload.status=status;
  msg.send();
}

void parse_msg()
{
	if (msg.verify_crc())
	{
		uint16_t addr=(uint16_t(msg.payload.addr_high)<<8) | msg.payload.addr_low;
		byte len=msg.payload.len;
    if (len>52)
    {
      send_status(STATUS_LEN_ERROR);
      return;
    }
    if (msg.payload.cmd!=COMMAND_READ &&
        msg.payload.cmd!=COMMAND_CLOCK)
      send_status(STATUS_ACK);
		if (msg.payload.cmd == COMMAND_PROGRAM)
		{
			program_data(addr,len,msg.payload.data);
		}
    if (msg.payload.cmd == COMMAND_AUTO_CLOCK)
    {
      AutoClock();
    }
		if (msg.payload.cmd == COMMAND_READ)
		{
			read_data(addr,len,msg.payload.data);
      msg.payload.status=STATUS_DATA;
			msg.send();
		}
    if (msg.payload.cmd == COMMAND_RESET)
    {
      // reset
    }
    if (msg.payload.cmd == COMMAND_CLOCK)
    {
      clock_read_bus(msg.payload.data);
      msg.payload.status=STATUS_DATA;
      msg.send();
    }
	}
}

uint8_t* in_ptr=(uint8_t*)&msg;
int in_pos=0;

void handle_incoming()
{
	while (Serial.available() > 0)
	{
		uint8_t b = Serial.read();
		in_ptr[in_pos++]=b;
		if (in_pos<=4 && !msg.valid_header(in_pos))
			in_pos=0;
		if (in_pos==64)
		{
			parse_msg();
			in_pos=0;
		}
	}
}
