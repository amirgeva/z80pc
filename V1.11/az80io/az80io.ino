#include "types.h"
#include <VGA_t4.h>
#include "bus_access.h"
#include "disk.h"

VGA_T4 vga;
//static int fb_width, fb_height;

#include "os.h"
constexpr Word MAX_ADDR = sizeof(os_data);

char msg[128];

void setup()
{
	Serial.begin(115200);
	Serial1.begin(9600);
	delay(3000);

	vga_error_t err = vga.begin(VGA_MODE_640x480);
	if(err != 0)
	{
		Serial.println("fatal error");
			while(1);
	}

	vga.clear(0);
	
	Serial.println("Starting");
	disk_setup();
	//long start, stop;
	//int failed;
	bus_setup();
	{
		BusAcquirer ba;
		for(Word addr=0;addr<MAX_ADDR;++addr)
		{
			write_byte(addr, os_data[addr]);
		}
		/*
		failed=0;
		start=millis();
		for(Word addr=0;addr<MAX_ADDR;++addr)
		{
			const byte value = os_data[addr];
			byte b = read_byte(addr);
			if (b != value)
			{
				++failed;
			}
		}
		stop=millis();
		*/
	}
	//Serial.print("Failed = ");
	//Serial.println(failed);
	//Serial.print("Speed = ");
	//double Bps = (MAX_ADDR * 1000.0) / (stop-start);
	//Serial.print(Bps);
	//Serial.println(" bytes per second");
	Serial.println("Doing reset");
	do_reset();
	Serial.println("Done");
}

void loop()
{
	//delay(100);
	clock_tick();
	process_io();
}
