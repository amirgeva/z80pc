/*
 * test_uart.cpp
 *
 * Created: 10/06/2022 12:24:24
 * Author : amir
 */ 

#include <avr/io.h>


void transmit0(uint8_t data)
{
	while (!(UCSR0A & (1<<UDRE0)));
	UDR0 = data;
}

int main(void)
{
	// BAUD = F_OSC / (16 * (UBRR+1))
	// 8e6 / (9600 * 16) - 1 = UBRR         ==>  51

	UBRR0H = 0;
	UBRR0L = 51;
	UBRR1H = 0;
	UBRR1L = 51;

	UCSR0B = (1 << RXCIE0) | (1 << RXEN0) | (1 << TXEN0);
	UCSR0C = (1 << UCSZ01) | (1 << UCSZ00);

	UCSR1B = (1 << RXCIE1) | (1 << RXEN1) | (1 << TXEN1);
	UCSR1C = (1 << UCSZ11) | (1 << UCSZ10);

	uint8_t c=32;
    while (1) 
    {
		transmit0(c++);
		if (c>='z') c=' ';
    }
}

