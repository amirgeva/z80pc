#include "zvga.h"
#include "zspi.h"
#include "iprotocol.h"

void setup()
{
    Serial.begin(115200,SERIAL_8N1, 44, 43);
    Serial1.begin(115200, SERIAL_8N1, 9, 14);
    delay(500);
    vga_setup();
    spi_setup();
    Serial1.println("Init done");
}

void loop()
{
    spi_loop();
    //vga_loop();
}
