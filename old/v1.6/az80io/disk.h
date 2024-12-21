#pragma once

constexpr uint8_t DISK_NOP        = 0;
constexpr uint8_t DISK_LIST       = 1;
constexpr uint8_t DISK_OPEN       = 2;
constexpr uint8_t DISK_READ       = 3;
constexpr uint8_t DISK_WRITE      = 4;
constexpr uint8_t DISK_SEEK       = 5;
constexpr uint8_t DISK_DELETE     = 6;
constexpr uint8_t DISK_MKDIR      = 7;
constexpr uint8_t DISK_MAX_CMD    = 7;

constexpr uint8_t DISK_OK = 1;
constexpr uint8_t DISK_ERR_NOT_FOUND = 2;
constexpr uint8_t DISK_ERR_FAILURE   = 3;
constexpr uint8_t DISK_ERR_NOT_DIR   = 4;
constexpr uint8_t DISK_ERR_BUF_SIZE  = 5;

constexpr uint8_t OPEN_FLAG_READ    = 0x01;
constexpr uint8_t OPEN_FLAG_WRITE   = 0x02;
constexpr uint8_t OPEN_FLAG_APPEND  = 0x04;
constexpr uint8_t OPEN_FLAG_CREATE  = 0x08;

struct DiskCommand
{
  uint8_t  done;
  uint8_t  cmd;
  uint8_t  flags;
  uint8_t  options;
  uint16_t data_ptr;
  uint16_t data_size;
};

static_assert(sizeof(DiskCommand)==8,"Not packed");

class Disk
{
  void clear();
  uint8_t process_LIST(uint16_t addr, DiskCommand& dc);
  uint8_t process_OPEN(uint16_t addr, DiskCommand& dc);
  uint8_t process_READ(uint16_t addr, DiskCommand& dc);
  uint8_t process_WRITE(uint16_t addr, DiskCommand& dc);
  uint8_t process_SEEK(uint16_t addr, DiskCommand& dc);
  uint8_t process_DELETE(uint16_t addr, DiskCommand& dc);
  uint8_t process_MKDIR(uint16_t addr, DiskCommand& dc);
public:
  Disk();
  void begin();
  void process();
};
