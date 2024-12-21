#pragma once

#include "screen.h"

namespace gpu {

  class Sprite
  {
    const Color* m_Pixels;
  public:
    Sprite(const Color* pixels)
      : m_Pixels(pixels)
    {}

    void draw(Screen& scr, int x, int y)
    {
      if (m_Pixels)
      {
        const Color* ptr = m_Pixels;
        for (int i = 0; i < 16; ++i, ++y)
          for (int j = 0; j < 16; ++j, ++ptr)
            if (*ptr) scr.pixel(x + j, y, *ptr);
      }
    }
  };

  class SpriteManager
  {
    Color* m_SpriteBuffer;
  public:
    SpriteManager() : m_SpriteBuffer(new Color[256 * 64]) {}
    SpriteManager(const SpriteManager&) = delete;
    SpriteManager& operator=(const SpriteManager&) = delete;
    ~SpriteManager() { delete[] m_SpriteBuffer; }
    Color* get_sprite(int id)
    {
      if (id < 0 || id >= 64) return nullptr;
      return &m_SpriteBuffer[id * 256];
    }
    void clear(int id)
    {
      Color* ptr = get_sprite(id);
      if (ptr)
        for (int i = 0; i < 256; ++i)
          * ptr++ = 0;
    }

  };

}
