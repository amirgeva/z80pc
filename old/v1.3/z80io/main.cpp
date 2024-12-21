#include <avr/io.h>
#include <avr/interrupt.h>
#include "queue.h"
#include "crc16.h"

/*
		PA - data
		
		PD0 - Rx
		PD1 - Tx
		PD2 - IORQ
		PD3 - WAIT
		
		PC0 - SCL
		PC1 - SDA
		PC2 - INT
		PC3 - BUSACK
		PC4 - BUSREQ
		PC5 - CLEAR_WAIT
		PC6 - LE
		PC7 - OE

		PB4 - CS
		PB5 - MOSI
		PB6 - MISO
		PB7 - SCK
*/

const int 		SCL			= 0x01;
const int 		SDA			= 0x02;
const int 		INT			= 0x04;
const int 		BUSACK		= 0x08;
const int 		BUSREQ		= 0x10;
const int 		CLEAR_WAIT	= 0x20;
const int 		LE			= 0x40;
const int 		OE			= 0x80;

const int 		CS			= 0x10;
const int 		MOSI		= 0x20;
const int 		MISO		= 0x40;
const int 		SCK			= 0x80;

const int 		IORQ		= 0x04;
const int 		WAIT		= 0x08;

#define dsendmsg(x)

Queue<256> in_queue; // Queue of data going to the CPU
Queue<1024> out_queue; // Queue to data coming from the CPU
volatile uint8_t incoming_in_progress=0;
volatile uint8_t outgoing_in_progress=0;

ISR(USART_RXC_vect)
{
	//queue_push(&in_queue,UDR);
	in_queue.push(UDR);
}

// Triggered when IORQ goes high
// This indicates that the IO instruction is done
ISR(INT0_vect)
{
	if (outgoing_in_progress)
	{
		outgoing_in_progress = 0;
		PORTC &= ~CLEAR_WAIT; // Disable CLEAR_WAIT (low)
	}
}

// Triggered when WAIT goes low
// this indicates that an OUT instruction has
// written a byte of data
ISR(INT1_vect)
{
	uint8_t outgoing_byte = PINA;
	outgoing_in_progress=1;
	//queue_push(&out_queue, outgoing_byte);
	out_queue.push(outgoing_byte);
	PORTC |= CLEAR_WAIT; // Enable CLEAR_WAIT (high)
}

// Triggered when OE goes low,
// indicating the CPU is reading the latch.
// This means that the IO input injection is complete
ISR(INT2_vect)
{
	incoming_in_progress=0;
}

ISR(TIMER0_COMP_vect)
{
	in_queue.push(0);
}

inline int tx_ready()
{
	return (UCSRA & (1 << UDRE)) != 0;
}

inline int rx_ready()
{
	return (UCSRA & (1 << RXC)) != 0;
}

inline void uart_transmit_char(uint8_t data)
{
	while (!tx_ready());
	UDR = data;
}

void sendmsg(const char* msg)
{
	const uint8_t* umsg=(const uint8_t*)msg;
	for(;*umsg;++umsg)
		uart_transmit_char(*umsg);
}

void  print(const char* msg)
{
	sendmsg(msg);
}

const char* hex="0123456789ABCDEF";

void printn(int n)
{
	char text[3];
	text[0]=hex[(n>>4)&15];
	text[1]=hex[(n)&15];
	text[2]=0;
	print(text);
}

void spi_init()
{
	DDRB = 0xB0;
	PORTB = 0xB0;
	SPCR = (1<<SPE)|(1<<MSTR)|(1<<SPR0);
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



void inject_data(uint8_t data)
{
	incoming_in_progress = 1;
	dsendmsg("Request BUSREQ\r\n");
	// Set BUSREQ to output
	DDRC |= BUSREQ;
	// BUSREQ = LOW
	PORTC &= ~BUSREQ;
	dsendmsg("Wait BUSACK\r\n");
	// Wait for BUSACK low
	while ((PINC&0x08) > 0);
	
	dsendmsg("Setting data\r\n");
	// We have the bus, fill the latch
	// First, set PA to output
	DDRA=0xFF;
	// Set the data bits
	PORTA=0xFF;
	PORTA = data;
	
	dsendmsg("Setting latch\r\n");
	// The following toggle will make LE high for at least 125nS (at 8MHz)
	// This is enough for the latch
	PORTC |= LE;
	PORTC &= ~LE;
	
	dsendmsg("Reset data\r\n");
	// Set data pins to input, pull up
	DDRA=0;
	PORTA=0;
	
	dsendmsg("disable BUSREQ\r\n");
	// Disable BUSREQ (pull up)
	PORTC |= BUSREQ;
	// Wait for BUSACK to go high
	while ((PINC&BUSACK) == 0);
	dsendmsg("BUSACK high\r\n");
	// Set BUSREQ to input
	DDRC &= ~BUSREQ;
	
	dsendmsg("Triggering interrupt\r\n");
	// Set INT to active (low)
	PORTC &= ~INT;
	// Wait for IORQ=0 & WAIT=1, indicating interrupt is being handled
	//while ((PIND & (IORQ | WAIT)) != IORQ);
	while (incoming_in_progress);
	// Set INT to inactive (high)
	PORTC |= INT;
	dsendmsg("Inject done\r\n");
}

int main(void)
{
	// Data input
	DDRA=0;
	PORTA=0;
	
	// CS, MOSI, SCK outputs
	// MISO input
	DDRB=0;
	PORTB=0;
	DDRB = CS | MOSI | SCK;
	PORTB = CS | MOSI | SCK;
	SPCR = (1<<SPE)|(1<<MSTR)|(1<<SPR0);
	
	DDRC=0;
	PORTC=0;
	// Inputs: SCL, SDA, BUSACK, OE, BUSREQ
	// Outputs: INT, CLEAR_WAIT, LE
	DDRC = INT | CLEAR_WAIT | LE;
	//DDRC=0;
	
	// All outputs inactive (INT active LOW,  CLEAR, LE active high)
	PORTC=INT | CLEAR_WAIT | LE;
	PORTC=INT;
	
	// Rx input, Tx output, WAIT & IORQ input
	DDRD=0x2;
	// Rx, WAIT, IORQ  pull up
	// Tx set to high
	//PORTD=0xF;
	PORTD=0x2;
	
	//queue_init(&in_queue);
	//queue_init(&out_queue);
	in_queue.init();
	out_queue.init();
	
	UBRRL = 51;
	UBRRH = 0;
	UCSRB = (1<<RXEN) | (1<<TXEN) | (1 << RXCIE);
	UCSRC = (1<<URSEL) | (3<<UCSZ0);

	// Prescalar 1/1024
	TCCR0 = (1<<CS02)|(1<<CS00);
	// Full 8 bit count
	OCR0 = 255;
	// Enable match interrupt
	TIMSK |= (1<<OCIE0);
	
	// Set INT1 falling edge, INT0 rising edge
	MCUCR = (1<<ISC11)| (1<<ISC01) | (1<<ISC00);
	// Set INT2 to falling edge
	MCUCSR &= ~(1 << ISC2);
	// Enable INT0, INT1, INT2
	GICR = 0xE0;

	uint8_t byte;
	sendmsg("Starting\n");
	
	// Enable interrupts
	sei();
	uint8_t spi_tx[32],spi_rx[32];
	for(uint8_t i=0;i<32;++i)
		spi_tx[i]=128-i;
	uint8_t tx_pos=1;
    while(1)
    {
		// If there is data pending to go out
		// on the UART, send it
		while (tx_pos < 30 && !out_queue.empty())
		{
			uint8_t data = out_queue.pop();
			spi_tx[tx_pos++] = data;
		}

		if (PINC & SDA)
		{
			if (tx_pos > 1 )
			{
				spi_tx[0]=tx_pos-1;
				uint16_t crc=calculate_crc16(spi_tx, 30);
				spi_tx[30]=crc&0xFF;
				spi_tx[31]=(crc>>8)&0xFF;
				spi_transaction(spi_tx, spi_rx, 32);
				tx_pos=1;
			}
		}
		// If there is data pending to go to
		// the CPU, inject it via interrupt
		if (incoming_in_progress == 0 && !in_queue.empty())
		{
			byte = in_queue.pop();
			inject_data(byte);
		}
		/*
		if (incoming_in_progress == 0 &&
			queue_empty(&in_queue) == 0)
		{
			byte = queue_pop(&in_queue);
			inject_data(byte);
		}
		*/
    }
	return 0;
}
