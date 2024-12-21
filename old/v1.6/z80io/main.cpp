#define F_CPU 8000000UL
#include <avr/io.h>
#include <avr/interrupt.h>
#include <avr/pgmspace.h>
#include <util/delay.h>
#include "uart.h"
#include "protocol.h"
#include "queue.h"
#include "consts.h"
#include "ram.h"
#include "spi.h"
#include "crc16.h"
#include "filesys.h"

struct Header
{
	uint16_t magic, length, crc;
};

static_assert (sizeof(Header) == 6, "Header size incorrect");
constexpr uint16_t GPU_BUFFER_SIZE=1024;
//uint8_t disk_buffer[512];

//Queue<256> gpu_queue;
struct GPUBuffer
{
	union {
		uint8_t data[GPU_BUFFER_SIZE + sizeof(Header)];
		Header  header;
	} buffer;
	
	GPUBuffer()
	{
		buffer.header.magic = 0xDA7A;
		clear();
	}
	
	void clear()
	{
		buffer.header.length=0;
	}
	
	uint16_t size() const
	{
		return sizeof(Header) + buffer.header.length;
	}
	
	void add(uint8_t data)
	{
		buffer.data[sizeof(Header)+buffer.header.length++] = data;
	}
	
	uint8_t& operator[] (uint16_t index)
	{
		return buffer.data[sizeof(Header)+index];
	}
	
	const uint8_t* payload() const
	{
		return &buffer.data[sizeof(Header)];
	}
	
	void calculate_crc()
	{
		buffer.header.crc = calculate_crc16(payload(),buffer.header.length);
	}
	
	void send()
	{
		//dbg << "Waiting for GPU\r\n";
		while ((PINE & SCS)!=0); // wait for gpu to be ready
		gpu_spi_transaction(buffer.data, nullptr, size());
		clear();
	}
} gpu_buffer;


constexpr uint8_t GPU_DEVICE=0;
constexpr uint8_t DISK_DEVICE=1;

volatile bool device_in_progress=false;
volatile uint8_t device=0;

//void setup_handlers();
//void deactivate();


/*
ISR(INT5_vect)
{
	if (gpu_out_in_progress)
	{
		gpu_out_in_progress=false;
		PORTD &= ~CLEAR_WAIT;
	}
}
*/

ISR(INT0_vect)
{
	device_in_progress=true;
	device=PINA;
	//uint8_t data = PINA;
	//gpu_queue.push(data);
	//gpu_out_in_progress=true;
	//PORTD |= CLEAR_WAIT;
}

void setup_interrupts()
{
	// INT0 - WAIT
	// INT5 - IORQ
	
	// Falling edge of INT0
	EICRA = (1 << ISC01); 
	// Rising edge for INT5
	//EICRB = (1 << ISC51) | (1 << ISC50);
	// Enable both
	EIMSK = (1 << INT0);// | (1 << INT5);
}

void loop_timer();

void gpu_transaction()
{
	bool restart_auto_clock = is_auto_clock();
	// busreq
	activate();
	
	// read data
	uint16_t len=read_byte(0x0C01);
	len <<= 8;
	len |= read_byte(0x0C00);
	dbg << "GPU Block " << len << "\r\n";
	if (len > GPU_BUFFER_SIZE) len=GPU_BUFFER_SIZE;
	uint16_t addr=0xC02;
	for(uint16_t i=0;i<len;++i,++addr)
	{
		gpu_buffer[i]=read_byte(addr);
		dbg << gpu_buffer[i];
	}
	dbg << "\r\n";
	gpu_buffer.buffer.header.length = len;
	write_byte(0xC00,0);
	write_byte(0xC01,0);
	
	device_in_progress=false;
	// clear BUSREQ
	deactivate(restart_auto_clock);
	
	// send SPI transaction
	gpu_buffer.calculate_crc();
	gpu_buffer.send();
	dbg << "Transaction complete\r\n";
}

DiskTransaction dt;

void disk_transaction()
{
	bool restart_auto_clock = is_auto_clock();
	// busreq
	activate();

	uint8_t* ptr=reinterpret_cast<uint8_t*>(&dt);
	uint16_t addr=0xC00;
	for(uint16_t i=0;i<sizeof(DiskTransaction);++i)
		*ptr++ = read_byte(addr++);
	switch (dt.command_and_result)
	{
		case DiskTransaction::INIT:
			dt.command_and_result = FileSystem::init() ? DiskTransaction::OK : DiskTransaction::FAILED; break;
		case DiskTransaction::LIST:
			dt.command_and_result = FileSystem::list(dt.data,dt.data,&dt.arg2) ? DiskTransaction::OK : DiskTransaction::FAILED; break;
		case DiskTransaction::NEXT:
			dt.command_and_result = FileSystem::list_next(dt.data,&dt.arg2) ? DiskTransaction::OK : DiskTransaction::FAILED; break;
		case DiskTransaction::CHDIR:
			dt.command_and_result = FileSystem::chdir(dt.data) ? DiskTransaction::OK : DiskTransaction::FAILED; break;
		case DiskTransaction::PWDIR:
			dt.command_and_result = FileSystem::pwd(dt.data) ? DiskTransaction::OK : DiskTransaction::FAILED; break;
		case DiskTransaction::OPENFILE:
			dt.arg1 = FileSystem::open_file(dt.data, dt.arg1);
			dt.command_and_result = (dt.arg1!=0xFF) ? DiskTransaction::OK : DiskTransaction::FAILED; break;
		case DiskTransaction::CLOSE:
			dt.command_and_result = FileSystem::close_file(dt.arg1) ? DiskTransaction::OK : DiskTransaction::FAILED; break;
		case DiskTransaction::READ:
		{
			uint16_t left=dt.arg2;
			uint16_t addr=dt.arg3;
			dt.arg2=0;
			while (left>0)
			{
				uint16_t cur = (left>DT_BUFFER_SIZE)?DT_BUFFER_SIZE:left;
				uint16_t act = FileSystem::read_file(dt.arg1, (uint8_t*)dt.data, cur);
				if (act==0) break;
				for(uint8_t i=0;act>0;--act,++addr,++i)
					write_byte(addr,dt.data[i]);
				left-=act;
				dt.arg2+=act;
			}
			dt.command_and_result = (dt.arg2>0) ? DiskTransaction::OK : DiskTransaction::FAILED;
			break;
		}
		case DiskTransaction::WRITE:
			dt.command_and_result=DiskTransaction::FAILED;
			break;
	}
	ptr=reinterpret_cast<uint8_t*>(&dt);
	addr=0xC00;
	for(uint8_t i=0;i<6;++i)
		write_byte(addr++, *ptr++);

	device_in_progress=false;
	// clear BUSREQ
	deactivate(restart_auto_clock);
}

void loop_devices()
{
	if (device_in_progress)
	{
		if (device == GPU_DEVICE)
			gpu_transaction();
		if (device == DISK_DEVICE)
			disk_transaction();
	}
}

int strlen(const char* s)
{
	int res=0;
	for(;*s;++s) ++res;
	return res;
}

void splash()
{
	const char* msg = "Hello z80";
	uint8_t len=uint8_t(strlen(msg));
	dbg << "Splash\r\n";
	
	gpu_buffer.clear();
	for(int i=0;i<100;++i)
	{
		gpu_buffer.add(0);
		gpu_buffer.add(1);
		gpu_buffer.calculate_crc();
		gpu_buffer.send();
		_delay_ms(10);
	}
	dbg << "Sent1\r\n";
	
	gpu_buffer.clear();
	gpu_buffer.add(0);
	gpu_buffer.add(1);		// clear screen
	gpu_buffer.add(30);		// print
	gpu_buffer.add(len);	// string length
	for(uint8_t i=0;i<len;++i)
		gpu_buffer.add(msg[i]);
	gpu_buffer.calculate_crc();
	gpu_buffer.send();
	dbg << "Sent2\r\n";
}

/*
uint8_t rnd()
{
	static uint8_t seed=1;
	seed = seed * 17 + 43;
	return seed;
}


void send_loop()
{
	_delay_ms(4000);
	while (true)
	{
		//dbg << "Sending\r\n";
		gpu_buffer.clear();
		uint8_t len=rnd();
		if (len<2) continue;
		for(uint8_t i=0;i<len;++i)
			gpu_buffer.add(rnd());
		gpu_buffer.calculate_crc();
		gpu_buffer.send();
		//dbg << "Sent\r\n";
		_delay_ms(10);
		loop_uart();
	}
}
*/

/*

void test_sdcard()
{
	DDRB=CLK | MOSI | CS | SCK | SDCS;
	PORTB=CS | SDCS;
		
	DDRD=TX1 | CLEAR_WAIT | INT | DRESET;
	PORTD=TX1 | INT | DRESET;
		
	DDRE=TX;
	PORTE=TX;
		
	SPCR = (1<<SPE)|(1<<MSTR)|(1<<SPR0);
	transmit0_text("Starting\r\n");

	if (!FileSystem::init())
	{
		transmit0_text("Failed to init filesys\r\n");
		return;
	}
	transmit0_text("FileSystem open\r\n");
	uint8_t f=FileSystem::open_file("FIB.SL",false);
	if (f==0xFF)
	{
		transmit0_text("Failed to open file\r\n");
		return;
	}
	transmit0_text("File open\r\n");
	while (true)
	{
		uint16_t n=FileSystem::read_file(f,(uint8_t*)dt.data,DT_BUFFER_SIZE-1);
		if (n==0) break;
		if (n==DT_BUFFER_SIZE) --n;
		dt.data[n]=0;
		transmit0_text(dt.data);
	}
	transmit0_text("\r\n-------- DONE ---------\r\n");
}

*/
int main(void)
{
	setup_uart();
	_delay_ms(1000);
	/*
	test_sdcard();
	while (1)
	{
		_delay_ms(100);
	}
	*/
	
	deactivate(false);
	// Enable SPI
	SPCR = (1<<SPE)|(1<<MSTR)|(1<<SPR0);
	
	FileSystem::init();
	upload_os();
	setup_interrupts();
	setup_handlers();
	sei();
	splash();
	reset_cpu();
	
    while (1) 
    {
		loop_uart();
		loop_timer();
		loop_devices();
    }
}

