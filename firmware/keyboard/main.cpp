/*
 * keyboard.cpp
 *
 * Created: 12-Jun-19 8:57:15 PM
 * Author : amir
 */ 

#define F_CPU 8000000UL
#define BAUD 9600
#define BR (F_CPU/16/BAUD-1)
#include <avr/io.h>
#include <util/delay.h>

inline bool tx_ready()
{
	return (UCSR0A & (1 << UDRE0))!=0;
}

inline void send(uint8_t b)
{
	while (!tx_ready());
	UDR0 = b;
}

uint8_t translation[75];
uint8_t last_state[75];

uint8_t scan_columns(uint8_t index, uint8_t from, uint8_t to, uint8_t val)
{
	for(uint8_t col=from;col<to;++col)
	{
		uint8_t cur=(val&1);
		if (cur != last_state[index])
		{
			uint8_t c=translation[index];
			if (cur) c|=0x80;
			send(c);
			last_state[index]=cur;
		}
		++index;
		val>>=1;
	}
	return index;
}

int main(void)
{
	DDRB = 0;
	DDRC = 0;
	DDRD = 0xFA;
	PORTB = 0xFF;
	PORTC = 0xFF;
	PORTD = 0xFF;
    UBRR0H = uint8_t(BR >> 8);
	UBRR0L = uint8_t(BR);
	UCSR0B = (1<<TXEN0);
	UCSR0C = (1<<UCSZ00) | (1<<UCSZ01);
	for(uint8_t i=0;i<75;++i)
	{
		last_state[i]=1;
		translation[i]=i;
	}
    while (1) 
    {
		uint8_t index=0;
		for(uint8_t row=0;row<5;++row)
		{
			uint8_t mask=(1<<(3+row));
			PORTD &= ~mask;
			_delay_us(1);
			index=scan_columns(index,0,8,PINB);
			index=scan_columns(index,8,14,PINC&0x3F);
			index=scan_columns(index,14,15,PIND>>2);
			PORTD |= mask;
			_delay_us(1);
		}
    }
}

