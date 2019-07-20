#pragma once

#include "defs.h"
#include "screen.h"

namespace gpu {

  class Font
  {
    uint8_t m_CharWidth, m_CharHeight;

    const uint8_t* get_char_data(int c)
    {
      static const uint8_t data[] = {
        #include "font.inl"
      };
      static const int n = sizeof(data) / 8;
      //c -= 32;
      if (c < 0 || c >= n) return nullptr;
      return &data[c * 8];
    }

    void new_line(uint16_t& x, uint16_t& y, Screen& scr)
    {
      x = 0;
      y += m_CharHeight;
      if (y >= gpu::HEIGHT)
      {
        scr.scroll();
        y -= m_CharHeight;
      }
    }

    void move_cursor_forward(uint16_t& x, uint16_t& y, Screen& scr)
    {
      x += m_CharWidth;
      if (x >= gpu::WIDTH)
      {
        new_line(x, y, scr);
      }
    }
  public:
    Font()
      : m_CharWidth(8)
      , m_CharHeight(8)
    {}

    uint16_t get_width() const { return m_CharWidth; }
    uint16_t get_height() const { return m_CharHeight; }

    void draw(const char* text, uint16_t& x, uint16_t& y, Screen & scr, Color fg, Color bg, bool progress)
    {
      for (; *text; ++text)
      {
        draw(*text, x, y, scr, fg, bg, progress);
      }
    }

    void draw(char c, uint16_t& x, uint16_t& y, Screen & scr, Color fg, Color bg, bool progress)
    {
      const uint8_t* ptr = get_char_data(c);
      if (c == 10)
      {
        new_line(x, y, scr);
        return;
      }
      if (ptr)
      {
        for (int i = 0; i < m_CharHeight; ++i, ++ptr)
        {
          for (int j = 0; j < m_CharWidth; ++j)
          {
            scr.pixel(x + m_CharWidth - j - 1, y + i, (*ptr & (1 << j)) ? fg : bg);
          }
        }
      }
      if (progress)
        move_cursor_forward(x, y, scr);
    }
  };

}
