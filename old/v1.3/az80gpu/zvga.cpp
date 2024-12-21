#include <Arduino.h>
#include "zvga.h"
#include <ESP32Video.h>
#include <Ressources/CodePage437_8x8.h>

VGA6Bit dsp;
PinConfig pinConfig(-1, -1, -1, 21, 22,  -1, -1, -1, 33, 4,  -1, -1, 27, 32,  16, 17,  -1);

struct Sprite16
{
  uint8_t data[256];
};
Sprite16* g_Sprites;

void vga_setup()
{
  dsp.init(VGA_MODE, pinConfig);
  g_Sprites=(Sprite16*)malloc(256 * sizeof(Sprite16));
  for(int i=0;i<256;++i)
  {
    Sprite16& spr = g_Sprites[i];
    for(int j=0;j<256;++j)
      spr.data[j]=i;
  }
  dsp.setFont(CodePage437_8x8);
  dsp.clear();
}

void vga_loop()
{
}

void vga_clear()
{
  dsp.clear();
}

void vga_fill_rect(uint16_t x, uint16_t y, uint16_t w, uint16_t h, uint8_t color)
{
  dsp.fillRect(x,y,w,h,color);
}

void vga_line(uint16_t x1, uint16_t y1, uint16_t x2, uint16_t y2, uint8_t color)
{
  if (y1==y2) dsp.xLine(x1,x2,y1,color);
  else
  {
    dsp.line(x1,y1,x2,y2,color);
  }
}

void vga_pixels(uint16_t x, uint16_t y, const uint8_t* data, uint8_t n)
{
  for(;n>0;--n)
    dsp.dot(x++,y,*data++);
}

void vga_text(uint16_t x, uint16_t y, const char* text, uint8_t n, uint8_t fg_color, uint8_t bg_color)
{
  dsp.setCursor(x,y);
  dsp.setTextColor(fg_color,bg_color);
  for(;n>0;--n)
    dsp.print(*text++);
}

void vga_set_sprite(uint8_t id, const uint8_t* data)
{
  Sprite16& s = g_Sprites[id];
  memcpy(s.data,data,256);
}

void vga_draw_sprite_fast(uint8_t id, uint16_t x, uint16_t y)
{
  const uint8_t* data = g_Sprites[id].data;
  for(int i=0;i<16;++i)
  {
    for(int j=0;j<16;++j)
    {
      dsp.dotFast(x+j,y+i,*data++);
    }
  }
}

void vga_draw_sprite(uint8_t id, uint16_t x, uint16_t y)
{
  if (x<(WIDTH-16) && y<(HEIGHT-16)) vga_draw_sprite_fast(id,x,y);
  else
  {
    const uint8_t* data = g_Sprites[id].data;
    for(int i=0;i<16;++i)
    {
      for(int j=0;j<16;++j)
      {
        dsp.dot(x+j,y+i,*data++);
      }
    }
  }
}

void vga_scroll(uint16_t lines)
{
  dsp.scroll(lines,0);
}
