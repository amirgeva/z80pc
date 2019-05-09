#pragma once

#include "defs.h"
#include "screen.h"
#include "font.h"
#include "sprites.h"

unsigned long millis();

constexpr uint8_t CMD_NOP          = 0;
constexpr uint8_t CMD_CLS          = 1;
constexpr uint8_t CMD_PIXEL_CURSOR = 5;
constexpr uint8_t CMD_TEXT_CURSOR  = 6;
constexpr uint8_t CMD_FG_COLOR     = 7;
constexpr uint8_t CMD_BG_COLOR     = 8;
constexpr uint8_t CMD_PUSH_CURSOR  = 9;
constexpr uint8_t CMD_POP_CURSOR   = 10;
constexpr uint8_t CMD_BLINK_CURSOR = 11;
constexpr uint8_t CMD_FILL_RECT    = 20;
constexpr uint8_t CMD_HORZ_LINE    = 21;
constexpr uint8_t CMD_VERT_LINE    = 22;
constexpr uint8_t CMD_HORZ_PIXELS  = 23;
constexpr uint8_t CMD_TEXT         = 30;
constexpr uint8_t CMD_SET_SPRITE   = 40;
constexpr uint8_t CMD_DRAW_SPRITE  = 41;

#pragma pack(push,1)

struct Command
{
  uint8_t opcode;
};

struct Command_CLS
{
  uint8_t opcode;
};

struct Command_PushCursor
{
  uint8_t opcode;
};

struct Command_PopCursor
{
  uint8_t opcode;
};

struct Command_BlinkCursor
{
  uint8_t opcode;
  uint8_t state;
};

struct Command_PixelCursor
{
  uint8_t opcode;
  uint16_t x, y;
};

struct Command_TextCursor
{
  uint8_t opcode;
  uint8_t x, y;
};

struct Command_FillRect
{
  uint8_t opcode;
  uint16_t w, h;
};

struct Command_HorzLine
{
  uint8_t opcode;
  uint16_t w;
};

struct Command_VertLine
{
  uint8_t opcode;
  uint16_t h;
};

struct Command_HorzPixels
{
  uint8_t opcode;
  uint8_t n;
};

struct Command_Text
{
  uint8_t opcode;
  uint8_t n;
};

struct Command_FGColor
{
  uint8_t opcode;
  uint16_t color;
};

struct Command_BGColor
{
  uint8_t opcode;
  uint16_t color;
};

struct Command_SetSprite
{
  uint8_t opcode;
  uint8_t id, w, h;
};

struct Command_DrawSprite
{
  uint8_t opcode;
  uint8_t id;
};

class CursorStack
{
  enum { SIZE = 32 };
  uint16_t m_Data[SIZE];
  uint16_t m_Pos;
public:
  CursorStack()
    : m_Pos(SIZE)
  {}

  void push(uint16_t x, uint16_t y)
  {
    if (m_Pos > 0)
    {
      m_Data[--m_Pos] = y;
      m_Data[--m_Pos] = x;
    }
  }

  void pop(uint16_t& x, uint16_t& y)
  {
    if (m_Pos < SIZE)
    {
      x = m_Data[m_Pos++];
      y = m_Data[m_Pos++];
    }
  }
};

class Protocol
{
  Screen        m_Screen;
  CursorStack   m_CursorStack;
  Font          m_Font;
  SpriteManager m_Sprites;
  uint16_t      m_Pos, m_BytesLeft;
  uint16_t      m_CursorX, m_CursorY;
  uint16_t      m_FGColor, m_BGColor;
  bool          m_Blink;

  union {
    Command             cmd;
    Command_CLS         cls;
    Command_PixelCursor pixel_cursor;
    Command_TextCursor  text_cursor;
    Command_PushCursor  push_cursor;
    Command_PopCursor   pop_cursor;
    Command_BlinkCursor blink_cursor;
    Command_FillRect    fill_rect;
    Command_HorzLine    horz_line;
    Command_VertLine    vert_line;
    Command_HorzPixels  horz_pixels;
    Command_Text        text;
    Command_FGColor     fg_color;
    Command_BGColor     bg_color;
    Command_SetSprite   set_sprite;
    Command_DrawSprite  draw_sprite;
    uint16_t            buffer[520];
  } Header;

  uint16_t get_header_len()
  {
    switch (Header.cmd.opcode) {
    case CMD_NOP: return sizeof(Command);
    case CMD_CLS: return sizeof(Command_CLS);
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

  uint16_t check_variable_len()
  {
    switch (Header.cmd.opcode)
    {
    case CMD_HORZ_PIXELS: return Header.horz_pixels.n * 2 + sizeof(Command_HorzPixels) - m_Pos;
    case CMD_TEXT: return Header.text.n + sizeof(Command_Text) - m_Pos;
    case CMD_SET_SPRITE: return Header.set_sprite.w * Header.set_sprite.h * 2 + sizeof(Command_SetSprite) - m_Pos;
    }
    return 0;
  }

  bool process_command()
  {
    switch(Header.cmd.opcode)
    {
      case CMD_CLS:
      {
        m_BGColor = 0;
        m_FGColor = 0x3FFF;
        m_Screen.fill_rect(0, 0, WIDTH - 1, HEIGHT - 1, 0);
        m_CursorX = 1;
        m_CursorY = 1;
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
        for(int i=0;i<Header.horz_pixels.n;++i)
          m_Screen.pixel(m_CursorX++, m_CursorY, *data++);
        return true;
      }
      case CMD_TEXT:
      {
        const char* text = reinterpret_cast<const char*>(&Header.text.opcode + sizeof(Command_Text));
        m_CursorX = m_Font.draw(text, m_CursorX, m_CursorY, m_Screen, m_FGColor, m_BGColor);
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
            for (int j = 0; j < w; ++j)
              *ptr++ = *src++;
            for (int j = w; j < 16; ++j)
              *ptr++ = 0;
          }
          for(int i=h;i<16;++i)
            for (int j = 0; j < 16; ++j)
              * ptr++ = 0;
          return true;
        }
        return false;
      }
      case CMD_DRAW_SPRITE:
      {
        Sprite spr(m_Sprites.get_sprite(Header.draw_sprite.id));
        spr.draw(m_Screen, m_CursorX, m_CursorY);
        return true;
      }
    }
    return false;
  }

public:
  Protocol()
    : m_Pos(0)
  {
    m_Screen.clear();
  }

  void loop()
  {
    if (m_Blink)
    {
      static bool on = false;
      static unsigned long start = 0;
      unsigned long cur = millis();
      if (start == 0) start = cur;
      if ((cur - start) > 500)
      {
        const char* text = "\177";
        m_Font.draw(on ? text : " ", m_CursorX, m_CursorY, m_Screen, m_FGColor, m_BGColor);
        start = cur;
        on = !on;
      }
    }
  }

  void add_byte(uint8_t b)
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

  const Screen& get_screen() const
  {
    return m_Screen;
  }
};


#pragma pack(pop)
