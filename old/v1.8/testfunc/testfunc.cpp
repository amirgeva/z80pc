#include <stdio.h>
#include "pico/stdlib.h"

const uint8_t data1[] = {
    0xea, 0x91, 0x05, 0xff, 0x41, 0x43, 0x4b, 0x0a, 0x63
};

const uint8_t data2[] = {
    0x6f, 0x63, 0x6f, 0x6c, 0x20, 0x69, 0x6d, 0x70
};

int main()
{
    stdio_init_all();
    sleep_ms(5000);
    int n1=sizeof(data1);
    int n2=sizeof(data2);
    while (true)
    {
        fwrite(data1,1,n1,stdout);
        fflush(stdout);
        fwrite(data2,1,n2,stdout);
        fflush(stdout);
        sleep_ms(1000);
    }
}
