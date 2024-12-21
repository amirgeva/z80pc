#pragma once

#include <cstdint>

constexpr uint8_t CMD_NOP = 0;
constexpr uint8_t CMD_CLS = 1;
constexpr uint8_t CMD_FLIP = 2;
constexpr uint8_t CMD_TEXT_NEWLINE = 4;
constexpr uint8_t CMD_PIXEL_CURSOR = 5;
constexpr uint8_t CMD_TEXT_CURSOR = 6;
constexpr uint8_t CMD_FG_COLOR = 7;
constexpr uint8_t CMD_BG_COLOR = 8;
constexpr uint8_t CMD_PUSH_CURSOR = 9;
constexpr uint8_t CMD_POP_CURSOR = 10;
constexpr uint8_t CMD_BLINK_CURSOR = 11;
constexpr uint8_t CMD_FILL_RECT = 20;
constexpr uint8_t CMD_HORZ_LINE = 21;
constexpr uint8_t CMD_VERT_LINE = 22;
constexpr uint8_t CMD_HORZ_PIXELS = 23;
constexpr uint8_t CMD_TEXT = 30;
constexpr uint8_t CMD_SET_SPRITE = 40;
constexpr uint8_t CMD_DRAW_SPRITE = 41;

constexpr uint8_t CMD_LIST_DIR   = 60;
constexpr uint8_t CMD_NEXT_FILE  = 61;
constexpr uint8_t CMD_OPEN_FILE  = 62;
constexpr uint8_t CMD_READ_FILE  = 63;
constexpr uint8_t CMD_WRITE_FILE = 64;
constexpr uint8_t CMD_CLOSE_FILE = 65;


#pragma pack(push,1)

struct Command
{
    uint8_t opcode;
};

struct Command_CLS
{
    uint8_t opcode;
};

struct Command_NewLine
{
    uint8_t opcode;
};

struct Command_Flip
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
    uint8_t color;
};

struct Command_BGColor
{
    uint8_t opcode;
    uint8_t color;
};

struct Command_SetSprite
{
    uint8_t opcode;
    uint8_t id;
};

struct Command_DrawSprite
{
    uint8_t opcode;
    uint8_t id;
};

struct Command_ListDir
{
    uint8_t opcode;
    uint8_t n;
};

struct Command_NextFile
{
    uint8_t opcode;
};

struct Command_OpenFile
{
    uint8_t opcode;
    uint8_t n;
};

struct Command_ReadFile
{
    uint8_t opcode;
    uint8_t n;
};

struct Command_WriteFile
{
    uint8_t opcode;
    uint8_t n;
};

struct Command_CloseFile
{
    uint8_t opcode;
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
    CursorStack   m_CursorStack;
    uint16_t      m_Pos=0, m_BytesLeft=0;
    uint16_t      m_CursorX=0, m_CursorY=0;
    uint8_t       m_FGColor=0xFF, m_BGColor=0;
    bool          m_Blink=false;

    union {
        Command             cmd;
        Command_CLS         cls;
        Command_Flip        flip;
        Command_NewLine     newline;
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
        Command_ListDir     list_dir;
        Command_NextFile    next_file;
        Command_OpenFile    open_file;
        Command_ReadFile    read_file;
        Command_WriteFile   write_file;
        Command_CloseFile   close_file;
        uint8_t             buffer[264];
    } Header;

    uint16_t get_header_len();
    uint16_t check_variable_len();
    bool process_command();

public:
    Protocol()
        : m_Pos(0)
    {
    }

    void add_byte(uint8_t b);
    void loop();
};
