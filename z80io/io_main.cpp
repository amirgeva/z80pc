#include "io_protocol.h"
#include <cyclic.h>

CyclicBuffer<16> keyboard_buffer;
CyclicBuffer<16> serial_buffer;
CyclicBuffer<64> disk_buffer;

namespace io
{
  void send_input_disk_byte(uint8_t data)
  {
    disk_buffer.push(data);
  }

}

using namespace io;

typedef unsigned char byte;

extern byte io_input_latch,io_input_int_vect;
bool io_buffer_empty = true;

void key_received(byte key)
{
  keyboard_buffer.push(key);
}

void io_input_cleared()
{
  io_buffer_empty = true;
}

#define CHECK(buffer,type) if (!buffer.empty() && io_buffer_empty) { send_input_byte(buffer.pop(), type); return; }

static int wait_count = 0;

void io_loop()
{
  if (wait_count > 0) 
    --wait_count;
  else
  if (io_buffer_empty)
  {
    CHECK(keyboard_buffer, TYPE_KEYBOARD);
    CHECK(serial_buffer, TYPE_SERIAL);
    CHECK(disk_buffer, TYPE_DISK);
  }
}

namespace io
{
  void send_input_byte(uint8_t data, InputType type)
  {
    wait_count = 100;
    io_buffer_empty = false;
    io_input_latch = data;
    switch (type)
    {
    case TYPE_KEYBOARD: io_input_int_vect = 0xCF; break; // ISR at 0x08
    case TYPE_DISK:     io_input_int_vect = 0xD7; break; // ISR at 0x10
    case TYPE_SERIAL:   io_input_int_vect = 0xDF; break; // ISR at 0x18
    }
  }
}