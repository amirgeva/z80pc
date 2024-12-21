#define F_CPU 8000000UL
#include <avr/io.h>
#include <avr/interrupt.h>
#include "uart.h"
#include "queue.h"
#include "protocol.h"

#define DEBUG_PRINTS

const char *hex="0123456789ABCDEF";

Protocol g_Protocol;
Queue<32> uart0_incoming,uart1_incoming;
Queue<32> uart0_outgoing;

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

void transmit0_text(const char* text)
{
	while (*text) transmit0(*text++);
}

void print_text(const char* text)
{
	while (*text) uart0_outgoing.push(*text++);
}

void transmit0_num(uint32_t value)
{
	uint8_t bits=28;
	for(int i=0;i<8;++i,bits-=4)
	{
		transmit0(hex[(value >> bits)&0x0F]);
	}
}

void transmit0_byte(uint8_t value)
{
	transmit0(hex[value>>4]);
	transmit0(hex[value&15]);
}

void transmit0_eol()
{
	transmit0(13);
	transmit0(10);
}

#ifdef DEBUG_PRINTS

DebugPrinter& DebugPrinter::operator << (const char* text)
{
	while (*text) uart0_outgoing.push(*text++);
	return *this;
}

DebugPrinter& DebugPrinter::operator << (uint8_t byte)
{
	uart0_outgoing.push(hex[byte>>4]);
	uart0_outgoing.push(hex[byte&15]);
	return *this;
}

DebugPrinter& DebugPrinter::operator << (uint16_t word)
{
	uart0_outgoing.push(hex[(word>>12)&15]);
	uart0_outgoing.push(hex[(word>>8)&15]);
	uart0_outgoing.push(hex[(word>>4)&15]);
	uart0_outgoing.push(hex[word&15]);
	return *this;
}

DebugPrinter& DebugPrinter::operator << (const endl&)
{
	uart0_outgoing.push(13);
	uart0_outgoing.push(10);
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
	
	OSCCAL=0xA5;
	dbg << "Starting...\r\n";
	//test_print();
}

void loop_uart()
{
	while (!uart1_incoming.empty())
	{
		uint8_t data = uart1_incoming.pop();
		//dbg << "Received: " << data << endl();
		//dbg << data << " ";
		g_Protocol.add_byte(data);
	}
	while (!uart0_incoming.empty())
	{
		//uint8_t data = 
		uart0_incoming.pop();
		//dbg << data << endl();
	}
	while (!uart0_outgoing.empty())
		transmit0(uart0_outgoing.pop());
	//uart0_incoming.init();
}
