#pragma once


void activate();
void deactivate();
uint8_t read_byte(uint16_t addr);
bool write_byte(uint16_t addr, uint8_t value);
void read_string(uint16_t addr, uint8_t* target);
void read_block(uint16_t addr, uint8_t* target, uint16_t size);