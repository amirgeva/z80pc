#define F_CPU 8000000UL
#include <avr/io.h>
#include "spi.h"
#include "consts.h"

/*
inline uint8_t spi_transfer_byte(uint8_t b)
{
	SPDR = b;
	while (!(SPSR & (1<<SPIF)));
	return SPDR;
}
*/
uint8_t gpu_spi_transaction(const uint8_t* tx, uint8_t* rx, uint16_t len)
{
	uint8_t res=0;
	PORTB &= ~CS;
	//while ((PINE&SCS)==0);
	if (rx)
	{
		for(uint16_t i=0;i<len;++i)
		{
			rx[i]=spi_transfer_byte(tx[i]);
		}
	}
	else
	{
		for(uint16_t i=0;i<len;++i)
		{
			res=spi_transfer_byte(tx[i]);
		}
	}
	PORTB |= CS;
	return res;
}

