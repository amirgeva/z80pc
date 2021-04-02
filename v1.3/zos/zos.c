#include "global_data.h"

GlobalData __at(0x1000) g;
extern void sendstr(const byte*);
extern char strcmp(const byte*,const byte*);

void scan_input();

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
	while (1) scan_input();
}

void input_handler(byte incoming)
{
	g.input_buffer[g.in_write++]=incoming;
}

void process_command()
{
	if (strcmp(g.cmd_buffer,"LOAD") == 0)
	{
		sendstr("Loading");
	}
}

void scan_input()
{
	byte cur;
	if (g.in_write==g.in_read) return;
	cur=g.input_buffer[g.in_read++];
	if (cur == 8)
	{
		if (g.cmd_pos>0) --g.cmd_pos;
	}
	else
	if (cur==10 || cur==13)
	{
		g.cmd_buffer[g.cmd_pos]=0;
		process_command();
		g.cmd_pos=0;
	}
	else
	if (g.cmd_pos < (CMD_BUFFER_SIZE-1))
		g.cmd_buffer[g.cmd_pos++]=cur;
}

byte send(byte* data)
{
	return 0;
}

byte receive(byte* data)
{
	return 0;
}