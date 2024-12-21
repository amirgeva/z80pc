#include <zvga.h>
#include <ESP32Lib.h>
#include <Ressources/CodePage437_8x8.h>

const int redPin = 14;
const int greenPin = 22;
const int bluePin = 27;
const int hsyncPin = 32;
const int vsyncPin = 33;

VGA6Bit dsp;
PinConfig pinConfig(-1, -1, -1, 21, 22,  -1, -1, -1, 25, 26,  -1, -1, 27, 32,  16, 17,  -1);

#define WIDTH 400
#define HEIGHT 300
#define VGA_MODE VGA::MODE400x300

void vga_setup()
{
  dsp.init(VGA_MODE, pinConfig);
  dsp.setFont(CodePage437_8x8);
  dsp.clear();
}

void zvga_setup()
{}

void zvga_loop()
{}
