#include <zspi.h>
#include <ESP32SPISlave.h>
#include <protocol.h>

ESP32SPISlave slave;

static constexpr uint32_t BUFFER_SIZE = 256;
uint8_t tx[BUFFER_SIZE];
uint8_t rx[BUFFER_SIZE];

void zspi_setup()
{
    slave.setDataMode(SPI_MODE0);
    slave.begin(VSPI);
    tx[0]=0;
}

void zspi_loop()
{
    if (slave.remained() == 0)
        slave.queue(rx, tx, BUFFER_SIZE);
    while (slave.available() != 0)
    {
        uint8_t n=uint8_t(slave.size());
        if (n>0)
        {
            --n;
            n=std::min(n, rx[0]);
            Protocol::add_data(&rx[1],n);
        }
    }
}