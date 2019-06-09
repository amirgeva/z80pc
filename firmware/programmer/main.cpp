/*
 * programmer.cpp
 *
 * Created: 07-Jun-19 8:26:10 AM
 * Author : amir
 */ 

#define F_CPU 8000000UL
#define BAUD 115200
#define BRC ((F_CPU/16/BAUD)-1)

#include <avr/io.h>
#include <util/delay.h>

#include <avr/interrupt.h>
#include <cyclic.h>
#include <message.h>

CyclicBuffer Serial;

void byte2text_bin(uint8_t b, byte* text)
{
	for(uint8_t i=0;i<8;++i)
	{
		uint8_t mask=(1 << (7-i));
		*text++ = ((b&mask)==mask ? '1' : '0');
	}
}

void byte2text(uint8_t b, byte* text)
{
	const byte* hex = (const byte*)"0123456789ABCDEF";
	text[0]=hex[b>>4];
	text[1]=hex[b&15];
}

bool write_serial(uint8_t c)
{
	if ( !( UCSRA & (1<<UDRE)) ) return false;
	UDR=c;
	return true;
}

void write_serial_block(const byte* buffer, byte len)
{
	while (len>0)
	{
		while (!write_serial(*buffer));
		++buffer;
		--len;
	}
}

Message outgoing,incoming;
int in_pos=0;

void read_data(uint16_t addr, uint8_t len, uint8_t* data)
{
	DDRB=0;
	_delay_us(1);
	for(uint8_t i=0;i<len;++i)
	{
		PORTA=uint8_t(addr>>8);
		PORTC=uint8_t(addr&0xFF);
		PORTD&=0xEB;
		_delay_us(1);
		data[i]=PINB;
		PORTD|=0x14;
		if (++addr == 0) break;
	}
}

void program_data(uint16_t addr, uint8_t len, uint8_t* data)
{
	DDRB=0xFF;
	_delay_us(1);
	for(uint8_t i=0;i<len;++i)
	{
		PORTA=uint8_t(addr>>8);
		PORTC=uint8_t(addr&0xFF);
		PORTB=data[i];
		PORTD&=0xE7;
		_delay_us(1);
		PORTD|=0x18;
		if (++addr == 0) break;
	}
}

void parse_incoming()
{
	if (incoming.verify_crc())
	{
		uint16_t addr=(uint16_t(incoming.payload.addr_high)<<8) | incoming.payload.addr_low;
		byte len=incoming.payload.len;
		if (len>54) len=54;
		if (incoming.payload.cmd == 1)
		{
			program_data(addr,len,incoming.payload.data);
		}
		if (incoming.payload.cmd == 2)
		{
			outgoing=incoming;
			outgoing.payload.len=len;
			read_data(addr,len,outgoing.payload.data);
			outgoing.send();
		}
	}
}

void handle_incoming()
{
	uint8_t* in_ptr=incoming.header;
	if (!Serial.empty())
	{
		byte b=Serial.pop();
		in_ptr[in_pos++]=b;
		if (in_pos<=4 && !incoming.valid_header(in_pos))
		in_pos=0;
		if (in_pos==64)
		{
			parse_incoming();
			in_pos=0;
		}
	}
}
/*
uint8_t read_ram(uint16_t addr)
{
	PORTB=0xFF;
	DDRB=0;
	PORTA=uint8_t(addr>>8);
	PORTC=uint8_t(addr&0xFF);
	PORTD&=0xEB;
	_delay_us(1000);
	PORTB=0xFF;
	_delay_us(1000);
	uint8_t val=PINB;
	_delay_us(1000);
	PORTD|=0x14;
	DDRB=0xFF;
	_delay_us(1000);
	return val;
}

void write_ram(uint16_t addr, uint8_t data)
{
	DDRB=0xFF;
	_delay_us(1000);
	PORTA=uint8_t(addr>>8);
	PORTC=uint8_t(addr&0xFF);
	PORTB=data;
	_delay_us(1000);
	PORTD&=0xE7;
	_delay_us(1000);
	PORTD|=0x18;
	_delay_us(1000);
}

void test_ram()
{
	byte msg[16];
	msg[13]=13;
	msg[14]=10;
	msg[15]=0;
	uint8_t b=0;
	bool do_write=true;
	uint16_t addr=0;
	while (1)
	{
		if (do_write)
		{
			write_ram(addr,b);
			b=b+1;
		}
		else 
			b=read_ram(addr);
		byte2text(addr>>8,msg);
		byte2text(addr&0xFF,msg+2);
		msg[4]=32;
		byte2text_bin(b,msg+5);
		write_serial_block(msg,15);
		_delay_ms(200);
		addr=(addr+1)&0xFF;
		if (addr==0)
			do_write=false;
	}
	DDRB=0xFF;
}
*/
		
int main(void)
{
	MCUCSR = (1<<JTD);
	MCUCSR = (1<<JTD);
	DDRA=0xFF;
	DDRC=0xFF;
	DDRB=0xFF;
	DDRD=0xDE;
	PORTD=0x7F;

	OSCCAL=0x96;
	UBRRH = (BRC >> 8);
	UBRRL = BRC;
	UCSRB = (1 << TXEN) | (1 << RXEN) | (1 << RXCIE);
	UCSRC = (1 << URSEL) | (1 << UCSZ0) | (1 << UCSZ1);

	
	sei();
    while (1) 
    {
		handle_incoming();
		//test_ram();
    }
}


ISR(USART_RXC_vect)
{
	Serial.push(UDR);
}


/*
int main()
{
	DDRA=0xFF;
	DDRC=0xFF;
	DDRB=0xFF;
	DDRD=0xFF;
	MCUCSR = (1<<JTD);
	MCUCSR = (1<<JTD);
	OSCCAL=0x96;
	uint8_t b=0;
	while (1)
	{
		PORTA=b;
		PORTC=b;
		PORTD=b;
		PORTB=b++;
		_delay_ms(200);
	}
}
*/
