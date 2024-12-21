#include "global_data.h"
#include "ll.h"
//#include "xmodem.h"

GlobalData __at(0x1000) g;

typedef void (*func_ptr)();
func_ptr user_program;

void scan_input();
void send_prompt();
word get_key();
word rng();

word service1(byte call_type)
{
	switch (call_type)
	{
		case 0:		return rng();
		case 1:		return get_key();
		case 2:		return g.timer;
	}
	return 0;
}

/*
void service2()
{
}

void service3()
{
}

void service4()
{
}

void service5()
{
}

void service6()
{
}
*/

void main()
{
	g.in_write=0;
	g.in_read=0;
	g.cmd_pos=0;
	g.timer=0;
	user_program = (func_ptr)USER_AREA;
	__asm
	LD SP,#0xFF00
	IM 1
	EI
	__endasm;
	cls();
	send_prompt();
	while (1) scan_input();
}

void process_command()
{
	/*
	if (strcmp(g.cmd_buffer,"upload") == 0)
	{
		xmodem_receive(USER_AREA);
	}
	else
	*/
	if (strcmp(g.cmd_buffer,"run") == 0)
	{
		user_program();
	}
	else
		println("Invalid command");
}

void scan_input()
{
	byte cur;
	if (g.in_write==g.in_read) return;
	cur=g.input_buffer[g.in_read++];
	printc(cur);
	if (cur == 8)
	{
		if (g.cmd_pos>0) --g.cmd_pos;
	}
	else
	if (cur==10 || cur==13)
	{
		if (g.cmd_pos>0)
		{
			g.cmd_buffer[g.cmd_pos]=0;
			process_command();
			g.cmd_pos=0;
		}
		send_prompt();
	}
	else
	if (g.cmd_pos < (CMD_BUFFER_SIZE-1))
		g.cmd_buffer[g.cmd_pos++]=cur;
}

word get_key()
{
	word res=0x100;
	if (g.in_write!=g.in_read)
	{
		word key = g.input_buffer[g.in_read++];
		res=key;
	}
	return res;
}

byte receive(byte* data)
{
	if (g.in_write==g.in_read) return 0;
	*data = g.input_buffer[g.in_read++];
	return 1;
}

void send_prompt()
{
  print("zOS>");
}
