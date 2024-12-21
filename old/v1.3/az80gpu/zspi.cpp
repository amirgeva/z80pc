#include <Arduino.h>
#include "zspi.h"
#include <ESP32SPISlave.h>
#include "iprotocol.h"

ESP32SPISlave slave;

static constexpr uint32_t BUFFER_SIZE = 32;
static constexpr uint32_t BUFFER_COUNT = 16;
uint8_t tx[BUFFER_SIZE*BUFFER_COUNT];
uint8_t rx[BUFFER_SIZE*BUFFER_COUNT];
uint8_t read_head=0;
uint8_t write_head=0;
constexpr int SLAVE_READY=2;

void spi_setup()
{
  pinMode(SLAVE_READY,OUTPUT);
  digitalWrite(SLAVE_READY,LOW);
  slave.setDataMode(SPI_MODE0);
  slave.setQueueSize(BUFFER_COUNT);
  slave.begin(VSPI);
  for(uint32_t i=0;i<BUFFER_COUNT;++i)
    tx[i*BUFFER_SIZE]=0;
}

void print_buffer(const uint8_t* data, uint8_t len)
{
  for(int i=0;i<32;++i)
  {
    int b=data[i];
    Serial.print(b);
    Serial.print(' ');
  }
  Serial.println("");
}

void spi_loop()
{
    digitalWrite(SLAVE_READY,HIGH);
    while (slave.available() != 0)
    {
        digitalWrite(SLAVE_READY,LOW);
        uint32_t offset = read_head*BUFFER_SIZE;
        read_head = (read_head+1)&(BUFFER_COUNT-1);
        const uint8_t* data = rx+offset;
        ProtocolInterface::add_data(&data[1],data[0]);
        //print_buffer(data,BUFFER_SIZE);
        slave.pop();
    }
    while (slave.remained() < (BUFFER_COUNT-2))
    {
      uint32_t offset = BUFFER_SIZE * write_head;
      write_head = (write_head+1)&(BUFFER_COUNT-1);
      slave.queue(rx+offset, tx+offset, BUFFER_SIZE);
    }
}
