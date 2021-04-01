#pragma once

#include <crc16.h>

void write_serial_block(const byte* buffer, byte len);

static const byte MAGIC[] = { 0x12, 0x34, 0x56, 0x78 };

struct Payload
{
	byte     cmd;
	byte     addr_low;
	byte     addr_high;
	byte     len;
	byte     data[54];
	
	void copy(const Payload& p)
	{
		cmd=p.cmd;
		addr_high=p.addr_high;
		addr_low=p.addr_low;
		len=p.len;		
	}
};

struct Message
{
  byte header[4];
  Payload payload;
  byte crc[2];

  Message()
  {
    for(uint8_t i=0;i<4;++i) header[i]=MAGIC[i];
  }

  bool valid_header(int len) const
  {
    for(byte i=0;i<len && i<4;++i)
      if (header[i]!=MAGIC[i]) return false;
    return true;
  }
  
  uint16_t calc_crc() const
  {
	  return calculate_crc16((const byte*)&payload,sizeof(Payload));
  }

  bool verify_crc()
  {
    uint16_t c=calc_crc();
    return uint8_t(c&0xFF)==crc[0] && uint8_t(c>>8)==crc[1];
  }

  void send()
  {
    uint16_t c=calc_crc();
    crc[0]=uint8_t(c&0xFF);
    crc[1]=uint8_t(c>>8);
    write_serial_block(header,64);
  }
};

