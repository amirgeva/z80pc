#include "iface.h"
#include "zboard.h"
#include <SoftwareSerial.h>

SoftwareSerial debug_serial(11, 10); // RX, TX
void debug_print(const char* msg)
{
  debug_serial.println(msg);
}

void debug_prints(const char* msg)
{
  debug_serial.print(msg);
}

void setup() {
  Serial.begin(115200);
  delay(1000);
  debug_serial.begin(9600);
  debug_serial.println("\n\n\n\n\n\n\n\n\n\n\n\n\n\nStarting...\n\n");
  iface_init();
  zboard_init();
}

void loop() {
  handle_incoming();
}
