#pragma once

void zboard_init();
void debug_print(const char* msg);
void debug_prints(const char* msg);

void program_data(uint16_t addr, uint8_t len, const uint8_t* data);
void read_data(uint16_t addr, uint8_t len, uint8_t* data);
void clock_read_bus(uint8_t* data);
void AutoClock();
void AcquireBUS();
void ReleaseBUS();
