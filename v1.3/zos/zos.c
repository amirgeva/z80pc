#include "global_data.h"
#include "ll.h"
#include "xmodem.h"

GlobalData __at(0x1000) g;

typedef void (*func_ptr)();
func_ptr user_program = (func_ptr)USER_AREA;

void scan_input();
void send_prompt();

void service1()
{
}

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

void main()
{
	send_prompt();
	while (1) scan_input();
}

void input_handler(byte incoming)
{
	g.input_buffer[g.in_write++]=incoming;
}

void process_command()
{
	if (strcmp(g.cmd_buffer,"upload") == 0)
	{
		xmodem_receive(USER_AREA);
	}
	else
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
	sendchar(cur);
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

byte send(byte* data)
{
	sendchar(*data);
	return 1;
}

byte receive(byte* data)
{
	if (g.in_write==g.in_read) return 0;
	*data = g.input_buffer[g.in_read++];
	return 1;
}

void send_prompt()
{
  send("zOS>");
}
