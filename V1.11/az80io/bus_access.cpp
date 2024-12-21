#include "types.h"
#include <Arduino.h>
#include "bus_access.h"
#include "io.h"

#define BUSACK 5
#define IO_WR 6
#define IO_RD 7
#define CLK 9
#define IO0 24
#define IO1 25
#define IO2 26
#define IO3 27
#define IO4 28
#define IO5 29
#define IO6 30
#define IO7 31
#define CLEAR 32
#define IO_A0 34
#define IO_A1 35
#define INT_PARAM 36
#define INT_RQ 37
#define DRESET 38
#define BUSREQ 39
#define SLE 40
#define SOE 41
#define A0LE 14
#define A0OE 16
#define A1LE 17
#define A1OE 18
#define DILE 19
#define DIOE 20
#define DOLE 21
#define DOOE 22
#define LS_OE 23

constexpr int ALWAYS_INPUT[] = {
	BUSACK, IO_WR, IO_RD, INT_PARAM, IO_A0, IO_A1
};

constexpr int ALWAYS_OUTPUT[] = {
	BUSREQ,  HIGH,
	DRESET,  HIGH,
	INT_RQ,  HIGH,
	CLK,     LOW,
	CLEAR,   LOW,
	SLE,     LOW,
	SOE,     HIGH,
	A0LE,    LOW,
	A0OE,    HIGH,
	A1LE,    LOW,
	A1OE,    HIGH,
	DILE,    LOW,
	DIOE,    HIGH,
	DOLE,    LOW,
	DOOE,    HIGH,
	LS_OE,   HIGH
};

void do_reset()
{
	digitalWriteFast(DRESET, LOW);
	for(int i=0;i<100;++i)
		clock_tick();
	digitalWriteFast(DRESET, HIGH);
	Serial.println("");
}

void bus_setup()
{
	int n_inputs = sizeof(ALWAYS_INPUT) / sizeof(int);
	for(int i=0;i<n_inputs;++i)
	{
		pinMode(ALWAYS_INPUT[i],INPUT);
	}
	int n_outputs = sizeof(ALWAYS_OUTPUT) / sizeof(int);
	for(int i=0;i<n_outputs;i+=2)
	{
		pinMode(ALWAYS_OUTPUT[i],OUTPUT);
		digitalWrite(ALWAYS_OUTPUT[i],ALWAYS_OUTPUT[i+1]);
	}
	pinMode(IO0, INPUT);
	pinMode(IO1, INPUT);
	pinMode(IO2, INPUT);
	pinMode(IO3, INPUT);
	pinMode(IO4, INPUT);
	pinMode(IO5, INPUT);
	pinMode(IO6, INPUT);
	pinMode(IO7, INPUT);
	Serial.println("First Reset");
	do_reset();
	Serial.println("Done");
	while (digitalReadFast(BUSACK)==LOW)
	{
		Serial.println("Waiting for BUSACK");
		clock_tick();
		delay(100);
	}
}

void bus_loop()
{
}

void us(int n) { delayMicroseconds(n); }

bool clock_pwm = false;
bool bus_acquired=false;
bool bus_output=false;

bool is_auto_clock() { return clock_pwm; }

void set_auto_clock(bool active)
{
  if (active==clock_pwm) return;
  if (active)
  {
    analogWriteFrequency(CLK,1000000);
    analogWrite(CLK,128);
  }
  else
  {
    digitalWriteFast(CLK,LOW);
  }
  clock_pwm=active;
  set_auto_clock(true);
}

void clock_tick()
{
	// while (!Serial.available())
	// {
	// 	io_loop();
	// 	delay(100);
	// }
	// Serial.print(".");
	// Serial.read();
	// {
	// 	digitalWriteFast(CLK, HIGH);
	// 	us(1);
	// 	digitalWriteFast(CLK, LOW);
	// 	us(1);
	// }

	if (clock_pwm) us(1);
	else
	{
		digitalWriteFast(CLK, HIGH);
		us(1);
		digitalWriteFast(CLK, LOW);
		us(1);
	}
}	

void busy_wait()
{
	if (clock_pwm)
		return;
	clock_tick();
}

bool is_bus_acquired() { return bus_acquired; }

void set_bus_output(bool output)
{
	if (output == bus_output) return;
	if (output)
	{
		pinMode(IO0, OUTPUT);
		pinMode(IO1, OUTPUT);
		pinMode(IO2, OUTPUT);
		pinMode(IO3, OUTPUT);
		pinMode(IO4, OUTPUT);
		pinMode(IO5, OUTPUT);
		pinMode(IO6, OUTPUT);
		pinMode(IO7, OUTPUT);
	}
	else
	{
		pinMode(IO0, INPUT);
		pinMode(IO1, INPUT);
		pinMode(IO2, INPUT);
		pinMode(IO3, INPUT);
		pinMode(IO4, INPUT);
		pinMode(IO5, INPUT);
		pinMode(IO6, INPUT);
		pinMode(IO7, INPUT);
	}
	bus_output=output;
}

void acquire_bus()
{
	if (bus_acquired) return;
	digitalWriteFast(BUSREQ,LOW);
	int clocks = 0;
	while (digitalReadFast(BUSACK)==HIGH)
	{
		++clocks;
		clock_tick();
	}
	Serial.print("Acquired clocks=");
	Serial.println(clocks);
	bus_acquired=true;
}

void release_bus()
{
	if (!bus_acquired) return;
	set_bus_output(false);
	digitalWriteFast(BUSREQ,HIGH);
	int clocks = 0;
	while (digitalReadFast(BUSACK)==LOW)
	{
		++clocks;
		clock_tick();
	}
	Serial.print("Released clocks=");
	Serial.println(clocks);
	bus_acquired=false;
}

void set_flags(int MREQ, int RD, int WR)
{
	digitalWriteFast(IO0, MREQ);
	digitalWriteFast(IO1, RD);
	digitalWriteFast(IO2, WR);
	digitalWriteFast(SLE, HIGH);
	us(1);
	digitalWriteFast(SLE,LOW);
	us(1); //@@
}

void set_io(byte value)
{
	digitalWriteFast(IO0, (value&0x01)?HIGH:LOW);
	digitalWriteFast(IO1, (value&0x02)?HIGH:LOW);
	digitalWriteFast(IO2, (value&0x04)?HIGH:LOW);
	digitalWriteFast(IO3, (value&0x08)?HIGH:LOW);
	digitalWriteFast(IO4, (value&0x10)?HIGH:LOW);
	digitalWriteFast(IO5, (value&0x20)?HIGH:LOW);
	digitalWriteFast(IO6, (value&0x40)?HIGH:LOW);
	digitalWriteFast(IO7, (value&0x80)?HIGH:LOW);
}

#define SET_LATCH(value, LE)\
set_io(value);\
digitalWriteFast(LE, HIGH);\
us(1);\
digitalWriteFast(LE,LOW);\
us(1) //@@


byte read_io()
{
	set_bus_output(false);
#define BIT(pin, shift) (digitalReadFast(pin) == HIGH ? (1 << shift) : 0)
	byte res = BIT(IO7, 7) | BIT(IO6, 6) | BIT(IO5, 5) | BIT(IO4, 4) |
			   BIT(IO3, 3) | BIT(IO2, 2) | BIT(IO1, 1) | BIT(IO0, 0);
#undef BIT
	return res;
}

void set_addr(Word addr)
{
	SET_LATCH(addr&0xFF,      A0LE);
	SET_LATCH((addr>>8)&0xFF, A1LE);
}

void set_data(byte value)
{
	SET_LATCH(value, DILE);
}

void write_byte(Word addr, byte value)
{
	if (!is_bus_acquired()) return;
	set_bus_output(true);
	set_flags(LOW, HIGH, LOW);
	set_addr(addr);
	set_data(value);
	digitalWriteFast(A0OE, LOW);
	digitalWriteFast(A1OE, LOW);
	digitalWriteFast(DIOE, LOW);
	us(1);
	digitalWriteFast(SOE,  LOW);
	us(1);
	digitalWriteFast(SOE,  HIGH);
	digitalWriteFast(DIOE, HIGH);
	digitalWriteFast(A1OE, HIGH);
	digitalWriteFast(A0OE, HIGH);
}

byte read_byte(Word addr)
{
	if (!is_bus_acquired()) return 0;
	set_bus_output(true);
	set_flags(LOW, LOW, HIGH);
	set_addr(addr);
	digitalWriteFast(A0OE, LOW);
	digitalWriteFast(A1OE, LOW);
	us(1);
	digitalWriteFast(SOE,  LOW);
	us(1);
	digitalWriteFast(DOLE, HIGH);
	us(1);
	digitalWriteFast(DOLE, LOW);
	digitalWriteFast(SOE,  HIGH);
	digitalWriteFast(A1OE, HIGH);
	digitalWriteFast(A0OE, HIGH);

	set_bus_output(false);
	digitalWriteFast(DOOE, LOW);
	us(1);
	byte res = read_io();
	digitalWriteFast(DOOE, HIGH);
	return res;
}

Word read_word(Word addr)
{
	Word w = read_byte(addr + 1);
	w = (w << 8) | read_byte(addr);
	return w;
}

void write_word(Word addr, word value)
{
	write_byte(addr, value & 0xFF);
	write_byte(addr + 1, (value >> 8) & 0xFF);
}

void clear_io_write()
{
	digitalWriteFast(CLEAR, HIGH);
	while (digitalReadFast(IO_WR) == LOW)
		busy_wait();
	digitalWriteFast(CLEAR, LOW);
}

byte read_output()
{
	digitalWriteFast(DOOE, LOW);
	us(1); // Wait for data to stabilize on the bus
	byte d = read_io();
	digitalWriteFast(DOOE, HIGH);
	return d;
}

void process_io()
{
	io_loop();
	if (digitalReadFast(IO_WR)==LOW) // OUT instruction
	{
		// Load data bus into latch
		digitalWriteFast(DOLE, HIGH);
		// Read lower part of the address bus
		byte addr = (digitalReadFast(IO_A1) == HIGH ? 2 : 0) | (digitalReadFast(IO_A0) == HIGH ? 1 : 0);
		us(1);
		// Disable latch loading
		digitalWriteFast(DOLE, LOW);
		Serial.print("OUT addr=");
		Serial.println(int(addr));

		// Set io to read data (from latch)
		set_bus_output(false);
		byte data = read_output();
		IOProcessing process_type = get_processing_type(addr);
		switch (process_type)
		{
			case PROCESS_AND_CLEAR:
				// Process and then clear
				process_out(addr,data);
				clear_io_write();
				break;
			case CLEAR_AND_PROCESS:
				clear_io_write();
				process_out(addr,data);
				break;
			case CLEAR_AND_DMA:
				digitalWriteFast(BUSREQ, LOW);
				clear_io_write();
				acquire_bus();
				process_out(addr,data);
				release_bus();
				break;
		}
	}
	else
	if (digitalReadFast(IO_RD)==LOW) // IN instruction
	{
		us(1);
		byte addr = (digitalReadFast(IO_A1) == HIGH ? 2 : 0) | (digitalReadFast(IO_A0) == HIGH ? 1 : 0);
		Serial.print("IN addr=");
		Serial.println(int(addr));
		byte d = process_in(addr);
		set_bus_output(true);
		set_data(d);
		digitalWriteFast(DIOE, LOW);   // Enable latch output
		digitalWriteFast(CLEAR, HIGH); // Clear wait state
		while (digitalReadFast(IO_RD) == LOW) // Wait for io to complete
			busy_wait();
		digitalWriteFast(DIOE, HIGH); // Disable latch output
		digitalWriteFast(CLEAR, LOW); // Enable next io wait
	}
}

void interrupt(byte data)
{
	int clock_waits = 0;
	//Serial.println("Request interrupt");
	digitalWriteFast(INT_RQ, LOW);			 // Tell the PLD to request interrupt
	//Serial.println("Wait for param");
	while (digitalReadFast(INT_PARAM)==HIGH) // wait for parameter request
	{
		clock_waits++;
		busy_wait();
	}
	//Serial.print(clock_waits);
	//Serial.println(" clock waits");
	clock_waits = 0;
	//Serial.print("DATA=");
	//Serial.println(int(data));
	set_bus_output(true);
	set_data(data);
	//Serial.println("Enable latch");
	digitalWriteFast(DIOE, LOW);		  // Enable latch output
	us(1);
	//Serial.println("Clear wait");
	digitalWriteFast(CLEAR, HIGH);		  // Clear wait state
	//Serial.println("Wait for param read");
	while (digitalReadFast(INT_PARAM) == LOW) // Wait for io to complete
	{
		++clock_waits;
		busy_wait();
	}
	// Serial.print(clock_waits);
	// Serial.println(" clock waits");
	digitalWriteFast(DIOE, HIGH); // Disable latch output
	digitalWriteFast(CLEAR, LOW); // Enable next io wait

	// Serial.println("Disable interrupt signal");
	digitalWriteFast(INT_RQ, HIGH); // Tell the PLD to stop requesting interrupt
	// Serial.println("Done");
}
