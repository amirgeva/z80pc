#pragma once

#include <cstdint>

#define WIDTH 640
#define HEIGHT 480
#define CHAR_WIDTH 8
#define CHAR_HEIGHT 16
#define SPRITE_WIDTH 16
#define SPRITE_HEIGHT 16
#define TOTAL_SPRITES 256

void gpu_setup(uint8_t* frame_buffer);
void gpu_loop();
void gpu_clear();
void gpu_fill_rect(uint16_t x, uint16_t y, uint16_t w, uint16_t h, uint8_t color);
void gpu_line(uint16_t x1, uint16_t y1, uint16_t x2, uint16_t y2, uint8_t color);
void gpu_pixels(uint16_t x, uint16_t y, const uint8_t* data, uint8_t n);
void gpu_text(uint16_t x, uint16_t y, const char* text, uint8_t n, uint8_t fg_color, uint8_t bg_color);
void gpu_set_sprite(uint8_t id, const uint8_t* data);
void gpu_draw_sprite(uint8_t id, uint16_t x, uint16_t y);
void gpu_scroll(uint16_t lines);
void gpu_flip();
