#pragma once

void zboard_init();

void program_data(uint16_t addr, uint8_t len, const uint8_t* data);
void read_data(uint16_t addr, uint8_t len, uint8_t* data);
void clock_read_bus(uint8_t* data);
void AutoClock();
