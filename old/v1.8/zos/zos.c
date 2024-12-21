#include "zos.h"
#include "stdlib.h"

byte command_buffer[32];
byte command_pos;

void print_prompt()
{
	const char* os_prompt="zOS>";
	print_text(os_prompt);
}


void load_program(const char* filename)
{
	byte handle = open_file(filename,0);
	if (handle != 0xFF)
	{
		byte* program_buffer = (byte*)0x1000;
		read_file(handle, program_buffer, 0xE000);
		close_file(handle);
	}
	else
	{
		print_text("File not found");
	}
}


void dir()
{
	word size;
	byte rc=list_dir("/",command_buffer,&size);
	while (rc==200)
	{
		print_text(command_buffer);
		print_text("  ");
		print_word(size);
		newline();
		gpu_flush();
		rc=list_next(command_buffer,&size);
	}
}

void cat_file(const char* filename)
{
	byte handle = open_file(filename,0);
	if (handle != 0xFF)
	{
		word act=1;
		while (act>0)
		{
			act = read_file(handle, command_buffer, 30);
			if (act>0)
			{
				command_buffer[act]=0;
				print_text(command_buffer);
			}
		}
		close_file(handle);
		gpu_flush();
	}
}

void process_command()
{
	typedef void (*program_ptr)();
	program_ptr user_program = (program_ptr)0x1000;
	if (strcmp(command_buffer, "run") == 0)
		user_program();
	else
	if (strcmp(command_buffer, "cls") == 0)
		cls();
	else
	if (strcmp(command_buffer, "dir") == 0)
		dir();
	else
	if (command_pos>4 && strncmp(command_buffer, "cat ", 4)==0)
		cat_file(command_buffer+4);
	else
	if (command_pos>5 && strncmp(command_buffer, "load ", 5)==0)
		load_program(command_buffer+5);
	else
	{
		print_text("Unknown Command");
		newline();
	}
}

void print_char(byte b)
{
	byte text[2];
	text[0]=b;
	text[1]=0;
	print_text(text);
}

void backspace()
{}

byte process_input()
{
	if (!input_empty())
	{
		byte data = input_read();
		if (data==10 || data==13)
		{
			newline();
			process_command();
			command_pos=0;
			return 1;
		}
		if (data == 8 && command_pos>0)
		{
			backspace();
			--command_pos;
			return 0;
		}
		if (data>=32 && command_pos < 30)
		{
			command_buffer[command_pos++]=data;
			print_char(data);
			gpu_flush();
			command_buffer[command_pos]=0;
		}
	}
	return 0;
}

void main()
{
	gpu_clear();
	command_pos=0;
	cls();
	while (1)
	{
		print_prompt();
		gpu_flush();
		while (!process_input());
	}
}

