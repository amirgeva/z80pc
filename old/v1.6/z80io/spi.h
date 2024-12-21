#pragma once



inline uint8_t spi_transfer_byte(uint8_t b)
{
	SPDR = b;
	while (!(SPSR & (1<<SPIF)));
	return SPDR;
}

uint8_t gpu_spi_transaction(const uint8_t* tx, uint8_t* rx, uint16_t len);