#include <iostream>
//#include <chrono>
#include "gpu_protocol.h"

namespace gpu {

  //Protocol prot;
  bool flip_screen = false;

/*
  unsigned long millis()
  {
    static auto start = std::chrono::system_clock::now();
    auto cur = std::chrono::system_clock::now();
    return uint32_t(std::chrono::duration_cast<std::chrono::milliseconds>(cur - start).count());
  }
*/

  uint16_t Protocol::get_header_len()
  {
    switch (Header.cmd.opcode) {
    case CMD_NOP: return sizeof(Command);
    case CMD_CLS: return sizeof(Command_CLS);
    case CMD_FLIP: return sizeof(Command_Flip);
    case CMD_TEXT_NEWLINE: return sizeof(Command_NewLine);
    case CMD_PUSH_CURSOR: return sizeof(Command_PushCursor);
    case CMD_POP_CURSOR: return sizeof(Command_PopCursor);
    case CMD_PIXEL_CURSOR: return sizeof(Command_PixelCursor);
    case CMD_TEXT_CURSOR: return sizeof(Command_TextCursor);
    case CMD_BLINK_CURSOR: return sizeof(Command_BlinkCursor);
    case CMD_FILL_RECT: return sizeof(Command_FillRect);
    case CMD_HORZ_LINE: return sizeof(Command_HorzLine);
    case CMD_VERT_LINE: return sizeof(Command_VertLine);
    case CMD_HORZ_PIXELS: return sizeof(Command_HorzPixels);
    case CMD_TEXT: return sizeof(Command_Text);
    case CMD_FG_COLOR: return sizeof(Command_FGColor);
    case CMD_BG_COLOR: return sizeof(Command_BGColor);
    case CMD_SET_SPRITE: return sizeof(Command_SetSprite);
    case CMD_DRAW_SPRITE: return sizeof(Command_DrawSprite);
    }
    return 1;
  }

  uint16_t Protocol::check_variable_len()
  {
    switch (Header.cmd.opcode)
    {
    case CMD_HORZ_PIXELS: return Header.horz_pixels.n + sizeof(Command_HorzPixels) - m_Pos;
    case CMD_TEXT: return Header.text.n + sizeof(Command_Text) - m_Pos;
    case CMD_SET_SPRITE: return 16 * 16 + sizeof(Command_SetSprite) - m_Pos;
    }
    return 0;
  }

  bool Protocol::process_command()
  {
    switch (Header.cmd.opcode)
    {
    case CMD_CLS:
    {
      //std::cout << "CLS\n";
      m_BGColor = 0;
      m_FGColor = 0xFF;
      m_Screen.fill_rect(0, 0, WIDTH - 1, HEIGHT - 1, 0);
      m_CursorX = 0;
      m_CursorY = 0;
      return true;
    }
    case CMD_FLIP:
    {
      flip_screen = true;
      return true;
    }
    case CMD_PUSH_CURSOR:
    {
      m_CursorStack.push(m_CursorX, m_CursorY);
      return true;
    }
    case CMD_POP_CURSOR:
    {
      m_CursorStack.pop(m_CursorX, m_CursorY);
      return true;
    }
    case CMD_TEXT_NEWLINE:
    {
      m_Font.new_line(m_CursorX, m_CursorY, m_Screen);
      return true;
    }
    case CMD_PIXEL_CURSOR:
    {
      m_CursorX = Header.pixel_cursor.x;
      m_CursorY = Header.pixel_cursor.y;
      return true;
    }
    case CMD_TEXT_CURSOR:
    {
      m_CursorX = Header.text_cursor.x * m_Font.get_width();
      m_CursorY = Header.text_cursor.y * m_Font.get_height();
      return true;
    }
    case CMD_BLINK_CURSOR:
    {
      m_Blink = (Header.blink_cursor.state > 0);
      return true;
    }
    case CMD_FILL_RECT:
    {
      m_Screen.fill_rect(m_CursorX, m_CursorY,
        m_CursorX + Header.fill_rect.w - 1,
        m_CursorY + Header.fill_rect.h - 1,
        m_BGColor);
      return true;
    }
    case CMD_HORZ_LINE:
    {
      m_Screen.horz_line(m_CursorY, m_CursorX, m_CursorX + Header.horz_line.w - 1, m_FGColor);
      m_CursorX += Header.horz_line.w;
      return true;
    }
    case CMD_VERT_LINE:
    {
      m_Screen.vert_line(m_CursorX, m_CursorY, m_CursorY + Header.vert_line.h - 1, m_FGColor);
      m_CursorY += Header.vert_line.h;
      return true;
    }
    case CMD_HORZ_PIXELS:
    {
      const uint16_t* data = reinterpret_cast<const uint16_t*>(&Header.horz_pixels.opcode + sizeof(Command_HorzPixels));
      for (int i = 0; i < Header.horz_pixels.n; ++i)
        m_Screen.pixel(m_CursorX++, m_CursorY, *data++);
      return true;
    }
    case CMD_TEXT:
    {
      const char* text = reinterpret_cast<const char*>(&Header.text.opcode + sizeof(Command_Text));
      m_Font.draw(text, m_CursorX, m_CursorY, m_Screen, m_FGColor, m_BGColor, true);
      return true;
    }
    case CMD_FG_COLOR:
    {
      m_FGColor = Header.fg_color.color;
      return true;
    }
    case CMD_BG_COLOR:
    {
      m_BGColor = Header.bg_color.color;
      return true;
    }
    case CMD_SET_SPRITE:
    {
      Color* ptr = m_Sprites.get_sprite(Header.set_sprite.id);
      if (ptr)
      {
        const Color* src = reinterpret_cast<const Color*>(&Header.set_sprite.opcode + sizeof(Command_SetSprite));
        constexpr uint8_t sixteen = 16;
        int w = Min(Header.set_sprite.w, sixteen);
        int h = Min(Header.set_sprite.h, sixteen);
        for (int i = 0; i < h; ++i)
        {
          for(int j = 0; j < w; ++j)
            *ptr++ = *src++;
          for(int j = w; j < 16; ++j)
            *ptr++ = 0;
        }
        for(int i = h; i < 16; ++i)
          for(int j = 0; j < 16; ++j)
            *ptr++ = 0;
        return true;
      }
      return false;
    }
    case CMD_DRAW_SPRITE:
    {
      //std::cout << "Draw sprite " << int(Header.draw_sprite.id) << " at " << m_CursorX << "," << m_CursorY << std::endl;
      Sprite spr(m_Sprites.get_sprite(Header.draw_sprite.id));
      spr.draw(m_Screen, m_CursorX, m_CursorY);
      return true;
    }
    }
    return false;
  }

  void Protocol::loop()
  {
    if (m_Blink)
    {
      static bool on = false;
      static unsigned long start = 0;
      unsigned long cur = millis();
      if (start == 0) start = cur;
      if ((cur - start) > 500)
      {
        const char* text = "\001";
        uint16_t x = m_CursorX, y = m_CursorY;
        m_Font.draw(on ? text : " ", x, y, m_Screen, m_FGColor, m_BGColor, false);
        start = cur;
        on = !on;
        flip_screen = true;
      }
    }
  }

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
