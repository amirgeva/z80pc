#pragma once

#include "crc16.h"

constexpr uint8_t  MAGIC[] = {0xEA, 0x91};
constexpr uint16_t PROTOCOL_BUFFER_SIZE=256;
constexpr uint8_t  PROTOCOL_COMMANDS = 9;

void send_response_buffer(const uint8_t* buffer, uint8_t length);
typedef void (*command_callback)(const uint8_t* params, uint8_t length);

class Protocol
{
	
	uint8_t m_Buffer[PROTOCOL_BUFFER_SIZE];
	uint16_t m_Pos,m_ResponseLength;
	command_callback m_Callbacks[PROTOCOL_COMMANDS];
	
	void process_message(const uint8_t* message, uint8_t length)
	{
		if (message[0] >= PROTOCOL_COMMANDS)
		{
			//dbg << "Command invalid: " << message[0] << "\r\n";
			return; // Invalid command index
		}
		command_callback cb = m_Callbacks[message[0]];
		if (!cb) 
		{
			//dbg << "Unhandled command: " << message[0] << "\r\n";
			return; // Unhandled command
		}
		print_text("<");
		cb(message+1, length-1); // Pass parameters
	}
public:
	Protocol()
	: m_Pos(0)
	{
		for(uint8_t i=0;i<PROTOCOL_COMMANDS;++i)
			m_Callbacks[i]=nullptr;
	}
		
	void add_byte(uint8_t data)
	{
		if (m_Pos<2 && data!=MAGIC[m_Pos])
		{
			//dbg << "Header invalid. Skipping\r\n";
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
						dbg << "NACK\r\n";
						m_Pos=0; // Invalid crc, ignore message
					}
					else 
					{
						dbg << "ACK\r\n";
						process_message(m_Buffer+3, n);
						m_Pos=0;
						for(uint16_t i=0;i<PROTOCOL_BUFFER_SIZE;++i)
							m_Buffer[i]=0;
					}
				}
				
			}
		}
	}
	
	void register_handler(uint8_t command, command_callback cb)
	{
		if (command<PROTOCOL_COMMANDS)
			m_Callbacks[command]=cb;
	}
	
	void send_response()
	{
		uint16_t crc = calculate_crc16(m_Buffer+3, m_ResponseLength-5);
		m_Buffer[m_ResponseLength-1]=(crc>>8)&0xFF;
		m_Buffer[m_ResponseLength-2]=crc&0xFF;
		print_text(">");
		send_response_buffer(m_Buffer,m_ResponseLength);
	}
	
	uint8_t* allocate_read_response(uint8_t length)
	{
		//dbg << "Allocate response size " << length << endl();
		m_ResponseLength = length + 5;
		m_Buffer[2]=length;
		return m_Buffer+3;
	}
};


extern Protocol g_Protocol;