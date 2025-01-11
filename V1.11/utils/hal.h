#pragma once

#include "types.h"

#ifdef __cplusplus
extern "C" {
#endif

void hal_init();
void hal_shutdown();

void hal_move(int x, int y);
//byte hal_cursor_x();
//byte hal_cursor_y();

void hal_draw_char(byte c);
void hal_rept_char(byte c, byte n);
void hal_color(byte fg_color, byte bg_color);
void hal_blink(byte state);
word hal_getkey();

//byte hal_open(const char* filename);
//word hal_read(byte handle, byte* buffer, word length);
//void hal_close(byte handle);

/*
word div_mod(word numerator, word denominator, word* remainder);
*/

#ifdef __cplusplus
}
#endif
