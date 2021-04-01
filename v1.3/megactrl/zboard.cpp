#include <Arduino.h>
#include "zboard.h"

// PINF = A0..A7
// PINK = A8..A15
// PINA = D0..D7

// C0 MREQ
// C1 RD
// C2 WR
// C3 IORQ
// C4 WAIT
// C5 CLEAR_WAIT
// C6 BUSREQ
// C7 BUSACK

enum class Mode { INSPECT, READ, WRITE };

void EnableRD(bool state)
{
  if (state)
  {
    PORTC &= ~3;
    delay(1);
  }
  else
  {
    PORTC |= 3;
  }
}

void EnableWR(bool state)
{
  if (state)
  {
    PORTC &= ~0x05;
  }
  else
  {
    PORTC |= 0x05;
  }
}

void AutoClock()
{
  analogWrite(3,128);
}

void ClockTick()
{
  digitalWrite(3,HIGH);
  delayMicroseconds(1);
  digitalWrite(3,LOW);
  delayMicroseconds(1);
}

void WaitForBus()
{
  DDRF=0;
  DDRK=0;
  DDRA=0;
  DDRC=0x40;
  PORTC=0;
  while (true)
  {
    uint8_t C=PINC;
    if ((C&0x80)==0) break;
    ClockTick();
  }
}

static Mode CurrentMode=Mode::INSPECT;

void set_mode(Mode mode)
{
  if (mode == CurrentMode) return;
  if (CurrentMode==Mode::INSPECT)
  {
    WaitForBus();
  }
  switch (mode)
  {
    case Mode::INSPECT:
      DDRF=0;
      DDRK=0;
      DDRA=0;
      DDRC=0;
      break;
    case Mode::READ:
      DDRC = 0x7F;  // Flags
      PORTC = 0x3F;
      DDRF = 0xFF;  // Address output
      PORTF = 0;
      DDRK = 0xFF;  // Address output
      PORTK = 0;
      DDRA = 0; // Input
      PORTA=0;  // Disable pullup
      break;
    case Mode::WRITE:
      DDRF=0xFF; // Address bus
      DDRK=0xFF; // Address bus
      DDRA=0xFF; // Data bus
      DDRC=0x7F; // Flags
      PORTC=0x3F; // Set all to 1
      break;
  }
  CurrentMode=mode;
}

void Addr2KF(uint16_t address)
{
  PORTK = (address>>8);
  PORTF = address&0xFF;
}

uint8_t read_data(uint16_t address)
{
  Addr2KF(address);
  EnableRD(true);
  delayMicroseconds(1);
  uint8_t Data=PINA;
  EnableRD(false);
  return Data;
}



void zboard_init()
{
  DDRC=0;
  PORTC=0;
  DDRA=0;
  DDRF=0;
  DDRK=0;
  CurrentMode = Mode::INSPECT;
  pinMode(3,OUTPUT);
  TCCR3B = TCCR3B & B11111000 | B00000001;
  digitalWrite(3,LOW);
  //analogWrite(3,128); // Clock
  set_mode(Mode::READ);
}


void program_data(uint16_t address, uint8_t len, const uint8_t* data)
{
  set_mode(Mode::WRITE);
  const uint8_t* ptr=data;
  for(;len>0;--len,++address,++ptr)
  {
    Addr2KF(address);
    PORTA=*ptr;
    EnableWR(true);
    delayMicroseconds(1);
    EnableWR(false);
  }
  set_mode(Mode::INSPECT);
}

void read_data(uint16_t address, uint8_t len, uint8_t* data)
{
  set_mode(Mode::READ);
  uint8_t* ptr=data;
  for(;len>0;--len,++address,++ptr)
    *ptr = read_data(address);
  set_mode(Mode::INSPECT);
}

void clock_read_bus(uint8_t* data)
{
  set_mode(Mode::INSPECT);
  ClockTick();
  data[0]=PINF;
  data[1]=PINK;
  data[2]=PINA;
  data[3]=PINC;
}
