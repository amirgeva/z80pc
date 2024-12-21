//#include <Arduino.h>
#include "iprotocol.h"
#include "protocol.h"


Protocol g_prot;

void ProtocolInterface::add_data(byte b)
{
  g_prot.add_byte(b);
}

void ProtocolInterface::add_data(const byte* data, uint8_t len)
{
  for(;len>0;--len)
    g_prot.add_byte(*data++);
}

void ProtocolInterface::loop()
{
  g_prot.loop();
}
