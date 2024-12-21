#pragma once



/*

	A - A8..A15
	C - A0..A7
	F - D0..D7
	
	PB4 - CLK
	PB6 - M1
	PB7 - RFSH
	
	PD0 - MREQ
	PD1 - RD
	PD2 - RX1
	PD3 - TX1
	PD4 - WR
	PD5 - CLEAR_WAIT
	PD6 - BUSREQ
	PD7 - INT
	
	PE0 - RX
	PE1 - TX
	PE4 - WAIT   (INT4)
	PE6 - BUSACK (INT6)
	PE7 - IORQ   (INT7)
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
constexpr uint8_t CLK  = (1 << 4);

// PORTG
constexpr uint8_t MREQ       = (1);
constexpr uint8_t RD         = (1<<1);
constexpr uint8_t WR         = (1<<2);
constexpr uint8_t BUSACK     = (1<<3);
constexpr uint8_t BUSREQ     = (1<<4);




