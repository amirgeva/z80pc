#define F_CPU 8000000
#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>

volatile uint8_t last=0;

ISR(USART0_RX_vect)
{
	last=UDR0;
}

ISR(USART1_RX_vect)
{
	last=UDR1;
}

void transmit0(uint8_t data)
{
	while (!(UCSR0A & (1<<UDRE0)));
	UDR0 = data;
}

void transmit1(uint8_t data)
{
	while (!(UCSR1A & (1<<UDRE1)));
	UDR1 = data;
}

const char *hex="0123456789ABCDEF";

/*
void print(uint16_t v)
{
	transmit1(hex[(v>>12)&15]);
	transmit1(hex[(v>> 8)&15]);
	transmit1(hex[(v>> 4)&15]);
	transmit1(hex[(v    )&15]);
}
*/

void print(uint8_t v)
{
	transmit1(hex[(v>> 4)&15]);
	transmit1(hex[(v    )&15]);
}

void print(const char* text)
{
	for(;*text;++text)
		transmit1(*text);
}

void setup_uart()
{
	// BAUD = F_OSC / (16 * (UBRR+1))
	// 8e6 / (9600 * 16) - 1 = UBRR		==>  51
	
	UBRR0H = 0;
	UBRR0L = 51;
	UBRR1H = 0;
	UBRR1L = 51;
	
	UCSR0B = (1 << RXCIE0) | (1 << RXEN0) | (1 << TXEN0);
	UCSR0C = (1 << UCSZ01) | (1 << UCSZ00);
	
	UCSR1B = (1 << RXCIE1) | (1 << RXEN1) | (1 << TXEN1);
	UCSR1C = (1 << UCSZ11) | (1 << UCSZ10);
}


int main(void)
{
	setup_uart();
	//sei();
	
	while (1)
	{
		uint8_t bkp=OSCCAL;
		for(uint8_t cal = 0; cal < 255; ++cal)
		{
			OSCCAL = cal;
			print("TESTING: ");
			print(cal);
			print("\r\n");
			_delay_ms(10);
		}
		OSCCAL=bkp;
		_delay_ms(10000);
	}
}

