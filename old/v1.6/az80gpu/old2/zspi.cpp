#include <SPI.h>
#define HSPI_HOST SPI2_HOST
#define VSPI_HOST SPI2_HOST
#define VSPI HSPI
#include <ESP32SPISlave.h>
#include "zspi.h"
#include "iprotocol.h"
#include "circular.h"

ESP32SPISlave slave;

static constexpr uint32_t BUFFER_SIZE {32};
static constexpr uint32_t GPC_BUFFER_SIZE = 65536;
uint8_t spi_slave_tx_buf[BUFFER_SIZE];
uint8_t spi_slave_rx_buf[BUFFER_SIZE];
unsigned long start_time=0, last_time=0;

QueueHandle_t queue;
uint8_t* queue_buffer=0;
StaticQueue_t xQueueBuffer;
constexpr int queueSize = 65536;

void protocol_single()
{
  uint8_t b;
  while (pdTRUE == xQueueReceive(queue, &b, 100))
    ProtocolInterface::add_data(b);
}

void protocol_task(void* params)
{
  while (true) protocol_single();
}

void spi_setup()
{
  Serial.println("SPI setup");
  pinMode(14,OUTPUT);
  digitalWrite(14,HIGH);
  memset(spi_slave_tx_buf, 0, BUFFER_SIZE);
  memset(spi_slave_rx_buf, 0, BUFFER_SIZE);
  //gpc_buffer=new uint8_t[65536];
  //gpc=new CircularBuffer(gpc_buffer,65536);
  //gpc.init(gpc_buffer, GPC_BUFFER_SIZE);
  queue_buffer = (uint8_t*)heap_caps_malloc(queueSize, MALLOC_CAP_INTERNAL | MALLOC_CAP_8BIT);
  ///queue = xQueueCreate(queueSize, 1);
  queue = xQueueCreateStatic(queueSize, 1, queue_buffer, &xQueueBuffer);
  if (!queue)
  {
    Serial.println("Failed to create queue");
    return;
  }

/*
  xTaskCreatePinnedToCore(
                    protocol_task,   // Function to implement the task
                    "protocol_task", // Name of the task
                    10000,           // Stack size in words
                    NULL,            // Task input parameter 
                    0,               // Priority of the task 
                    NULL,            // Task handle. 
                    1);              // Core where the task should run 
*/
  
  slave.setDataMode(SPI_MODE0);
  slave.begin();
  Serial.println("done");
  last_time=start_time=millis();
  slave.queue(spi_slave_rx_buf, spi_slave_tx_buf, BUFFER_SIZE);
  digitalWrite(14,LOW);
}

unsigned long rx_count=0;
int ready_state=0;

void spi_loop()
{
  /*
  if (slave.remained() == 0)
  {
    //Serial.println("Queueing buffer");
    slave.queue(spi_slave_rx_buf, spi_slave_tx_buf, BUFFER_SIZE);
    digitalWrite(14,LOW);
    ready_state=1;
  }
  */
  //slave.wait(spi_slave_rx_buf, spi_slave_tx_buf, BUFFER_SIZE);
  while (slave.available())
  {
    digitalWrite(14,HIGH);
    ready_state=0;
    //Serial.println("Received packet");
    //Serial.write(&spi_slave_rx_buf[1],spi_slave_rx_buf[0]);
    rx_count+=spi_slave_rx_buf[0];
    //if (gpc.size()>60000)
    ///{
    //  Serial.println("Buffer Full");
    //  delay(1000);
    //}
    //else
    {
      for(uint8_t i=0;i<spi_slave_rx_buf[0];++i)
      {
        xQueueSend(queue, &spi_slave_rx_buf[i+1], portMAX_DELAY);
        //gpc.push(spi_slave_rx_buf[i+1]);
      }
    }
    slave.pop();
    protocol_single();

    unsigned long cur=millis();
    if ((cur-last_time)>1000)
    {
      last_time=cur;
      Serial.print(rx_count);
      Serial.print(" Bps.   ready=");
      Serial.println(ready_state);
      rx_count=0;
    }

    
    slave.queue(spi_slave_rx_buf, spi_slave_tx_buf, BUFFER_SIZE);
    digitalWrite(14,LOW);
    ready_state=1;
  }
}

/*
static constexpr uint32_t BUFFER_SIZE = 32;
static constexpr uint32_t BUFFER_COUNT = 2;
uint8_t tx[BUFFER_SIZE*BUFFER_COUNT];
uint8_t rx[BUFFER_SIZE*BUFFER_COUNT];
uint8_t read_head=0;
uint8_t write_head=0;
constexpr int SLAVE_READY=2;

void spi_setup()
{
  Serial.println("SPI setup");
  pinMode(SLAVE_READY,OUTPUT);
  digitalWrite(SLAVE_READY,LOW);
  slave.setDataMode(SPI_MODE0);
  slave.setQueueSize(BUFFER_COUNT);
  slave.begin(VSPI);
  for(uint32_t i=0;i<BUFFER_COUNT;++i)
    tx[i*BUFFER_SIZE]=0;
  Serial.println("done");
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
      Serial.println("Received packet");
        digitalWrite(SLAVE_READY,LOW);
        uint32_t offset = read_head*BUFFER_SIZE;
        read_head = (read_head+1)&(BUFFER_COUNT-1);
        const uint8_t* data = rx+offset;
        ProtocolInterface::add_data(&data[1],data[0]);
        tx[offset]=0; // Clear completed transmission
        slave.pop();
    }
    while (slave.remained() < (BUFFER_COUNT-2))
    {
      Serial.println("Queueing buffer");
      uint32_t offset = BUFFER_SIZE * write_head;
      write_head = (write_head+1)&(BUFFER_COUNT-1);
      slave.queue(rx+offset, tx+offset, BUFFER_SIZE);
    }
}
*/
