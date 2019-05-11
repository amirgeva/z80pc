#include <iostream>
#include <fstream>
#include <thread>
#include <screen.h>
#include <protocol.h>
#include <cxx/xstring.h>
#include "z80.h"
#include "gui.h"

extern Protocol prot;
extern bool flip_screen;
uint8_t RAM[65536];
byte key = 0, key_latch = 0;

void vis_init();
void vis_draw(uint8_t& key);
uint8_t vis_wait(int ms);

bool load_ram(const cxx::xstring& filename, bool zero_rest_of_ram)
{
  std::ifstream fin(filename, std::ios::in | std::ios::binary);
  if (fin.fail())
    throw cxx::xstring("Failed to open " + filename);
  fin.seekg(0, std::ios::end);
  size_t n = fin.tellg();
  fin.seekg(0);
  if (n > 65536) n = 65536;
  fin.read((char*)RAM, n);
  if (zero_rest_of_ram)
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

bool done = false;

void vis_thread_loop()
{
  vis_init();
  while (!done)
  {
    if (flip_screen)
    {
      flip_screen = false;
      vis_draw(key);
    }
    else
      key=vis_wait(10);
    if (key == 27) break;
  }
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
    std::thread vis_thread(vis_thread_loop);
    load_ram(rom + ".bin", true);
    load_ram("zos.bin", false);
    if (exists(rom + ".asm") && exists(rom+".lst"))
    {
      gui_init(&cpu,RAM);
      gui_load_code(rom + ".asm", rom + ".lst");
    }
    int timer = 500000;
    for (int i = 0; i < 0x7FFFFFFF; ++i)
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
      if (--timer <= 0)
      {
        cpu.int_vector = 0xFF;
        cpu.int_req = 1;
        timer = 500000;
      }
      Z80Execute(&cpu);
      gui_update(&cpu);
      if (!gui_sync()) break;
      //print_registers(&cpu);
      if ((i & 0xFFFF) == 0)
      {
        std::cout << i << "    \r";
      }
    }
    done = true;
    vis_thread.join();
    //vis_wait();
  }
  catch (const cxx::xstring& msg)
  {
    std::cerr << msg << std::endl;
  }
  return 0;
}
