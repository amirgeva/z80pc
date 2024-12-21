#include "zvga.h"
#include "zspi.h"
#include "protocol.h"

void setup()
{
  Serial.begin(115200);
  delay(500);
  Serial.println("Initializing");
  vga_setup();
  spi_setup();
}

void loop()
{
  vga_loop();
  spi_loop();
}
