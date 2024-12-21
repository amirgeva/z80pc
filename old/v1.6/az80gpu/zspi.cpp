#include <Arduino.h>
#include <ESP32DMASPISlave.h>
#include "zspi.h"
#include "iprotocol.h"
#include "circular.h"
#include "crc16.h"

ESP32DMASPI::Slave slave;
constexpr int SCS = 21;
constexpr int CS = 10;

#pragma pack(push, 1)

struct Header
{
	uint16_t magic, length, crc;
};

constexpr size_t BUFFER_SIZE=2048;

CircularBuffer circular;

void push(const char* text)
{
    for(;*text;++text)
        circular.push(*text);
}

const char* hex = "0123456789ABCDEF";
void push_num(uint16_t num)
{
    circular.push(hex[(num>>12)&0x0F]);
    circular.push(hex[(num>>8 )&0x0F]);
    circular.push(hex[(num>>4 )&0x0F]);
    circular.push(hex[(num    )&0x0F]);
}

//#define PUSH(x) push(x)
//#define PUSH_NUM(x) push_num(x)
#define PUSH(x)
#define PUSH_NUM(x)

struct SPIBuffer
{
	union {
		uint8_t data[2048];
		Header  header;
	} buffer;

    bool verify(uint16_t total_size) const
    {
        if (buffer.header.magic != 0xDA7A) 
        {
            PUSH("bad magic\r\n");
            return false;
        }
        if (buffer.header.length>2040)
        {
            PUSH("large size\r\n");
            return false;
        }
        if (total_size != (sizeof(Header)+buffer.header.length))
        {
            PUSH("size mismatch\r\n");
            return false;
        }
        uint16_t crc = calculate_crc16(payload(), buffer.header.length);
        if (buffer.header.crc != crc)
        {
            PUSH("bad crc\r\n");
            return false;
        }
        return true;
    }

    const uint8_t* payload() const
    {
        return &buffer.data[sizeof(Header)];
    }
};


void receive_transactions(void* parameters)
{
    uint16_t last_size=2048;
    uint8_t* tx_data;
    uint8_t* rx_data;
    tx_data = slave.allocDMABuffer(BUFFER_SIZE);
    rx_data = slave.allocDMABuffer(BUFFER_SIZE);
    while (1)
    {
        for(uint16_t i=0;i<last_size;++i)
        {
            rx_data[i]=0;
            tx_data[i]=0;
        }
        digitalWrite(SCS, LOW);
        //while (digitalRead(CS)==HIGH);
        //digitalWrite(SCS, HIGH);
        const uint16_t received_bytes = slave.transfer(tx_data, rx_data, BUFFER_SIZE);
        digitalWrite(SCS,HIGH);
        if (received_bytes>2048)
        {
            continue;
        }
        last_size=received_bytes;
        if (received_bytes<=sizeof(Header)) continue;
        const SPIBuffer* spi_buffer = reinterpret_cast<const SPIBuffer*>(rx_data);
        if (spi_buffer->verify(received_bytes))
        {
            const uint8_t* payload = spi_buffer->payload();
            uint16_t len = spi_buffer->buffer.header.length;
            for(uint16_t i=0;i<len;++i)
            {
                while (circular.full()); // wait for consumer
                circular.push(payload[i]);
            }
        }
        else 
        {
            circular.push(0x40);
            circular.push(0x40);
            circular.push(0x40);
            circular.push(0x40);
        }
        /*
        else
        {
            PUSH("----------\r\n");
            for(uint16_t i=0;i<received_bytes;++i)
                circular.push(rx_data[i]);
            PUSH("----------\r\n");                
        }
        */
    }
}


void spi_setup()
{
    pinMode(SCS,OUTPUT);
    digitalWrite(SCS,HIGH);

    slave.setDataMode(SPI_MODE0);
    slave.setMaxTransferSize(BUFFER_SIZE);
    slave.setQueueSize(1);
    slave.begin();

    // Start task on core 0
    xTaskCreatePinnedToCore(receive_transactions, "Receive", 8192, NULL, 1, NULL, 0);
}

void spi_loop()
{
    byte b;
    //while (xQueueReceive(queue, &b, 0) == pdTRUE)
    while (circular.pop(b))
    {
        //Serial1.write(b);
        ProtocolInterface::add_data(b);
    }
}
