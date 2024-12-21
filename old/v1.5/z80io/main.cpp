#include <avr/io.h>
#include <avr/interrupt.h>
#include <avr/pgmspace.h>
#include "uart.h"
#include "protocol.h"
#include "queue.h"
#include "consts.h"

Queue<256> gpu_queue;

void setup_handlers();
void deactivate();

volatile bool gpu_out_in_progress=false;

ISR(INT5_vect)
{
	if (gpu_out_in_progress)
	{
		gpu_out_in_progress=false;
		PORTD &= ~CLEAR_WAIT;
	}
}

ISR(INT0_vect)
{
	uint8_t data = PINA;
	gpu_queue.push(data);
	gpu_out_in_progress=true;
	PORTD |= CLEAR_WAIT;
}

void setup_interrupts()
{
	// INT0 - WAIT
	// INT5 - IORQ
	
	// Falling edge of INT0
	EICRA = (1 << ISC01); 
	// Rising edge for INT5
	EICRB = (1 << ISC51) | (1 << ISC50);
	// Enable both
	EIMSK = (1 << INT0) | (1 << INT5);
}


uint8_t spi_transfer(uint8_t b)
{
	SPDR = b;
	while (!(SPSR & (1<<SPIF)));
	return SPDR;
}

void spi_transaction(const uint8_t* tx, uint8_t* rx, uint8_t len)
{
	PORTB &= ~CS;
	for(uint8_t i=0;i<len;++i)
		rx[i]=spi_transfer(tx[i]);
	PORTB |= CS;
}

int main(void)
{
	setup_uart();

	deactivate();
	// Enable SPI
	SPCR = (1<<SPE)|(1<<MSTR)|(1<<SPR0);
	//upload_os();
	setup_interrupts();
	setup_handlers();
	sei();
	
	uint8_t spi_tx[32],spi_rx[32];
	for(uint8_t i=0;i<32;++i)
	spi_tx[i]=128-i;
	uint8_t tx_pos=1;
	
    while (1) 
    {
		loop_uart();
		
		while (tx_pos < 30 && !gpu_queue.empty())
		{
			uint8_t data = gpu_queue.pop();
			spi_tx[tx_pos++] = data;
		}
		if (tx_pos>1 && (PINE & SCS))
		{
			spi_tx[0]=tx_pos-1;
			uint16_t crc=calculate_crc16(spi_tx, 30);
			spi_tx[30]=crc&0xFF;
			spi_tx[31]=(crc>>8)&0xFF;
			spi_transaction(spi_tx, spi_rx, 32);
			tx_pos=1;
		}
    }
}

