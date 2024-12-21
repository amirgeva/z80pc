#include <string.h>
#include "gpu.h"
#include "font.h"
#include "pico/rand.h"

uint8_t* g_FrameBuffer=nullptr;

const uint8_t tiles[] = {
#include "tiles.inl"
};

void initialize_frame_buffer(uint8_t* frame_buffer)
{
    int n=sizeof(tiles);
    for(int i=0;i<(640*480);++i)
    {
        frame_buffer[i]=(i<n ? tiles[i] : 0);
    }
    /*
    uint8_t color=0;
    for(int iy=0;iy<15;++iy)
    {
        for(int ix=0;ix<20;++ix, ++color)
        {
            for(int i=0;i<32;++i)
            {
                int y=iy*32+i;
                int x=ix*32;
                int idx = y*640+x;
                for(int j=0;j<32;++j)
                {
                    g_FrameBuffer[idx++]=color;
                }
            }
        }
    }
    */
    // for(int i=0;i<(640*480);++i)
    // {
        
    //     g_FrameBuffer[i]=get_rand_32();
    // }
}

struct Character
{
    uint8_t pixels[CHAR_HEIGHT];
};

static_assert(sizeof(Character)==CHAR_HEIGHT);

const Character* g_Font=reinterpret_cast<const Character*>(font);

struct Sprite
{
    uint8_t pixels[SPRITE_WIDTH*SPRITE_HEIGHT];
};
Sprite g_Sprites[TOTAL_SPRITES];

void gpu_setup(uint8_t* frame_buffer)
{
    g_FrameBuffer=frame_buffer;
    for(int sprite_index=0;sprite_index<256;++sprite_index)
    {
        uint8_t color=uint8_t(sprite_index);
        Sprite& s = g_Sprites[sprite_index];
        for(int i=0;i<256;++i)
            s.pixels[i]=color;
    }
}

void gpu_loop() {}


void gpu_clear()
{
    gpu_fill_rect(0,0,WIDTH,HEIGHT,0);
}

uint8_t* row(uint16_t y)
{
    return g_FrameBuffer + y*WIDTH;
}

void gpu_fill_rect(uint16_t x, uint16_t y, uint16_t w, uint16_t h, uint8_t color)
{
	uint16_t x1=x+w;
	if (x>=WIDTH || y>=HEIGHT || x1>WIDTH || (y+h)>HEIGHT) return;
	for(;h>0;++y,--h)
	{
		uint8_t* ptr=row(y);
		for(uint16_t j=x;j<x1;++j)
			ptr[j]=color;
	}
}

void gpu_line(uint16_t x1, uint16_t y1, uint16_t x2, uint16_t y2, uint8_t color)
{

}

void gpu_pixels(uint16_t x, uint16_t y, const uint8_t* data, uint8_t n)
{
	uint16_t x1=x+n;
	if (x>=WIDTH || y>=HEIGHT || x1>WIDTH) return;
	uint8_t* ptr=row(y);
	for(uint16_t j=x;j<x1;++j)
		ptr[j]=*data++;
}

void gpu_draw_char(uint16_t x, uint16_t y, uint8_t c, uint8_t fg_color, uint8_t bg_color)
{
    uint16_t x1=x+CHAR_WIDTH;
    uint16_t y1=y+CHAR_HEIGHT;
    if (x>=WIDTH || y>=HEIGHT || x1>WIDTH || y1>HEIGHT) return;
    const Character& ch = g_Font[c];
    for(uint16_t i=0;i<CHAR_HEIGHT;++i)
    {
        uint16_t ch_row=ch.pixels[i];
        const uint8_t* pixels=&pixels_lut[ch_row*8];
        uint8_t* ptr=row(y+i);
        ptr+=x;
        for(uint8_t j=0;j<8;++j)
        {
            *ptr++ = pixels[j]?fg_color:bg_color;
        }
    }
}

void gpu_text(uint16_t x, uint16_t y, const char* text, uint8_t n, uint8_t fg_color, uint8_t bg_color)
{
    const uint8_t* buffer=reinterpret_cast<const uint8_t*>(text);
    while(*buffer)
    {
        gpu_draw_char(x,y,*buffer++,fg_color,bg_color);
        x+=CHAR_WIDTH;
    }
}

void gpu_set_sprite(uint8_t id, const uint8_t* data)
{
	Sprite& s = g_Sprites[id];
	memcpy(s.pixels,data,SPRITE_WIDTH*SPRITE_HEIGHT);
}

void gpu_draw_sprite_fast(uint8_t id, uint16_t x, uint16_t y)
{
	uint16_t x1=x+16;
	const uint8_t* data = g_Sprites[id].pixels;
	for(uint16_t i=0;i<SPRITE_HEIGHT;++i,++y)
	{
		uint8_t* ptr=row(y);
		for(uint16_t j=x;j<x1;++j)
			ptr[j]=*data++;
	}
}

void gpu_draw_sprite(uint8_t id, uint16_t x, uint16_t y)
{
	if (x<(WIDTH-SPRITE_WIDTH) && y<(HEIGHT-SPRITE_HEIGHT)) gpu_draw_sprite_fast(id,x,y);
	else
	{
		const uint8_t* data = g_Sprites[id].pixels;
		for(int i=0;i<SPRITE_HEIGHT && y<HEIGHT;++i,++y)
		{
			uint8_t* ptr=row(y);
			uint16_t xj=x;
			for(int j=0;j<SPRITE_WIDTH && xj<WIDTH;++j,++xj)
			{
				ptr[xj]=data[j];
			}
			data+=16;
		}
	}
}

void gpu_scroll(uint16_t lines)
{
  //dsp.scroll(lines,0);
}

void gpu_flip()
{
}

