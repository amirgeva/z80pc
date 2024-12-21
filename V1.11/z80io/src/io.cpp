#include "types.h"
#include <Arduino.h>
#include "io.h"
#include "bus_access.h"
#include "gpu_protocol.h"
#include "disk.h"

// Indicate if processing should be done before clearing the wait state
// This is true for 3 (debug), and 1 (disk)
// Disk commands are done in DMA, so the wait state will continue until operation is done
IOProcessing get_processing_type(Word addr)
{
	if (addr==3 || addr==1)
		return CLEAR_AND_DMA;
	return CLEAR_AND_PROCESS;
}

GPUProtocol g_Protocol;

void process_out(Word addr, byte data) // Take an OUT instruction and handle it
{
	//Serial.print(addr);
	//Serial.print(":");
	//Serial.println(int(data));
	if (addr==3)
	{
		// CPU state reporting by DMA
		BusAcquirer _a;
		byte state[16];
		Word *wstate = reinterpret_cast<Word *>(state);
		for (Word i = 0; i < 16;++i)
			state[i] = read_byte(0x00F0 + i);
		Word pc = wstate[7];
		//(uint16_t(state[15]) << 8) | state[14];
		Serial.print("PC:");
		Serial.println(int(pc));
		// Send to debug protocol......
	}
	if (addr==0)
	{
		g_Protocol.add_byte(data);
	}

	if (addr == 1)
	{
		disk_process(data);
	}
}

byte pending[4] = {0,0,0,0};

void set_pending_in(Word addr, byte value)
{
	pending[addr & 3] = value;
}

byte process_in(Word addr)	// IN instruction, provide the byte to be read
{
	addr &= 3;
	// Serial.print("IN: ");
	// Serial.print(int(addr));
	// Serial.print(" ");
	// Serial.println(int(pending[addr]));
	byte res = pending[addr];
	pending[addr] = 0;
	return res;
}

void io_loop()
{
	if (Serial1.available())
	{
		byte b = Serial1.read();
		Serial.print("Recv:");
		Serial.println(int(b));
		set_pending_in(0, b);
		interrupt(0x22);
	}
	/*
	if (Serial.available())
	{
		int c = Serial.read();
		if (c=='s')
		{
			BusAcquirer ba;
			Serial.println("========");
			for (Word addr = 0; addr < 2000;++addr)
			{
				byte b = read_byte(addr);
				Serial.write(b);
			}
			Serial.println("========");
			while (true)
				delay(100);
		}
	}
	*/
}
