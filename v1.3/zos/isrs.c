#include "global_data.h"

extern GlobalData g;

void input_handler(byte incoming);

void input_isr()
{
	__asm
	PUSH	AF
	PUSH	HL
	PUSH	BC
	IN		A,(0)
	PUSH	AF
	CALL	_input_handler
	POP		AF
	POP		BC
	POP		HL
	POP		AF
	__endasm;
}
