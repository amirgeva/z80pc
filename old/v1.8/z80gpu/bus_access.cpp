#include <stdio.h>
#include "bus_access.h"
#include "hardware/spi.h"
#include "hardware/pwm.h"
#include "hardware/gpio.h"
#include "pico/time.h"
#include "consts.h"

volatile bool bus_acquired = false;
bool clock_pwm = false;

//#define BITBANG_SPI

#define SPI_PORT spi0
#define PIN_MISO 4
#define PIN_SCK  2
#define PIN_MOSI 3

#define PIN_SCPY 26
#define PIN_OE 27
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
#define PIN_M1 28

#define HIGH 1
#define LOW 0

const int out_pins[] = {
    PIN_SCPY,
    PIN_OE,
    PIN_CLK_EN,
    PIN_DIN_EN,
    PIN_DOE,
    PIN_SOE,
    PIN_BUSREQ,
    PIN_INT,
    PIN_DRESET
};

const int out_init[] = {
    0, // SCPY
    1, // OE
    1, // CLK_EN
    1, // PIN_DIN_EN
    1, // PIN_DOE
    1, // PIN_SOE
    1, // PIN_BUSREQ
    1, // PIN_INT
    1  // PIN_DRESET
};

const int in_pins[] = {
    PIN_BUSACQ,
    PIN_IORQ,
    PIN_M1
};

volatile bool io_available=false;

void iorq_callback(uint gpio, uint32_t events)
{
    if (gpio_get(PIN_M1)>0)
        io_available=true;
}

void bus_setup()
{
#ifdef BITBANG_SPI
    gpio_set_function(PIN_MISO, GPIO_FUNC_SIO);
    gpio_set_function(PIN_SCK,  GPIO_FUNC_SIO);
    gpio_set_function(PIN_MOSI, GPIO_FUNC_SIO);
    gpio_set_dir(PIN_SCK, GPIO_OUT);
    gpio_set_dir(PIN_MOSI, GPIO_OUT);
    gpio_set_dir(PIN_MISO, GPIO_IN);
    gpio_put(PIN_SCK, false);
#else
    spi_init(SPI_PORT, 200*1000);
    gpio_set_function(PIN_MISO, GPIO_FUNC_SPI);
    gpio_set_function(PIN_SCK,  GPIO_FUNC_SPI);
    gpio_set_function(PIN_MOSI, GPIO_FUNC_SPI);
#endif

    const int OUT_N = sizeof(out_pins)/sizeof(int);
    const int IN_N = sizeof(in_pins)/sizeof(int);
    for(int i=0;i<OUT_N;++i)
    {
        gpio_set_function(out_pins[i], GPIO_FUNC_SIO);
        gpio_set_dir(out_pins[i], GPIO_OUT);
        gpio_put(out_pins[i],out_init[i]);
    }
    for(int i=0;i<IN_N;++i)
    {
        gpio_set_function(in_pins[i], GPIO_FUNC_SIO);
        gpio_set_dir(in_pins[i], GPIO_IN);
    }
    gpio_set_function(PIN_CLK,GPIO_FUNC_SIO);
    gpio_set_dir(PIN_CLK,GPIO_OUT);

    //gpio_set_irq_enabled_with_callback(PIN_M1,GPIO_IRQ_)
    gpio_set_irq_enabled_with_callback(PIN_IORQ, GPIO_IRQ_EDGE_FALL, true, &iorq_callback);

    perform_reset();

    acquire_bus();
    write_byte(IO_BUFFER-2,0);
    write_byte(IO_BUFFER-1,0);
    release_bus();
}

void clock_tick()
{
    if (clock_pwm) sleep_us(1);
    else
    {
        gpio_put(PIN_CLK,1);
        sleep_us(1);
        gpio_put(PIN_CLK,0);
        sleep_us(1);
    }
}

bool is_bus_acquired()
{
    return bus_acquired;
}

void acquire_bus()
{
    if (!bus_acquired)
    {
        //gpio_set_irq_enabled_with_callback(PIN_IORQ, GPIO_IRQ_EDGE_FALL, false, &iorq_callback);
        gpio_put(PIN_BUSREQ, 0);
        while (gpio_get(PIN_BUSACQ))
            clock_tick();
        bus_acquired=true;
    }
}

void release_bus()
{
    if (bus_acquired)
    {
        gpio_put(PIN_BUSREQ, 1);
        while (!gpio_get(PIN_BUSACQ))
            clock_tick();
        bus_acquired=false;
        //gpio_set_irq_enabled_with_callback(PIN_IORQ, GPIO_IRQ_EDGE_FALL, true, &iorq_callback);
    }
}

void trigger_interrupt()
{
    release_bus();
    gpio_put(PIN_INT,0);
    uint8_t addrl,addrh,data,flags;
    do
    {
        clock_tick();
        read_bus(addrl,addrh,data,flags);
    } while (!FLAGS_FETCH || addrh>0);
    gpio_put(PIN_INT,1);
}

void bitbanged_write(uint8_t byte)
{
    for(int i=7;i>=0;--i)
    {
        bool bit=(((byte>>i)&1) > 0);
        gpio_put(PIN_MOSI,bit);
        __asm volatile ("nop\nnop\nnop\n");
        gpio_put(PIN_SCK,true);
        sleep_us(1);
        gpio_put(PIN_SCK,false);
        __asm volatile ("nop\nnop\nnop\n");
    }
}

void bitbanged_read(uint8_t& byte)
{
    byte=0;
    for(int i=7;i>=0;--i)
    {
        //bool bit=(((byte>>i)&1) > 0);
        //gpio_put(PIN_MOSI,bit);
        //__asm volatile ("nop\nnop\nnop\n");
        gpio_put(PIN_SCK,true);
        __asm volatile ("nop\nnop\nnop\n");
        if (gpio_get(PIN_MISO))
            byte|=(1<<i);
        sleep_us(1);
        gpio_put(PIN_SCK,false);
        sleep_us(1);
        //__asm volatile ("nop\nnop\nnop\n");
    }

}

void bitbanged_write(const uint8_t* buffer, int len)
{
    for(int i=0;i<len;++i)
        bitbanged_write(buffer[i]);
}

void bitbanged_read(uint8_t* buffer, int len)
{
    for(int i=0;i<len;++i)
        bitbanged_read(buffer[i]);
}

#ifdef BITBANG_SPI
#define SPI_WRITE(buf,len) bitbanged_write(buf,len)
#define SPI_READ(buf,len) bitbanged_read(buf,len)
#else
#define SPI_WRITE(buf,len) spi_write_blocking(SPI_PORT,buf,len)
#define SPI_READ(buf,len) spi_read_blocking(SPI_PORT,0,buf,len)
#endif


bool write_byte(uint16_t addr, uint8_t data)
{
    if (!bus_acquired) return false;
    uint8_t tx[4], rx[4];
    tx[0]=2;
    tx[1]=data;
    tx[2]=(addr>>8);
    tx[3]=addr&0xFF;
    SPI_WRITE(tx, 4);
    gpio_put(PIN_SCPY, HIGH);
    gpio_put(PIN_SCPY, LOW);
    gpio_put(PIN_OE, LOW);
    gpio_put(PIN_DOE, LOW);
    gpio_put(PIN_SOE, LOW);
    sleep_us(1);
    gpio_put(PIN_SOE, HIGH);
    gpio_put(PIN_DOE, HIGH);
    gpio_put(PIN_OE, HIGH);
    return true;
}

uint8_t read_byte(uint16_t addr)
{
    if (!bus_acquired) return 0;
    uint8_t tx[4], rx[4];
    tx[0]=4;
    tx[1]=0;
    tx[2]=(addr>>8);
    tx[3]=addr&0xFF;
    
    SPI_WRITE(tx, 4);
    gpio_put(PIN_SCPY, HIGH);
    gpio_put(PIN_SCPY, LOW);
    gpio_put(PIN_OE, LOW);
    gpio_put(PIN_SOE, LOW);
    sleep_us(1);

    gpio_put(PIN_DIN_EN, LOW);
    sleep_us(1);
    gpio_put(PIN_DIN_EN, HIGH);

    gpio_put(PIN_SOE, HIGH);
    gpio_put(PIN_OE, HIGH);

    gpio_put(PIN_CLK_EN,LOW);
    SPI_READ(rx, 1);
    gpio_put(PIN_CLK_EN,HIGH);
    return rx[0];
}

void read_bus(uint8_t* buffer)
{
    gpio_put(PIN_DIN_EN, LOW);
    sleep_us(1);
    gpio_put(PIN_DIN_EN, HIGH);

    gpio_put(PIN_CLK_EN,LOW);
    sleep_us(1);
    SPI_READ(buffer, 5);
    gpio_put(PIN_CLK_EN,HIGH);
}

void read_bus(uint8_t& addrl, uint8_t& addrh, uint8_t& data, uint8_t& flags)
{
    gpio_put(PIN_DIN_EN, LOW);
    sleep_us(1);
    gpio_put(PIN_DIN_EN, HIGH);

    uint8_t rx[4];
    gpio_put(PIN_CLK_EN,LOW);
    sleep_us(1);
    SPI_READ(rx, 4);
    gpio_put(PIN_CLK_EN,HIGH);
    //printf("%02x %02x %02x %02x\n",rx[0],rx[1],rx[2],rx[3]);
    data=rx[0];
    addrl=rx[1];
    addrh=rx[2];
    flags=rx[3];
}

void perform_reset()
{
    release_bus();
    gpio_put(PIN_DRESET, 0);
    for(int i=0;i<100;++i)
        clock_tick();
    gpio_put(PIN_DRESET, 1);
}

void set_clock_pwm(bool active)
{
    if (clock_pwm == active) return;
    if (active)
    {
        gpio_set_function(PIN_CLK, GPIO_FUNC_PWM);
        uint slice = pwm_gpio_to_slice_num (PIN_CLK);
        uint channel = pwm_gpio_to_channel(PIN_CLK);
        // pwm_set_wrap(slice, 149);   // Base clock is 150MHz, set pwm to 1MHz (counter limit at 150)
        // pwm_set_chan_level(slice, channel, 75);
        pwm_set_wrap(slice, 1499);   // Base clock is 150MHz, set pwm to 100KHz (counter limit at 1500)
        pwm_set_chan_level(slice, channel, 750);
        pwm_set_enabled(slice, true);
    }
    else
    {
        uint slice = pwm_gpio_to_slice_num (PIN_CLK);
        pwm_set_enabled(slice, false);
        gpio_set_function(PIN_CLK, GPIO_FUNC_SIO);
    }
    clock_pwm = active;
}
