;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 4.2.0 #13081 (MINGW64)
;--------------------------------------------------------
	.module tetris
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _main
	.globl _draw_game_over
	.globl _draw_frame
	.globl _rotate_piece
	.globl _draw_piece
	.globl _generate_piece
	.globl _place_piece
	.globl _remove_full_rows
	.globl _board_position_free
	.globl _initialize_board
	.globl _wait_key
	.globl _initialize_cubes
	.globl _draw_cube
	.globl _pixel_cursor
	.globl _timer
	.globl _gpu_block
	.globl _rng
	.globl _input_read
	.globl _input_empty
	.globl _cls
	.globl _offsets
	.globl _move_piece
;--------------------------------------------------------
; special function registers
;--------------------------------------------------------
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _DATA
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _INITIALIZED
;--------------------------------------------------------
; absolute external ram data
;--------------------------------------------------------
	.area _DABS (ABS)
;--------------------------------------------------------
; global & static initialisations
;--------------------------------------------------------
	.area _HOME
	.area _GSINIT
	.area _GSFINAL
	.area _GSINIT
;--------------------------------------------------------
; Home
;--------------------------------------------------------
	.area _HOME
	.area _HOME
;--------------------------------------------------------
; code
;--------------------------------------------------------
	.area _CODE
;tetris.c:4: void pixel_cursor(word x, word y)
;	---------------------------------
; Function pixel_cursor
; ---------------------------------
_pixel_cursor::
	push	ix
	ld	ix,#0
	add	ix,sp
	push	af
	push	af
	push	af
	ld	c, l
	ld	b, h
;tetris.c:7: cmd[0]=5;
	ld	-6 (ix), #0x05
;tetris.c:8: cmd[1]=5;
	ld	-5 (ix), #0x05
;tetris.c:9: cmd[2]=x&0xFF;
	ld	-4 (ix), c
;tetris.c:10: cmd[3]=(x>>8)&0xFF;
	ld	-3 (ix), b
;tetris.c:11: cmd[4]=y&0xFF;
	ld	-2 (ix), e
;tetris.c:12: cmd[5]=(y>>8)&0xFF;
	ld	-1 (ix), d
;tetris.c:13: gpu_block(cmd);
	ld	hl, #0
	add	hl, sp
	call	_gpu_block
;tetris.c:14: }
	ld	sp, ix
	pop	ix
	ret
;tetris.c:16: void draw_cube(word x, word y, byte color)
;	---------------------------------
; Function draw_cube
; ---------------------------------
_draw_cube::
	push	af
	dec	sp
;tetris.c:19: pixel_cursor(x,y);
	call	_pixel_cursor
;tetris.c:20: cmd[0]=2;
	ld	hl, #0
	add	hl, sp
	ex	de, hl
	ld	a, #0x02
	ld	(de), a
;tetris.c:21: cmd[1]=41;
	ld	l, e
;	spillPairReg hl
;	spillPairReg hl
	ld	h, d
;	spillPairReg hl
;	spillPairReg hl
	inc	hl
	ld	(hl), #0x29
;tetris.c:22: cmd[2]=color;
	ld	c, e
	ld	b, d
	inc	bc
	inc	bc
	ld	iy, #5
	add	iy, sp
	ld	a, 0 (iy)
	ld	(bc), a
;tetris.c:23: gpu_block(cmd);
	ex	de, hl
	call	_gpu_block
;tetris.c:24: }
	pop	af
	inc	sp
	pop	hl
	inc	sp
	jp	(hl)
;tetris.c:26: void initialize_cubes()
;	---------------------------------
; Function initialize_cubes
; ---------------------------------
_initialize_cubes::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	hl, #-261
	add	hl, sp
	ld	sp, hl
;tetris.c:32: header[0]=4;
	ld	iy, #0
	add	iy, sp
	ld	0 (iy), #0x04
;tetris.c:33: header[1]=40; // set sprite command
	inc	iy
	ld	0 (iy), #0x28
;tetris.c:35: color[0]=254;
	ld	iy, #5
	add	iy, sp
	ld	0 (iy), #0xfe
;tetris.c:36: for(byte i=0;i<64;++i)
	ld	c, #0x00
00107$:
	ld	a, c
	sub	a, #0x40
	jr	NC, 00109$
;tetris.c:38: header[2]=i; // sprite id
	ld	iy, #2
	add	iy, sp
	ld	0 (iy), c
;tetris.c:39: header[3]=i; // sprite color
	inc	iy
	ld	0 (iy), c
;tetris.c:40: header[4]=i; // sprite color
	inc	iy
	ld	0 (iy), c
;tetris.c:41: for(byte j=0;j<254;++j)
	ld	b, #0x00
00104$:
	ld	a, b
	sub	a, #0xfe
	jr	NC, 00101$
;tetris.c:42: color[1+j]=i;
	ld	e, b
	ld	d, #0x00
	inc	de
	ld	hl, #5
	add	hl, sp
	add	hl, de
	ld	(hl), c
;tetris.c:41: for(byte j=0;j<254;++j)
	inc	b
	jr	00104$
00101$:
;tetris.c:43: gpu_block(header);
	push	bc
	ld	hl, #2
	add	hl, sp
	call	_gpu_block
	ld	hl, #7
	add	hl, sp
	call	_gpu_block
	pop	bc
;tetris.c:36: for(byte i=0;i<64;++i)
	inc	c
	jr	00107$
00109$:
;tetris.c:46: }
	ld	sp, ix
	pop	ix
	ret
;tetris.c:48: byte wait_key()
;	---------------------------------
; Function wait_key
; ---------------------------------
_wait_key::
;tetris.c:50: if (input_empty()) return 0xFF;
	call	_input_empty
	or	a, a
	jp	Z,_input_read
;tetris.c:51: return input_read();
	ld	a, #0xff
;tetris.c:52: }
	ret
;tetris.c:74: void initialize_board(Board* board)
;	---------------------------------
; Function initialize_board
; ---------------------------------
_initialize_board::
	ex	de, hl
;tetris.c:76: for (byte i = 0; i < (W * H); ++i)
	ld	c, #0x00
00103$:
	ld	a, c
	sub	a, #0xb0
	jr	NC, 00101$
;tetris.c:77: board->grid[i] = 0;
	ld	l, c
	ld	h, #0x00
	add	hl, de
	ld	(hl), #0x00
;tetris.c:76: for (byte i = 0; i < (W * H); ++i)
	inc	c
	jr	00103$
00101$:
;tetris.c:78: board->game_over=0;
	ld	hl, #0x00b0
	add	hl, de
	ld	(hl), #0x00
;tetris.c:79: }
	ret
;tetris.c:81: byte board_position_free(Board* board, byte x, byte y)
;	---------------------------------
; Function board_position_free
; ---------------------------------
_board_position_free::
	push	ix
	ld	ix,#0
	add	ix,sp
	ex	de, hl
;tetris.c:83: if (x >= W || y >= H) return 0;
	ld	a, 4 (ix)
	sub	a, #0x0b
	jr	NC, 00101$
	ld	a, 5 (ix)
	sub	a, #0x10
	jr	C, 00102$
00101$:
	xor	a, a
	jr	00104$
00102$:
;tetris.c:84: return board->grid[y * W + x] == 0;
	ld	c, 5 (ix)
	ld	b, #0x00
	ld	l, c
	ld	h, b
	add	hl, hl
	add	hl, hl
	add	hl, bc
	add	hl, hl
	add	hl, bc
	ld	c, 4 (ix)
	ld	b, #0x00
	add	hl, bc
	add	hl, de
	ld	a, (hl)
	or	a, a
	ld	a, #0x01
	jr	Z, 00112$
	xor	a, a
00112$:
00104$:
;tetris.c:85: }
	pop	ix
	pop	hl
	pop	bc
	jp	(hl)
;tetris.c:87: void remove_full_rows(Board* board)
;	---------------------------------
; Function remove_full_rows
; ---------------------------------
_remove_full_rows::
	push	ix
	ld	ix,#0
	add	ix,sp
	push	af
	push	af
	push	af
	ld	c, l
	ld	b, h
;tetris.c:90: byte ofs = (H - 1) * W;
	ld	e, #0xa5
;tetris.c:91: for (byte y = H - 1; y > 0; --y, ofs-=W)
	ld	-4 (ix), #0x0f
	ld	-3 (ix), #0x00
00127$:
	ld	a, -4 (ix)
	or	a, a
	jp	Z, 00109$
;tetris.c:94: for (byte x = 0; x < W; ++x)
	ld	-2 (ix), #0x00
	ld	-1 (ix), #0x00
00115$:
	ld	a, -1 (ix)
	sub	a, #0x0b
	jr	NC, 00103$
;tetris.c:95: if (board->grid[ofs + x] != 0)
	ld	a, e
	ld	d, #0x00
	ld	l, -1 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, #0x00
;	spillPairReg hl
;	spillPairReg hl
	add	a, l
	ld	l, a
;	spillPairReg hl
;	spillPairReg hl
	ld	a, d
	adc	a, h
	ld	h, a
;	spillPairReg hl
;	spillPairReg hl
	add	hl, bc
	ld	a, (hl)
	or	a, a
	jr	Z, 00116$
;tetris.c:96: ++count;
	inc	-2 (ix)
00116$:
;tetris.c:94: for (byte x = 0; x < W; ++x)
	inc	-1 (ix)
	jr	00115$
00103$:
;tetris.c:97: if (count == W)
	ld	a, -2 (ix)
	sub	a, #0x0b
	jr	NZ, 00128$
;tetris.c:99: full_rows++;
	inc	-3 (ix)
;tetris.c:100: byte aofs = ofs;
	ld	d, e
;tetris.c:101: for (byte ay = y; ay > 0; --ay)
	ld	a, -4 (ix)
	ld	-2 (ix), a
00121$:
	ld	a, -2 (ix)
	or	a, a
	jr	Z, 00151$
;tetris.c:103: for (byte x = 0; x < W; ++x)
	ld	-1 (ix), #0x00
00118$:
	ld	a, -1 (ix)
	sub	a, #0x0b
	jr	NC, 00104$
;tetris.c:104: board->grid[aofs + x] = board->grid[aofs + x - W];
	ld	-6 (ix), d
	ld	-5 (ix), #0x00
	ld	a, -1 (ix)
	ld	h, #0x00
;	spillPairReg hl
;	spillPairReg hl
	add	a, -6 (ix)
	ld	l, a
;	spillPairReg hl
;	spillPairReg hl
	ld	a, h
	adc	a, -5 (ix)
	ld	h, a
;	spillPairReg hl
;	spillPairReg hl
	ld	a, c
	add	a, l
	ld	-6 (ix), a
	ld	a, b
	adc	a, h
	ld	-5 (ix), a
	ld	a, l
	add	a, #0xf5
	ld	l, a
;	spillPairReg hl
;	spillPairReg hl
	ld	a, h
	adc	a, #0xff
	ld	h, a
;	spillPairReg hl
;	spillPairReg hl
	add	hl, bc
	ld	a, (hl)
	pop	hl
	push	hl
	ld	(hl), a
;tetris.c:103: for (byte x = 0; x < W; ++x)
	inc	-1 (ix)
	jr	00118$
00104$:
;tetris.c:105: aofs -= W;
	ld	a, d
	add	a, #0xf5
	ld	d, a
;tetris.c:101: for (byte ay = y; ay > 0; --ay)
	dec	-2 (ix)
	jr	00121$
;tetris.c:107: for (byte x = 0; x < W; ++x)
00151$:
	ld	d, #0x00
00124$:
	ld	a, d
	sub	a, #0x0b
	jr	NC, 00106$
;tetris.c:108: board->grid[x] = 0;
	ld	l, d
	ld	h, #0x00
	add	hl, bc
	ld	(hl), #0x00
;tetris.c:107: for (byte x = 0; x < W; ++x)
	inc	d
	jr	00124$
00106$:
;tetris.c:110: ++y;
	inc	-4 (ix)
;tetris.c:111: ofs += W;
	ld	a, e
	add	a, #0x0b
	ld	e, a
00128$:
;tetris.c:91: for (byte y = H - 1; y > 0; --y, ofs-=W)
	dec	-4 (ix)
	ld	a, e
	add	a, #0xf5
	ld	e, a
	jp	00127$
00109$:
;tetris.c:114: if (full_rows > 0)
	ld	a, -3 (ix)
	or	a, a
	jr	Z, 00135$
;tetris.c:116: byte ofs = 0;
	ld	e, #0x00
;tetris.c:117: for (byte by = 0; by < H; ++by)
	ld	-3 (ix), #0x00
00133$:
	ld	a, -3 (ix)
	sub	a, #0x10
	jr	NC, 00135$
;tetris.c:119: word y= ((word)by) << 4;
	ld	l, -3 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, #0x00
;	spillPairReg hl
;	spillPairReg hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	-5 (ix), l
	ld	-4 (ix), h
;tetris.c:120: for (byte bx = 0; bx < W; ++bx, ++ofs)
	ld	-2 (ix), #0x00
	ld	-1 (ix), e
00130$:
	ld	a, -2 (ix)
	sub	a, #0x0b
	jr	NC, 00161$
;tetris.c:122: word x = ((word)(bx + L)) << 4;
	ld	e, -2 (ix)
	ld	d, #0x00
	ld	hl, #0x0007
	add	hl, de
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
;tetris.c:123: draw_cube(x, y, board->grid[ofs]);
	ld	a, -1 (ix)
	add	a, c
	ld	e, a
	ld	a, #0x00
	adc	a, b
	ld	d, a
	ld	a, (de)
	push	bc
	push	af
	inc	sp
	ld	e, -5 (ix)
	ld	d, -4 (ix)
	call	_draw_cube
	pop	bc
;tetris.c:120: for (byte bx = 0; bx < W; ++bx, ++ofs)
	inc	-2 (ix)
	inc	-1 (ix)
	jr	00130$
00161$:
	ld	e, -1 (ix)
;tetris.c:117: for (byte by = 0; by < H; ++by)
	inc	-3 (ix)
	jr	00133$
00135$:
;tetris.c:127: }
	ld	sp, ix
	pop	ix
	ret
;tetris.c:140: void place_piece(Board* board, Piece* piece)
;	---------------------------------
; Function place_piece
; ---------------------------------
_place_piece::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	iy, #-10
	add	iy, sp
	ld	sp, iy
	ld	-3 (ix), l
	ld	-2 (ix), h
;tetris.c:142: for (byte i = 0; i < 4; ++i)
	ld	hl, #0x0002
	add	hl, de
	ex	(sp), hl
	ld	-8 (ix), e
	ld	-7 (ix), d
	ld	-6 (ix), e
	ld	-5 (ix), d
	ld	-1 (ix), #0x00
00103$:
	ld	a, -1 (ix)
	sub	a, #0x04
	jr	NC, 00101$
;tetris.c:144: byte x = piece->offsets[i * 2 + 0] + piece->cx;
	ld	a, -1 (ix)
	add	a, a
	ld	c, a
	pop	hl
	push	hl
	ld	b, #0x00
	add	hl, bc
	ld	a, (de)
	ld	b, (hl)
	add	a, b
	ld	-4 (ix), a
;tetris.c:145: byte y = piece->offsets[i * 2 + 1] + piece->cy;
	ld	a, c
	inc	a
	add	a, -10 (ix)
	ld	c, a
	ld	a, #0x00
	adc	a, -9 (ix)
	ld	b, a
	ld	l, -8 (ix)
	ld	h, -7 (ix)
	inc	hl
	ld	l, (hl)
;	spillPairReg hl
	ld	a, (bc)
	add	a, l
;tetris.c:146: board->grid[y * W + x] = piece->color;
	ld	c, a
	ld	b, #0x00
	ld	l, c
	ld	h, b
	add	hl, hl
	add	hl, hl
	add	hl, bc
	add	hl, hl
	add	hl, bc
	ld	c, -4 (ix)
	ld	b, #0x00
	add	hl, bc
	ld	a, l
	add	a, -3 (ix)
	ld	c, a
	ld	a, h
	adc	a, -2 (ix)
	ld	b, a
	ld	l, -6 (ix)
	ld	h, -5 (ix)
	push	bc
	ld	bc, #0x000a
	add	hl, bc
	pop	bc
	ld	a, (hl)
	ld	(bc), a
;tetris.c:142: for (byte i = 0; i < 4; ++i)
	inc	-1 (ix)
	jr	00103$
00101$:
;tetris.c:148: piece->valid = 0;
	ld	hl, #0x000b
	add	hl, de
	ld	(hl), #0x00
;tetris.c:149: }
	ld	sp, ix
	pop	ix
	ret
_offsets:
	.db #0xfe	; 254
	.db #0x00	; 0
	.db #0xff	; 255
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x01	; 1
	.db #0x00	; 0
	.db #0xff	; 255
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x01	; 1
	.db #0x00	; 0
	.db #0x01	; 1
	.db #0x01	; 1
	.db #0xff	; 255
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x01	; 1
	.db #0x00	; 0
	.db #0x01	; 1
	.db #0xff	; 255
	.db #0xff	; 255
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x01	; 1
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x01	; 1
	.db #0xff	; 255
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0xff	; 255
	.db #0x01	; 1
	.db #0xff	; 255
	.db #0xff	; 255
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x01	; 1
	.db #0x01	; 1
	.db #0x01	; 1
	.db #0xff	; 255
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0xff	; 255
	.db #0x01	; 1
	.db #0x00	; 0
	.db #0x01	; 1
;tetris.c:151: byte generate_piece(Board* board, Piece* piece)
;	---------------------------------
; Function generate_piece
; ---------------------------------
_generate_piece::
	push	ix
	ld	ix,#0
	add	ix,sp
	push	af
	push	af
	push	af
	dec	sp
	ld	-2 (ix), l
	ld	-1 (ix), h
;tetris.c:154: piece->cx = W/2;
	ld	a, #0x05
	ld	(de), a
;tetris.c:155: piece->cy = 2;
	ld	l, e
;	spillPairReg hl
;	spillPairReg hl
	ld	h, d
;	spillPairReg hl
;	spillPairReg hl
	inc	hl
	ld	(hl), #0x02
;tetris.c:156: byte type = rng() & 7;
	push	de
	call	_rng
	ex	de, hl
	pop	de
	ld	a, l
	and	a, #0x07
;tetris.c:157: if (type < 7)
	cp	a, #0x07
	jr	NC, 00105$
;tetris.c:159: byte base = type << 3;
	ld	c, a
	add	a, a
	add	a, a
	add	a, a
	ld	-7 (ix), a
;tetris.c:160: for (i = 0; i < 8; ++i)
	ld	hl, #0x0002
	add	hl, de
	ld	-6 (ix), l
	ld	-5 (ix), h
	ld	b, #0x00
00106$:
;tetris.c:161: piece->offsets[i] = offsets[base + i];
	ld	a, -6 (ix)
	add	a, b
	ld	-4 (ix), a
	ld	a, -5 (ix)
	adc	a, #0x00
	ld	-3 (ix), a
	ld	a, -7 (ix)
	add	a, b
	add	a, #<(_offsets)
	ld	l, a
;	spillPairReg hl
;	spillPairReg hl
	ld	a, #0x00
	adc	a, #>(_offsets)
	ld	h, a
	ld	a, (hl)
	ld	l, -4 (ix)
	ld	h, -3 (ix)
	ld	(hl), a
;tetris.c:160: for (i = 0; i < 8; ++i)
	inc	b
	ld	a, b
	sub	a, #0x08
	jr	C, 00106$
;tetris.c:162: piece->color = type+1;
	ld	hl, #0x000a
	add	hl, de
	inc	c
	ld	(hl), c
;tetris.c:163: piece->valid = 1;
	ld	hl, #0x000b
	add	hl, de
	ld	(hl), #0x01
;tetris.c:164: if (!move_piece(board, piece, 0, 0))
	xor	a, a
	push	af
	inc	sp
	xor	a, a
	push	af
	inc	sp
	ld	l, -2 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -1 (ix)
;	spillPairReg hl
;	spillPairReg hl
	call	_move_piece
	or	a, a
	jr	NZ, 00103$
;tetris.c:165: board->game_over=1;
	ld	l, -2 (ix)
	ld	h, -1 (ix)
	ld	de, #0x00b0
	add	hl, de
	ld	(hl), #0x01
00103$:
;tetris.c:166: return 1;
	ld	a, #0x01
	jr	00108$
00105$:
;tetris.c:168: return 0;
	xor	a, a
00108$:
;tetris.c:169: }
	ld	sp, ix
	pop	ix
	ret
;tetris.c:171: void draw_piece(Piece* piece, byte erase)
;	---------------------------------
; Function draw_piece
; ---------------------------------
_draw_piece::
	push	ix
	ld	ix,#0
	add	ix,sp
	push	af
	push	af
	push	af
	dec	sp
	ld	c, l
	ld	b, h
;tetris.c:173: byte color = erase ? 0 : piece->color;
	ld	a, 4 (ix)
	or	a, a
	jr	Z, 00107$
	xor	a, a
	ld	e, a
	jr	00108$
00107$:
	push	bc
	pop	iy
	ld	a, 10 (iy)
	ld	e, #0x00
00108$:
	ld	-7 (ix), a
;tetris.c:174: for (byte i = 0; i < 4; ++i)
	ld	hl, #0x0002
	add	hl, bc
	ld	-6 (ix), l
	ld	-5 (ix), h
	ld	-4 (ix), c
	ld	-3 (ix), b
	ld	-1 (ix), #0x00
00103$:
	ld	a, -1 (ix)
	sub	a, #0x04
	jr	NC, 00105$
;tetris.c:176: byte bx = piece->cx + piece->offsets[i * 2 + 0];
	ld	a, (bc)
	ld	d, a
	ld	a, -1 (ix)
	add	a, a
	ld	e, a
	add	a, -6 (ix)
	ld	l, a
;	spillPairReg hl
;	spillPairReg hl
	ld	a, #0x00
	adc	a, -5 (ix)
	ld	h, a
	ld	a, (hl)
	add	a, d
	ld	-2 (ix), a
;tetris.c:177: byte by = piece->cy + piece->offsets[i * 2 + 1];
	ld	l, -4 (ix)
	ld	h, -3 (ix)
	inc	hl
	ld	l, (hl)
;	spillPairReg hl
	ld	a, e
	inc	a
	add	a, -6 (ix)
	ld	e, a
	ld	a, #0x00
	adc	a, -5 (ix)
	ld	d, a
	ld	a, (de)
	add	a, l
	ld	e, a
;tetris.c:178: bx += L;
	ld	a, -2 (ix)
	add	a, #0x07
;tetris.c:179: word x = bx << 4;
	ld	h, #0x00
;	spillPairReg hl
;	spillPairReg hl
	ld	l, a
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
;tetris.c:180: word y = by << 4;
	ld	d, #0x00
	ex	de, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
;tetris.c:181: draw_cube(x, y, color);
	push	bc
	ex	de, hl
	ld	a, -7 (ix)
	push	af
	inc	sp
	call	_draw_cube
	pop	bc
;tetris.c:174: for (byte i = 0; i < 4; ++i)
	inc	-1 (ix)
	jr	00103$
00105$:
;tetris.c:183: }
	ld	sp, ix
	pop	ix
	pop	hl
	inc	sp
	jp	(hl)
;tetris.c:185: byte move_piece(Board* board, Piece* piece, byte dx, byte dy)
;	---------------------------------
; Function move_piece
; ---------------------------------
_move_piece::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	iy, #-10
	add	iy, sp
	ld	sp, iy
	ld	c, l
	ld	b, h
;tetris.c:187: for (byte i = 0; i < 4; ++i)
	ld	hl, #0x0002
	add	hl, de
	ex	(sp), hl
	ld	l, e
	ld	h, d
	inc	hl
	ld	-8 (ix), l
	ld	-7 (ix), h
	ld	a, -8 (ix)
	ld	-6 (ix), a
	ld	a, -7 (ix)
	ld	-5 (ix), a
	ld	-1 (ix), #0x00
00105$:
	ld	a, -1 (ix)
	sub	a, #0x04
	jr	NC, 00103$
;tetris.c:189: byte x = piece->offsets[i * 2 + 0] + piece->cx + dx;
	ld	a, -1 (ix)
	add	a, a
	ld	-2 (ix), a
	add	a, -10 (ix)
	ld	l, a
;	spillPairReg hl
;	spillPairReg hl
	ld	a, #0x00
	adc	a, -9 (ix)
	ld	h, a
;	spillPairReg hl
;	spillPairReg hl
	ld	a, (de)
	ld	l, (hl)
;	spillPairReg hl
	add	a, l
	add	a, 4 (ix)
	ld	-4 (ix), a
;tetris.c:190: byte y = piece->offsets[i * 2 + 1] + piece->cy + dy;
	ld	a, -2 (ix)
	inc	a
	add	a, -10 (ix)
	ld	-3 (ix), a
	ld	a, #0x00
	adc	a, -9 (ix)
	ld	-2 (ix), a
	ld	l, -6 (ix)
	ld	h, -5 (ix)
	ld	a, (hl)
	ld	l, -3 (ix)
	ld	h, -2 (ix)
	ld	l, (hl)
;	spillPairReg hl
	add	a, l
	add	a, 5 (ix)
;tetris.c:191: if (!board_position_free(board, x, y))
	push	bc
	push	de
	push	af
	inc	sp
	ld	a, -4 (ix)
	push	af
	inc	sp
	ld	l, c
;	spillPairReg hl
;	spillPairReg hl
	ld	h, b
;	spillPairReg hl
;	spillPairReg hl
	call	_board_position_free
	pop	de
	pop	bc
	or	a, a
	jr	NZ, 00106$
;tetris.c:192: return 0;
	xor	a, a
	jr	00107$
00106$:
;tetris.c:187: for (byte i = 0; i < 4; ++i)
	inc	-1 (ix)
	jr	00105$
00103$:
;tetris.c:194: draw_piece(piece, 1);
	push	de
	ld	a, #0x01
	push	af
	inc	sp
;	spillPairReg hl
;	spillPairReg hl
	ex	de,hl
;	spillPairReg hl
;	spillPairReg hl
	call	_draw_piece
	pop	de
;tetris.c:195: piece->cx += dx;
	ld	a, (de)
	add	a, 4 (ix)
	ld	(de), a
;tetris.c:196: piece->cy += dy;
	ld	l, -8 (ix)
	ld	h, -7 (ix)
	ld	a, (hl)
	add	a, 5 (ix)
	pop	bc
	pop	hl
	push	hl
	push	bc
	ld	(hl), a
;tetris.c:197: draw_piece(piece, 0);
	xor	a, a
	push	af
	inc	sp
	ex	de, hl
	call	_draw_piece
;tetris.c:198: return 1;
	ld	a, #0x01
00107$:
;tetris.c:199: }
	ld	sp, ix
	pop	ix
	pop	hl
	pop	bc
	jp	(hl)
;tetris.c:201: byte rotate_piece(Board* board, Piece* piece)
;	---------------------------------
; Function rotate_piece
; ---------------------------------
_rotate_piece::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	iy, #-21
	add	iy, sp
	ld	sp, iy
	ld	c, l
	ld	b, h
	ld	-3 (ix), e
	ld	-2 (ix), d
;tetris.c:204: byte j=0;
	ld	e, #0x00
;tetris.c:205: for (byte i = 0; i < 4; ++i, j+=2)
	ld	a, -3 (ix)
	add	a, #0x02
	ld	-13 (ix), a
	ld	a, -2 (ix)
	adc	a, #0x00
	ld	-12 (ix), a
	ld	a, -13 (ix)
	ld	-11 (ix), a
	ld	a, -12 (ix)
	ld	-10 (ix), a
	ld	a, -3 (ix)
	ld	-9 (ix), a
	ld	a, -2 (ix)
	ld	-8 (ix), a
	ld	-1 (ix), #0x00
00106$:
	ld	a, -1 (ix)
	sub	a, #0x04
	jr	NC, 00103$
;tetris.c:207: offsets[j] = -piece->offsets[j+1];
	push	de
	ld	d, #0x00
	ld	hl, #2
	add	hl, sp
	add	hl, de
	pop	de
	ld	-7 (ix), l
	ld	-6 (ix), h
	ld	-5 (ix), e
	ld	d, e
	inc	d
	ld	a, d
	add	a, -11 (ix)
	ld	l, a
;	spillPairReg hl
;	spillPairReg hl
	ld	a, #0x00
	adc	a, -10 (ix)
	ld	h, a
	ld	a, (hl)
	neg
	ld	-4 (ix), a
	ld	l, -7 (ix)
	ld	h, -6 (ix)
	ld	a, -4 (ix)
	ld	(hl), a
;tetris.c:208: offsets[j+1] = piece->offsets[j];
	ld	a, d
	ld	l, a
;	spillPairReg hl
;	spillPairReg hl
	rlca
	sbc	a, a
	ld	d, a
	push	de
	ld	e, l
	ld	hl, #2
	add	hl, sp
	add	hl, de
	pop	de
	ld	a, -11 (ix)
	add	a, e
	ld	e, a
	ld	a, -10 (ix)
	adc	a, #0x00
	ld	d, a
	ld	a, (de)
	ld	e, a
	ld	(hl), e
;tetris.c:209: byte x = offsets[j] + piece->cx;
	ld	l, -3 (ix)
	ld	h, -2 (ix)
	ld	a, (hl)
	add	a, -4 (ix)
	ld	-4 (ix), a
;tetris.c:210: byte y = offsets[j+1] + piece->cy;
	ld	l, -9 (ix)
	ld	h, -8 (ix)
	inc	hl
	ld	a, (hl)
	add	a, e
;tetris.c:211: if (!board_position_free(board, x, y))
	push	bc
	push	af
	inc	sp
	ld	a, -4 (ix)
	push	af
	inc	sp
	ld	l, c
;	spillPairReg hl
;	spillPairReg hl
	ld	h, b
;	spillPairReg hl
;	spillPairReg hl
	call	_board_position_free
	pop	bc
;tetris.c:212: return 0;
	or	a,a
	jr	Z, 00111$
;tetris.c:205: for (byte i = 0; i < 4; ++i, j+=2)
	inc	-1 (ix)
	ld	e, -5 (ix)
	inc	e
	inc	e
	jp	00106$
00103$:
;tetris.c:214: draw_piece(piece, 1);
	ld	a, #0x01
	push	af
	inc	sp
	ld	l, -3 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -2 (ix)
;	spillPairReg hl
;	spillPairReg hl
	call	_draw_piece
;tetris.c:215: for (byte i = 0; i < 8; ++i)
	ld	c, -13 (ix)
	ld	b, -12 (ix)
	ld	hl, #0
	add	hl, sp
	ex	de, hl
	ld	-1 (ix), #0x00
00109$:
	ld	a, -1 (ix)
	sub	a, #0x08
	jr	NC, 00104$
;tetris.c:216: piece->offsets[i] = offsets[i];
	ld	a, c
	add	a, -1 (ix)
	ld	-5 (ix), a
	ld	a, b
	adc	a, #0x00
	ld	-4 (ix), a
	ld	l, -1 (ix)
	ld	h, #0x00
	add	hl, de
	ld	a, (hl)
	ld	l, -5 (ix)
	ld	h, -4 (ix)
	ld	(hl), a
;tetris.c:215: for (byte i = 0; i < 8; ++i)
	inc	-1 (ix)
	jr	00109$
00104$:
;tetris.c:217: draw_piece(piece, 0);
	xor	a, a
	push	af
	inc	sp
	ld	l, -3 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -2 (ix)
;	spillPairReg hl
;	spillPairReg hl
	call	_draw_piece
;tetris.c:218: return 1;
	ld	a, #0x01
00111$:
;tetris.c:219: }
	ld	sp, ix
	pop	ix
	ret
;tetris.c:221: void draw_frame()
;	---------------------------------
; Function draw_frame
; ---------------------------------
_draw_frame::
;tetris.c:225: for (word y = 0; y < H; ++y)
	ld	bc, #0x0000
00104$:
	ld	l, c
;	spillPairReg hl
;	spillPairReg hl
	ld	h, b
;	spillPairReg hl
;	spillPairReg hl
	ld	a, l
	sub	a, #0x10
	ld	a, h
	sbc	a, #0x00
	jr	NC, 00101$
;tetris.c:227: draw_cube(x0, y * 16, 63);
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	push	bc
	ex	de, hl
	push	de
	ld	a, #0x3f
	push	af
	inc	sp
	ld	hl, #0x0060
	call	_draw_cube
	pop	de
	ld	a, #0x3f
	push	af
	inc	sp
	ld	hl, #0x0120
	call	_draw_cube
	pop	bc
;tetris.c:225: for (word y = 0; y < H; ++y)
	inc	bc
	jr	00104$
00101$:
;tetris.c:231: for (word x = L-1; x <= (L+W); ++x)
	ld	bc, #0x0006
00107$:
	ld	a, #0x12
	cp	a, c
	ld	a, #0x00
	sbc	a, b
	ret	C
;tetris.c:233: draw_cube(x*16, y1, 63);
	ld	l, c
;	spillPairReg hl
;	spillPairReg hl
	ld	h, b
;	spillPairReg hl
;	spillPairReg hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	push	bc
	ld	a, #0x3f
	push	af
	inc	sp
	ld	de, #0x0100
	call	_draw_cube
	pop	bc
;tetris.c:231: for (word x = L-1; x <= (L+W); ++x)
	inc	bc
;tetris.c:235: }
	jr	00107$
;tetris.c:237: void draw_game_over()
;	---------------------------------
; Function draw_game_over
; ---------------------------------
_draw_game_over::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	hl, #-185
	add	hl, sp
	ld	sp, hl
;tetris.c:239: const byte coords[] = {
	ld	hl, #0
	add	hl, sp
	ld	c, l
	ld	b, h
	ld	(hl), #0x01
	ld	e, c
	ld	d, b
	inc	de
	xor	a, a
	ld	(de), a
	ld	l, c
;	spillPairReg hl
;	spillPairReg hl
	ld	h, b
;	spillPairReg hl
;	spillPairReg hl
	inc	hl
	inc	hl
	ld	(hl), #0x02
	ld	e, c
	ld	d, b
	inc	de
	inc	de
	inc	de
	xor	a, a
	ld	(de), a
	ld	hl, #0x0004
	add	hl, bc
	ld	(hl), #0x03
	ld	hl, #0x0005
	add	hl, bc
	ld	(hl), #0x00
	ld	hl, #0x0006
	add	hl, bc
	ld	(hl), #0x07
	ld	hl, #0x0007
	add	hl, bc
	ld	(hl), #0x00
	ld	hl, #0x0008
	add	hl, bc
	ld	(hl), #0x0b
	ld	hl, #0x0009
	add	hl, bc
	ld	(hl), #0x00
	ld	hl, #0x000a
	add	hl, bc
	ld	(hl), #0x0c
	ld	hl, #0x000b
	add	hl, bc
	ld	(hl), #0x00
	ld	hl, #0x000c
	add	hl, bc
	ld	(hl), #0x0e
	ld	hl, #0x000d
	add	hl, bc
	ld	(hl), #0x00
	ld	hl, #0x000e
	add	hl, bc
	ld	(hl), #0x0f
	ld	hl, #0x000f
	add	hl, bc
	ld	(hl), #0x00
	ld	hl, #0x0010
	add	hl, bc
	ld	(hl), #0x11
	ld	hl, #0x0011
	add	hl, bc
	ld	(hl), #0x00
	ld	hl, #0x0012
	add	hl, bc
	ld	(hl), #0x12
	ld	hl, #0x0013
	add	hl, bc
	ld	(hl), #0x00
	ld	hl, #0x0014
	add	hl, bc
	ld	(hl), #0x13
	ld	hl, #0x0015
	add	hl, bc
	ld	(hl), #0x00
	ld	hl, #0x0016
	add	hl, bc
	ld	(hl), #0x14
	ld	hl, #0x0017
	add	hl, bc
	ld	(hl), #0x00
	ld	hl, #0x0018
	add	hl, bc
	ld	(hl), #0x00
	ld	hl, #0x0019
	add	hl, bc
	ld	(hl), #0x01
	ld	hl, #0x001a
	add	hl, bc
	ld	(hl), #0x06
	ld	hl, #0x001b
	add	hl, bc
	ld	(hl), #0x01
	ld	hl, #0x001c
	add	hl, bc
	ld	(hl), #0x08
	ld	hl, #0x001d
	add	hl, bc
	ld	(hl), #0x01
	ld	hl, #0x001e
	add	hl, bc
	ld	(hl), #0x0b
	ld	hl, #0x001f
	add	hl, bc
	ld	(hl), #0x01
	ld	hl, #0x0020
	add	hl, bc
	ld	(hl), #0x0d
	ld	hl, #0x0021
	add	hl, bc
	ld	(hl), #0x01
	ld	hl, #0x0022
	add	hl, bc
	ld	(hl), #0x0f
	ld	hl, #0x0023
	add	hl, bc
	ld	(hl), #0x01
	ld	hl, #0x0024
	add	hl, bc
	ld	(hl), #0x11
	ld	hl, #0x0025
	add	hl, bc
	ld	(hl), #0x01
	ld	hl, #0x0026
	add	hl, bc
	ld	(hl), #0x00
	ld	hl, #0x0027
	add	hl, bc
	ld	(hl), #0x02
	ld	hl, #0x0028
	add	hl, bc
	ld	(hl), #0x03
	ld	hl, #0x0029
	add	hl, bc
	ld	(hl), #0x02
	ld	hl, #0x002a
	add	hl, bc
	ld	(hl), #0x05
	ld	hl, #0x002b
	add	hl, bc
	ld	(hl), #0x02
	ld	hl, #0x002c
	add	hl, bc
	ld	(hl), #0x09
	ld	hl, #0x002d
	add	hl, bc
	ld	(hl), #0x02
	ld	hl, #0x002e
	add	hl, bc
	ld	(hl), #0x0b
	ld	hl, #0x002f
	add	hl, bc
	ld	(hl), #0x02
	ld	hl, #0x0030
	add	hl, bc
	ld	(hl), #0x0f
	ld	hl, #0x0031
	add	hl, bc
	ld	(hl), #0x02
	ld	hl, #0x0032
	add	hl, bc
	ld	(hl), #0x11
	ld	hl, #0x0033
	add	hl, bc
	ld	(hl), #0x02
	ld	hl, #0x0034
	add	hl, bc
	ld	(hl), #0x12
	ld	hl, #0x0035
	add	hl, bc
	ld	(hl), #0x02
	ld	hl, #0x0036
	add	hl, bc
	ld	(hl), #0x00
	ld	hl, #0x0037
	add	hl, bc
	ld	(hl), #0x03
	ld	iy, #56
	add	iy, sp
	ld	0 (iy), #0x03
	ld	-128 (ix), #0x03
	ld	-127 (ix), #0x05
	ld	-126 (ix), #0x03
	ld	-125 (ix), #0x06
	ld	-124 (ix), #0x03
	ld	-123 (ix), #0x07
	ld	-122 (ix), #0x03
	ld	-121 (ix), #0x08
	ld	-120 (ix), #0x03
	ld	-119 (ix), #0x09
	ld	-118 (ix), #0x03
	ld	-117 (ix), #0x0b
	ld	-116 (ix), #0x03
	ld	-115 (ix), #0x0f
	ld	-114 (ix), #0x03
	ld	-113 (ix), #0x11
	ld	-112 (ix), #0x03
	ld	-111 (ix), #0x01
	ld	-110 (ix), #0x04
	ld	-109 (ix), #0x02
	ld	-108 (ix), #0x04
	ld	-107 (ix), #0x05
	ld	-106 (ix), #0x04
	ld	-105 (ix), #0x09
	ld	-104 (ix), #0x04
	ld	-103 (ix), #0x0b
	ld	-102 (ix), #0x04
	ld	-101 (ix), #0x0f
	ld	-100 (ix), #0x04
	ld	-99 (ix), #0x11
	ld	-98 (ix), #0x04
	ld	-97 (ix), #0x12
	ld	-96 (ix), #0x04
	ld	-95 (ix), #0x13
	ld	-94 (ix), #0x04
	ld	-93 (ix), #0x14
	ld	-92 (ix), #0x04
	ld	-91 (ix), #0x01
	ld	-90 (ix), #0x06
	ld	-89 (ix), #0x02
	ld	-88 (ix), #0x06
	ld	-87 (ix), #0x03
	ld	-86 (ix), #0x06
	ld	-85 (ix), #0x06
	ld	-84 (ix), #0x06
	ld	-83 (ix), #0x0a
	ld	-82 (ix), #0x06
	ld	-81 (ix), #0x0c
	ld	-80 (ix), #0x06
	ld	-79 (ix), #0x0d
	ld	-78 (ix), #0x06
	ld	-77 (ix), #0x0e
	ld	-76 (ix), #0x06
	ld	-75 (ix), #0x0f
	ld	-74 (ix), #0x06
	ld	-73 (ix), #0x11
	ld	-72 (ix), #0x06
	ld	-71 (ix), #0x12
	ld	-70 (ix), #0x06
	ld	-69 (ix), #0x13
	ld	-68 (ix), #0x06
	ld	-67 (ix), #0x00
	ld	-66 (ix), #0x07
	ld	-65 (ix), #0x04
	ld	-64 (ix), #0x07
	ld	-63 (ix), #0x06
	ld	-62 (ix), #0x07
	ld	-61 (ix), #0x0a
	ld	-60 (ix), #0x07
	ld	-59 (ix), #0x0c
	ld	-58 (ix), #0x07
	ld	-57 (ix), #0x11
	ld	-56 (ix), #0x07
	ld	-55 (ix), #0x14
	ld	-54 (ix), #0x07
	ld	-53 (ix), #0x00
	ld	-52 (ix), #0x08
	ld	-51 (ix), #0x04
	ld	-50 (ix), #0x08
	ld	-49 (ix), #0x07
	ld	-48 (ix), #0x08
	ld	-47 (ix), #0x09
	ld	-46 (ix), #0x08
	ld	-45 (ix), #0x0c
	ld	-44 (ix), #0x08
	ld	-43 (ix), #0x0d
	ld	-42 (ix), #0x08
	ld	-41 (ix), #0x11
	ld	-40 (ix), #0x08
	ld	-39 (ix), #0x12
	ld	-38 (ix), #0x08
	ld	-37 (ix), #0x13
	ld	-36 (ix), #0x08
	ld	-35 (ix), #0x00
	ld	-34 (ix), #0x09
	ld	-33 (ix), #0x04
	ld	-32 (ix), #0x09
	ld	-31 (ix), #0x07
	ld	-30 (ix), #0x09
	ld	-29 (ix), #0x09
	ld	-28 (ix), #0x09
	ld	-27 (ix), #0x0c
	ld	-26 (ix), #0x09
	ld	-25 (ix), #0x11
	ld	-24 (ix), #0x09
	ld	-23 (ix), #0x14
	ld	-22 (ix), #0x09
	ld	-21 (ix), #0x01
	ld	-20 (ix), #0x0a
	ld	-19 (ix), #0x02
	ld	-18 (ix), #0x0a
	ld	-17 (ix), #0x03
	ld	-16 (ix), #0x0a
	ld	-15 (ix), #0x08
	ld	-14 (ix), #0x0a
	ld	-13 (ix), #0x0c
	ld	-12 (ix), #0x0a
	ld	-11 (ix), #0x0d
	ld	-10 (ix), #0x0a
	ld	-9 (ix), #0x0e
	ld	-8 (ix), #0x0a
	ld	-7 (ix), #0x0f
	ld	-6 (ix), #0x0a
	ld	-5 (ix), #0x11
	ld	-4 (ix), #0x0a
	ld	-3 (ix), #0x14
	ld	-2 (ix), #0x0a
;tetris.c:250: const byte* ptr=coords;
;tetris.c:251: for(byte i=0;i<n;++i)
	ld	-1 (ix), #0x00
00103$:
	ld	a, -1 (ix)
	sub	a, #0x5c
	jr	NC, 00105$
;tetris.c:253: word x=((word)*ptr++) * 16;
	ld	a, (bc)
	inc	bc
	ld	h, #0x00
;	spillPairReg hl
;	spillPairReg hl
	ld	l, a
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
;tetris.c:254: word y=((word)*ptr++) * 16;
	ld	a, (bc)
	inc	bc
	ld	e, a
	ld	d, #0x00
	ex	de, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
;tetris.c:255: draw_cube(x,y,4);
	push	bc
	ex	de, hl
	ld	a, #0x04
	push	af
	inc	sp
	call	_draw_cube
	pop	bc
;tetris.c:251: for(byte i=0;i<n;++i)
	inc	-1 (ix)
	jr	00103$
00105$:
;tetris.c:257: }
	ld	sp, ix
	pop	ix
	ret
;tetris.c:259: void main()
;	---------------------------------
; Function main
; ---------------------------------
_main::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	hl, #-191
	add	hl, sp
	ld	sp, hl
;tetris.c:263: initialize_cubes();
	call	_initialize_cubes
;tetris.c:264: cls();
	call	_cls
;tetris.c:265: initialize_board(&board);
	ld	hl, #0
	add	hl, sp
	call	_initialize_board
;tetris.c:266: piece.valid = 0;
	ld	-3 (ix), #0x00
;tetris.c:267: draw_frame();
	call	_draw_frame
;tetris.c:268: word last_timer=0;
	xor	a, a
	ld	-2 (ix), a
	ld	-1 (ix), a
;tetris.c:269: while (1)
00127$:
;tetris.c:271: if (piece.valid == 0)
	ld	a, -3 (ix)
	or	a, a
	jr	NZ, 00109$
;tetris.c:273: while (!generate_piece(&board, &piece));
00101$:
	ld	hl, #177
	add	hl, sp
	ex	de, hl
	ld	hl, #0
	add	hl, sp
	call	_generate_piece
	or	a, a
	jr	Z, 00101$
;tetris.c:274: if (piece.valid)
	ld	a, -3 (ix)
	or	a, a
	jr	Z, 00105$
;tetris.c:275: draw_piece(&piece, 0);
	xor	a, a
	push	af
	inc	sp
	ld	hl, #178
	add	hl, sp
	call	_draw_piece
00105$:
;tetris.c:276: if (board.game_over) break;
	ld	a, -15 (ix)
	or	a, a
	jp	NZ, 00128$
00109$:
;tetris.c:278: byte key = wait_key();
	call	_wait_key
;tetris.c:279: if (key == '4')
	cp	a, #0x34
	jr	NZ, 00124$
;tetris.c:280: move_piece(&board, &piece, 0xFF, 0);
	ld	hl, #0xff
	push	hl
	ld	hl, #179
	add	hl, sp
	ex	de, hl
	ld	hl, #2
	add	hl, sp
	call	_move_piece
	jr	00127$
00124$:
;tetris.c:282: if (key == '6')
	cp	a, #0x36
	jr	NZ, 00121$
;tetris.c:283: move_piece(&board, &piece, 1, 0);
	ld	hl, #0x01
	push	hl
	ld	hl, #179
	add	hl, sp
	ex	de, hl
	ld	hl, #2
	add	hl, sp
	call	_move_piece
	jr	00127$
00121$:
;tetris.c:285: if (key == '2')
	cp	a, #0x32
	jr	NZ, 00118$
;tetris.c:286: move_piece(&board, &piece, 0, 1);
	ld	hl, #0x100
	push	hl
	ld	hl, #179
	add	hl, sp
	ex	de, hl
	ld	hl, #2
	add	hl, sp
	call	_move_piece
	jr	00127$
00118$:
;tetris.c:288: if (key == '5')
	sub	a, #0x35
	jr	NZ, 00115$
;tetris.c:289: rotate_piece(&board, &piece);
	ld	hl, #177
	add	hl, sp
	ex	de, hl
	ld	hl, #0
	add	hl, sp
	call	_rotate_piece
	jp	00127$
00115$:
;tetris.c:292: word cur_timer = timer();
	call	_timer
;tetris.c:293: word diff = cur_timer - last_timer;
	ld	a, e
	sub	a, -2 (ix)
	ld	c, a
	ld	a, d
	sbc	a, -1 (ix)
;tetris.c:294: if (diff > 50)
	ld	b, a
	ld	a, #0x32
	cp	a, c
	ld	a, #0x00
	sbc	a, b
	jp	NC, 00127$
;tetris.c:296: last_timer=cur_timer;
	ld	-2 (ix), e
	ld	-1 (ix), d
;tetris.c:297: if (!move_piece(&board, &piece, 0, 1))
	ld	a, #0x01
	push	af
	inc	sp
	xor	a, a
	push	af
	inc	sp
	ld	hl, #179
	add	hl, sp
	ex	de, hl
	ld	hl, #2
	add	hl, sp
	call	_move_piece
	or	a, a
	jp	NZ, 00127$
;tetris.c:299: place_piece(&board, &piece);
	ld	hl, #177
	add	hl, sp
	ex	de, hl
	ld	hl, #0
	add	hl, sp
	call	_place_piece
;tetris.c:300: remove_full_rows(&board);
	ld	hl, #0
	add	hl, sp
	call	_remove_full_rows
	jp	00127$
00128$:
;tetris.c:305: cls();
	call	_cls
;tetris.c:306: draw_game_over();
	call	_draw_game_over
;tetris.c:307: while (wait_key()==0xFF);
00129$:
	call	_wait_key
	inc	a
	jr	Z, 00129$
;tetris.c:308: cls();
	call	_cls
;tetris.c:309: }
	ld	sp, ix
	pop	ix
	ret
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
