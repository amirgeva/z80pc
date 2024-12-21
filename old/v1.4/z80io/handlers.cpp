#include <avr/io.h>
#include <avr/interrupt.h>
#include <avr/pgmspace.h>
#include "uart.h"
#include "protocol.h"
#include "consts.h"


const uint8_t OS[] PROGMEM = {
	#include "os.inl"
};

bool Active          = false;
bool DebugMode       = false;
bool SingleEnabled   = false;
uint16_t LastAddress = 0;

void clock_tick()
{
	__asm("nop\nnop");
	PORTB |= CLK;
	__asm("nop\nnop");
	PORTB &= ~CLK;
	__asm("nop\nnop");
}

void deactivate()
{
	DDRA=0;
	PORTA=0;
	DDRB=CLK | MOSI | CS | SCK;
	PORTB=CS;
	DDRC=0;
	PORTC=0;
	DDRD=TX1 | CLEAR_WAIT | BUSREQ | INT;
	PORTD=TX1 | BUSREQ | INT;
	DDRE=TX;
	PORTE=TX;
	DDRF=0;
	PORTF=0;
	DDRG=0;
	PORTG=0;
	while ((PINE & BUSACK)==0) clock_tick();
	Active=false;
}

void activate()
{
	dbg << "Activating" << endl();
	PORTD &= ~BUSREQ;
	while ((PINE & BUSACK)>0)
		clock_tick();
	PORTD |= MREQ|RD|WR;
	DDRD |= MREQ|RD|WR;
	PORTD |= MREQ|RD|WR;
	
	DDRA = 0xFF;
	PORTA=0;
	DDRC = 0xFF;
	PORTC=0;
	DDRF = 0;
	PORTF = 0;
	Active=true;
}

bool write_byte(uint16_t addr, uint8_t value)
{
	if (!Active) return false;
	PORTA=(addr>>8)&0xFF;
	PORTC=addr&0xFF;
	DDRF=0xFF;
	PORTF=value;
	__asm volatile( "nop\n\t"
					"nop\n\t");
	PORTD &= ~(MREQ | WR);
	__asm volatile( "nop\n\t"
					"nop\n\t");
	PORTD |= MREQ | WR;
	
	DDRF=0;
	PORTF=0;
	return true;
}

void upload_os()
{
	activate();
	dbg << "Uploading OS: ";
	uint16_t n = sizeof(OS);
	for(uint16_t i=0;i<n;++i)
	{
		uint8_t data = pgm_read_byte_near(OS+i);
		write_byte(i, data);
	}
	dbg << "Done\r\n";
	deactivate();
}

uint8_t read_byte(uint16_t addr)
{
	if (!Active) return 0xCD;
	DDRF=0;
	PORTF=0;
	PORTA=(addr>>8)&0xFF;
	PORTC=addr&0xFF;

	__asm volatile( "nop\n\t"
					"nop\n\t");

	PORTD &= ~(MREQ | RD);

	__asm volatile( "nop\n\t"
					"nop\n\t");

	uint8_t res = PINF;

	PORTD |= MREQ | RD;
	return res;
}

void handle_read_message(const uint8_t* data, uint8_t length)
{
	if (length != 3) 
	{
		dbg << "Invalid read message\r\n";
		return; // Need address, and byte count
	}
	uint16_t address = data[0] | (uint16_t(data[1]) << 8);
	length = data[2];
	if (length > 250)
	{
		dbg << "Read too many bytes\r\n";
		return; // Too many bytes
	}
	dbg << "Read from: " << address << "  len=" << length << endl();
	uint8_t* buffer = g_Protocol.allocate_read_response(length);
	if (!Active) activate();
	dbg << "Start to read\r\n";
	for(;length>0;--length,++address,++buffer)
	{
		*buffer = read_byte(address);
		dbg << *buffer << " ";
	}
	dbg << "\r\nSending response\r\n";
	g_Protocol.send_response();
	dbg << "Done\r\n";
}

void handle_write_message(const uint8_t* data, uint8_t length)
{
	if (length < 2)
	{
		dbg << "Invalid write message\r\n";
		return; // Need at least address
	}
	uint16_t address = data[0] | (uint16_t(data[1]) << 8);
	length-=2;
	dbg << "Writing data: " << address << " length=" << length << endl();
	if (!Active) activate();
	dbg << "Writing\r\n";
	for(uint8_t i=0; i<length; ++i,++address)
		write_byte(address, data[i+2]);
	dbg << "Done\r\n";
}

bool reading_instruction()
{
	return (PINB & M1)==0 && (PIND & (MREQ | RD))==0;
}

inline uint16_t read_address()
{
	return (uint16_t(PINA) << 8) | PINC;
}

void handle_refresh(const uint8_t*, uint8_t)
{
	uint8_t* buffer = g_Protocol.allocate_read_response(16);
	buffer[0]=LastAddress&255;
	buffer[1]=(LastAddress>>8)&255;
	if (!Active) activate();
	for(uint8_t i=0;i<14;++i)
		buffer[i+2]=read_byte(0xF0+i);
	deactivate();
	g_Protocol.send_response();
}

void handle_single_step(const uint8_t*, uint8_t)
{
	if (Active) deactivate();
	uint8_t* buffer = g_Protocol.allocate_read_response(16);
	for(uint8_t i=0;i<16;++i)
		buffer[i]=i;
	uint16_t address=read_address();
	if (SingleEnabled && address>=0x100)
	{
		PORTD &= ~INT;
		while (true)
		{
			if (reading_instruction() && read_address()<0x100) break;
			clock_tick();
		}
		PORTD |= INT;
		while (true)
		{
			if (reading_instruction())
			{
				address=read_address();
				if (address == 0x55) // Just before interrupt end
				{
					activate();
					for(uint8_t i=0;i<14;++i)
						buffer[i+2]=read_byte(0xF0+i);
					deactivate();
				}
				if (address>=0x100) break;
			}
			clock_tick();
		}
		LastAddress=address;
	}
	else
	{
		while (reading_instruction())
		clock_tick();
		while (!reading_instruction())
		clock_tick();
	}
	buffer[0]=PINC;
	buffer[1]=PINA;
	LastAddress=(uint16_t(buffer[1])<<8)|buffer[0];
	g_Protocol.send_response();
	//uint16_t address = 
}

void handle_interrupt(const uint8_t*, uint8_t)
{
	if (Active) deactivate();
	PORTD &= ~INT;
	for(uint8_t i=0;i<8;++i) clock_tick();
	PORTD |= INT;
}

void handle_enhanced_single_step(const uint8_t* data, uint8_t length)
{
	if (length>0)
	{
		SingleEnabled=(data[0]>0);
	}
}

void handle_input(const uint8_t* data, uint8_t length)
{
	if (!Active) activate();
	uint8_t offset = read_byte(0xF0);
	uint16_t buffer_address = 0x100;
	for(;length>0;--length,++data,++offset)
	{
		write_byte(buffer_address + offset, *data);
	}
	write_byte(0xF0,offset);
	deactivate();
}


void setup_handlers()
{
	g_Protocol.register_handler(0,handle_read_message);
	g_Protocol.register_handler(1,handle_write_message);
	g_Protocol.register_handler(2,handle_single_step);
	g_Protocol.register_handler(3,handle_interrupt);
	g_Protocol.register_handler(4,handle_enhanced_single_step);
	g_Protocol.register_handler(5,handle_refresh);
	g_Protocol.register_handler(6,handle_input);
}