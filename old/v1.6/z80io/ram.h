#pragma once

void setup_handlers();
void activate();
void deactivate(bool restart_autoclock);
uint8_t read_byte(uint16_t addr);
bool write_byte(uint16_t addr, uint8_t value);
void read_string(uint16_t addr, uint8_t* target);
void read_block(uint16_t addr, uint8_t* target, uint16_t size);
bool is_auto_clock();
void reset_cpu();
void upload_os();

