#pragma once



/*

	A - D0..D7
	C - A8..A15
	F - A0..A7
	
	PB0 - CS
	PB1 - SCK
	PB2 - MOSI
	PB3 - MISO
	PB4 - CLK
	PB5 - SDCS
	PB6 -
	PB7 -
		
	PD0 - WAIT
	PD1 - M1
	PD2 - RX1
	PD3 - TX1
	PD4 - 
	PD5 - DRESET
	PD6 - INT
	PD7 - CLEAR_WAIT
	
	PE0 - RX
	PE1 - TX
	PE2 -
	PE3 -
	PE4 -
	PE5 - IORQ   (INT5)
	PE6 - 
	PE7 - SCS    (INT7)
	
	PG0 - MREQ
	PG1 - RD
	PG2 - WR
	PG3 - BUSACK
	PG4 - BUSREQ
*/

// PORTE
constexpr uint8_t PIN_RX			= (1);
constexpr uint8_t PIN_TX			= (1<<1);
constexpr uint8_t PIN_IO_PE2		= (1<<2);
constexpr uint8_t PIN_IO_PE3		= (1<<3);
constexpr uint8_t PIN_IO_PE4		= (1<<4);
constexpr uint8_t PIN_IORQ			= (1<<5);
constexpr uint8_t PIN_IO_PE6		= (1<<6);
constexpr uint8_t PIN_SCS			= (1<<7);

// PORTD
constexpr uint8_t PIN_WAIT			= (1);
constexpr uint8_t PIN_M1			= (1<<1);
constexpr uint8_t PIN_RX1			= (1<<2);
constexpr uint8_t PIN_TX1			= (1<<3);
constexpr uint8_t PIN_DRESET		= (1<<5);
constexpr uint8_t PIN_INT			= (1<<6);
constexpr uint8_t PIN_CLEAR_WAIT	= (1<<7);

// PORTB
constexpr uint8_t PIN_CS   = (1);
constexpr uint8_t PIN_SCK  = (1 << 1);
constexpr uint8_t PIN_MOSI = (1 << 2);
constexpr uint8_t PIN_MISO = (1 << 3);
constexpr uint8_t PIN_CLK  = (1 << 4);
constexpr uint8_t PIN_SDCS = (1 << 5);

// PORTG
constexpr uint8_t PIN_MREQ       = (1);
constexpr uint8_t PIN_RD         = (1<<1);
constexpr uint8_t PIN_WR         = (1<<2);
constexpr uint8_t PIN_BUSACK     = (1<<3);
constexpr uint8_t PIN_BUSREQ     = (1<<4);

constexpr uint16_t DISK_LSB = 0xEA;
constexpr uint16_t DISK_MSB = 0xEB;
constexpr uint16_t TIMER_LSB = 0xEC;
constexpr uint16_t TIMER_MSB = 0xED;
constexpr uint16_t INPUT_WRITE = 0xEE;
constexpr uint16_t INPUT_READ = 0xEF;
