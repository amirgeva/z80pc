#include <stdio.h>
#include "pico/stdlib.h"
#include "debug_protocol.h"
#include "bus_access.h"

static bool g_EnhanceSingle = false;

enum {
    READ_DATA = 0,
    WRITE_DATA = 1,
    SINGLE_STEP = 2,
    TRIGGER_INTERRUPT = 3,
	ENHANCED_SINGLE_STEP = 4,
    REFRESH = 5,
    KEYBOARD_INPUT = 6,
    TRIGGER_RESET = 7,
    AUTO_CLOCK = 8,
	RUN_TO_ADDR = 9
};

void handle_read(const uint8_t* data, uint8_t length)
{
	if (length != 3) 
	{
		g_DebugProtocol.print_text("Invalid read message");
		return; // Need address, and byte count
	}
	uint16_t address = data[0] | (uint16_t(data[1]) << 8);
	length = data[2];
	if (length > 248)
	{
        g_DebugProtocol.print_text("Read too many bytes");
		return; // Too many bytes
	}
	if (0)
	{
		char msg[64];
		sprintf(msg,"Read %04hx n=%d",address,int(length));
		g_DebugProtocol.print_text(msg);
	}
	uint8_t* buffer = g_DebugProtocol.allocate_read_response(length);
	acquire_bus();
	for(;length>0;--length,++address,++buffer)
	{
		*buffer = read_byte(address);
	}
	g_DebugProtocol.send_response();
	//g_DebugProtocol.print_text("Done");
}

void handle_write(const uint8_t* data, uint8_t length)
{
	if (length < 2)
	{
		g_DebugProtocol.print_text("Invalid write message");
		return; // Need at least address
	}
	uint16_t address = data[0] | (uint16_t(data[1]) << 8);
	length-=2;
    if (length > 0)
    {
		if (0)
		{
			char msg[64];
			sprintf(msg, "Writing %04hx n=%d",address,int(length));
			g_DebugProtocol.print_text(msg);
		}
        acquire_bus();
        for(uint8_t i=0; i<length; ++i,++address)
		{
            write_byte(address, data[i+2]);
			sleep_ms(1);
		}
    }
  	//g_DebugProtocol.print_text("Done");
}

void copy_state(uint8_t* buffer)
{
	ACQUIRE;
	for(uint8_t i=0;i<14;++i)
		buffer[i+2]=read_byte(0xF0+i);
}

void handle_run_to(const uint8_t* data, uint8_t length)
{
	if (length!=2)
	{
		g_DebugProtocol.print_text("Invalid length");
		return;
	}
	uint16_t address = data[0] | (uint16_t(data[1]) << 8);
	set_clock_pwm(false);
	release_bus();
	{
		char msg[32];
		sprintf(msg,"Run to %hd",address);
		g_DebugProtocol.print_text(msg);
	}

	uint8_t goal_l=data[0],goal_h=data[1];
	uint8_t addrh,addrl;
	uint8_t dbyte, flags=0;
	//uint8_t* buffer = g_DebugProtocol.allocate_read_response(16);
	//for(int i=0;i<10000;++i)
	while (true)
	{
		flags=0;
		while (!FLAGS_FETCH)
		{
			clock_tick();
			read_bus(addrl, addrh, dbyte, flags);
		}
		if (addrl==goal_l && addrh==goal_h)
		{
			clock_tick();
			break;
		}
	}

	// buffer[0]=addrl;
	// buffer[1]=addrh;
	// g_DebugProtocol.send_response();
}

void handle_single_step(const uint8_t* unused_data, uint8_t unused_length)
{
	//g_DebugProtocol.print_text("CLK");
	set_clock_pwm(false);
	release_bus();
	uint8_t addrh,addrl;
	uint8_t dbyte, flags=0;
	//uint8_t stage=0;
	uint8_t* buffer = g_DebugProtocol.allocate_read_response(16);
	//if (g_EnhanceSingle) 
	if (!g_EnhanceSingle)
	{
		while (!FLAGS_FETCH)
		{
			clock_tick();
			read_bus(addrl, addrh, dbyte, flags);
		}
		buffer[0]=addrl;
		buffer[1]=addrh;
		clock_tick();
	}
	else
	{
		trigger_interrupt();
		bool copied=false;
		//while (true)
		for(int i=0;i<100;++i)
		{
			flags=0;
			while (!FLAGS_FETCH)
			{
				clock_tick();
				read_bus(addrl, addrh, dbyte, flags);
			}
			//printf("%02x%02x\n",addrh,addrl);
			if (addrh==0 && addrl==0x55)
			{
				copy_state(buffer);
				copied=true;
			}
			if (copied && addrh>0) break;
		}
		buffer[0]=addrl;
		buffer[1]=addrh;
	}
	g_DebugProtocol.send_response();
}

void handle_interrupt(const uint8_t* data, uint8_t length)
{
	//printf("INT\n");
	trigger_interrupt();
}

void handle_enhanced_single_step(const uint8_t* data, uint8_t length)
{
	g_EnhanceSingle = (data[0]>0);
}
void handle_refresh(const uint8_t* data, uint8_t length) {}
void handle_input(const uint8_t* data, uint8_t length)
{
	ACQUIRE;
	constexpr uint16_t INPUT_WRITE = 0xEE;
	constexpr uint16_t INPUT_READ = 0xEF;	
	uint8_t offset = read_byte(INPUT_WRITE);
	uint16_t buffer_address = 0x100;
	for(;length>0;--length,++data)
	{
		write_byte(buffer_address + offset, *data);
		offset = (offset + 1) & 0x1F;
	}
	write_byte(INPUT_WRITE,offset);
}

void handle_dreset(const uint8_t* data, uint8_t length)
{
	perform_reset();
}

void handle_autoclock(const uint8_t* data, uint8_t length)
{
	release_bus();
	set_clock_pwm(true);
}

void setup_handlers()
{
    g_DebugProtocol.register_handler(READ_DATA, handle_read);
    g_DebugProtocol.register_handler(WRITE_DATA, handle_write);
	g_DebugProtocol.register_handler(SINGLE_STEP,handle_single_step);
	g_DebugProtocol.register_handler(TRIGGER_INTERRUPT,handle_interrupt);
	g_DebugProtocol.register_handler(ENHANCED_SINGLE_STEP,handle_enhanced_single_step);
	g_DebugProtocol.register_handler(REFRESH,handle_refresh);
	g_DebugProtocol.register_handler(KEYBOARD_INPUT,handle_input);
	g_DebugProtocol.register_handler(TRIGGER_RESET,handle_dreset);
	g_DebugProtocol.register_handler(AUTO_CLOCK,handle_autoclock);
	g_DebugProtocol.register_handler(RUN_TO_ADDR,handle_run_to);
}
