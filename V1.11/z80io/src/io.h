#pragma once

enum IOProcessing
{
	CLEAR_AND_PROCESS,
	PROCESS_AND_CLEAR,
	CLEAR_AND_DMA
};

void io_loop();
void set_pending_in(Word addr, byte value);
IOProcessing get_processing_type(Word addr); // Indicate if processing should be done before clearing the wait state
void process_out(Word addr, byte data); // Take an OUT instruction and handle it
byte process_in(Word addr);				// IN instruction, provide the byte to be read
