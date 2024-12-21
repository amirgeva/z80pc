#include <Arduino.h>
#include <zvga.h>
#include <zspi.h>
#include <protocol.h>

void setup() {
  zvga_setup();
}

void loop() {
  zvga_loop();
}