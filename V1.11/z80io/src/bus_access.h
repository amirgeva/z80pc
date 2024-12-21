#pragma once

void bus_setup();
void bus_loop();
void clock_tick();
void do_reset();
bool is_bus_acquired();
bool is_auto_clock();
void set_auto_clock(bool active);
void acquire_bus();
void release_bus();
void write_byte(Word addr, byte value);
void write_word(Word addr, word value);
byte read_byte(Word addr);
Word read_word(Word addr);
void process_io();
void interrupt(byte data);

class BusAcquirer
{
	bool already_acquired;
public:
	BusAcquirer() : already_acquired(is_bus_acquired())
	{
		acquire_bus();
	}
	~BusAcquirer()
	{
		if (!already_acquired)
			release_bus();
	}
};

//#define ACQUIRE BusAcquirer l_##__LINE__
