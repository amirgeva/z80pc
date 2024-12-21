#define F_CPU 8000000UL
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
bool AutoClock		 = false;

bool is_auto_clock()
{
	return AutoClock;
}

uint16_t LastAddress = 0;

void setup_timer();
void stop_timer();

void start_auto_clock()
{
	if (!AutoClock)
	{
		AutoClock=true;
		
		setup_timer();
		TCCR0 = (1 << WGM01) | (1 << CS00) | (1 << COM00);
		OCR0 = 0x2;
		TCNT0 = 0;
	}
}

void clock_tick()
{
	if (AutoClock)
	{
		AutoClock=false;
		stop_timer();
		TCCR0 = 0;
	}
	__asm("nop\nnop");
	PORTB |= CLK;
	__asm("nop\nnop");
	PORTB &= ~CLK;
	__asm("nop\nnop");
}

void reset_cpu()
{
	PORTD &= ~DRESET;
	clock_tick();
	clock_tick();
	clock_tick();
	clock_tick();
	PORTD |= DRESET;
}

void deactivate(bool restart_autoclock)
{
	DDRA=0;		// Data
	PORTA=0;
	DDRC=0;		// Address high
	PORTC=0;
	DDRF=0;		// Address low
	PORTF=0;

	DDRB=CLK | MOSI | CS | SCK | SDCS;
	PORTB=CS | SDCS;
	
	DDRD=TX1 | CLEAR_WAIT | INT | DRESET;
	PORTD=TX1 | INT | DRESET;
	
	DDRE=TX;
	PORTE=TX;
	
	DDRG=BUSREQ;
	PORTG=BUSREQ;
	
	while ((PING & BUSACK)==0) 
	{
		dbg << uint8_t('.');
		clock_tick();
	}
	Active=false;
	if (restart_autoclock)
		start_auto_clock();
}

void activate()
{
	//dbg << "Activating" << endl();
	PORTG &= ~BUSREQ;
	PORTD |= CLEAR_WAIT;
	while ((PING & BUSACK)>0)
		clock_tick();
	PORTD &= ~CLEAR_WAIT;
	PORTG |= MREQ|RD|WR; // pull high
	DDRG |= MREQ|RD|WR;  // set as output
	PORTG |= MREQ|RD|WR; // inactive high
	
	DDRF = 0xFF;  // Address low output
	PORTF=0;
	DDRC = 0xFF;  // Address high output
	PORTC=0;
	DDRA = 0;     // Data bus input
	PORTA = 0;
	Active=true;
}

bool write_byte(uint16_t addr, uint8_t value)
{
	if (!Active) return false;
	PORTC=(addr>>8)&0xFF;
	PORTF=addr&0xFF;
	DDRA=0xFF;		// Data bus output
	PORTA=value;
	__asm volatile( "nop\n\t"
					"nop\n\t");
	PORTG &= ~(MREQ | WR);		// Enable RAM write
	__asm volatile( "nop\n\t"
					"nop\n\t");
	PORTG |= MREQ | WR;			// Disable RAM write
	
	DDRA=0;			// Data bus input
	PORTA=0;
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
	write_byte(0x800,0);
	write_byte(0x801,0);
	dbg << "Done\r\n";
	deactivate(false);
}

uint8_t read_byte(uint16_t addr)
{
	if (!Active) return 0xCD;
	DDRA=0;
	PORTA=0;
	PORTC=(addr>>8)&0xFF;
	PORTF=addr&0xFF;

	__asm volatile( "nop\n\t"
					"nop\n\t");

	PORTG &= ~(MREQ | RD);

	__asm volatile( "nop\n\t"
					"nop\n\t");

	uint8_t res = PINA;

	PORTG |= MREQ | RD;
	return res;
}

void send_timer_update(uint16_t counter)
{
	bool auto_clock_active=AutoClock;
	if (!Active) activate();
	write_byte(0xEC,counter&255);
	write_byte(0xED,(counter>>8)&255);
	deactivate(auto_clock_active);
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
	dbg << "Read " << address << " " << length << endl();
	uint8_t* buffer = g_Protocol.allocate_read_response(length);
	if (!Active) activate();
	for(;length>0;--length,++address,++buffer)
	{
		*buffer = read_byte(address);
		//dbg << *buffer << " ";
	}
	//dbg << "\r\nSending response\r\n";
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
	dbg << "Writing " << address << " " << length << endl();
	if (!Active) activate();
	//dbg << "Writing\r\n";
	for(uint8_t i=0; i<length; ++i,++address)
		write_byte(address, data[i+2]);
	dbg << "Done\r\n";
}

bool reading_instruction()
{
	return (PIND & M1)==0 && (PING & (MREQ | RD))==0;
}

inline uint16_t read_address()
{
	return (uint16_t(PINC) << 8) | PINF;
}

void handle_refresh(const uint8_t*, uint8_t)
{
	//dbg << "Refresh: ";
	uint8_t* buffer = g_Protocol.allocate_read_response(16);
	buffer[0]=LastAddress&255;
	buffer[1]=(LastAddress>>8)&255;
	//dbg << buffer[1] << buffer[0] << "\r\n";
	if (!Active) activate();
	for(uint8_t i=0;i<14;++i)
		buffer[i+2]=read_byte(0xF0+i);
	deactivate(false);
	g_Protocol.send_response();
}

void handle_single_step(const uint8_t*, uint8_t)
{
	if (Active) deactivate(false);
	PORTD |= CLEAR_WAIT;
	uint8_t* buffer = g_Protocol.allocate_read_response(16);
	for(uint8_t i=0;i<16;++i)
		buffer[i]=i;
	uint16_t address=read_address();
	if (SingleEnabled && address>=0x100)
	{
		dbg << "EStep\r\n";
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
					deactivate(false);
				}
				if (address>=0x100) break;
			}
			clock_tick();
		}
		LastAddress=address;
	}
	else
	{
		dbg << "Step\r\n";
		while (reading_instruction())
			clock_tick();
		while (!reading_instruction())
			clock_tick();
	}
	buffer[0]=PINF;
	buffer[1]=PINC;
	LastAddress=(uint16_t(buffer[1])<<8)|buffer[0];
	g_Protocol.send_response();
	PORTD &= ~CLEAR_WAIT;
}

void handle_interrupt(const uint8_t*, uint8_t)
{
	dbg << "INT\r\n";
	if (Active) deactivate(false);
	PORTD &= ~INT;
	for(uint8_t i=0;i<255;++i)
	{
		clock_tick();
		if (reading_instruction() && read_address()<0x100) break;
	}
	PORTD |= INT;
}

void handle_enhanced_single_step(const uint8_t* data, uint8_t length)
{
	if (length>0)
	{
		dbg << "ENHANCE\r\n";
		SingleEnabled=(data[0]>0);
	}
}

void handle_input(const uint8_t* data, uint8_t length)
{
	bool auto_clock_active = AutoClock;
	if (!Active) activate();
	uint8_t offset = read_byte(0xEE);
	uint16_t buffer_address = 0x100;
	for(;length>0;--length,++data,++offset)
	{
		write_byte(buffer_address + offset, *data);
	}
	write_byte(0xEE,offset);
	deactivate(auto_clock_active);
}

void handle_dreset(const uint8_t* data, uint8_t length)
{
	reset_cpu();
}

void handle_autoclock(const uint8_t* data, uint8_t length)
{
	start_auto_clock();
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
	g_Protocol.register_handler(7,handle_dreset);
	g_Protocol.register_handler(8,handle_autoclock);
	reset_cpu();
}
