#include "iface.h"
#include "zboard.h"

void setup() {
  Serial.begin(115200);
  iface_init();
  zboard_init();
}

void loop() {
  handle_incoming();
}
