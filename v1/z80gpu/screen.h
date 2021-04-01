#pragma once

#include "defs.h"

namespace gpu {

  constexpr auto WIDTH = 320;
  constexpr auto HEIGHT = 240;

  class Screen
  {
    Color* m_FrameBuffer;
    Color* m_Rows[HEIGHT];
    Screen& operator=(const Screen&) { return *this; }
    Screen(const Screen&) {}
  public:
    Screen() : m_FrameBuffer(new Color[WIDTH * HEIGHT])
    {
      Color* ptr = m_FrameBuffer;
      for (int i = 0; i < HEIGHT; ++i)
      {
        m_Rows[i] = ptr;
        ptr += WIDTH;
      }
    }

    ~Screen() { delete[] m_FrameBuffer; }

    const Color* get_buffer() const { return m_FrameBuffer; }

    void clear(Color color = 0)
    {
      fill_rect(0, 0, WIDTH - 1, HEIGHT - 1, color);
    }

    void scroll()
    {
      const Color* src = m_Rows[8];
      Color* dst = m_FrameBuffer;
      unsigned n = WIDTH * (HEIGHT - 8);
      for (unsigned i = 0; i < n; ++i)
        *dst++ = *src++;
      fill_rect(0, HEIGHT - 8, WIDTH - 1, HEIGHT - 1, 0);
    }

    void draw_rect(int x0, int y0, int x1, int y1, Color color)
    {
      vert_line(x0, y0 + 1, y1 - 1, color);
      vert_line(x1, y0 + 1, y1 - 1, color);
      horz_line(y0, x0, x1, color);
      horz_line(y1, x0, x1, color);
    }

    void fill_rect(int x0, int y0, int x1, int y1, Color color)
    {
      for (int y = y0; y <= y1; ++y)
        horz_line(y, x0, x1, color);
    }

    void horz_line(int y, int x0, int x1, Color color)
    {
      Color* ptr = m_Rows[y];
      for (int x = x0; x <= x1 && x >= 0 && x < WIDTH; ++x)
        ptr[x] = color;
    }

    void vert_line(int x, int y0, int y1, Color color)
    {
      for (int y = y0; y <= y1; ++y)
        pixel(x, y, color);
    }

    void pixel(int x, int y, Color color)
    {
      if (y >= 0 && y < HEIGHT && x >= 0 && x < WIDTH)
        m_Rows[y][x] = color;
    }
  };

}
