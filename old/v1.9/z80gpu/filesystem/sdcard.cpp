// #define F_CPU 8000000UL
// #include <avr/io.h>
// #include <util/delay.h>
// #include "consts.h"
#include "sdcard.h"
#include "platform_utils.h"
// #include "spi.h"
// #include "uart.h"
#include <cstdint>
#include "dbg.h"

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
	if (r1==0) debug_print("ready");
	else
	{
		for(int i=0;i<8;++i)
		{
			if ((r1&1)!=0) debug_print(msgs[i]);
			r1>>=1;
		}
	}
	debug_print("\n");
}

void print_r7(const uint8_t* r7)
{
	print_r1(r7[0]);
	if (r7[0]<=1)
	{
		debug_print("version: ");
		debug_print(r7[1], true);
		
		debug_print("voltage: ");
		uint8_t voltage=r7[3]&0x1F;
		if (voltage==0x01) debug_print("2.7-3.6V");
		else
		if (voltage==0x02) debug_print("low");
		else
		if (voltage==0x04 || voltage==0x08) 
			debug_print("reserved");
		else
			debug_print("unknown");
		debug_print("\n");
		
		debug_print("echo: ");
		debug_print(r7[4],true);
	}
}
#else // VERBOSE
void print_r1(uint8_t r1) {}
void print_r7(const uint8_t* r7) {}
#endif

SDCard::SDCard()
: _spi(nullptr)
{
}

bool SDCard::init(ispi::SPI* s)
{
	_spi=s;
	init_card();
	uint8_t r1=go_idle();
	print_r1(r1);
	if (r1!=0x01) return false;
	if (!check_card_version()) return false;
	if (!wait_for_ready()) return false;
	debug_print("Card Ready!\r\n");
	return true;
}

bool SDCard::wait_for_ready() const
{
	uint8_t r1;
	debug_print("Waiting for ready\r\n");
	for(int iter=0;iter<100;++iter)
	{
		r1=command_transaction(cmd55);
		debug_print("cmd55 ");
		print_r1(r1);
		if (r1<2)
		{
			r1=command_transaction(acmd41);
			debug_print("acmd41 ");
			print_r1(r1);
			if (r1==0) return true;
		}
		//break;	
	}
	return false;
}

bool SDCard::check_card_version() const
{
	_spi->transfer(0xFF);
	delay_ms(1);
	_spi->start();
	//_spi->transfer(0xFF);
	
	command(cmd8);
	uint8_t r7[5];
	if (!read_res7(r7))
		debug_print("Failed to read r7");
	else
		print_r7(r7);

	//_spi->transfer(0xFF);
	_spi->stop();
	_spi->transfer(0xFF);
	return r7[0]==1 && r7[4]==0xAA;
}

void SDCard::init_card() const
{
	_spi->stop();
	delay_ms(1);
	const uint8_t blanks[] = { 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF };
	_spi->transfer(blanks, sizeof(blanks));
}

uint8_t SDCard::go_idle() const
{
	uint8_t r1=0;
	for(int i=0;i<10 && r1!=1;++i)
	{
		r1=command_transaction(cmd0);
		debug_print("idle r1=");
		debug_print(r1,true);
	}
	return r1;
}

uint8_t SDCard::read_res1() const
{
	uint8_t res1=0xFF;
	for(uint8_t iter=0;iter<8;++iter)
	{
		res1=_spi->transfer(0xFF);
		if ((res1&0x80)==0) break;
	}
	return res1;
}

bool SDCard::read_res7(uint8_t* res) const
{
	res[0]=read_res1();
	if (res[0]>1) return false;
	for(int i=1;i<=4;++i)
		res[i]=_spi->transfer(0xFF);
	return true;
}

void SDCard::command(const Command& c) const
{
	command(c.cmd, c.arg, c.crc);
}

uint8_t	SDCard::command_transaction(const Command& c) const
{
	_spi->transfer(0xFF);
	delay_ms(1);
	_spi->start();
	/*
	for(uint32_t i=0;i<300;++i)
	{
		if (_spi->transfer(0xFF)==0xFF) break;
		delay_ms(1);
	}
	*/
	command(c);
	uint8_t res1 = read_res1();

	_spi->stop();
	delay_ms(1);
	_spi->transfer(0xFF);
	
	return res1;
}

void SDCard::command(uint8_t cmd, uint32_t arg, uint8_t crc) const
{
	_spi->transfer(cmd | 0x40);
	_spi->transfer(uint8_t(arg >> 24));
	_spi->transfer(uint8_t(arg >> 16));
	_spi->transfer(uint8_t(arg >>  8));
	_spi->transfer(uint8_t(arg      ));
	_spi->transfer(crc | 0x01);
}

bool SDCard::read_sector(uint32_t address, uint8_t* buffer, uint8_t* token)
{
	bool rc=false;
	*token = 0xFF;
	
	_spi->transfer(0xFF);
	_spi->start();
	_spi->transfer(0xFF);

	command(17,address,0);
	uint8_t res1 = read_res1();
	if (res1 != 0xFF)
	{
		uint16_t attempts=0;
		uint8_t read=0;
		while (attempts++ < 62500)
		{
			read = _spi->transfer(0xFF);
			if (read!=0xFF) break;
		}
		//debug_print("res1 was "); debug_print(res1); debug_print("\n");
		if (read == 0xFE)
		{
			for(uint16_t i=0;i<512;++i)
				buffer[i]=_spi->transfer(0xFF);
			uint16_t crc;
			crc=_spi->transfer(0xFF);
			crc<<=8;
			crc|=_spi->transfer(0xFF);
			rc=true;
		}
		else
		{
			debug_print("Failed read=");
			debug_print(read,true);
		}
		*token = read;
	}
	else 
	{
		debug_print("Failed: ");
		print_r1(res1);
		debug_print("\n");
	}

	_spi->transfer(0xFF);
	_spi->stop();
	_spi->transfer(0xFF);
	
	return rc;
}