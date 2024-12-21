#include <avr/io.h>
#include <avr/interrupt.h>
#include <string.h>
#include "queue.h"

const char* hex="0123456789ABCDEF";
char msg[64];

Queue in_queue;
Queue out_queue;
volatile uint8_t incoming_in_progress=0;
volatile uint8_t outgoing_in_progress=0;

inline int tx_ready()
{
	return (UCSR0A & (1 << UDRE0)) != 0;
}

inline int rx_ready()
{
	return (UCSR0A & (1 << RXC0)) != 0;
}

inline void send_char(uint8_t data)
{
	while (!tx_ready());
	UCSR0B &= ~(1<<TXB80);
	if ( data & 0x0100 )
	UCSR0B |= (1<<TXB80);
	UDR0 = data;
}

void sendmsg(const char* text)
{
	const char* ptr=text;
	for(int i=0;i<64 && *ptr;++i, ++ptr)
	{
		send_char(*ptr);
	}
}


ISR(INT0_vect)
{
	uint8_t incoming_byte = (PINC & 0x3F) | (PINB << 6);
	incoming_in_progress=1;
	queue_push(&in_queue, incoming_byte);
	PORTD |= 0x20; // Enable CLEAR_WAIT
}

ISR(INT1_vect)
{
	if (incoming_in_progress)
	{
		PORTD &= ~0x20; // Disable CLEAR_WAIT
	}
	else
	{
		outgoing_in_progress=0;
	}
}

ISR(USART_RX_vect)
{
	queue_push(&out_queue,UDR0);
}

void inject_byte(uint8_t byte)
{
	// Request access to bus  BUSREQ=0
	sendmsg("Request BUSREQ\r\n");
	DDRD |= 0x40; // Set BUSREQ to output
	PORTD &= ~0x40;
	// Wait for BUSACK to go low
	sendmsg("Wait BUSACK\r\n");
	while ((PIND&0x80)>0);
	
	sendmsg("Setting data\r\n");
	// Set data pins to output
	DDRC=0x3F;
	DDRB=0x43;
	
	// Clear data bits
	PORTC &= 0xC0;
	PORTB &= 0xFC;
	// Set data bits
	PORTC |= (byte & 0x3F);
	PORTB |= ((byte >> 6)&3);

	sendmsg("Setting latch\r\n");
	
	// The following toggle will make LE high for at least 125nS (at 8MHz)
	// This is enough for the latch
	PORTD |= 0x10; // Set LE=1 - Load 74573 latch
	PORTD &= ~0x10;// Set LE=0
	
	sendmsg("Reset data\r\n");
	// Reset data pins to input
	DDRC=0;
	DDRB=0x40;
	
	sendmsg("disable BUSREQ\r\n");
	// Disable BUSREQ
	PORTD |= 0x40;
	DDRD &= ~0x40;
	// Wait for BUSACK to go high
	while ((PIND&0x80)==0);
	sendmsg("BUSACK high\r\n");
	
	PORTB &= ~0x40; // Trigger an interrupt  INT=0
	// Wait for IORQ=0 & WAIT=1, indicating interrupt is being handled
	sendmsg("Triggered interrupt\r\n");
	while ((PIND&0x0C)!=4);
	PORTB |= 0x40; // Disable INT pins
	sendmsg("Inject done\r\n");
}

int main(void)
{
	uint8_t byte;
	DDRB = 0x40; // Output INT
	PORTB = 0x40;
	DDRD = 0x31; // Outputs  TX, LE, CLEAR
	PORTD = 0x01; // BUSREQ=1 TX=1,  LE=0, CLEAR=0
	DDRC = 0;
	UBRR0L = 0;
	UBRR0H = 0;
	
	// Enable Tx / Rx, and enable receive interrupt
	UCSR0B = (1 << RXEN0) | (1 << TXEN0) | (1 << RXCIE0);
	
	// This value is specific for the instance of the chip used.
	// Calibration was performed to find this value
	OSCCAL = 0xB0;
	
	// Configure external interrupts for receiving processor OUT instructions
	EICRA = 0x0E; // Falling edge for INT0, Rising for INT1
	EIMSK = 3; // Enable INT0, INT1
	
	queue_init(&in_queue);
	queue_init(&out_queue);
	
	// Enable interrupts
	sei();

    while(1)
    {
		// Send OUT bytes through the UART
		if (queue_empty(&in_queue) == 0)
		{
			byte = queue_pop(&in_queue);
			send_char(byte);
		}
		
		// Check for incoming UART data
		if (queue_empty(&out_queue) == 0)
		{
			byte = queue_pop(&out_queue);
			inject_byte(byte);
		}
    }
	return 0;
}

