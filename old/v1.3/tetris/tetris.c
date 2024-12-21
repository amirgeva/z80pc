/*
#include "global_data.h"

extern GlobalData g;
*/

typedef unsigned char uint8_t;
typedef unsigned char byte;
typedef unsigned short word;

#pragma disable_warning  59
word system_call(byte call_type)
{
	call_type;
	__asm
	rst #8
	__endasm;
}

word random()
{
	return system_call(0);
}

void send_command(const byte* data, byte len)
{
	data;
	len;
	__asm
	ld b,a
	otir
	__endasm;
}

void cls()
{
	__asm
	ld a,#1
	out (0),a
	__endasm;
}

void nop()
{
	__asm
	ld a,#0
	out (0),a
	__endasm;
}


void pixel_cursor(word x, word y)
{
	uint8_t cmd[5];
	cmd[0]=5;
	cmd[1]=x&0xFF;
	cmd[2]=(x>>8)&0xFF;
	cmd[3]=y&0xFF;
	cmd[4]=(y>>8)&0xFF;
	send_command(cmd,5);
}

void draw_cube(word x, word y, uint8_t color)
{
	uint8_t cmd[2];
	pixel_cursor(x,y);
	cmd[0]=41;
	cmd[1]=color;
	send_command(cmd,2);
}

void initialize_cubes()
{
	uint8_t cmd[258];
	cmd[0]=40;
	for(uint8_t i=0;i<64;++i)
	{
		cmd[1]=i;
		for(word j=0;j<0x100;++j)
			cmd[2+j]=i;
		send_command(cmd,4);
		send_command(cmd+4,254);
	}
}

uint8_t wait_key()
{
	word key = system_call(1);
	if (key&0xFF00)
		return 0xFF;
	return key&0xFF;
}

#define L 7
#define W 11
#define H 16

typedef struct board_
{
	uint8_t grid[W * H];
} Board;

void initialize_board(Board* board)
{
	for (uint8_t i = 0; i < (W * H); ++i)
		board->grid[i] = 0;
}

uint8_t board_position_free(Board* board, uint8_t x, uint8_t y)
{
	if (x >= W || y >= H) return 0;
	return board->grid[y * W + x] == 0;
}

void remove_full_rows(Board* board)
{
	uint8_t full_rows = 0;
	uint8_t ofs = (H - 1) * W;
	for (uint8_t y = H - 1; y > 0; --y, ofs-=W)
	{
		uint8_t count = 0;
		for (uint8_t x = 0; x < W; ++x)
			if (board->grid[ofs + x] != 0)
				++count;
		if (count == W)
		{
			full_rows++;
			uint8_t aofs = ofs;
			for (uint8_t ay = y; ay > 0; --ay)
			{
				for (uint8_t x = 0; x < W; ++x)
					board->grid[aofs + x] = board->grid[aofs + x - W];
				aofs -= W;
			}
			for (uint8_t x = 0; x < W; ++x)
				board->grid[x] = 0;
			// Do the same row again
			++y;
			ofs += W;
		}
	}
	if (full_rows > 0)
	{
		uint8_t ofs = 0;
		for (uint8_t by = 0; by < H; ++by)
		{
			word y= ((word)by) << 4;
			for (uint8_t bx = 0; bx < W; ++bx, ++ofs)
			{
				word x = ((word)(bx + L)) << 4;
				draw_cube(x, y, board->grid[ofs]);
			}
		}
	}
}

const uint8_t offsets[] = 
{
	0xFE, 0x00, 0xFF, 0x00, 0x00, 0x00, 0x01, 0x00,
	0xFF, 0x00, 0x00, 0x00, 0x01, 0x00, 0x01, 0x01,
	0xFF, 0x00, 0x00, 0x00, 0x01, 0x00, 0x01, 0xFF,
	0xFF, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x01,
	0xFF, 0x00, 0x00, 0x00, 0x00, 0xFF, 0x01, 0xFF,
	0xFF, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x01,
	0xFF, 0x00, 0x00, 0x00, 0xFF, 0x01, 0x00, 0x01
};

typedef struct piece_
{
	uint8_t cx, cy;
	uint8_t offsets[8];
	uint8_t color;
	uint8_t valid;
} Piece;

void place_piece(Board* board, Piece* piece)
{
	for (uint8_t i = 0; i < 4; ++i)
	{
		uint8_t x = piece->offsets[i * 2 + 0] + piece->cx;
		uint8_t y = piece->offsets[i * 2 + 1] + piece->cy;
		board->grid[y * W + x] = piece->color;
	}
	piece->valid = 0;
}

uint8_t generate_piece(Piece* piece)
{
	uint8_t i;
	piece->cx = W/2;
	piece->cy = 2;
	uint8_t type = random() & 7;
	if (type < 7)
	{
		uint8_t base = type << 3;
		for (i = 0; i < 8; ++i)
			piece->offsets[i] = offsets[base + i];
		piece->color = type+1;
		piece->valid = 1;
		return 1;
	}
	return 0;
}

void draw_piece(Piece* piece, uint8_t erase)
{
	uint8_t color = erase ? 0 : piece->color;
	for (uint8_t i = 0; i < 4; ++i)
	{
		uint8_t bx = piece->cx + piece->offsets[i * 2 + 0];
		uint8_t by = piece->cy + piece->offsets[i * 2 + 1];
		bx += L;
		word x = bx << 4;
		word y = by << 4;
		draw_cube(x, y, color);
	}
}

uint8_t move_piece(Board* board, Piece* piece, uint8_t dx, uint8_t dy)
{
	for (uint8_t i = 0; i < 4; ++i)
	{
		uint8_t x = piece->offsets[i * 2 + 0] + piece->cx + dx;
		uint8_t y = piece->offsets[i * 2 + 1] + piece->cy + dy;
		if (!board_position_free(board, x, y))
			return 0;
	}
	draw_piece(piece, 1);
	piece->cx += dx;
	piece->cy += dy;
	draw_piece(piece, 0);
	return 1;
}

uint8_t rotate_piece(Board* board, Piece* piece)
{
	uint8_t offsets[8];
	uint8_t j=0;
	for (uint8_t i = 0; i < 4; ++i, j+=2)
	{
		offsets[j] = -piece->offsets[j+1];
		offsets[j+1] = piece->offsets[j];
		uint8_t x = offsets[j] + piece->cx;
		uint8_t y = offsets[j+1] + piece->cy;
		if (!board_position_free(board, x, y))
			return 0;
	}
	draw_piece(piece, 1);
	for (uint8_t i = 0; i < 8; ++i)
		piece->offsets[i] = offsets[i];
	draw_piece(piece, 0);
	return 1;
}

void draw_frame()
{
	word x0 = (L-1) * 16;
	word x1 = (L+W) * 16;
	for (word y = 0; y < H; ++y)
	{
		draw_cube(x0, y * 16, 63);
		draw_cube(x1, y * 16, 63);
	}
	word y1 = H * 16;
	for (word x = L-1; x <= (L+W); ++x)
	{
		draw_cube(x*16, y1, 63);
	}
}

void game()
{
	Board board;
	Piece piece;
	//initialize_cubes();
	cls();
	initialize_board(&board);
	piece.valid = 0;
	draw_frame();
	word last_timer=0;
	while (1)
	{
		if (piece.valid == 0)
		{
			while (!generate_piece(&piece));
			if (piece.valid)
				draw_piece(&piece, 0);
		}
		uint8_t key = wait_key();
		if (key == '4')
			move_piece(&board, &piece, 0xFF, 0);
		else
		if (key == '6')
			move_piece(&board, &piece, 1, 0);
		else
		if (key == '2')
			move_piece(&board, &piece, 0, 1);
		else
		if (key == '5')
			rotate_piece(&board, &piece);
		else
		{
			word cur_timer = system_call(2); /* timer */
			word diff = cur_timer - last_timer;
			if (diff > 50)
			{
				last_timer=cur_timer;
				if (!move_piece(&board, &piece, 0, 1))
				{
					place_piece(&board, &piece);
					remove_full_rows(&board);
				}
			}
		}
	}
}