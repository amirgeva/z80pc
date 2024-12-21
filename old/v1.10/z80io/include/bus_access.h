#pragma once

void bus_setup();
void bus_loop();

void clock_tick();
void perform_reset();
bool is_bus_acquired();
void acquire_bus();
void release_bus();

void upload(const byte *data, word addr, word len);

void write_byte(word addr, byte data);
byte read_byte(word addr);

class BusAcquirer
{
	bool m_ReleaseOnEnd = false;
public:
	BusAcquirer()
	: m_ReleaseOnEnd(!is_bus_acquired())
	{
		acquire_bus();
	}

	~BusAcquirer()
	{
		if (m_ReleaseOnEnd)
			release_bus();
	}
};

#define ACQUIRER BusAcquirer l_##__LINE__
