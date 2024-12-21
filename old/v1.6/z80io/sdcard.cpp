#define F_CPU 8000000UL
#include <avr/io.h>
#include <util/delay.h>
#include "consts.h"
#include "sdcard.h"
#include "spi.h"
#include "uart.h"

#define VERBOSE

struct Command
{
	uint8_t		cmd;
	uint32_t	arg;
	uint8_t		crc;
};

constexpr Command cmd0   = { 0x00, 0x00000000, 0x94 };
constexpr Command cmd8   = { 0x08, 0x000001AA, 0x86 };
constexpr Command cmd58  = {   58, 0x00000000, 0x00 };
constexpr Command cmd55  = {   55, 0x00000000, 0x00 };
constexpr Command acmd41 = {   41, 0x40000000, 0x00 };

#ifdef VERBOSE
void print_r1(uint8_t r1)
{
	const char* msgs[] = {
		"in idle",
		"erase reset",
		"illegal command",
		"crc error",
		"erase sequence error",
		"address error",
		"param error",
		"msb error"
	};
	if (r1==0) transmit0_text("ready");
	else
	{
		for(int i=0;i<8;++i)
		{
			if ((r1&1)!=0) transmit0_text(msgs[i]);
			r1>>=1;
		}
	}
	transmit0_eol();
}

void print_r7(const uint8_t* r7)
{
	print_r1(r7[0]);
	if (r7[0]<=1)
	{
		transmit0_text("version: ");
		transmit0_num(r7[1]);
		transmit0_eol();
		
		transmit0_text("voltage: ");
		uint8_t voltage=r7[3]&0x1F;
		if (voltage==0x01) transmit0_text("2.7-3.6V");
		else
		if (voltage==0x02) transmit0_text("low");
		else
		if (voltage==0x04 || voltage==0x08) 
			transmit0_text("reserved");
		else
			transmit0_text("unknown");
		transmit0_eol();
		
		transmit0_text("echo: ");
		transmit0_num(r7[4]);
		transmit0_eol();
	}
}
#else // VERBOSE
void print_r1(uint8_t r1) {}
void print_r7(const uint8_t* r7) {}
#endif

inline void enable_cs()
{
	PORTB &= ~SDCS;
}

inline void disable_cs()
{
	PORTB |= SDCS;
}

SDCard::SDCard()
{
}

bool SDCard::init() 
{
	init_card();
	uint8_t r1=go_idle();
	print_r1(r1);
	if (r1!=0x01) return false;
	if (!check_card_version()) return false;
	if (!wait_for_ready()) return false;
	transmit0_text("Card Ready!\r\n");
	return true;
}

bool SDCard::wait_for_ready() const
{
	uint8_t r1;
	transmit0_text("Waiting for ready\r\n");
	for(int iter=0;iter<100;++iter)
	{
		r1=command_transaction(cmd55);
		transmit0_text("cmd55 ");
		print_r1(r1);
		if (r1<2)
		{
			r1=command_transaction(acmd41);
			transmit0_text("acmd41 ");
			print_r1(r1);
			if (r1==0) return true;
		}
		//break;	
	}
	return false;
}

bool SDCard::check_card_version() const
{
	spi_transfer_byte(0xFF);
	enable_cs();
	spi_transfer_byte(0xFF);
	
	command(cmd8);
	uint8_t r7[5];
	read_res7(r7);
	print_r7(r7);

	spi_transfer_byte(0xFF);
	disable_cs();
	spi_transfer_byte(0xFF);
	return r7[0]==1 && r7[4]==0xAA;
}

void SDCard::init_card() const
{
	disable_cs();
	_delay_ms(1);
	for(int i=0;i<10;++i) spi_transfer_byte(0xFF);
	
	disable_cs();
	spi_transfer_byte(0xFF);
}

uint8_t SDCard::go_idle() const
{
	uint8_t r1=0;
	for(int i=0;i<10 && r1!=1;++i)
	{
		r1=command_transaction(cmd0);
		transmit0_text("idle r1=");
		transmit0_num(r1);
		transmit0_eol();
	}
	return r1;
}

uint8_t SDCard::read_res1() const
{
	uint8_t res1=0xFF;
	for(uint8_t iter=0;iter<8;++iter)
	{
		res1=spi_transfer_byte(0xFF);
		if (res1!=0xFF) break;
	}
	return res1;
}

bool SDCard::read_res7(uint8_t* res) const
{
	res[0]=read_res1();
	if (res[0]>1) return false;
	for(int i=1;i<=4;++i)
		res[i]=spi_transfer_byte(0xFF);
	return true;
}

void SDCard::command(const Command& c) const
{
	command(c.cmd, c.arg, c.crc);
}

uint8_t	SDCard::command_transaction(const Command& c) const
{
	spi_transfer_byte(0xFF);
	enable_cs();
	spi_transfer_byte(0xFF);

	command(c);
	uint8_t res1 = read_res1();

	spi_transfer_byte(0xFF);
	disable_cs();
	spi_transfer_byte(0xFF);
	
	return res1;
}

void SDCard::command(uint8_t cmd, uint32_t arg, uint8_t crc) const
{
	spi_transfer_byte(cmd | 0x40);
	spi_transfer_byte(uint8_t(arg >> 24));
	spi_transfer_byte(uint8_t(arg >> 16));
	spi_transfer_byte(uint8_t(arg >>  8));
	spi_transfer_byte(uint8_t(arg      ));
	spi_transfer_byte(crc | 0x01);
}

bool SDCard::read_sector(uint32_t address, uint8_t* buffer, uint8_t* token)
{
	bool rc=false;
	*token = 0xFF;
	
	spi_transfer_byte(0xFF);
	enable_cs();
	spi_transfer_byte(0xFF);

	command(17,address,0);
	uint8_t res1 = read_res1();
	if (res1 != 0xFF)
	{
		uint16_t attempts=0;
		uint8_t read=0;
		while (attempts++ < 62500)
		{
			read = spi_transfer_byte(0xFF);
			if (read!=0xFF) break;
		}
		//transmit0_text("res1 was "); transmit0_num(res1); transmit0_eol();
		if (read == 0xFE)
		{
			for(uint16_t i=0;i<512;++i)
				buffer[i]=spi_transfer_byte(0xFF);
			uint16_t crc;
			crc=spi_transfer_byte(0xFF);
			crc<<=8;
			crc|=spi_transfer_byte(0xFF);
			rc=true;
		}
		else
		{
			transmit0_text("Failed read=");
			transmit0_num(read);
			transmit0_eol();
		}
		*token = read;
	}
	else 
	{
		transmit0_text("Failed: ");
		print_r1(res1);
		transmit0_eol();
	}

	spi_transfer_byte(0xFF);
	disable_cs();
	spi_transfer_byte(0xFF);
	
	return rc;
}