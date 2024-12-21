#include "platform_utils.h"
#include <pico/time.h>

void delay_ms (uint32_t ms)
{
    sleep_ms(ms);
}