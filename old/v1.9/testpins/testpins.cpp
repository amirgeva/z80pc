#include <stdio.h>
#include "pico/stdlib.h"
#include "hardware/spi.h"
#include "hardware/pwm.h"
#include "pico/time.h"

constexpr bool pwm_clk = true;

// SPI Defines
// We are going to use SPI 0, and allocate it to the following GPIO pins
// Pins can be changed, see the GPIO function select table in the datasheet for information on GPIO assignments
#define SPI_PORT spi0
#define PIN_MISO 4
#define PIN_SCK  2
#define PIN_MOSI 3

#define PIN_SCPY 0
#define PIN_OE 1
#define PIN_CLK_EN 5
#define PIN_DIN_EN 6
#define PIN_DOE 7
#define PIN_SOE 20
#define PIN_CLK 9
#define PIN_BUSACQ 10
#define PIN_IORQ 11
#define PIN_BUSREQ 8
#define PIN_INT 21
#define PIN_DRESET 22

#define HIGH 1
#define LOW 0

const uint8_t code[] = {
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x3e, 0x3a, 0xd3, 0x00, 0xc3, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
};

const int out_pins[] = {
    PIN_SCPY,PIN_OE,PIN_CLK_EN,PIN_DIN_EN,PIN_DOE,PIN_SOE,
    PIN_BUSREQ,PIN_INT,PIN_DRESET
};

const int in_pins[] = {
    PIN_BUSACQ,PIN_IORQ
};

/*
const uint8_t rand_data[] = {
    104,16,177,225,76,254,36,121,198,244,37,177,52,52,215,53,16,59,129,157,228,160,74,132,101,99,89,95,11,107,137,90
};
*/

volatile int event_count=0;
volatile bool io_event=false;

void iorq_callback(uint gpio, uint32_t events)
{
    ++event_count;
    io_event=true;
}

void write_byte(uint16_t addr, uint8_t data)
{
    uint8_t tx[4], rx[4];
    tx[0]=2;
    tx[1]=data;
    tx[2]=(addr>>8);
    tx[3]=addr&0xFF;
    spi_write_read_blocking(SPI_PORT, tx, rx, 4);
    gpio_put(PIN_SCPY, HIGH);
    gpio_put(PIN_SCPY, LOW);
    gpio_put(PIN_OE, LOW);
    gpio_put(PIN_DOE, LOW);
    gpio_put(PIN_SOE, LOW);
    gpio_put(PIN_SOE, HIGH);
    gpio_put(PIN_DOE, HIGH);
    gpio_put(PIN_OE, HIGH);
}

uint8_t read_byte(uint16_t addr)
{
    uint8_t tx[4], rx[4];
    tx[0]=4;
    tx[1]=0;
    tx[2]=(addr>>8);
    tx[3]=addr&0xFF;
    spi_write_read_blocking(SPI_PORT, tx, rx, 4);
    gpio_put(PIN_SCPY, HIGH);
    gpio_put(PIN_SCPY, LOW);
    gpio_put(PIN_OE, LOW);
    gpio_put(PIN_SOE, LOW);

    gpio_put(PIN_DIN_EN, LOW);
    gpio_put(PIN_DIN_EN, HIGH);

    gpio_put(PIN_SOE, HIGH);
    gpio_put(PIN_OE, HIGH);

    gpio_put(PIN_CLK_EN,LOW);
    spi_write_read_blocking(SPI_PORT, tx, rx, 1);
    gpio_put(PIN_CLK_EN,HIGH);
    return rx[0];
}

uint16_t addr=0;

void upload_code()
{
    for(int i=0;i<2;++i)
    {
        for(uint16_t addr=0;addr<sizeof(code);++addr)
            write_byte(addr,code[addr]);
    }
}

void test_read_write(const uint8_t* data, const int N)
{
    addr=0;
    printf("Writing to RAM at: %hx  size %d\n", addr,N);
    for(int i=0;i<=N;++i)
    {
        int j=(i>=N?(i-N):i);
        //int j=i;
        write_byte(addr+j,data[j]);
        printf("+");
    }
    printf("\n");
    printf("Reading from RAM\n");
    for(int i=0;i<=N;++i)
    {
        int j=(i>=N)?(i-N):i;
        //int j=i;
        uint16_t b = read_byte(addr+j);
        if (b==data[j]) printf("+");
        else //printf("-");
        {
            uint16_t r=data[j];
            printf("%d  %hx expecting %hx\n", j, b, r);
        }
    }
    addr+=N;
}

void test_read_speed()
{
    uint32_t start = to_ms_since_boot(get_absolute_time());
    for(addr=0;addr<32768;++addr)
    {
        read_byte(addr);
    }
    uint32_t stop = to_ms_since_boot(get_absolute_time());
    uint32_t period=stop-start;
    printf("Read took %dms\n",period);
}

void clock_tick()
{
    if (!pwm_clk)
    {
        gpio_put(PIN_CLK, 1);
        sleep_ms(1);
        gpio_put(PIN_CLK, 0);
        sleep_ms(1);
    }
}

void perform_reset()
{
    gpio_put(PIN_DRESET, 0);
    if (pwm_clk)
    {
        sleep_ms(10);
    }
    else
    {
        for(int i=0;i<100;++i)
        clock_tick();
    }
    gpio_put(PIN_DRESET, 1);
}

int main()
{
    stdio_init_all();

    // SPI initialisation. This example will use SPI at 1MHz.
    spi_init(SPI_PORT, 1000*1000);
    gpio_set_function(PIN_MISO, GPIO_FUNC_SPI);
    //gpio_set_function(PIN_CS,   GPIO_FUNC_SIO);
    gpio_set_function(PIN_SCK,  GPIO_FUNC_SPI);
    gpio_set_function(PIN_MOSI, GPIO_FUNC_SPI);

    const int OUT_N = sizeof(out_pins)/sizeof(int);
    const int IN_N = sizeof(in_pins)/sizeof(int);
    for(int i=0;i<OUT_N;++i)
    {
        gpio_set_function(out_pins[i], GPIO_FUNC_SIO);
        gpio_set_dir(out_pins[i], GPIO_OUT);
    }
    for(int i=0;i<IN_N;++i)
    {
        gpio_set_function(in_pins[i], GPIO_FUNC_SIO);
        gpio_set_dir(in_pins[i], GPIO_IN);
        //gpio_pull_up(in_pins[i]);
    }
    gpio_set_irq_enabled_with_callback(PIN_IORQ, GPIO_IRQ_EDGE_FALL, true, &iorq_callback);
    if (pwm_clk)
    {
        gpio_set_function(PIN_CLK, GPIO_FUNC_PWM);
        uint slice = pwm_gpio_to_slice_num (PIN_CLK);
        uint channel = pwm_gpio_to_channel(PIN_CLK);
        //pwm_set_clkdiv(slice, 150.0f);
        pwm_set_wrap(slice, 149);
        pwm_set_chan_level(slice, channel, 75);
        pwm_set_enabled(slice, true);
    }
    else
    {
        gpio_set_function(PIN_CLK, GPIO_FUNC_SIO);
    }

    sleep_ms(5000);
    printf("Reset CPU\n");
    perform_reset();
    printf("Request BUS\n");
    gpio_put(PIN_BUSREQ, 0);
    while (gpio_get(PIN_BUSACQ)) clock_tick();
    printf("BUS acquired\n");
    //for(int i=0;i<10;++i) clock_tick();
    test_read_write(code, sizeof(code));

    printf("Release BUS\n");
    gpio_put(PIN_BUSREQ, 1);
    //printf("Sleeping 100ms\n");
    //sleep_ms(100);
    printf("Resetting\n");
    perform_reset();
    printf("Loop\n");
    int last_event_count=0;
    while (true)
    {
        if (event_count > last_event_count)
        {
            printf("Events %d\n",event_count);
            last_event_count=event_count;
        }
        clock_tick();
        //test_read_write();
        //test_read_speed();
        //printf("Hello, world!\n");
        //sleep_ms(1);
    }
}
