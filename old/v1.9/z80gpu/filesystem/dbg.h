#pragma once

#include <cstdint>

void debug_print(const char* text);
void debug_print(uint8_t number, bool add_eol);
#define DBG(x) x