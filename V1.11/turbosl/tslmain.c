#include <stdio.h>
#include <hal.h>
#include <vector.h>
#include <utils.h>
#include <stdlib.h>
#include <memory.h>

#define CONTROL(x) (x - 0x40)

byte fg = 0xFF;
byte bg = 0x00;
#define W 80
#define H 30
const byte TL = 0xC9;
const byte TR = 0xBB;
const byte BL = 0xC8;
const byte BR = 0xBC;
const byte HORZ = 0xCD;
const byte VERT = 0xBA;
byte insert = 1;
Vector* document;
Vector* clipboard;

typedef struct _cursor
{
	short x, y;
} Cursor;

typedef struct _mapping
{
	short logical, visual;
} Mapping;

typedef struct _range
{
	byte start, stop;
} Range;

Mapping line_mapping[W];

Cursor cursor, offset, select_start, select_stop;
short redraw_start, redraw_stop;

void init_state()
{
	fg = 0xFF;
	bg = 0;
	redraw_start = 0;
	redraw_stop = 0x7000;
	insert = 1;
	document = 0;
	cursor.x = 0;
	cursor.y = 0;
	offset.x = 0;
	offset.y = 0;
	select_start.x = 0;
	select_start.y = 0;
	select_stop.x = 0;
	select_stop.y = 0;
}

byte in_selection(short x, short y)
{
	if (y > select_start.y || (y == select_start.y && x >= select_start.x))
	{
		if (y < select_stop.y || (y == select_stop.y && x < select_stop.x))
		{
			return 1;
		}
	}
	return 0;
}

byte visual_mapping(Vector* line, Mapping* mapping, short start, short stop)
{
	short n = vector_size(line);
	const byte* data = vector_access(line, 0);
	short visual = -offset.x;
	short x = 0;
	
	byte index = 0;
	for (short logical = 0; logical < n; ++logical)
	{
		if (visual >= 0 && visual < (W - 2) && logical >= start && logical < stop)
		{
			mapping[index].logical = logical;
			mapping[index].visual = visual;
			index++;
		}
		++visual;
		++x;
		if (data[logical] == 9)
		{
			while ((x & 3) != 0)
			{
				++visual;
				++x;
			}
		}
	}
	return index;
}

short logical_to_visual(Vector* line, word logical)
{
	word n = min(logical, vector_size(line));
	const byte* data = vector_access(line, 0);
	short x = 0;
	for (word i = 0; i < n; ++i)
	{
		++x;
		if (data[i] == 9)
		{
			while ((x & 3) != 0) ++x;
		}
	}
	return x - offset.x;
}

byte cursor_lt(Cursor* a, Cursor* b)
{
	if (a->y == b->y) return a->x < b->x;
	return a->y < b->y;
}

byte valid_select()
{
	if (select_start.y == select_stop.y) return select_start.x < select_stop.x;
	return select_start.y < select_stop.y;
}

void redraw_line(short y)
{
	redraw_start = y;
	redraw_stop = y + 1;
}

void redraw_from(short y)
{
	redraw_start = y;
	redraw_stop = 0x7000;
}

void redraw_range(short y1, short y2)
{
	redraw_start = min(y1, y2);
	redraw_stop = max(y1, y2) + 1;
}

void clear_select()
{
	redraw_start = select_start.y;
	redraw_stop = select_stop.y+1;
	select_start.x = 0;
	select_start.y = 0;
	select_stop.x = 0;
	select_stop.y = 0;
}

void start_select()
{
	select_stop = select_start = cursor;
}

void extend_select()
{
	if (cursor_lt(&cursor, &select_start))
		select_start = cursor;
	else
		select_stop = cursor;
}

void clear()
{
	word n = vector_size(document);
	Vector* line;
	for (word i = 0; i < n; ++i)
	{
		vector_get(document, i, &line);
		vector_shut(line);
	}
	vector_clear(document);
}

word round_up(word value, word margin)
{
	return (value + margin) & ~(margin-1);
}

Vector* get_line(word line_index)
{
	word size = vector_size(document);
	if (line_index < size)
	{
		Vector* line;
		vector_get(document, line_index, &line);
		return line;
	}
	vector_reserve(document, round_up(line_index + 1, 16));
	vector_resize(document, line_index + 1);
	word new_size = vector_size(document);
	while (size < new_size)
	{
		Vector* new_line = vector_new(1);
		vector_set(document, size++, &new_line);
	}
	Vector* line;
	vector_get(document, line_index, &line);
	return line;
}

void append_line(Vector* line, byte b)
{
	vector_push(line, &b);
}

void load_file(const char* filename)
{
	byte buffer[256];
	clear();
	byte handle = open_file(filename, 0);
	if (handle == 0xFF) return;
	word act = 0;
	word line_index = 0;
	do
	{
		act = read_file(handle, buffer, 256);
		for (word i = 0; i < act; ++i)
		{
			if (buffer[i] == 10)
				++line_index;
			else
			if (buffer[i] >= 32 || buffer[i]==9)
			{
				Vector* line = get_line(line_index);
				if (line)
					append_line(line, buffer[i]);
			}
		}
	} while (act > 0);
	close_file(handle);
}

/*
void draw_str(const char* s)
{
	for (; *s; ++s)
	{
		hal_draw_char(*s);
	}
}
*/

void draw_str(const char* s)
{
	for (; *s; ++s)
		hal_draw_char(*s);
}

void  draw_menu_item(const char* s)
{
	hal_color(5, 173);
	hal_draw_char(' ');
	hal_draw_char(' ');
	hal_draw_char(*s);
	++s;
	if (*s)
	{
		hal_color(0, 173);
		draw_str(s);
	}
}

void draw_status_item(const char* key, const char* name)
{
	hal_color(5, 173);
	hal_draw_char(' ');
	draw_str(key);
	hal_draw_char(' ');
	hal_color(0, 173);
	draw_str(name);
	hal_draw_char(' ');
}

void  draw_menu()
{
	hal_move(0, 0);
	hal_color(0, 173);
	hal_rept_char(' ', W);
	hal_move(0, 0);
	draw_menu_item("\xF0");
	draw_menu_item("File");
	draw_menu_item("Edit");
	draw_menu_item("Search");
	draw_menu_item("Run");
	draw_menu_item("Compile");
}

void draw_status()
{
	hal_move(0, H - 1);
	hal_color(0, 173);
	hal_rept_char(' ', W);
	hal_move(0, H - 1);
	draw_status_item("F1", "Help");
	draw_status_item("F2", "Save");
	draw_status_item("F3", "Open");
	draw_status_item("F9", "Compile");
}

void draw_brackets(byte b)
{
	hal_draw_char('[');
	hal_color(122, 128);
	hal_draw_char(b);
	hal_color(255, 128);
	hal_draw_char(']');
}

void draw_frame()
{
	draw_menu();
	fg = 255;
	bg = 128;
	byte i;
	hal_color(255, 128);
	hal_move(0, 1);
	hal_draw_char(TL);
	hal_draw_char(HORZ);
	draw_brackets(254);
	hal_rept_char(HORZ, W - 10);
	draw_brackets(0x12);
	hal_draw_char(HORZ);
	hal_draw_char(TR);
	
	//hal_draw_char(' ');
	//hal_draw_str("fib.sl");
	
	for (i = 2; i < (H - 2); ++i)
	{
		hal_color(255, 128);
		hal_move(0, i);
		hal_draw_char(VERT);
		hal_rept_char(' ',W-2);
		hal_color(128, 168);
		if (i == 2) hal_draw_char(0x1E);
		else if (i == 3) hal_draw_char(0xFE);
		else if (i == (H - 3)) hal_draw_char(0x1F);
		else   hal_draw_char(0xB1);
		//hal_draw_char(VERT);
	}
	hal_color(255, 128);
	hal_move(0, H-2);
	hal_draw_char(BL);
	hal_rept_char(HORZ,20);
	hal_color(128, 168);
	hal_draw_char(0x11);
	hal_draw_char(0xFE);
	hal_rept_char(0xB1,W-26);
	hal_draw_char(0x10);
	hal_color(168, 128);
	hal_draw_char(0xC4);
	hal_draw_char(0xD9);
		//hal_draw_char(BR);
	draw_status();
	hal_color(fg, bg);
}

/**
 * Draw a single text line, from start character index to stop index.
 * Returns true if draw was successful (valid indices)
 */
byte draw_line(short logical_y)
{
	if (logical_y < 0 || logical_y >= vector_size(document)) return 0;
	short visual_y = logical_y - offset.y;
	if (visual_y < 0 || visual_y >= (H - 4)) return 0;

	if (in_selection(0, logical_y))
		hal_color(bg, fg);
	Vector* line = get_line(logical_y);
	byte* data = vector_access(line, 0);
	byte n = 0;
	hal_move(1, visual_y + 2);
	if (data)
	{
		n = visual_mapping(line, line_mapping, 0, 0x7000);
	}
	else
	{
		hal_rept_char(' ', W - 2);
		return 1;
	}

	short x = 0, i = 0;
	while (x<(W-2))
	{
		if (i < n)
		{
			if (x < line_mapping[i].visual)
			{
				byte m = (byte)(line_mapping[i].visual - x);
				hal_rept_char(' ', m);
				x = line_mapping[i].visual;
			}
			if (select_start.x == line_mapping[i].logical && select_start.y == logical_y)
				hal_color(bg, fg);
			if (select_stop.x == line_mapping[i].logical && select_stop.y == logical_y)
				hal_color(fg, bg);
			byte c = data[line_mapping[i].logical];
			hal_draw_char(c>=32?c:' ');
			++x;
			++i;
		}
		else
		{
			if (select_stop.y == logical_y)
				hal_color(fg, bg);
			hal_rept_char(' ', (byte)(W - 2 - x));
			break;
		}
	}
	return 1;
}

void visual_cursor(byte with_offset, Cursor* vc)
{
	Vector* line = get_line(cursor.y);
	short visual_x = logical_to_visual(line, cursor.x);
	vc->x = visual_x;
	vc->y = cursor.y;
	if (with_offset)
	{
		vc->x -= offset.x;
		vc->y -= offset.y;
	}
}

byte cursor_in_view()
{
	Cursor v;
	visual_cursor(1, &v);
	if (v.x >= 0 && v.y >= 0 && v.x < (W - 2) && v.y < (H - 4))
		return 1;
	return 0;
}

void eod_cursor(Cursor* c)
{
	c->x = 0;
	c->y = vector_size(document);
}

void redraw_all()
{
	redraw_start = 0;
	redraw_stop = 0x7000;
}

void calculate_new_offset()
{
	Cursor v;
	visual_cursor(0,&v);
	if (v.x < (W >> 1)) v.x = 0;
	else offset.x = v.x - (W >> 1);
	if (v.y < (H >> 1)) offset.y = 0;
	else offset.y = v.y - (H >> 1);
	draw_frame();
	redraw_all();
}

void place_cursor()
{
	if (cursor_in_view() == 0) calculate_new_offset();
	Cursor v;
	visual_cursor(1,&v);
	hal_move(v.x + 1, v.y + 2);
}

void decimal_string(byte* buffer, short length, word value)
{
	short index = length - 1;
	while (value > 0)
	{
		DivMod dm;
		dm.a = value;
		dm.b = 10;
		div_mod(&dm);
		buffer[index--] = (byte)(48 + dm.b);
		value=dm.a;
	}
	while (index >= 0)
		buffer[index--] = 48;
}

void draw_number(word value)
{
	byte buffer[8];
	buffer[7] = 0;
	decimal_string(buffer, 7, value);
	byte* ptr = buffer;
	for (; *ptr == 48; ++ptr);
	for (; *ptr; ++ptr)
		hal_draw_char(*ptr);
}

void draw_cursor_position()
{
	hal_move(5, H - 2);
	//hal_draw_char(0xB9);
	hal_draw_char(' ');
	draw_number(cursor.x + 1);
	hal_draw_char(':');
	draw_number(cursor.y + 1);
	hal_draw_char(' ');
	//hal_draw_char(0xCC);
	for (byte i = 0; i < 5; ++i)
		hal_draw_char(HORZ);
}

void draw_screen()
{
	if (offset.y > redraw_start)
	{
		redraw_start = offset.y;
	}
	for (short y = redraw_start; y < redraw_stop; ++y)
	{
		if (!draw_line(y)) break;
	}
	redraw_stop = redraw_start;
	draw_cursor_position();
	place_cursor();
}

word visual_to_logical(Vector* line, word visual)
{
	word n = vector_size(line);
	const byte* data = vector_access(line, 0);
	word x = 0;
	for (word i = 0; i < n; ++i)
	{
		if (x >= visual) return i;
		++x;
		if (data[i] == 9)
		{
			while ((x & 3) != 0) ++x;
		}
	}
	return n;
}

void move_x_cursor(short dx)
{
	if (dx==0 || cursor.y<0 || cursor.y >= vector_size(document)) return;
	Vector* line = get_line(cursor.y);
	cursor.x += dx;
	if (cursor.x < 0) cursor.x = 0;
	short n = vector_size(line);
	if (cursor.x >= n) cursor.x = n;
	place_cursor();
}

#define LEFT		0x0500
#define RIGHT		0x0700
#define UP			0x0600
#define DOWN		0x0800
#define PGUP		0x0100
#define PGDN		0x0200
#define HOME		0x0400
#define INSERT		0x0D00
#define END			0x0300
#define DEL			0x0E00
#define CTRL		0x8000
#define SHIFT		0x4000

byte is_move_key(word key)
{
	if (key >= 0x100)
	{
		byte b = (key >> 8) & 0x3F;
		return (b > 0 && b < 9);
	}
	return 0;
}

void join_prev_line()
{
	Vector* prev_line = get_line(cursor.y - 1);
	Vector* cur_line = get_line(cursor.y);
	word m = vector_size(prev_line);
	word n = vector_size(cur_line);
	byte* data = vector_access(cur_line, 0);
	for (word i = 0; i < n; ++i)
		vector_push(prev_line, &data[i]);
	vector_shut(cur_line);
	vector_erase(document, cursor.y);
	cursor.y--;
	cursor.x = logical_to_visual(prev_line, m);
}

byte delete_single_line_selection()
{
	Vector* line = get_line(select_start.y);
	vector_erase_range(line, select_start.x, select_stop.x);
	cursor = select_start;
	redraw_line(select_start.y);
	select_stop = select_start;
	return 1;
}

byte delete_selection()
{
	if (select_start.y == select_stop.y)
		return delete_single_line_selection();
	Vector* line = get_line(select_start.y);
	word n = vector_size(line);
	vector_erase_range(line, select_start.x, n);
	if ((select_stop.y - select_start.y) > 1)
	{
		for (short y = select_start.y + 1; y < select_stop.y; ++y)
		{
			line = get_line(y);
			vector_shut(line);
		}
		vector_erase_range(document, select_start.y + 1, select_stop.y);
		select_stop.y = select_start.y + 1;
	}
	if (select_stop.x > 0)
	{
		line = get_line(select_stop.y);
		n = vector_size(line);
		vector_erase_range(line, 0, select_stop.x);
	}
	if (select_stop.y > select_start.y)
	{
		cursor.y = select_stop.y;
		cursor.x = 0;
		join_prev_line();
	}
	cursor = select_start;
	redraw_start = 0;
	redraw_stop = 0x7000;
	select_stop = select_start;
	return 0;
}

byte do_delete()
{
	if (valid_select()) return delete_selection();
	Vector* line = get_line(cursor.y);
	if (cursor.x < vector_size(line))
	{
		vector_erase(line, cursor.x);
	}
	else
	if (cursor.y < (vector_size(document)-1))
	{
		Vector* next_line = get_line(cursor.y + 1);
		word n = vector_size(next_line);
		byte* data = vector_access(next_line, 0);
		for (word j = 0; j < n; ++j)
			vector_push(line, &data[j]);
		vector_shut(next_line);
		vector_erase(document, cursor.y + 1);
		return 0; /* Indicate redraw from line to end of screen */
	}
	return 1;
}

void backspace()
{
	move_x_cursor(-1);
	do_delete();
}

void add_enter()
{
	if (insert)
	{
		Vector* cur_line = get_line(cursor.y);
		word n = vector_size(cur_line);
		byte* data = vector_access(cur_line, 0);
		Vector* next_line = vector_new(1);
		vector_insert(document, cursor.y + 1, &next_line);
		for (word j = cursor.x; j < n; ++j)
			vector_push(next_line, &data[j]);
		vector_erase_range(cur_line, cursor.x, n);
		cursor.y++;
		cursor.x = 0;
	}
}

void add_char(byte c)
{
	if (c == 10 || c == 13)
	{
		add_enter();
	}
	else
	{
		Vector* line = get_line(cursor.y);
		if (cursor.x >= vector_size(line)) vector_push(line, &c);
		else
		{
			if (insert)
			{
				vector_insert(line, cursor.x, &c);
			}
			else
			{
				vector_set(line, cursor.x, &c);
			}
		}
		++cursor.x;
	}
}

word getkey()
{
	//if (!input_empty())
	//	return input_read();
	//return 0;
	return hal_getkey();
}

void move_y(short dy)
{
	Vector* line = get_line(cursor.y);
	short vx = logical_to_visual(line, cursor.x);
	cursor.y += dy;
	line = get_line(cursor.y);
	cursor.x = visual_to_logical(line, vx);
}

void clipboard_copy()
{
	if (!valid_select()) return;
	vector_clear(clipboard);
	for (short y = select_start.y; y <= select_stop.y; ++y)
	{
		Vector* line = get_line(y);
		if (!line) continue;
		short start = 0, stop=vector_size(line);
		if (y == select_start.y)
		{
			start = select_start.x;
		}
		if (y == select_stop.y && select_stop.x < stop)
			stop = select_stop.x;
		byte* data = vector_access(line, 0);
		for (short x = start; x < stop; ++x)
		{
			vector_push(clipboard, &(data[x]));
		}
		if (y < select_stop.y)
		{
			byte enter = 10;
			vector_push(clipboard, &enter);
		}
	}
}

void clipboard_cut()
{
	if (!valid_select()) return;
	clipboard_copy();
	do_delete();
}

void clipboard_paste()
{
	if (valid_select())
		do_delete();
	word n = vector_size(clipboard);
	const byte* data = vector_access(clipboard, 0);
	for (word i = 0; i < n; ++i)
	{
		add_char(data[i]);
	}
	redraw_start = 0;
	redraw_stop = 0x7000;
}

void event_loop()
{
	byte done = 0;
	const word total_lines = vector_size(document);
	while (!done)
	{
		Cursor prev_cursor;
		prev_cursor.x = cursor.x;
		prev_cursor.y = cursor.y;
		Vector* line = get_line(cursor.y);
		word n = vector_size(line);
		word key = getkey();
		byte moving = is_move_key(key);
		byte shifted = ((key & SHIFT) != 0 ? 1 : 0);
		byte ctrl = ((key & CTRL) != 0 ? 1 : 0);
		key &= ~CTRL;
		if (moving)
		{
			if (shifted)
			{
				if (!valid_select())
					start_select();
				key &= ~SHIFT;
			}
			else
				clear_select();
		}
		switch (key)
		{
			case LEFT: if (cursor.x > 0) move_x_cursor(-1); break;
			case RIGHT: move_x_cursor(1); break;
			case UP:
			{
				if (ctrl)
				{
					if (offset.y > 0)
					{
						--offset.y;
						redraw_all();
					}
				}
				else
				{
					if (cursor.y > 0)
						move_y(-1);
				}
				break;
			}
			case DOWN:
			{
				if (ctrl)
				{
					if (offset.y < vector_size(document))
					{
						++offset.y;
						if (!cursor_in_view())
							move_y(1);
						redraw_all();
					}
				}
				else
				{
					if (cursor.y < total_lines)
						move_y(1);
				}
				break;
			}
			case HOME:
			{
				if (ctrl)
				{
					cursor.y = 0;
					cursor.x = 0;
				}
				else
					cursor.x = 0;
				break;
			}
			case END:
			{
				if (ctrl)
				{
					cursor.y = vector_size(document) - 1;
					Vector* end_line = get_line(cursor.y);
					cursor.x = vector_size(end_line);
				}
				else
					cursor.x = n;
				break;
			}
			case PGUP: if (cursor.y < 25) cursor.y = 0; else cursor.y -= 25; break;
			case PGDN: cursor.y = min(cursor.y + 25, total_lines); break;
			case 27: done = 1; break;
			case INSERT:
			{
				if (ctrl) clipboard_copy();
				else if (shifted) clipboard_paste();
				break;
			}
			case CONTROL('C'): clipboard_copy(); break;
			case CONTROL('X'): clipboard_cut(); break;
			case CONTROL('V'): clipboard_paste(); break;
			case 9:
			{
				add_char(9);
				redraw_line(cursor.y);
				break;
			}
			case 8:
			{
				if (cursor.x > 0)
				{
					backspace();
					redraw_line(cursor.y);
				}
				else
				if (cursor.y>0)
				{
					join_prev_line();
				}
				break;
			}
			case DEL:
			{
				if (ctrl) clipboard_cut();
				else
				if (do_delete())
					redraw_line(cursor.y);
				else
				{
					redraw_from(cursor.y);
				}
				break;
			}
			case 13:
			case 10:
			{
				add_enter();
				redraw_from(prev_cursor.y);
			}
			default:
			{
				if (key >= 32 && key < 127)
				{
					add_char((byte)key);
					redraw_line(cursor.y);
				}
			}
		}
		line = get_line(cursor.y);
		n = vector_size(line);
		if (cursor.x > n) 
			cursor.x = n;
		if (moving && shifted)
		{
			extend_select();
			redraw_range(prev_cursor.y, cursor.y);
		}
		place_cursor();
		draw_screen();
		draw_cursor_position();
		place_cursor();
	}
}

#ifdef DEV
#define MAIN dev_main
#else
#define MAIN main
#endif

int MAIN(char** args)
{
	init_state();
	alloc_init();
	hal_init();
	clipboard = vector_new(1);
	vector_reserve(clipboard, 256);
	document = vector_new(sizeof(Vector*));
	if (args[0])
	{
		load_file(args[0]);
	}
	fg = 0x3F;
	bg = 0x40;
	draw_frame();
	draw_screen();
	hal_blink(1);
	event_loop();
	hal_shutdown();
	clear();
	vector_shut(document);
	return 0;
}


#ifdef DEV
int main(int argc, char* argv[])
{
	char* args[8];
	for (int i = 0; i < 8; ++i)
		args[i] = 0;
	for (int i = 1; i < argc; ++i)
		args[i - 1] = argv[i];
	dev_main(args);
	return 0;
}
#endif