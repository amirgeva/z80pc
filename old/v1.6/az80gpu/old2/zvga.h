#pragma once

#define WIDTH 640
#define HEIGHT 480
#define VGA_MODE Mode::MODE_640x480x60;
#define CHAR_WIDTH 8
#define CHAR_HEIGHT 8

void vga_setup();
void vga_loop();
void vga_clear();
void vga_fill_rect(uint16_t x, uint16_t y, uint16_t w, uint16_t h, uint8_t color);
void vga_line(uint16_t x1, uint16_t y1, uint16_t x2, uint16_t y2, uint8_t color);
void vga_pixels(uint16_t x, uint16_t y, const uint8_t* data, uint8_t n);
void vga_text(uint16_t x, uint16_t y, const char* text, uint8_t n, uint8_t fg_color, uint8_t bg_color);
void vga_set_sprite(uint8_t id, const uint8_t* data);
void vga_draw_sprite(uint8_t id, uint16_t x, uint16_t y);
void vga_scroll(uint16_t lines);
void vga_flip();
