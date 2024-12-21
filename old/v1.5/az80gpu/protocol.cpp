#include <Arduino.h>
#include "protocol.h"
#include "zvga.h"

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
    case CMD_LIST_DIR: return sizeof(Command_ListDir);
    case CMD_NEXT_FILE: return sizeof(Command_NextFile);
    case CMD_OPEN_FILE: return sizeof(Command_OpenFile);
    case CMD_READ_FILE: return sizeof(Command_ReadFile);
    case CMD_WRITE_FILE: return sizeof(Command_WriteFile);
    case CMD_CLOSE_FILE: return sizeof(Command_CloseFile);
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
    case CMD_LIST_DIR: return Header.list_dir.n + sizeof(Command_ListDir) - m_Pos;
    case CMD_OPEN_FILE: return Header.open_file.n + sizeof(Command_OpenFile) - m_Pos;
    case CMD_WRITE_FILE: return Header.write_file.n + sizeof(Command_WriteFile) - m_Pos;
    }
    return 0;
}

bool Protocol::process_command()
{
  //Serial.print("Processing ");
  //Serial.println(Header.cmd.opcode);
    switch (Header.cmd.opcode)
    {
        case CMD_CLS:
        {
            //std::cout << "CLS\n";
            m_BGColor = 0;
            m_FGColor = 0xFF;
            vga_fill_rect(0, 0, WIDTH - 1, HEIGHT - 1, 0);
            m_CursorX = 0;
            m_CursorY = 0;
            return true;
        }
        case CMD_FLIP:
        {
            //flip_screen = true;
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
            if (m_CursorY < (HEIGHT - CHAR_HEIGHT))
              m_CursorY+=CHAR_HEIGHT;
            else
              vga_scroll(CHAR_HEIGHT);
            m_CursorX=0;
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
            m_CursorX = Header.text_cursor.x * CHAR_WIDTH;
            m_CursorY = Header.text_cursor.y * CHAR_HEIGHT;
            return true;
        }
        case CMD_BLINK_CURSOR:
        {
            m_Blink = (Header.blink_cursor.state > 0);
            return true;
        }
        case CMD_FILL_RECT:
        {
            vga_fill_rect(m_CursorX, m_CursorY,
                          Header.fill_rect.w,
                          Header.fill_rect.h,
                          m_BGColor);
            return true;
        }
        case CMD_HORZ_LINE:
        {
            vga_line(m_CursorX, m_CursorY, m_CursorX + Header.horz_line.w - 1, m_CursorY, m_FGColor);
            m_CursorX += Header.horz_line.w;
            return true;
        }
        case CMD_VERT_LINE:
        {
            vga_line(m_CursorX, m_CursorY, m_CursorX, m_CursorY + Header.vert_line.h - 1, m_FGColor);
            m_CursorY += Header.vert_line.h;
            return true;
        }
        case CMD_HORZ_PIXELS:
        {
            const uint8_t* data = (Header.buffer + sizeof(Command_HorzPixels));
            vga_pixels(m_CursorX, m_CursorY, data, Header.horz_pixels.n);
            return true;
        }
        case CMD_TEXT:
        {
            const char* text = reinterpret_cast<const char*>(Header.buffer + sizeof(Command_Text));
            Serial.print("Printing: ");
            Serial.print(m_CursorX);
            Serial.print(',');
            Serial.print(m_CursorY);
            Serial.print(' ');
            Serial.print(int(m_FGColor));
            Serial.print('/');
            Serial.print(int(m_BGColor));
            Serial.print(' ');
            Serial.println(text);
            vga_text(m_CursorX, m_CursorY, text, Header.text.n, m_FGColor, m_BGColor);
            m_CursorX += Header.text.n * CHAR_WIDTH;
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
            const uint8_t* data = Header.buffer + sizeof(Command_SetSprite);
            vga_set_sprite(Header.set_sprite.id, data);
            return true;
        }
        case CMD_DRAW_SPRITE:
        {
            vga_draw_sprite(Header.draw_sprite.id, m_CursorX, m_CursorY);
            return true;
        }
    }
    return false;
}

void Protocol::loop()
{
    if (m_Blink)
    {
      /*
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
      */
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
