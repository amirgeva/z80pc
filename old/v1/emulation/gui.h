#pragma once

#include "z80.h"
#include <cxx/xstring.h>


void gui_init(Z80Context* cpu, uint8_t* ram);
void gui_load_code(const cxx::xstring& source, const cxx::xstring& listing);
void gui_update(Z80Context* cpu);
bool gui_sync();