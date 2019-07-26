#pragma once

#include <cstdint>

namespace io {

  constexpr uint8_t CMD_NOP           = 0x00;
  constexpr uint8_t CMD_OUTBYTE       = 0x01;
  constexpr uint8_t CMD_OUTBLOCK      = 0x02;
  constexpr uint8_t CMD_OPEN_FILE_W   = 0x10;
  constexpr uint8_t CMD_OPEN_FILE_R   = 0x11;
  constexpr uint8_t CMD_OPEN_FILE_A   = 0x12;
  constexpr uint8_t CMD_CLOSE_FILE    = 0x13;
  constexpr uint8_t CMD_GET_FILE_SIZE = 0x20;
  constexpr uint8_t CMD_GET_FILE_NUM  = 0x21;
  constexpr uint8_t CMD_ERASE_FILE    = 0x22;
  constexpr uint8_t CMD_GET_FILE_NAME = 0x23;
  constexpr uint8_t CMD_WRITE_FILE    = 0x30;
  constexpr uint8_t CMD_READ_FILE     = 0x31;

  enum InputType
  {
    TYPE_DISK,
    TYPE_KEYBOARD,
    TYPE_SERIAL
  };

  void send_input_byte(uint8_t data, InputType type);
  void send_input_disk_byte(uint8_t data);


#pragma pack(push,1)

  struct Command
  {
    uint8_t opcode;
  };

  struct Command_Byte
  {
    uint8_t opcode;
    uint8_t data;
  };

  struct Command_SBlock
  {
    uint8_t  opcode;
    uint8_t  len;
  };

  struct Command_Block
  {
    uint8_t  opcode;
    uint16_t len;
  };

  struct Command_File
  {
    uint8_t opcode;
    uint8_t name[15];
  };

  class Protocol
  {
    union {
      Command        cmd;
      Command_Byte   cmd_byte;
      Command_Block  cmd_block;
      Command_SBlock cmd_sblock;
      Command_File   cmd_file;
      uint8_t        buffer[64];
    } Header;

    uint8_t get_header_len();

    uint8_t check_variable_len();

    bool process_command();
    bool respond(); // fail
    bool respond(bool value);
    bool respond(uint16_t value);
    bool respond(const Command_File& file);

    uint8_t      m_Pos,m_BytesLeft;

  public:
    Protocol()
      : m_Pos(0)
      , m_BytesLeft(0)
    {
    }

    void add_byte(uint8_t b);
    void loop();

  };


#pragma pack(pop)

}
