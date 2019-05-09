#include <iostream>
#include <fstream>
#include <screen.h>
#include <protocol.h>
#include "z80.h"

extern Protocol prot;
uint8_t RAM[65536];
byte key = 0, key_latch = 0;

void vis_init();
void vis_draw(byte& key);
void vis_wait();

bool load_ram(const char* filename)
{
  std::ifstream fin(filename, std::ios::in | std::ios::binary);
  if (fin.fail())
  {
    std::cerr << "Failed to open " << filename << std::endl;
    return false;
  }
  fin.seekg(0, std::ios::end);
  size_t n = fin.tellg();
  fin.seekg(0);
  if (n > 65536) n = 65536;
  fin.read((char*)RAM, n);
  for (; n < 65536; ++n)
    RAM[n] = 0;
  return true;
}

void gpu_out(int param, ushort address, byte data)
{
  prot.add_byte(data);
}

byte io_read(int param, ushort address) 
{
  byte ret = key_latch;
  return ret;
}

void mem_write(int param, ushort address, byte data)
{
  RAM[address] = data;
}

byte mem_read(int param, ushort address)
{
  return RAM[address];
}

int main(int argc, char* argv[])
{
  Z80Context cpu;
  Z80RESET(&cpu);
  cpu.memRead = mem_read;
  cpu.memWrite = mem_write;
  cpu.ioWrite = gpu_out;
  cpu.ioRead = io_read;
  vis_init();
  load_ram("os.bin");
  for (int i = 0; i < 1000000; ++i)
  {
    if ((i&1023)==0)
      std::cout << i << "\r";
    prot.loop();
    if (key>0)
    {
      key_latch = key;
      key = 0;
      cpu.int_vector = 0xCF;
      cpu.int_req = 1;
    }
    Z80Execute(&cpu);
    if ((i & 255) == 0)
    {
      vis_draw(key);
      if (key == 27) break;
    }
  }
  //vis_wait();
  return 0;
}
