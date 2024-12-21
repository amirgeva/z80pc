#include "zos.h"

const byte gdata[] = {12,77,65,255};

byte service1()
{
	return 0;
}

byte service2(byte data)
{
	data;
	return 0;
}

byte service3(byte* pointer)
{
	pointer;
	return 0;
}

byte service4(byte* pointer, byte data)
{
	pointer;
	data;
	return 0;
}

byte service5()
{
	return 0;
}

byte service6()
{
	return 0;
}


byte command_buffer[32];
byte command_pos;

void main()
{
	command_pos=0;
	cls();
	while (1)
	{
		print_prompt();
		while (!process_input());
	}
}

byte input_empty() __naked
{
	__asm
	LD		A,(#0xF1)
	LD		HL,#0xF0
	SUB		(HL)
	LD		A,#1
	RET		Z
	XOR		A
	RET
	__endasm;
}

byte input_read() __naked
{
	__asm
	LD		A,(#0xF1)
	LD		H,#1
	LD		L,A
	LD		A,(HL)
	LD		HL,#0xF1
	INC		(HL)
	RET
	__endasm;
}

byte strlen(const byte* text)
{
	byte res=0;
	for(;*text;++text,++res);
	return res;
}

char strcmp(const char* a, const char* b)
{
	if (!a && !b) return 0;
	if (!a) return 1;
	if (!b) return -1;
	while (1)
	{
		if (*a==0 && *b==0) return 0;
		if (*a==0) return 1;
		if (*b==0) return -1;
		if (*a==*b) 
		{
			++a;
			++b;
			continue;
		}
		return *a<*b?-1:1;
	}
	return 0;
}

void print_text(const char* text)
{
	text;
	__asm
	LD		A,#30		// Send 30, code for print
	OUT		(0),A
	push	HL			// text is pointed by HL
	call	_strlen
	pop		HL
	OUT		(0),A		// strlen returns length in A,  send it
	LD		B,A			
	OTIR				// Send all the text characters
	__endasm;
}

void cls()
{
	__asm
	LD		A,#1
	OUT		(0),A
	__endasm;
}

void print_prompt()
{
	const char* os_prompt="zOS>";
	print_text(os_prompt);
}

void process_command()
{
	typedef void (*program_ptr)();
	program_ptr user_program = (program_ptr)0x1000;
	if (strcmp(command_buffer, "run") == 0)
		user_program();
}

byte process_input()
{
	if (!input_empty())
	{
		byte data = input_read();
		if (data==10 || data==13)
		{
			process_command();
			command_pos=0;
			return 1;
		}
		if (command_pos < 30)
		{
			command_buffer[command_pos++]=data;
			command_buffer[command_pos]=0;
		}
	}
	return 0;
}