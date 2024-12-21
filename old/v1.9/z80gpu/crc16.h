#pragma once

inline uint16_t calculate_crc16(const uint8_t* buffer, int len)
{
  uint16_t result=0;
  for(int i=0;i<len;++i)
  {
    uint8_t data=buffer[i] ^ uint8_t(result & 0xFF);
    data = data ^ (data << 4);
    result = ((uint16_t(data)<<8)|(result>>8)) ^ (data>>4) ^ (uint16_t(data) << 3);
  }
  return result;
}
