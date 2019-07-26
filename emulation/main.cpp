#include <iostream>
#include <fstream>
#include <thread>
#include <screen.h>
#include <gpu_protocol.h>
#include <io_protocol.h>
#include <cxx/xstring.h>
#include "z80.h"
#include "gui.h"

namespace gpu {
  extern Protocol prot;
  extern bool flip_screen;
}

namespace io {
  extern Protocol prot;
}

uint8_t RAM[65536];
byte io_input_latch = 0, io_input_int_vect=0;

void vis_init();
void vis_draw(uint8_t& key);
uint8_t vis_wait(int ms);

void key_received(byte key);
void io_input_cleared();
void io_loop();

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

void io_out(int param, ushort address, byte data)
{
  if ((address & 255) == 0) io::prot.add_byte(data);
  if ((address & 255) == 2) gpu::prot.add_byte(data);
}

byte io_in(int param, ushort address)
{
  byte ret = io_input_latch;
  io_input_cleared();
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
  byte key = 0;
  while (!done)
  {
    key = 0;
    if (gpu::flip_screen)
    {
      gpu::flip_screen = false;
      vis_draw(key);
    }
    else
      key=vis_wait(10);
    if (key != 0)
    {
      key_received(key);
    }
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
    cpu.ioWrite = io_out;
    cpu.ioRead = io_in;
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
      gpu::prot.loop();
      if (io_input_int_vect > 0)
      {
        cpu.int_vector = io_input_int_vect;
        io_input_int_vect = 0;
        cpu.int_req = 1;
      }
      if (--timer <= 0)
      {
        cpu.int_vector = 0xE7; // ISR at 0x20
        cpu.int_req = 1;
        timer = 500000;
      }
      Z80Execute(&cpu);
      gui_update(&cpu);
      io_loop();
      if (!gui_sync()) break;
      //print_registers(&cpu);
      //if ((i & 0xFFFF) == 0)  std::cout << i << "    \r";
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
