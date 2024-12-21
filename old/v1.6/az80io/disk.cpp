#include <SD.h>
#include "consts.h"
#include "disk.h"
#include "uart.h"
#include "ram.h"

static File file;
static bool file_open = false;
static char path[256];

void copy_str(uint16_t addr, const char* text, uint16_t size)
{
  while (size>0)
  {
    if (*text == 0) break;
    write_byte(addr++,*text++);
    --size;
  }
  while (size-- >0)
  {
    write_byte(addr++,0);
  }
}

void copy_u16(uint16_t addr, uint16_t value)
{
  write_byte(addr++,(value&255));
  write_byte(addr++,((value>>8)&255));
}

Disk::Disk()
{}

void Disk::begin()
{
  if (!SD.begin(13))
    dbg << "Failed to initialize SD\r\n";
}

void Disk::clear()
{
  write_byte(DISK_MSB, 0);
}

void Disk::process()
{
  uint8_t addr_msb = read_byte(DISK_MSB);
  if (addr_msb == 0) return;
  uint16_t addr = read_byte(DISK_LSB);
  addr |= uint16_t(addr_msb) << 8;
  DiskCommand dc;
  read_block(addr, (uint8_t*)&dc, sizeof(DiskCommand));
  uint8_t rc=DISK_OK;
  if (dc.done==0 && dc.cmd<=DISK_MAX_CMD)
  {
    switch (dc.cmd)
    {
      #define P(x)case DISK_##x: rc=process_##x(addr,dc); break
      P(LIST);
      P(OPEN);
      P(READ);
      P(WRITE);
      P(SEEK);
      P(DELETE);
      P(MKDIR);
      #undef P
      case DISK_NOP:
      default:
        break;
    }
  }
  clear();
}

uint8_t Disk::process_LIST(uint16_t addr, DiskCommand& dc)
{
  if (dc.data_size < 18) return DISK_ERR_BUF_SIZE;
  read_string(dc.data_ptr, (uint8_t*)path);
  File dir = SD.open(path);
  if (!dir.isDirectory()) return DISK_ERR_NOT_DIR;
  else
  {
    dir.rewindDirectory();
    uint16_t addr = dc.data_ptr + 2;
    uint16_t left = dc.data_size - 2;
    uint16_t entry_count=0;
    File entry;
    while (left >= 16)
    {
      entry=dir.openNextFile();
      if (entry==NULL) break;
      copy_str(addr,entry.name(),12);
      copy_u16(addr+12,entry.size());
      addr+=16;
      left-=16;
      entry_count++;
      entry.close();
    }
    copy_u16(dc.data_ptr,entry_count);
  }
  return DISK_OK;
}

uint8_t Disk::process_OPEN(uint16_t addr, DiskCommand& dc)
{
}

uint8_t Disk::process_READ(uint16_t addr, DiskCommand& dc)
{
}

uint8_t Disk::process_WRITE(uint16_t addr, DiskCommand& dc)
{
}

uint8_t Disk::process_SEEK(uint16_t addr, DiskCommand& dc)
{
}

uint8_t Disk::process_DELETE(uint16_t addr, DiskCommand& dc)
{
}

uint8_t Disk::process_MKDIR(uint16_t addr, DiskCommand& dc)
{
}
