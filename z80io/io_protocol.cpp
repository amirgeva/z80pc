#include "io_protocol.h"

#ifdef _MSC_VER
#include "emu_impl.h"
#endif

namespace io {

  inline uint8_t MIN(uint8_t a, uint8_t b)
  {
    return a < b ? a : b;
  }

  Protocol prot;

  uint8_t Protocol::get_header_len()
  {
    switch (Header.cmd.opcode) {
    case CMD_NOP: return sizeof(Command);
    case CMD_OUTBYTE: return sizeof(Command_Byte);
    case CMD_OUTBLOCK: return sizeof(Command_Block);
    case CMD_OPEN_FILE_W: return sizeof(Command_File);
    case CMD_OPEN_FILE_R: return sizeof(Command_File);
    case CMD_OPEN_FILE_A: return sizeof(Command_File);
    case CMD_CLOSE_FILE: return sizeof(Command);
    case CMD_GET_FILE_SIZE: return sizeof(Command_File);
    case CMD_GET_FILE_NUM: return sizeof(Command);
    case CMD_GET_FILE_NAME: return sizeof(Command_Block);
    case CMD_ERASE_FILE: return sizeof(Command_File);
    case CMD_WRITE_FILE: return sizeof(Command_Block);
    case CMD_READ_FILE: return sizeof(Command);
    }
    return 1;
  }

  uint8_t Protocol::check_variable_len()
  {
    switch (Header.cmd.opcode)
    {
    case CMD_OUTBLOCK: 
    case CMD_WRITE_FILE: return Header.cmd_block.len + sizeof(Command_Block) - m_Pos;
    }
    return 0;
  }

  bool Protocol::respond()
  {
    send_input_disk_byte(0);
    return true;
  }

  bool Protocol::respond(bool value)
  {
    send_input_disk_byte(1);
    send_input_disk_byte(value ? 1 : 0);
    return true;
  }

  bool Protocol::respond(uint16_t value)
  {
    send_input_disk_byte(2);
    send_input_disk_byte(value & 0xFF);
    send_input_disk_byte((value>>8) & 0xFF);
    return true;
  }

  bool Protocol::respond(const Command_File& file)
  {
    send_input_disk_byte(15);
    for(uint8_t i=0;i<15;++i)
      send_input_disk_byte(file.name[i]);
    return true;
  }

  bool Protocol::process_command()
  {
    switch (Header.cmd.opcode)
    {
      case CMD_NOP: return true;
      case CMD_OUTBYTE:
      {
        // Send over serial (not implemented yet)
        return true;
      }
      case CMD_OUTBLOCK: 
      {
        // Send over serial (not implemented yet)
        return true;
      }
      case CMD_OPEN_FILE_W:
      {
        Header.cmd_file.name[14] = 0;
        return respond(open_write_file(Header.cmd_file.name));
      }
      case CMD_OPEN_FILE_R:
      {
        Header.cmd_file.name[14] = 0;
        return respond(open_read_file(Header.cmd_file.name));
      }
      case CMD_OPEN_FILE_A:
      {
        Header.cmd_file.name[14] = 0;
        return respond(open_append_file(Header.cmd_file.name));
      }
      case CMD_CLOSE_FILE:
      {
        close_file();
        return respond(true);
      }
      case CMD_GET_FILE_SIZE:
      {
        uint16_t size = get_file_size(Header.cmd_file.name);
        return respond(size);
      }
      case CMD_GET_FILE_NUM:
      {
        return respond(get_files_number());
      }
      case CMD_GET_FILE_NAME:
      {
        if (!get_file_name(Header.cmd_block.len, Header.cmd_file.name))
          return respond();
        return respond(Header.cmd_file);
      }
      case CMD_ERASE_FILE:
      {
        Header.cmd_file.name[14] = 0;
        erase_file(Header.cmd_file.name);
        return respond(true);
      }
      case CMD_WRITE_FILE:
      {
        write_file(&Header.buffer[sizeof(Command_Block)], MIN(Header.cmd_block.len, 62));
        return respond(true);
      }
      case CMD_READ_FILE:
      {
        uint8_t* buffer = Header.buffer;
        uint8_t act;
        while ((act=read_file(buffer, 64))>0)
        {
          for (uint8_t i = 0; i < act; ++i)
            send_input_disk_byte(Header.buffer[sizeof(Command_Block) + i]);
        }
        return true;
      }
    }
    return false;
  }

  void Protocol::loop()
  {}

  void Protocol::add_byte(uint8_t b)
  {
    if (m_Pos == 0)
    {
      Header.cmd.opcode = b;
      m_BytesLeft = get_header_len() - 1;
      ++m_Pos;
    }
    else
    {
      uint8_t* ptr = &Header.cmd.opcode;
      ptr[m_Pos++] = b;
      ptr[m_Pos] = 0;
      --m_BytesLeft;
    }
    if (m_BytesLeft == 0) m_BytesLeft = check_variable_len();
    if (m_BytesLeft == 0)
    {
      process_command();
      m_Pos = 0;
    }
  }


}