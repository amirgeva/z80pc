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

constexpr uint8_t RX = (1);
constexpr uint8_t TX = (1<<1);
constexpr uint8_t TX1 = (1<<3);
constexpr uint8_t RX1 = (1<<2);

constexpr uint8_t CS   = (1);
constexpr uint8_t SCK  = (1 << 1);
constexpr uint8_t MOSI = (1 << 2);
constexpr uint8_t CLK  = (1 << 4);

constexpr uint8_t MREQ       = (1);
constexpr uint8_t RD         = (1<<1);
constexpr uint8_t WR         = (1<<4);
constexpr uint8_t CLEAR_WAIT = (1<<5);
constexpr uint8_t BUSREQ     = (1<<6);
constexpr uint8_t INT        = (1<<7);

constexpr uint8_t WAIT       = (1<<4);
constexpr uint8_t BUSACK     = (1<<6);
constexpr uint8_t IORQ       = (1<<7);

constexpr uint8_t M1         = (1<<6);
constexpr uint8_t RFSH       = (1<<7);


