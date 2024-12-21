#pragma once

#include <cstdint>



void send_response_buffer(const uint8_t* buffer, uint8_t length);
typedef void (*command_callback)(const uint8_t* params, uint8_t length);

class DebugProtocol
{
	enum { PROTOCOL_COMMANDS=32, PROTOCOL_BUFFER_SIZE=256 };
	uint8_t m_Buffer[PROTOCOL_BUFFER_SIZE];
	uint8_t m_DebugBuffer[PROTOCOL_BUFFER_SIZE];
	uint16_t m_Pos,m_ResponseLength;
	command_callback m_Callbacks[PROTOCOL_COMMANDS];
	
	void process_message(const uint8_t* message, uint8_t length);
public:
	DebugProtocol();
	void add_byte(uint8_t data);
	void register_handler(uint8_t command, command_callback cb);
	void send_response();
	uint8_t* allocate_read_response(uint8_t length);
	void print_text(const char* text);
};


extern DebugProtocol g_DebugProtocol;