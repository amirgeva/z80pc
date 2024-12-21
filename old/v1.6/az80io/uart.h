#pragma once

void setup_uart();
void loop_uart();
void print_text(const char* text);
struct endl{};

class DebugPrinter
{
public:
	DebugPrinter& operator << (const char* text);
	DebugPrinter& operator << (uint8_t byte);
	DebugPrinter& operator << (uint16_t word);
	DebugPrinter& operator << (const endl&);
};

extern DebugPrinter dbg;