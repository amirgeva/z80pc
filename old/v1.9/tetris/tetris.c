#include <stdlib.h>


void pixel_cursor(word x, word y)
{
	byte cmd[6];
	cmd[0]=5;
	cmd[1]=5;
	cmd[2]=x&0xFF;
	cmd[3]=(x>>8)&0xFF;
	cmd[4]=y&0xFF;
	cmd[5]=(y>>8)&0xFF;
	gpu_block(cmd);
}

void draw_cube(word x, word y, byte color)
{
	byte cmd[3];
	pixel_cursor(x,y);
	cmd[0]=2;
	cmd[1]=41;
	cmd[2]=color;
	gpu_block(cmd);
}

void initialize_cubes()
{
	// Since we need to send 256 color bytes,
	// 2 command bytes and 2 length bytes
	// We'll split it into 2 buffers
	byte header[5];
	header[0]=4;
	header[1]=40; // set sprite command
	byte color[256];
	color[0]=254;
	for(byte i=0;i<64;++i)
	{
		header[2]=i; // sprite id
		header[3]=i; // sprite color
		header[4]=i; // sprite color
		for(byte j=0;j<254;++j)
			color[1+j]=i;
		gpu_block(header);
		gpu_block(color);
	}
}

byte wait_key()
{
	if (input_empty()) return 0xFF;
	return input_read();
}

#define L 7
#define W 11
#define H 16

typedef struct board_
{
	byte grid[W * H];
	byte game_over;
} Board;

typedef struct piece_
{
	byte cx, cy;
	byte offsets[8];
	byte color;
	byte valid;
} Piece;

byte move_piece(Board* board, Piece* piece, byte dx, byte dy);

void initialize_board(Board* board)
{
	for (byte i = 0; i < (W * H); ++i)
		board->grid[i] = 0;
	board->game_over=0;
}

byte board_position_free(Board* board, byte x, byte y)
{
	if (x >= W || y >= H) return 0;
	return board->grid[y * W + x] == 0;
}

void remove_full_rows(Board* board)
{
	byte full_rows = 0;
	byte ofs = (H - 1) * W;
	for (byte y = H - 1; y > 0; --y, ofs-=W)
	{
		byte count = 0;
		for (byte x = 0; x < W; ++x)
			if (board->grid[ofs + x] != 0)
				++count;
		if (count == W)
		{
			full_rows++;
			byte aofs = ofs;
			for (byte ay = y; ay > 0; --ay)
			{
				for (byte x = 0; x < W; ++x)
					board->grid[aofs + x] = board->grid[aofs + x - W];
				aofs -= W;
			}
			for (byte x = 0; x < W; ++x)
				board->grid[x] = 0;
			// Do the same row again
			++y;
			ofs += W;
		}
	}
	if (full_rows > 0)
	{
		byte ofs = 0;
		for (byte by = 0; by < H; ++by)
		{
			word y= ((word)by) << 4;
			for (byte bx = 0; bx < W; ++bx, ++ofs)
			{
				word x = ((word)(bx + L)) << 4;
				draw_cube(x, y, board->grid[ofs]);
			}
		}
	}
}

const byte offsets[] = 
{
	0xFE, 0x00, 0xFF, 0x00, 0x00, 0x00, 0x01, 0x00,
	0xFF, 0x00, 0x00, 0x00, 0x01, 0x00, 0x01, 0x01,
	0xFF, 0x00, 0x00, 0x00, 0x01, 0x00, 0x01, 0xFF,
	0xFF, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x01,
	0xFF, 0x00, 0x00, 0x00, 0x00, 0xFF, 0x01, 0xFF,
	0xFF, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x01,
	0xFF, 0x00, 0x00, 0x00, 0xFF, 0x01, 0x00, 0x01
};

void place_piece(Board* board, Piece* piece)
{
	for (byte i = 0; i < 4; ++i)
	{
		byte x = piece->offsets[i * 2 + 0] + piece->cx;
		byte y = piece->offsets[i * 2 + 1] + piece->cy;
		board->grid[y * W + x] = piece->color;
	}
	piece->valid = 0;
}

byte generate_piece(Board* board, Piece* piece)
{
	byte i;
	piece->cx = W/2;
	piece->cy = 2;
	byte type = rng() & 7;
	if (type < 7)
	{
		byte base = type << 3;
		for (i = 0; i < 8; ++i)
			piece->offsets[i] = offsets[base + i];
		piece->color = type+1;
		piece->valid = 1;
		if (!move_piece(board, piece, 0, 0))
			board->game_over=1;
		return 1;
	}
	return 0;
}

void draw_piece(Piece* piece, byte erase)
{
	byte color = erase ? 0 : piece->color;
	for (byte i = 0; i < 4; ++i)
	{
		byte bx = piece->cx + piece->offsets[i * 2 + 0];
		byte by = piece->cy + piece->offsets[i * 2 + 1];
		bx += L;
		word x = bx << 4;
		word y = by << 4;
		draw_cube(x, y, color);
	}
}

byte move_piece(Board* board, Piece* piece, byte dx, byte dy)
{
	for (byte i = 0; i < 4; ++i)
	{
		byte x = piece->offsets[i * 2 + 0] + piece->cx + dx;
		byte y = piece->offsets[i * 2 + 1] + piece->cy + dy;
		if (!board_position_free(board, x, y))
			return 0;
	}
	draw_piece(piece, 1);
	piece->cx += dx;
	piece->cy += dy;
	draw_piece(piece, 0);
	return 1;
}

byte rotate_piece(Board* board, Piece* piece)
{
	byte offsets[8];
	byte j=0;
	for (byte i = 0; i < 4; ++i, j+=2)
	{
		offsets[j] = -piece->offsets[j+1];
		offsets[j+1] = piece->offsets[j];
		byte x = offsets[j] + piece->cx;
		byte y = offsets[j+1] + piece->cy;
		if (!board_position_free(board, x, y))
			return 0;
	}
	draw_piece(piece, 1);
	for (byte i = 0; i < 8; ++i)
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

void draw_game_over()
{
	const byte coords[] = {
		1, 0, 2, 0, 3, 0, 7, 0, 11, 0, 12, 0, 14, 0, 15, 0, 17, 0, 18, 0, 19, 0, 20, 0, 
		0, 1, 6, 1, 8, 1, 11, 1, 13, 1, 15, 1, 17, 1, 0, 2, 3, 2, 5, 2, 9, 2, 11, 2, 15,
		2, 17, 2, 18, 2, 0, 3, 3, 3, 5, 3, 6, 3, 7, 3, 8, 3, 9, 3, 11, 3, 15, 3, 17, 3, 
		1, 4, 2, 4, 5, 4, 9, 4, 11, 4, 15, 4, 17, 4, 18, 4, 19, 4, 20, 4, 1, 6, 2, 6, 3,
		6, 6, 6, 10, 6, 12, 6, 13, 6, 14, 6, 15, 6, 17, 6, 18, 6, 19, 6, 0, 7, 4, 7, 6, 
		7, 10, 7, 12, 7, 17, 7, 20, 7, 0, 8, 4, 8, 7, 8, 9, 8, 12, 8, 13, 8, 17, 8, 18, 
		8, 19, 8, 0, 9, 4, 9, 7, 9, 9, 9, 12, 9, 17, 9, 20, 9, 1, 10, 2, 10, 3, 10, 8, 
		10, 12, 10, 13, 10, 14, 10, 15, 10, 17, 10, 20, 10
	};
	const byte n = sizeof(coords)/2;
	const byte* ptr=coords;
	for(byte i=0;i<n;++i)
	{
		word x=((word)*ptr++) * 16;
		word y=((word)*ptr++) * 16;
		draw_cube(x,y,4);
	}
}

void main()
{
	Board board;
	Piece piece;
	initialize_cubes();
	cls();
	initialize_board(&board);
	piece.valid = 0;
	draw_frame();
	word last_timer=0;
	while (1)
	{
		if (piece.valid == 0)
		{
			while (!generate_piece(&board, &piece));
			if (piece.valid)
				draw_piece(&piece, 0);
			if (board.game_over) break;
		}
		byte key = wait_key();
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
			word cur_timer = timer();
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
	cls();
	draw_game_over();
	while (wait_key()==0xFF);
	cls();
}