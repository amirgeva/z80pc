#pragma once

#include <cstdint>

void bus_setup();

bool is_bus_acquired();
void acquire_bus();
void release_bus();
bool write_byte(uint16_t addr, uint8_t data);
uint8_t read_byte(uint16_t addr);
void read_bus(uint8_t* buffer);
void read_bus(uint8_t& addrl, uint8_t& addrh, uint8_t& data, uint8_t& flags);
void trigger_interrupt();

#define FLAG_IORQ  ((flags & 0x01)==0)
#define FLAG_MREQ  ((flags & 0x02)==0)
#define FLAG_RD    ((flags & 0x04)==0)
#define FLAG_WR    ((flags & 0x08)==0)
#define FLAG_M1    ((flags & 0x10)==0)
#define FLAG_HALT  ((flags & 0x20)==0)
#define FLAG_A16   ((flags & 0x40)==1)
#define FLAG_WAIT  ((flags & 0x80)==0)

// M1 MREQ RD active,  IORQ WR inactive
#define FLAGS_FETCH ((flags & 0x1F) == 0x09)

void perform_reset();
void clock_tick();
void set_clock_pwm(bool active);

class BusAcquirer
{
    bool m_StartingState;
public:
    BusAcquirer()
    : m_StartingState(is_bus_acquired())
    {
        acquire_bus();
    }

    ~BusAcquirer()
    {
        if (!m_StartingState)
            release_bus();
    }
};

#define ACQUIRE BusAcquirer l_##__LINE__
