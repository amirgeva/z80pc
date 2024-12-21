#include <Arduino.h>
#include <ESP32S3VGA.h>
#include "zvga.h"
#include "font.h"

const PinConfig pins(-1,-1,4,5,6,  -1,-1,-1,16,17,18,  -1,-1,-1,7,15,  1,2);
VGA dsp;

struct Character
{
    uint8_t pixels[16];
};
const Character* g_Font=reinterpret_cast<const Character*>(font);

struct Sprite
{
    uint8_t pixels[16*16];
};
Sprite g_Sprites[256];

void vga_setup()
{
    for(int sprite_index=0;sprite_index<256;++sprite_index)
    {
        uint8_t color=uint8_t(sprite_index);
        Sprite& s = g_Sprites[sprite_index];
        for(int i=0;i<256;++i)
            s.pixels[i]=color;
    }
    Mode mode = Mode::MODE_640x480x60;
    dsp.bufferCount=1;
    if(!dsp.init(pins, mode, 8)) while(1) delay(1);
    vga_fill_rect(200,100,200,100,7);
    dsp.show();
    dsp.start();
}

void vga_loop() {}


void vga_clear()
{
    vga_fill_rect(0,0,WIDTH,HEIGHT,0);
}

void vga_fill_rect(uint16_t x, uint16_t y, uint16_t w, uint16_t h, uint8_t color)
{
	uint16_t x1=x+w;
	if (x>=WIDTH || y>=HEIGHT || x1>WIDTH || (y+h)>HEIGHT) return;
	for(;h>0;++y,--h)
	{
		uint8_t* ptr=dsp.dmaBuffer->getLineAddr8(y,dsp.backBuffer);
		for(uint16_t j=x;j<x1;++j)
			ptr[j]=color;
	}
}

void vga_line(uint16_t x1, uint16_t y1, uint16_t x2, uint16_t y2, uint8_t color)
{

}

void vga_pixels(uint16_t x, uint16_t y, const uint8_t* data, uint8_t n)
{
	uint16_t x1=x+n;
	if (x>=WIDTH || y>=HEIGHT || x1>WIDTH) return;
	uint8_t* ptr=dsp.dmaBuffer->getLineAddr8(y,dsp.backBuffer);
	for(uint16_t j=x;j<x1;++j)
		ptr[j]=*data++;
}

void vga_draw_char(uint16_t x, uint16_t y, uint8_t c, uint8_t fg_color, uint8_t bg_color)
{
    uint16_t x1=x+CHAR_WIDTH;
    uint16_t y1=x+CHAR_HEIGHT;
    if (x>=WIDTH || y>=HEIGHT || x1>WIDTH || y1>HEIGHT) return;
    const Character& ch = g_Font[c];
    for(uint16_t i=0;i<CHAR_HEIGHT;++i)
    {
        uint16_t row=ch.pixels[i];
        const uint8_t* pixels=&pixels_lut[row*8];
        uint8_t* ptr=dsp.dmaBuffer->getLineAddr8(y+i,dsp.backBuffer);
        ptr+=x;
        for(uint8_t j=0;j<8;++j)
        {
            *ptr++ = pixels[j]?fg_color:bg_color;
        }
    }
}

void vga_text(uint16_t x, uint16_t y, const char* text, uint8_t n, uint8_t fg_color, uint8_t bg_color)
{
    const uint8_t* buffer=reinterpret_cast<const uint8_t*>(text);
    while(*buffer)
    {
        /*
        Serial1.print(x);
        Serial1.print(" ");
        Serial1.print(y);
        Serial1.print(" ");
        Serial1.println(int(*buffer));
        */
        vga_draw_char(x,y,*buffer++,fg_color,bg_color);
        x+=CHAR_WIDTH;
    }
}

void vga_set_sprite(uint8_t id, const uint8_t* data)
{
	Sprite& s = g_Sprites[id];
	memcpy(s.pixels,data,256);
}

void vga_draw_sprite_fast(uint8_t id, uint16_t x, uint16_t y)
{
	uint16_t x1=x+16;
	const uint8_t* data = g_Sprites[id].pixels;
	for(uint16_t i=0;i<16;++i,++y)
	{
		uint8_t* ptr=dsp.dmaBuffer->getLineAddr8(y,dsp.backBuffer);
		for(uint16_t j=x;j<x1;++j)
			ptr[j]=*data++;
	}
}

void vga_draw_sprite(uint8_t id, uint16_t x, uint16_t y)
{
	if (x<(WIDTH-16) && y<(HEIGHT-16)) vga_draw_sprite_fast(id,x,y);
	else
	{
		const uint8_t* data = g_Sprites[id].pixels;
		for(int i=0;i<16 && y<HEIGHT;++i,++y)
		{
			uint8_t* ptr=dsp.dmaBuffer->getLineAddr8(y,dsp.backBuffer);
			uint16_t xj=x;
			for(int j=0;j<16 && xj<WIDTH;++j,++xj)
			{
				ptr[xj]=data[j];
			}
			data+=16;
		}
	}
}

void vga_scroll(uint16_t lines)
{
  //dsp.scroll(lines,0);
}

void vga_flip()
{
	dsp.show();
}

