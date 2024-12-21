#pragma once

#include "../MCP23S17/ISPI.h"
#include <stdint.h>
struct Command;

class SDCard
{
	ispi::SPI*	_spi;

	void	init_card() const;
	uint8_t go_idle() const;
	uint8_t	command_transaction(const Command& c) const;
	void	command(uint8_t cmd, uint32_t arg, uint8_t crc) const;
	void	command(const Command& c) const;
	bool	check_card_version() const;
	bool	wait_for_ready() const;
	uint8_t read_res1() const;
	bool	read_res7(uint8_t* res) const;
public:
	SDCard();
	
	bool init(ispi::SPI* s);
	bool read_sector(uint32_t address, uint8_t* buffer, uint8_t* token);
};