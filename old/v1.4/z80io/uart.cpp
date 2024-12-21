#include <avr/io.h>
#include <avr/interrupt.h>
#include "uart.h"
#include "queue.h"
#include "protocol.h"

//#define DEBUG_PRINTS

Protocol g_Protocol;
Queue<32> uart0_incoming,uart1_incoming;


ISR(USART0_RX_vect)
{
	uart0_incoming.push(UDR0);
}

ISR(USART1_RX_vect)
{
	uart1_incoming.push(UDR1);
}

void transmit0(uint8_t data)
{
	while (!(UCSR0A & (1<<UDRE0)));
	UDR0 = data;
}

void print_text(const char* text)
{
	while (*text) transmit0(*text++);
}

#ifdef DEBUG_PRINTS

DebugPrinter& DebugPrinter::operator << (const char* text)
{
	while (*text) transmit0(*text++);
	return *this;
}

const char *hex="0123456789ABCDEF";

DebugPrinter& DebugPrinter::operator << (uint8_t byte)
{
	transmit0(hex[byte>>4]);
	transmit0(hex[byte&15]);
	return *this;
}

DebugPrinter& DebugPrinter::operator << (uint16_t word)
{
	transmit0(hex[(word>>12)&15]);
	transmit0(hex[(word>>8)&15]);
	transmit0(hex[(word>>4)&15]);
	transmit0(hex[word&15]);
	return *this;
}

DebugPrinter& DebugPrinter::operator << (const endl&)
{
	transmit0(13);
	transmit0(10);
	return *this;
}
#else
DebugPrinter& DebugPrinter::operator << (const char* text) { return *this; }
DebugPrinter& DebugPrinter::operator << (uint8_t byte) { return *this; }
DebugPrinter& DebugPrinter::operator << (uint16_t word) { return *this; }
DebugPrinter& DebugPrinter::operator << (const endl&) { return *this; }
#endif

DebugPrinter dbg;

void transmit1(uint8_t data)
{
	while (!(UCSR1A & (1<<UDRE1)));
	UDR1 = data;
}

void test_print()
{
	const char* data="Hello\r\n";
	for(int i=0;i<7;++i)
		transmit1(data[i]);
}

void send_response_buffer(const uint8_t* buffer, uint8_t length)
{
	transmit1(0);
	transmit1(0);
	for(;length>0;--length)
		transmit1(*buffer++);
	transmit1(0);
	transmit1(0);
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
	
	dbg << "Starting...\r\n";
	//test_print();
}

void loop_uart()
{
	while (!uart1_incoming.empty())
	{
		uint8_t data = uart1_incoming.pop();
		//dbg << "Received: " << data << endl();
		g_Protocol.add_byte(data);
	}
	while (!uart0_incoming.empty())
	{
		//uint8_t data = 
		uart0_incoming.pop();
		//dbg << data << endl();
	}
	//uart0_incoming.init();
}
