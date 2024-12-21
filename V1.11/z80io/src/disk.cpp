#include "types.h"
#include <Arduino.h>
#include <memory>
#include "io.h"
#include "bus_access.h"
#include "disk.h"
#include <SD.h>

const int SD_CS = BUILTIN_SDCARD;
static bool disk_active = false;
static File current_dir;
static bool listing = false;

struct ActiveFile
{
	File f;
	bool opened=false;
};

constexpr int N_FILES = 4;
ActiveFile files[N_FILES];

void disk_setup()
{
	if (!SD.begin(SD_CS))
	{
		Serial.println("initialization failed!");
		return;
	}
	Serial.println("SD Card Connected.");
	disk_active = true;
	//root = SD.open("/");
}

void disk_loop()
{}

constexpr Word DISK_ARG1 = 0x00E0;
constexpr Word DISK_ARG2 = 0x00E2;
constexpr Word DISK_ARG3 = 0x00E4;

constexpr byte CMD_LIST_DIR      = 1;
constexpr byte CMD_LIST_NEXT     = 2;
constexpr byte CMD_OPEN_FILE     = 3;
constexpr byte CMD_READ_FILE     = 4;
constexpr byte CMD_WRITE_FILE    = 5;
constexpr byte CMD_CLOSE_FILE    = 6;
constexpr byte CMD_LOAD_SPRITES  = 7;

void copy_str(Word target, const char* s)
{
	do
	{
		write_byte(target++, *s);
	} while (*s++);
}

void copy_str(char* target, Word source, int limit)
{
	target[limit] = 0;
	for (int i = 0; i < limit; ++i)
	{
		target[i] = read_byte(source++);
		if (!target[i])
			break;
	}
}

void disk_process(byte command)
{
	Serial.print("Disk Command: ");
	Serial.println(int(command));
	set_pending_in(1, 201);
	if (!disk_active)
	{
		Serial.println("Disk not active");
		return;
	}
	Word arg1 = read_word(DISK_ARG1);
	Word arg2 = read_word(DISK_ARG2);
	Word arg3 = read_word(DISK_ARG3);
	Serial.print("arg1=");
	Serial.println(int(arg1));
	Serial.print("arg2=");
	Serial.println(int(arg2));
	Serial.print("arg3=");
	Serial.println(int(arg3));
	char filename[13];
	for (int i = 0; i < 13;++i)
		filename[i] = 0;
	set_pending_in(1, 201);
	switch (command)
	{
		case CMD_LIST_DIR:
		{

			Serial.println("Listing");
			current_dir = SD.open("/");
			listing = true;
		}
		case CMD_LIST_NEXT:
		{
			if (listing)
			{
				File f = current_dir.openNextFile();
				if (f)
				{
					Serial.println(f.name());
					Serial.print("Size: ");
					Serial.println(f.size());
					copy_str(arg2, f.name());
					write_word(arg3, f.size()&0xFFFF);
					set_pending_in(1, 200);
				}
				else
					listing = false;
			}
			break;
		}
		case CMD_OPEN_FILE:
		{
			set_pending_in(1, 0xFF);
			for (int i = 0; i < N_FILES;++i)
			{
				if (!files[i].opened)
				{
					copy_str(filename, arg1, 12);
					Serial.print("Opening: '");
					Serial.print(filename);
					Serial.println("'");
					files[i].f = SD.open(filename); // Add write option
					if (files[i].f)
					{
						files[i].opened = true;
						set_pending_in(1, i);
					}
					break;
				}
			}
			break;
		}
		case CMD_READ_FILE:
		{
			if (arg1 < N_FILES)
			{
				if (files[arg1].opened)
				{
					Serial.print("Reading ");
					Serial.print(int(arg3));
					Serial.print(" bytes into ");
					Serial.println(arg2, HEX);
					Word addr = arg2;
					Word total = 0;
					for (Word i = 0; i < arg3;++i)
					{
						int d = files[arg1].f.read();
						if (d<0)
							break;
						total++;
						write_byte(addr++, byte(d));
					}
					Serial.print("Actual ");
					Serial.println(int(total));
					write_word(DISK_ARG3, total);
					set_pending_in(1, 200);
				}
			}
			break;
		}
		case CMD_WRITE_FILE:
		{
			break;
		}
		case CMD_CLOSE_FILE:
		{
			if (arg1 < N_FILES)
			{
				if (files[arg1].opened)
				{
					files[arg1].f.close();
					files[arg1].opened = false;
					set_pending_in(1, 200);
				}
			}
			break;
		}
		case CMD_LOAD_SPRITES:
		{
			break;
		}
	}
}
