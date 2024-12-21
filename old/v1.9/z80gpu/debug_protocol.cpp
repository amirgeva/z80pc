#include <string.h>
#include "debug_protocol.h"
#include "crc16.h"
#include "bus_access.h"

constexpr uint8_t DEBUG_TEXT=255;

void setup_handlers();

DebugProtocol g_DebugProtocol;

constexpr uint8_t  MAGIC[] = {0xEA, 0x91};

void DebugProtocol::process_message(const uint8_t* message, uint8_t length)
{
    if (message[0] >= PROTOCOL_COMMANDS)
    {
        print_text("Invalid command id");
        //dbg << "Command invalid: " << message[0] << "\r";
        return; // Invalid command index
    }
    command_callback cb = m_Callbacks[message[0]];
    if (!cb) 
    {
        print_text("Unhandled command");
        //dbg << "Unhandled command: " << message[0] << "\r";
        return; // Unhandled command
    }
    cb(message+1, length-1); // Pass parameters
}


DebugProtocol::DebugProtocol()
: m_Pos(0)
{
    for(uint8_t i=0;i<PROTOCOL_COMMANDS;++i)
        m_Callbacks[i]=nullptr;
    setup_handlers();
}
    
void DebugProtocol::add_byte(uint8_t data)
{
    if (m_Pos<2 && data!=MAGIC[m_Pos])
    {
        //dbg << "Header invalid. Skipping\r";
        m_Pos=0;
    }
    else
    {
        m_Buffer[m_Pos++]=data;
        if (m_Pos>=3)
        {
            // 2 bytes for magic, 1 byte for length, 2 bytes for crc
            // Total 5 bytes of message overhead, n is length of payload
            uint16_t n=m_Buffer[2];
            if (m_Pos >= (n+5))
            {
                //dbg << "Received packet size=" << (n+5) << endl();
                uint16_t crc = (uint16_t(m_Buffer[m_Pos-1]) << 8) | m_Buffer[m_Pos-2];
                uint16_t calculated = calculate_crc16(m_Buffer+3,n);
                if (crc != calculated)
                {
                    print_text("NACK");
                    m_Pos=0; // Invalid crc, ignore message
                }
                else 
                {
                    //print_text("ACK");
                    process_message(m_Buffer+3, n);
                    m_Pos=0;
                    for(uint16_t i=0;i<PROTOCOL_BUFFER_SIZE;++i)
                        m_Buffer[i]=0;
                }
            }
            
        }
    }
}

void DebugProtocol::register_handler(uint8_t command, command_callback cb)
{
    if (command<PROTOCOL_COMMANDS)
        m_Callbacks[command]=cb;
}

void DebugProtocol::send_response()
{
    uint16_t crc = calculate_crc16(m_Buffer+3, m_ResponseLength-5);
    m_Buffer[m_ResponseLength-1]=(crc>>8)&0xFF;
    m_Buffer[m_ResponseLength-2]=crc&0xFF;
    //print_text(">");
    send_response_buffer(m_Buffer,m_ResponseLength);
}

uint8_t* DebugProtocol::allocate_read_response(uint8_t length)
{
    m_ResponseLength = length + 6; // 2 MAGIC, 1 length, 1 type, 2 crc
    m_Buffer[2]=length+1; // [2] is payload size.  type byte + data
    return m_Buffer+4; // Start of payload data (after type)
}

void DebugProtocol::print_text(const char* text)
{
    int n=strlen(text);
    if (n>248) n=248;
    m_DebugBuffer[0]=MAGIC[0];
    m_DebugBuffer[1]=MAGIC[1];
    m_DebugBuffer[2]=n+1;
    m_DebugBuffer[3]=DEBUG_TEXT;
    strncpy((char*)&m_DebugBuffer[4],text,n);
    uint16_t crc = calculate_crc16(m_DebugBuffer+3, n+1);
    int i=n+4;
    m_DebugBuffer[i]=crc&0xFF;
    m_DebugBuffer[i+1]=(crc>>8)&0xFF;
    send_response_buffer(m_DebugBuffer,n+6);
}

void debug_print(const char* text)
{
    g_DebugProtocol.print_text(text);
}

void debug_print(uint8_t number, bool add_eol)
{
    const char hex[] = "0123456789ABCDEF";
    char text[4];
    int i=0;
    text[i++]=hex[(number>>4)&0x0F];
    text[i++]=hex[(number   )&0x0F];
    if (add_eol)
    text[i++]='\n';
    text[i++]=0;
    debug_print(text);
}
