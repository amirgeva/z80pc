#include <cstdint>
#include <stdio.h>
//#include <tusb.h>
#include "pico/stdlib.h"
#include "debug_protocol.h"
#include "bus_access.h"
#include "gpu_protocol.h"
#include "gpu.h"
#include "consts.h"
#include "circular.h"
//#include "hardware/uart.h"
//#define UART_ID uart0

GPUProtocol g_GPUProtocol;

extern CircularBuffer g_Incoming;

constexpr int W=640,H=480;

extern volatile bool io_available;

void initialize_frame_buffer(uint8_t* frame_buffer);

uint32_t millis()
{
    return to_ms_since_boot(get_absolute_time());
}

void process_disk_transaction();

void gpu_main(uint8_t* frame_buffer)
{
    g_DebugProtocol.print_text("Starting");
    gpu_setup(frame_buffer);
    initialize_frame_buffer(frame_buffer);
    uint8_t gpu_command_buffer[0x400];
    uint32_t last_time=millis();
    while (true)
    {
        int gpu_command_buffer_available=0;
        uint32_t now = millis();
        while (!g_Incoming.empty())
        {
            uint8_t b;
            if (g_Incoming.pop(b))
                g_DebugProtocol.add_byte(b);
        }
        if (io_available)
        {
            io_available=false;
            ACQUIRE;
            uint16_t addr=IO_BUFFER-2;
            char msg[32];
            g_DebugProtocol.print_text("IO");
            uint16_t length = read_byte(addr+1);
            length <<= 8;
            length |= read_byte(addr);
            if (length == 0xFFFF) // Disk transaction
            {
                g_DebugProtocol.print_text("DISK");
                process_disk_transaction();
                write_byte(IO_BUFFER-2,0);
                write_byte(IO_BUFFER-1,0);
                g_DebugProtocol.print_text("DONE");
            }
            else
            if (length<0x400)
            {
                sprintf(msg,"len=%d",int(length));
                g_DebugProtocol.print_text(msg);
                if (length > 1024) length=1024;
                if (length>0)
                {
                    addr+=2;
                    for(uint16_t i=0;i<length;++i,++addr)
                    {
                        uint8_t b = read_byte(addr);
                        //sprintf(msg,"RBYTE %d",int(b));
                        //g_DebugProtocol.print_text(msg);
                        gpu_command_buffer[gpu_command_buffer_available++]=b;
                        //sprintf(msg,"BYTE %d",int(b));
                        //g_DebugProtocol.print_text(msg);
                        //g_GPUProtocol.add_byte(b);
                    }
                    write_byte(IO_BUFFER-2,0);
                    write_byte(IO_BUFFER-1,0);
                }
            }
        }
        if (gpu_command_buffer_available>0)
        {
            char msg[64];
            for(int i=0;i<gpu_command_buffer_available;++i)
            {
                // sprintf(msg, "BYTE %d", int(gpu_command_buffer[i]));
                // g_DebugProtocol.print_text(msg);
                g_GPUProtocol.add_byte(gpu_command_buffer[i]);
            }
            gpu_command_buffer_available=0;
        }
    }
}
