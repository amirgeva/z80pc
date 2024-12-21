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
constexpr uint8_t RX			= (1);
constexpr uint8_t TX			= (1<<1);
constexpr uint8_t IO_PE2		= (1<<2);
constexpr uint8_t IO_PE3		= (1<<3);
constexpr uint8_t IO_PE4		= (1<<4);
constexpr uint8_t IORQ			= (1<<5);
constexpr uint8_t IO_PE6		= (1<<6);
constexpr uint8_t SCS			= (1<<7);

// PORTD
constexpr uint8_t WAIT			= (1);
constexpr uint8_t M1			= (1<<1);
constexpr uint8_t RX1			= (1<<2);
constexpr uint8_t TX1			= (1<<3);
constexpr uint8_t DRESET		= (1<<5);
constexpr uint8_t INT			= (1<<6);
constexpr uint8_t CLEAR_WAIT	= (1<<7);

// PORTB
constexpr uint8_t CS   = (1);
constexpr uint8_t SCK  = (1 << 1);
constexpr uint8_t MOSI = (1 << 2);
constexpr uint8_t MISO = (1 << 3);
constexpr uint8_t CLK  = (1 << 4);
constexpr uint8_t SDCS = (1 << 5);

// PORTG
constexpr uint8_t MREQ       = (1);
constexpr uint8_t RD         = (1<<1);
constexpr uint8_t WR         = (1<<2);
constexpr uint8_t BUSACK     = (1<<3);
constexpr uint8_t BUSREQ     = (1<<4);




