#include <iostream>
#include <fstream>
#include <screen.h>
#include <protocol.h>
#include <cxx/xstring.h>
#include "z80.h"
#include "gui.h"

extern Protocol prot;
uint8_t RAM[65536];
byte key = 0, key_latch = 0;

void vis_init();
void vis_draw(byte& key);
void vis_wait();

bool load_ram(const cxx::xstring& filename)
{
  std::ifstream fin(filename, std::ios::in | std::ios::binary);
  if (fin.fail())
    throw cxx::xstring("Failed to open " + filename);
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

static const std::string hex_chars = "0123456789ABCDEF";

std::string hex(uint8_t b)
{
  return hex_chars.substr(b >> 4, 1) + hex_chars.substr(b & 15, 1);
}

std::string hex16(uint16_t u)
{
  std::ostringstream os;
  for (int i = 0; i < 4; ++i)
    os << hex_chars.substr((u >> ((3 - i) * 4)) & 0xF, 1);
  return os.str();
}

void print_registers(Z80Context* cpu)
{
  std::cout << "A=" << hex(cpu->R1.br.A) << ' '
    << "B=" << hex(cpu->R1.br.B) << ' '
    << "C=" << hex(cpu->R1.br.C) << ' '
    << "D=" << hex(cpu->R1.br.D) << ' '
    << "E=" << hex(cpu->R1.br.E) << ' '
    << "H=" << hex(cpu->R1.br.H) << ' '
    << "L=" << hex(cpu->R1.br.L) << '\n';
}

bool exists(const cxx::xstring& filename)
{
  std::ifstream fin(filename);
  return !fin.fail();
}

int main(int argc, char* argv[])
{
  try
  {
    cxx::xstring rom = "os";
    if (argc > 1)
      rom = argv[1];
    Z80Context cpu;
    Z80RESET(&cpu);
    cpu.memRead = mem_read;
    cpu.memWrite = mem_write;
    cpu.ioWrite = gpu_out;
    cpu.ioRead = io_read;
    vis_init();
    load_ram(rom + ".bin");
    if (exists(rom + ".asm") && exists(rom+".lst"))
    {
      gui_init(&cpu,RAM);
      gui_load_code(rom + ".asm", rom + ".lst");
    }
    for (int i = 0; i < 1000000; ++i)
    {
      //if ((i&1023)==0) std::cout << i << "\t\t" << cpu.PC << "\r";
      prot.loop();
      if (key > 0)
      {
        key_latch = key;
        key = 0;
        cpu.int_vector = 0xCF;
        cpu.int_req = 1;
      }
      Z80Execute(&cpu);
      gui_update(&cpu);
      if (!gui_sync()) break;
      //print_registers(&cpu);
      if ((i & 255) == 0)
      {
        vis_draw(key);
        if (key == 27) break;
      }
    }
    //vis_wait();
  }
  catch (const cxx::xstring& msg)
  {
    std::cerr << msg << std::endl;
  }
  return 0;
}
