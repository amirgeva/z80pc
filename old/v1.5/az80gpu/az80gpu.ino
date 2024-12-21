#include "zvga.h"
#include "zspi.h"
#include "zsd.h"
#include "protocol.h"

void setup()
{
  Serial.begin(115200);
  delay(500);
  Serial.println("Initializing");
  sd_init();
  vga_setup();
  spi_setup();
}

void loop()
{
  sd_loop();
  vga_loop();
  spi_loop();
}
