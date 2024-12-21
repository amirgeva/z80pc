#include <Arduino.h>
#include "zboard.h"

// PA = A0..A7
// PC = A8..A15
// PF = D0..D7

inline void set_addr(uint16_t addr)
{
  PORTA=addr&0xFF;
  PORTC=(addr>>8)&0xFF;
}

inline uint16_t get_addr()
{
  return (PINC<<8)|PINA;
}

inline void set_data(uint8_t data)
{
  PORTF=data;
}

inline uint8_t get_data()
{
  return PINF;
}

void AutoClock()
{
  //analogWrite(3,128);
  TCCR3A|=(1<<COM3A0);
}

void ClockTick()
{
  TCCR3A&=~(1<<COM3A0);
  digitalWrite(5,HIGH);
  delayMicroseconds(1);
  digitalWrite(5,LOW);
  delayMicroseconds(1);
}


// K0 BUSREQ
// K1 WAIT
// K2 BUSACK
// K3 WR
// K4 RD
// K5 IORQ
// K6 MREQ
// K7 CLEAR_WAIT

const uint8_t BUSREQ       = 0x01;
const uint8_t WAIT         = 0x02;
const uint8_t BUSACK       = 0x04;
const uint8_t WR           = 0x08;
const uint8_t RD           = 0x10;
const uint8_t IORQ         = 0x20;
const uint8_t MREQ         = 0x40;
const uint8_t CLEAR_WAIT   = 0x80;

enum class Mode { INSPECT, READ, WRITE, READWRITE };

char dmsg[64];
bool bus_acquired=false;

void AcquireBUS()
{
  DDRK |= BUSREQ;
  PORTK &= ~BUSREQ;
  debug_print("Acquiring BUS");
  while ((PINK & BUSACK) != 0)
  {
    debug_prints(".");
    ClockTick();
  }
  bus_acquired=true;
  debug_print("Got BUS");
}

void ReleaseBUS()
{
  debug_print("Releasing BUS");
  DDRA=0;
  DDRC=0;
  DDRF=0;
  DDRK |= BUSREQ;
  PORTK |= BUSREQ;
  while ((PINK & BUSACK) == 0)
  {
    debug_prints(".");
    ClockTick();
  }
  debug_print("BUS Released");
  bus_acquired=false;
  DDRK &= ~BUSREQ;
  PORTK |= MREQ | WR | RD;
  DDRK=0;
  PORTK = 0;
}

void Enable(uint8_t flags)
{
  PORTK &= ~flags;
}

void Disable(uint8_t flags)
{
  PORTK |= flags;
}

static Mode CurrentMode=Mode::INSPECT;

void set_mode(Mode mode)
{
  if (mode == CurrentMode) return;
  if (CurrentMode==Mode::INSPECT) AcquireBUS();
  debug_print("Changing mode");
  switch (mode)
  {
    case Mode::INSPECT:
      DDRK=0;
      DDRF=0;
      DDRA=0;
      DDRC=0;
      PORTK=0;
      PORTF=0;
      PORTA=0;
      PORTC=0;
      ReleaseBUS();
      break;
    case Mode::READWRITE:
    //default:
      DDRA=0xFF;
      DDRC=0xFF;
      set_addr(0xFFFF);
      DDRF=0;
      PORTF=0;
      DDRK |= MREQ | RD | WR;
      PORTK |= MREQ | RD | WR;
      delayMicroseconds(1);
      break;
    /*
    case Mode::WRITE:
      DDRA=0xFF;
      DDRC=0xFF;
      DDRF=0xFF;
      DDRK |= MREQ | WR;
      delayMicroseconds(1);
      Disable(WR);
      Enable(MREQ);
      delayMicroseconds(1);
      break;
    */
  }
  CurrentMode=mode;
}

uint8_t read_data(uint16_t address, bool dbg)
{
  if (CurrentMode == Mode::INSPECT)
  {
    debug_print("Cannot read data in INSPECT mode");
    return 0;
  }
  uint8_t res;
  DDRF=0;
  PORTF=0;
  set_addr(address);
  delayMicroseconds(1);
  Enable(MREQ | RD);
  delayMicroseconds(1);
  res = get_data();
  delayMicroseconds(1);
  res = get_data();
  delayMicroseconds(1);
  res = get_data();
  delayMicroseconds(1);
  res = get_data();
  delayMicroseconds(1);
  res = get_data();
  delayMicroseconds(1);
  Disable(MREQ | RD);
  delayMicroseconds(1);
  set_addr(0xFFFF);
  if (dbg)
  {
    sprintf(dmsg, "%x:%x ", int(address), int(res)); 
    debug_prints(dmsg);
  }
  return res;
}



void program_data(uint16_t address, uint8_t len, const uint8_t* data)
{
  //sprintf(dmsg, "Programming %x  len=%d",int(address),int(len));  debug_print(dmsg);
  set_mode(Mode::READWRITE);
  DDRF=0xFF;
  PORTF=0xFF;
  PORTF=0;
  //PORTC=0;
  const uint8_t* ptr=data;
  for(;len>0;--len,++address,++ptr)
  {
    //sprintf(dmsg, "%x:%x ",int(address),int(*ptr));  debug_prints(dmsg);
    set_addr(address);
    //PORTA=address;
    delayMicroseconds(1);
    set_data(*ptr);
    //PORTF=*ptr;
    delayMicroseconds(1);
    Enable(MREQ | WR);
    delayMicroseconds(1);
    Disable(MREQ | WR);
    delayMicroseconds(1);
  }
  PORTF=0;
  DDRF=0;
  //debug_print("Done");
}

void read_data(uint16_t address, uint8_t len, uint8_t* data)
{
  bool dbg=len<50;
  if (dbg)
  {
    sprintf(dmsg, "Reading %x  len=%d",int(address),int(len));  
    debug_print(dmsg);
  }
  set_mode(Mode::READWRITE);
  PORTF=0;
  DDRF=0;
  PORTF=0;
  delayMicroseconds(1);
  uint8_t* ptr=data;
  for(;len>0;--len,++address,++ptr)
    *ptr = read_data(address, dbg);
  if (dbg)
    debug_print("Done");
}

void clock_read_bus(uint8_t* data)
{
  set_mode(Mode::INSPECT);
  ClockTick();
  data[0]=PINA;
  data[1]=PINC;
  data[2]=PINF;
  data[3]=PINK;
}

void zboard_init()
{
  DDRK=0;
  PORTK=0;
  DDRA=0;
  PORTA=0;
  DDRC=0;
  PORTC=0;
  DDRF=0;
  PORTF=0;
  TCCR3A = (1<<WGM31)|(1<<WGM30);
  TCCR3B = (1<<WGM33) | (1<<CS30);
  OCR3AH=0;
  OCR3AL=4;
  CurrentMode = Mode::INSPECT;
  pinMode(5,OUTPUT);
  digitalWrite(5,LOW);
  //analogWrite(3,128); // Clock
  //set_mode(Mode::READ);
}
