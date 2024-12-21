#include <Arduino.h>
#include "zvga.h"
#include <ESP32S3VGA.h>
//#include <Ressources/CodePage437_8x8.h>

VGA dsp;
const PinConfig pins(-1,-1,-1,-1,39,  -1,-1,-1,-1,-1,40,  -1,-1,-1,-1,41,  1,2);

struct Sprite16
{
	uint8_t data[256];
};
struct Character
{
	uint8_t data[64];
};
Sprite16* g_Sprites;
//Character* g_Font;

void vga_setup()
{
  Serial.println("Init vga");
	dsp.bufferCount=2;
	Mode mode = Mode::MODE_640x480x60;
	if(!dsp.init(pins, mode, 8)) while(1) delay(1);
  Serial.println("Allocate Sprites");
  /*
	g_Sprites=(Sprite16*)malloc(256 * sizeof(Sprite16));
	for(int i=0;i<256;++i)
	{
		Sprite16& spr = g_Sprites[i];
		for(int j=0;j<256;++j)
			spr.data[j]=i;
	}
 */
	//dsp.setFont(CodePage437_8x8);
	//dsp.clear();
  dsp.show();
  dsp.start();
  Serial.println("VGA setup done");
  vga_fill_rect(100,100,200,100,0x80);
  dsp.show();
  Serial.println("Drawn rect");
}

void vga_loop()
{
}

void vga_clear()
{
  vga_fill_rect(0,0,WIDTH,HEIGHT,0);
}

void vga_fill_rect(uint16_t x, uint16_t y, uint16_t w, uint16_t h, uint8_t color)
{
  //Serial.printf("fill_rect(%hd,%hd,%hd,%hd,%hd)\r\n",x,y,w,h,uint16_t(color));
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
//  if (y1==y2) dsp.xLine(x1,x2,y1,color);
//  else
//{
//    dsp.line(x1,y1,x2,y2,color);
//  }
}

void vga_pixels(uint16_t x, uint16_t y, const uint8_t* data, uint8_t n)
{
	uint16_t x1=x+n;
	if (x>=WIDTH || y>=HEIGHT || x1>WIDTH) return;
	uint8_t* ptr=dsp.dmaBuffer->getLineAddr8(y,dsp.backBuffer);
	for(uint16_t j=x;j<x1;++j)
		ptr[j]=*data++;
}

void vga_text(uint16_t x, uint16_t y, const char* text, uint8_t n, uint8_t fg_color, uint8_t bg_color)
{
	/*
  dsp.setCursor(x,y);
  dsp.setTextColor(fg_color,bg_color);
  for(;n>0;--n)
    dsp.print(*text++);
	*/
}

void vga_set_sprite(uint8_t id, const uint8_t* data)
{
	Sprite16& s = g_Sprites[id];
	memcpy(s.data,data,256);
}

void vga_draw_sprite_fast(uint8_t id, uint16_t x, uint16_t y)
{
	uint16_t x1=x+16;
	const uint8_t* data = g_Sprites[id].data;
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
		const uint8_t* data = g_Sprites[id].data;
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
