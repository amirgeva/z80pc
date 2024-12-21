#include <Arduino.h>
#include "Common.h"
#include "bus_access.h"

#define D_OE 24
#define D_LD 20
#define S_OE 37
#define A_OE 38
#define A_LD0 39
#define A_LD1 40

#define D0 25
#define D1 26
#define D2 27
#define D3 28
#define D4 29
#define D5 30
#define D6 31
#define D7 32
#define RD 5
#define WR 6
#define MREQ 7
#define IORQ 41
#define CLK 9
#define BUSACK 17
#define BUSREQ 36
#define DRESET 35
#define CLEAR_WAIT 14
#define M1 16
#define IO1 18
#define IO2 19
#define WAIT 21

constexpr int input_always[] = {
	M1, IORQ, BUSACK, WAIT};

constexpr int N_INPUTS = sizeof(input_always) / sizeof(int);

constexpr int data_pins[] = {
	D0, D1, D2, D3, D4, D5, D6, D7};

constexpr int input_sometimes[] = {
	D0, D1, D2, D3, D4, D5, D6, D7,
	RD, WR, MREQ};

const int N_SOMETIME = sizeof(input_sometimes) / sizeof(int);

constexpr int output_always[] = {
	D_OE, D_LD, S_OE, A_OE, A_LD0, A_LD1, CLK, BUSREQ, DRESET, CLEAR_WAIT, IO1, IO2};

constexpr int N_OUTPUTS = sizeof(output_always) / sizeof(int);

bool bus_acquired = false;
// bool data_output=false;
bool clk_pwm = false;

/*
void set_data_output()
{
  if (data_output) return;
  data_output=true;
  for(int i=0;i<8;++i)
	pinMode(data_pins[i],OUTPUT);
}

void set_data_input()
{
  if (!data_output) return;
  for(int i=0;i<8;++i)
	pinMode(data_pins[i],INPUT);
  data_output=false;
}
*/

bool is_bus_acquired()
{
	return bus_acquired;
}

void release_bus()
{
	if (!bus_acquired)
		return;
	digitalWriteFast(A_OE, HIGH);
	for (int i = 0; i < N_SOMETIME; ++i)
		pinMode(input_sometimes[i], INPUT_PULLUP);
	digitalWriteFast(BUSREQ, HIGH);
	while (digitalReadFast(BUSACK) == LOW)
		clock_tick();
  if (g_Verbose)
    Serial.println("Released");
	bus_acquired = false;
}

void acquire_bus()
{
	if (bus_acquired)
		return;
  if (g_Verbose)
    Serial.println("BUSREQ");
	digitalWriteFast(BUSREQ, LOW);
	while (digitalReadFast(BUSACK) == HIGH)
		clock_tick();
	delayMicroseconds(1);
	if (g_Verbose)
		Serial.println("BUSACK");

	pinMode(WR, OUTPUT);
	digitalWriteFast(WR, HIGH);
	pinMode(RD, OUTPUT);
	digitalWriteFast(RD, HIGH);
	pinMode(MREQ, OUTPUT);
	digitalWriteFast(MREQ, HIGH);

	for (int i = 0; i < 8; ++i)
		pinMode(data_pins[i], OUTPUT);
	bus_acquired = true;
	if (g_Verbose)
		Serial.println("Acquired");
}

void perform_reset()
{
  if (g_Verbose)
    Serial.println("Reset");

	digitalWriteFast(DRESET, LOW);
	for (int i = 0; i < 100; ++i)
		clock_tick();
	digitalWriteFast(DRESET, HIGH);
}

constexpr int DELAY = 1;

void set_dbus(uint8_t value)
{
#define DB(x) digitalWriteFast(D##x, ((value >> x) & 1) ? HIGH : LOW);
	DB(7);
	DB(6);
	DB(5);
	DB(4);
	DB(3);
	DB(2);
	DB(1);
	DB(0);
#undef DB
	delayMicroseconds(DELAY);
}

#define HTOGGLE(x)                 \
	{                              \
		delayMicroseconds(DELAY);  \
		digitalWriteFast(x, HIGH); \
		delayMicroseconds(DELAY);  \
		digitalWriteFast(x, LOW);  \
	}


void clock_tick()
{
  if (clk_pwm)
    delayMicroseconds(2);
  else
  {
    HTOGGLE(CLK);
  }
}

void set_address(word addr)
{
	set_dbus((addr >> 8) & 0xFF);
	HTOGGLE(A_LD1);
	set_dbus(addr & 0xFF);
	HTOGGLE(A_LD0);
	delayMicroseconds(DELAY);
	digitalWriteFast(A_OE, LOW);
	delayMicroseconds(DELAY);
}

void set_data(byte data)
{
	set_dbus(data);
}

void set_read_dir()
{
	pinMode(D0, INPUT);
	pinMode(D1, INPUT);
	pinMode(D2, INPUT);
	pinMode(D3, INPUT);
	pinMode(D4, INPUT);
	pinMode(D5, INPUT);
	pinMode(D6, INPUT);
	pinMode(D7, INPUT);
	delayMicroseconds(DELAY);
}

byte read_dbus()
{
#define RB(x) ((digitalReadFast(D##x) == HIGH ? 1 : 0) << x)
	byte res = RB(7) | RB(6) | RB(5) | RB(4) | RB(3) | RB(2) | RB(1) | RB(0);
#undef RB
	return res;
}

void set_write_dir()
{
	pinMode(D0, OUTPUT);
	pinMode(D1, OUTPUT);
	pinMode(D2, OUTPUT);
	pinMode(D3, OUTPUT);
	pinMode(D4, OUTPUT);
	pinMode(D5, OUTPUT);
	pinMode(D6, OUTPUT);
	pinMode(D7, OUTPUT);
	delayMicroseconds(DELAY);
}

void write_byte(word addr, byte data)
{
	if (!bus_acquired)
		return;
	set_address(addr);
	set_dbus(data);
	digitalWriteFast(MREQ, LOW);
	digitalWriteFast(WR, LOW);
	delayMicroseconds(DELAY);
	digitalWriteFast(WR, HIGH);
	digitalWriteFast(MREQ, HIGH);
}

byte read_byte(word addr)
{
	if (!bus_acquired)
		return 0;
	set_address(addr);
	set_read_dir();
	digitalWriteFast(MREQ, LOW);
	digitalWriteFast(RD, LOW);
	delayMicroseconds(DELAY);
	byte res = read_dbus();
	digitalWriteFast(RD, HIGH);
	digitalWriteFast(MREQ, HIGH);
	set_write_dir();
	return res;
}

/*
volatile bool handle_io = false;
volatile int io_events = 0;

void handle_iorq()
{
	handle_io = true;
 ++io_events;
}
*/

void upload(const byte* data, word addr, word len)
{
	ACQUIRER;
	for (word i=0; i < len; ++i)
	{
    if (g_Verbose)
    {
      Serial.print("U");
      //Serial.println(addr,HEX);
    }
		write_byte(addr+i, data[i]);
	}
  if (g_Verbose) Serial.println(".");
  for (word i=0; i < len; ++i)
  {
    byte b=read_byte(addr+i);
    if (g_Verbose)
    {
      Serial.print(b==data[i]?"R":"X");
    }
  }
  if (g_Verbose) Serial.println(".");
}

void bus_setup()
{
	for (int i = 0; i < N_INPUTS; ++i)
		pinMode(input_always[i], INPUT_PULLUP);
	for (int i = 0; i < N_OUTPUTS; ++i)
		pinMode(output_always[i], OUTPUT);
	if (g_Verbose)
		Serial.println("Releasing bus");
	release_bus();
	digitalWrite(CLK, LOW);
	//attachInterrupt(digitalPinToInterrupt(IORQ), handle_iorq, FALLING);
	// if (g_Verbose) Serial.println("Reset");
	// perform_reset();
	// if (g_Verbose) Serial.println("Acquire bus");
	// acquire_bus();
	if (g_Verbose)
		Serial.println("Start");
}

void io_loop()
{
  //static int last_ev=0;
  //if (io_events!=last_ev)
  {
    //Serial.print("\r\n:");
    //Serial.println(io_events);
    //last_ev=io_events;
  }
  bool handle_io = digitalReadFast(IORQ)==LOW;
	if (handle_io)
	{
    Serial.println("\nIO");
		while (handle_io)
		{
			clock_tick();
			if (digitalReadFast(WR) == LOW)
			{
        delayMicroseconds(2);
        char c=read_dbus();
				Serial.print(c);// Serial.print("  ");  Serial.println(int(c));
				handle_io = false;
			}
			else if (digitalReadFast(RD) == LOW)
			{
				handle_io = false;
			}
			else if (digitalReadFast(M1) == LOW)
			{
				handle_io = false;
			}
		}
		digitalWriteFast(CLEAR_WAIT, HIGH);
		while (digitalReadFast(IORQ) == LOW)
			clock_tick();
		digitalWriteFast(CLEAR_WAIT, LOW);
	}
  clock_tick();
  Serial.print(".");
	//delayMicroseconds(100);
  delay(100);
}

void bus_loop()
{
	io_loop();
}
