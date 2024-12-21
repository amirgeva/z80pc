#include <stdio.h>
#include "bus_access.h"
#include "hardware/spi.h"
#include "hardware/pwm.h"
#include "hardware/gpio.h"
#include "pico/time.h"
#include "consts.h"
#include "MCP23S17/MCP23S17.h"
#include "MCP23S17/platform/pico.h"
#include "debug_protocol.h"

void init_filesys();

volatile bool bus_acquired = false;
volatile bool data_output = false;
bool clock_pwm = false;
bool restore_pwm = false;

// #define BITBANG_SPI

#define SPI_PORT spi0
#define PIN_MISO 4
#define PIN_SCK 2
#define PIN_MOSI 3
#define PIN_CS0 5
#define PIN_CS1 6
#define PIN_CSSD 26

#define PIN_MREQ 7
#define PIN_WAIT 8
#define PIN_CLK 9
#define PIN_BUSREQ 10
#define PIN_DRESET 11
#define PIN_INT 20
#define PIN_IORQ 21
#define PIN_BUSACQ 22
#define PIN_27 27
#define PIN_28 28

#define HIGH 1
#define LOW 0

const int out_pins[] = {
    PIN_BUSREQ,
    PIN_INT,
    PIN_DRESET,
    PIN_CS0,
    PIN_CS1,
    PIN_CSSD,
    PIN_WAIT,
    PIN_CLK};

const int out_init[] = {
    1, // BUSREQ
    1, // INT
    1, // DRESET
    1, // CS0
    1, // CS1
    1, // CSSD
    1, // WAIT
    0  // CLK
};

const int in_pins[] = {
    PIN_BUSACQ,
    PIN_IORQ,
    PIN_MREQ,
    PIN_27,
    PIN_28};

ispi::PicoHardwareSPI *inst1 = nullptr;
ispi::PicoHardwareSPI *inst2 = nullptr;
ispi::PicoHardwareSPI *sd_inst = nullptr;
MCP23S17 *mcp1 = nullptr;
MCP23S17 *mcp2 = nullptr;

volatile bool io_available = false;
volatile bool iorq_detect = true;

void iorq_callback(uint gpio, uint32_t events)
{
    gpio_put(PIN_WAIT,0);
    if (iorq_detect)
        io_available = true;
    //sleep_us(10);
    gpio_put(PIN_WAIT,1);
}

void bus_setup()
{
    inst1 = new ispi::PicoHardwareSPI(0, 200 * 1000, PIN_SCK, PIN_MOSI, PIN_MISO, PIN_CS0);
    inst2 = new ispi::PicoHardwareSPI(*inst1, PIN_CS1);
    sd_inst = new ispi::PicoHardwareSPI(*inst1, PIN_CSSD);
    mcp1 = new MCP23S17(inst1, 0);
    mcp2 = new MCP23S17(inst2, 1);
    mcp1->begin();
    mcp2->begin();
    mcp1->pinMode16(0xFFFF); // Read mode
    mcp2->pinMode16(0xFFFF);
    const int OUT_N = sizeof(out_pins) / sizeof(int);
    const int IN_N = sizeof(in_pins) / sizeof(int);
    for (int i = 0; i < OUT_N; ++i)
    {
        gpio_set_function(out_pins[i], GPIO_FUNC_SIO);
        gpio_set_dir(out_pins[i], GPIO_OUT);
        gpio_put(out_pins[i], out_init[i]);
    }
    for (int i = 0; i < IN_N; ++i)
    {
        gpio_set_function(in_pins[i], GPIO_FUNC_SIO);
        gpio_set_dir(in_pins[i], GPIO_IN);
    }

    gpio_set_irq_enabled_with_callback(PIN_IORQ, GPIO_IRQ_EDGE_FALL, true, &iorq_callback);

    perform_reset();

    acquire_bus();

    init_filesys();

    write_byte(IO_BUFFER - 2, 0);
    write_byte(IO_BUFFER - 1, 0);
    for (uint16_t addr = 0xFF00; addr != 0; addr++)
        write_byte(addr, 0);
    release_bus();
    perform_reset();
}

void clock_tick()
{
    if (clock_pwm)
        sleep_us(1);
    else
    {
        gpio_put(PIN_CLK, 1);
        sleep_us(1);
        gpio_put(PIN_CLK, 0);
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
        iorq_detect=false;
        restore_pwm = is_clock_pwm();
        set_clock_pwm(false);
        gpio_put(PIN_BUSREQ, 0);
        while (gpio_get(PIN_BUSACQ))
            clock_tick();
        bus_acquired = true;
        mcp1->pinMode16(0);                   // set address as output
        mcp2->pinMode8(0, 0xFF);              // set data as input
        mcp2->pinMode1(10, MCP23S17::OUTPUT); // \ RD and WR pins
        mcp2->pinMode1(11, MCP23S17::OUTPUT); // /
        mcp2->write1(10, 1);
        mcp2->write1(11, 1);
        gpio_set_dir(PIN_MREQ, true);
        gpio_put(PIN_MREQ, 1);
        data_output = false;
    }
}

void release_bus()
{
    if (bus_acquired)
    {
        gpio_set_dir(PIN_MREQ, false);
        mcp1->pinMode16(0xFFFF); // All input
        mcp2->pinMode16(0xFFFF); // All input
        data_output = false;
        iorq_detect=true;
        gpio_put(PIN_BUSREQ, 1);
        while (!gpio_get(PIN_BUSACQ))
            clock_tick();
        if (restore_pwm)
        {
            restore_pwm=false;
            set_clock_pwm(true);
        }
        bus_acquired = false;
    }
}

void trigger_interrupt()
{
    iorq_detect = false;
    release_bus();
    gpio_put(PIN_INT, 0);
    uint8_t addrl, addrh, data, flags;
    do
    {
        clock_tick();
        read_bus(addrl, addrh, data, flags);
    } while (!FLAGS_FETCH || addrh > 0);
    gpio_put(PIN_INT, 1);
    iorq_detect = true;
}

void bitbanged_write(uint8_t byte)
{
    for (int i = 7; i >= 0; --i)
    {
        bool bit = (((byte >> i) & 1) > 0);
        gpio_put(PIN_MOSI, bit);
        __asm volatile("nop\nnop\nnop\n");
        gpio_put(PIN_SCK, true);
        sleep_us(1);
        gpio_put(PIN_SCK, false);
        __asm volatile("nop\nnop\nnop\n");
    }
}

void bitbanged_read(uint8_t &byte)
{
    byte = 0;
    for (int i = 7; i >= 0; --i)
    {
        // bool bit=(((byte>>i)&1) > 0);
        // gpio_put(PIN_MOSI,bit);
        //__asm volatile ("nop\nnop\nnop\n");
        gpio_put(PIN_SCK, true);
        __asm volatile("nop\nnop\nnop\n");
        if (gpio_get(PIN_MISO))
            byte |= (1 << i);
        sleep_us(1);
        gpio_put(PIN_SCK, false);
        sleep_us(1);
        //__asm volatile ("nop\nnop\nnop\n");
    }
}

void bitbanged_write(const uint8_t *buffer, int len)
{
    for (int i = 0; i < len; ++i)
        bitbanged_write(buffer[i]);
}

void bitbanged_read(uint8_t *buffer, int len)
{
    for (int i = 0; i < len; ++i)
        bitbanged_read(buffer[i]);
}

#ifdef BITBANG_SPI
#define SPI_WRITE(buf, len) bitbanged_write(buf, len)
#define SPI_READ(buf, len) bitbanged_read(buf, len)
#else
#define SPI_WRITE(buf, len) spi_write_blocking(SPI_PORT, buf, len)
#define SPI_READ(buf, len) spi_read_blocking(SPI_PORT, 0, buf, len)
#endif

bool write_byte(uint16_t addr, uint8_t data)
{
    if (!bus_acquired)
        return false;
    if (!data_output)
    {
        mcp2->pinMode8(0, 0); // Set data to output
        data_output = true;
    }
    mcp1->write16((addr >> 8) | (addr << 8));
    mcp2->write8(0, data);
    gpio_put(PIN_MREQ, 0);
    mcp2->write1(11, 0);
    sleep_us(20);
    mcp2->write1(11, 1);
    gpio_put(PIN_MREQ, 1);
    return true;
}

uint8_t read_byte(uint16_t addr)
{
    if (!bus_acquired)
        return 0;
    if (data_output)
    {
        mcp2->pinMode8(0, 0xFF); // Set data to input
        data_output = false;
    }
    mcp1->write16((addr >> 8) | (addr << 8));
    gpio_put(PIN_MREQ, 0);
    mcp2->write1(10, 0);
    uint8_t res = mcp2->read8(0);
    mcp2->write1(10, 1);
    gpio_put(PIN_MREQ, 1);
    return res;
}

void read_bus(uint8_t *buffer)
{
    if (is_bus_acquired())
        return;
    buffer[0] = mcp1->read8(0);
    buffer[1] = mcp1->read8(1);
    buffer[2] = mcp2->read8(0);
    buffer[3] = mcp2->read8(1);
}

void read_bus(uint8_t &addrl, uint8_t &addrh, uint8_t &data, uint8_t &flags)
{
    if (is_bus_acquired())
        return;
    addrl = mcp1->read8(0);
    addrh = mcp1->read8(1);
    data = mcp2->read8(0);
    flags = mcp2->read8(1);
    // char msg[64];
    // sprintf(msg, "%02x %02x %02x %02x",int(addrh),int(addrl),int(data),int(flags));
    // g_DebugProtocol.print_text(msg);
}

void perform_reset()
{
    release_bus();
    gpio_put(PIN_DRESET, 0);
    for (int i = 0; i < 100; ++i)
        clock_tick();
    gpio_put(PIN_DRESET, 1);
}

bool is_clock_pwm()
{
    return clock_pwm;
}

void set_clock_pwm(bool active)
{
    if (clock_pwm == active)
        return;
    if (active)
    {
        g_DebugProtocol.print_text("PWM");
        gpio_set_function(PIN_CLK, GPIO_FUNC_PWM);
        uint slice = pwm_gpio_to_slice_num(PIN_CLK);
        uint channel = pwm_gpio_to_channel(PIN_CLK);
        // pwm_set_wrap(slice, 37);   // Base clock is 150MHz, set pwm to 4MHz (counter limit at 37)
        // pwm_set_chan_level(slice, channel, 18);
        pwm_set_wrap(slice, 149); // Base clock is 150MHz, set pwm to 1MHz (counter limit at 150)
        pwm_set_chan_level(slice, channel, 75);
        // pwm_set_wrap(slice, 1499);   // Base clock is 150MHz, set pwm to 100KHz (counter limit at 1500)
        // pwm_set_chan_level(slice, channel, 750);
        pwm_set_enabled(slice, true);
    }
    else
    {
        uint slice = pwm_gpio_to_slice_num(PIN_CLK);
        pwm_set_enabled(slice, false);
        gpio_set_function(PIN_CLK, GPIO_FUNC_SIO);
    }
    clock_pwm = active;
}

bool is_fetching(uint8_t flags)
{
    return ((flags & 0x10) == 0);
}