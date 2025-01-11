#include "zos.h"
#include "stdlib.h"

#define CMD_BUF_SIZE 64
byte command_buffer[CMD_BUF_SIZE];
byte* args_buffer[8];
byte command_pos;
typedef void (*program_ptr)(byte**);

void print_prompt()
{
	const char* os_prompt="zOS>";
	print_text(os_prompt);
}


byte load_program(const char* filename)
{
	byte handle = open_file(filename,0);
	if (handle != 0xFF)
	{
		byte* program_buffer = (byte*)0x1000;
		read_file(handle, program_buffer, 0xE000);
		close_file(handle);
		return 1;
	}
	else
	{
		print_text("File not found");
		newline();
	}
	return 0;
}


void dir()
{
	word size;
	byte rc=list_dir("/",command_buffer,&size);
	if (rc!=200)
	{
		print_text("Cannot read directory");
		newline();
	}
	while (rc==200)
	{
		print_text(command_buffer);
		print_text("  ");
		print_word(size);
		newline();
		rc=list_next(command_buffer,&size);
	}
}

void lsp_file(const char* filename)
{
	load_sprites(filename,0);
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
	}
}

byte load_run()
{
	byte i;
	byte arg_index=0;
	byte last_space=1;
	for(i=0;i<CMD_BUF_SIZE;++i)
	{
		if (command_buffer[i]==0 || arg_index==7) break;
		if (command_buffer[i]==32) /* Space */
		{
			command_buffer[i]=0;
			last_space=1;
		}
		else
		{
			if (last_space!=0)
			{
				args_buffer[arg_index++] = &command_buffer[i];
			}
			last_space=0;
		}
	}
	args_buffer[arg_index]=0;
	if (arg_index>0)
	{
		if (load_program(args_buffer[0]))
		{
			program_ptr user_program = (program_ptr)0x1000;
			user_program(&args_buffer[1]);
			return 1;
		}
	}
	return 0;
}

void process_command()
{
	program_ptr user_program = (program_ptr)0x1000;
	if (strcmp(command_buffer, "run") == 0)
	{
		args_buffer[0]=0;
		user_program(args_buffer);
	}
	else
	if (strcmp(command_buffer, "cls") == 0)
		cls();
	else
	if (strcmp(command_buffer, "dir") == 0)
		dir();
	else
	if (command_pos>4 && strncmp(command_buffer, "lsp ", 4)==0)
		lsp_file(command_buffer+4);
	else
	if (command_pos>4 && strncmp(command_buffer, "cat ", 4)==0)
		cat_file(command_buffer+4);
	else
	if (command_pos>5 && strncmp(command_buffer, "load ", 5)==0)
		load_program(command_buffer+5);
	else
	if (!load_run())
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
		word data = input_read();
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
		if (data>=32 && data<127 && command_pos < (CMD_BUF_SIZE-2))
		{
			byte ch=(byte)data;
			command_buffer[command_pos++]=ch;
			print_char(ch);
			command_buffer[command_pos]=0;
		}
	}
	return 0;
}

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

