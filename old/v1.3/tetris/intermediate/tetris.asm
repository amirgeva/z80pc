;--------------------------------------------------------
; File Created by SDCC : free open source ISO C Compiler 
; Version 4.2.2 #13407 (MINGW64)
;--------------------------------------------------------
	.module tetris
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _game
	.globl _draw_frame
	.globl _rotate_piece
	.globl _move_piece
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
	.globl _nop
	.globl _cls
	.globl _send_command
	.globl _random
	.globl _system_call
	.globl _offsets
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
	.area _APP
;tetris.c:12: word system_call(byte call_type)
;	---------------------------------
; Function system_call
; ---------------------------------
_system_call::
;tetris.c:17: __endasm;
	rst	#8
;tetris.c:18: }
	ret
;tetris.c:20: word random()
;	---------------------------------
; Function random
; ---------------------------------
_random::
;tetris.c:22: return system_call(0);
	xor	a, a
;tetris.c:23: }
	jp	_system_call
;tetris.c:25: void send_command(const byte* data, byte len)
;	---------------------------------
; Function send_command
; ---------------------------------
_send_command::
;tetris.c:32: __endasm;
	ld	b,a
	otir
;tetris.c:33: }
	pop	hl
	inc	sp
	jp	(hl)
;tetris.c:35: void cls()
;	---------------------------------
; Function cls
; ---------------------------------
_cls::
;tetris.c:40: __endasm;
	ld	a,#1
	out	(0),a
;tetris.c:41: }
	ret
;tetris.c:43: void nop()
;	---------------------------------
; Function nop
; ---------------------------------
_nop::
;tetris.c:48: __endasm;
	ld	a,#0
	out	(0),a
;tetris.c:49: }
	ret
;tetris.c:52: void pixel_cursor(word x, word y)
;	---------------------------------
; Function pixel_cursor
; ---------------------------------
_pixel_cursor::
	push	ix
	ld	ix,#0
	add	ix,sp
	push	af
	push	af
	dec	sp
	ld	c, l
	ld	b, h
;tetris.c:55: cmd[0]=5;
	ld	-5 (ix), #0x05
;tetris.c:56: cmd[1]=x&0xFF;
	ld	-4 (ix), c
;tetris.c:57: cmd[2]=(x>>8)&0xFF;
	ld	-3 (ix), b
;tetris.c:58: cmd[3]=y&0xFF;
	ld	-2 (ix), e
;tetris.c:59: cmd[4]=(y>>8)&0xFF;
	ld	-1 (ix), d
;tetris.c:60: send_command(cmd,5);
	ld	a, #0x05
	push	af
	inc	sp
	ld	hl, #1
	add	hl, sp
	call	_send_command
;tetris.c:61: }
	ld	sp, ix
	pop	ix
	ret
;tetris.c:63: void draw_cube(word x, word y, uint8_t color)
;	---------------------------------
; Function draw_cube
; ---------------------------------
_draw_cube::
	push	af
;tetris.c:66: pixel_cursor(x,y);
	call	_pixel_cursor
;tetris.c:67: cmd[0]=41;
	ld	hl, #0
	add	hl, sp
	ex	de, hl
	ld	a, #0x29
	ld	(de), a
;tetris.c:68: cmd[1]=color;
	ld	c, e
	ld	b, d
	inc	bc
	ld	iy, #4
	add	iy, sp
	ld	a, 0 (iy)
	ld	(bc), a
;tetris.c:69: send_command(cmd,2);
	ld	a, #0x02
	push	af
	inc	sp
	ex	de, hl
	call	_send_command
;tetris.c:70: }
	pop	af
	pop	hl
	inc	sp
	jp	(hl)
;tetris.c:72: void initialize_cubes()
;	---------------------------------
; Function initialize_cubes
; ---------------------------------
_initialize_cubes::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	hl, #-258
	add	hl, sp
	ld	sp, hl
;tetris.c:75: cmd[0]=40;
	ld	iy, #0
	add	iy, sp
	ld	0 (iy), #0x28
;tetris.c:76: for(uint8_t i=0;i<64;++i)
	ld	c, #0x00
00107$:
	ld	a, c
	sub	a, #0x40
	jr	NC, 00109$
;tetris.c:78: cmd[1]=i;
	ld	hl,#0x1
	add	hl,sp
	ld	(hl), c
;tetris.c:79: for(word j=0;j<0x100;++j)
	ld	de, #0x0000
00104$:
	ld	l, e
;	spillPairReg hl
;	spillPairReg hl
	ld	h, d
;	spillPairReg hl
;	spillPairReg hl
	ld	a, h
	sub	a, #0x01
	jr	NC, 00101$
;tetris.c:80: cmd[2+j]=i;
	inc	hl
	inc	hl
	ld	b, h
	push	de
	ld	e, l
	ld	d, b
	ld	hl, #2
	add	hl, sp
	add	hl, de
	pop	de
	ld	(hl), c
;tetris.c:79: for(word j=0;j<0x100;++j)
	inc	de
	jr	00104$
00101$:
;tetris.c:81: send_command(cmd,4);
	push	bc
	ld	a, #0x04
	push	af
	inc	sp
	ld	hl, #3
	add	hl, sp
	call	_send_command
	ld	a, #0xfe
	push	af
	inc	sp
	ld	hl, #7
	add	hl, sp
	call	_send_command
	pop	bc
;tetris.c:76: for(uint8_t i=0;i<64;++i)
	inc	c
	jr	00107$
00109$:
;tetris.c:84: }
	ld	sp, ix
	pop	ix
	ret
;tetris.c:86: uint8_t wait_key()
;	---------------------------------
; Function wait_key
; ---------------------------------
_wait_key::
;tetris.c:88: word key = system_call(1);
	ld	a, #0x01
	call	_system_call
;tetris.c:89: if (key&0xFF00)
	ld	a, d
	or	a, a
	jr	Z, 00102$
;tetris.c:90: return 0xFF;
	ld	a, #0xff
	ret
00102$:
;tetris.c:91: return key&0xFF;
	ld	a, e
;tetris.c:92: }
	ret
;tetris.c:103: void initialize_board(Board* board)
;	---------------------------------
; Function initialize_board
; ---------------------------------
_initialize_board::
	ex	de, hl
;tetris.c:105: for (uint8_t i = 0; i < (W * H); ++i)
	ld	c, #0x00
00103$:
	ld	a, c
	sub	a, #0xb0
	ret	NC
;tetris.c:106: board->grid[i] = 0;
	ld	l, c
	ld	h, #0x00
	add	hl, de
	ld	(hl), #0x00
;tetris.c:105: for (uint8_t i = 0; i < (W * H); ++i)
	inc	c
;tetris.c:107: }
	jr	00103$
;tetris.c:109: uint8_t board_position_free(Board* board, uint8_t x, uint8_t y)
;	---------------------------------
; Function board_position_free
; ---------------------------------
_board_position_free::
	push	ix
	ld	ix,#0
	add	ix,sp
	ex	de, hl
;tetris.c:111: if (x >= W || y >= H) return 0;
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
;tetris.c:112: return board->grid[y * W + x] == 0;
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
;tetris.c:113: }
	pop	ix
	pop	hl
	pop	bc
	jp	(hl)
;tetris.c:115: void remove_full_rows(Board* board)
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
;tetris.c:118: uint8_t ofs = (H - 1) * W;
	ld	e, #0xa5
;tetris.c:119: for (uint8_t y = H - 1; y > 0; --y, ofs-=W)
	ld	-4 (ix), #0x0f
	ld	-3 (ix), #0x00
00127$:
	ld	a, -4 (ix)
	or	a, a
	jp	Z, 00109$
;tetris.c:122: for (uint8_t x = 0; x < W; ++x)
	ld	-2 (ix), #0x00
	ld	-1 (ix), #0x00
00115$:
	ld	a, -1 (ix)
	sub	a, #0x0b
	jr	NC, 00103$
;tetris.c:123: if (board->grid[ofs + x] != 0)
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
;tetris.c:124: ++count;
	inc	-2 (ix)
00116$:
;tetris.c:122: for (uint8_t x = 0; x < W; ++x)
	inc	-1 (ix)
	jr	00115$
00103$:
;tetris.c:125: if (count == W)
	ld	a, -2 (ix)
	sub	a, #0x0b
	jr	NZ, 00128$
;tetris.c:127: full_rows++;
	inc	-3 (ix)
;tetris.c:128: uint8_t aofs = ofs;
	ld	d, e
;tetris.c:129: for (uint8_t ay = y; ay > 0; --ay)
	ld	a, -4 (ix)
	ld	-2 (ix), a
00121$:
	ld	a, -2 (ix)
	or	a, a
	jr	Z, 00151$
;tetris.c:131: for (uint8_t x = 0; x < W; ++x)
	ld	-1 (ix), #0x00
00118$:
	ld	a, -1 (ix)
	sub	a, #0x0b
	jr	NC, 00104$
;tetris.c:132: board->grid[aofs + x] = board->grid[aofs + x - W];
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
;tetris.c:131: for (uint8_t x = 0; x < W; ++x)
	inc	-1 (ix)
	jr	00118$
00104$:
;tetris.c:133: aofs -= W;
	ld	a, d
	add	a, #0xf5
	ld	d, a
;tetris.c:129: for (uint8_t ay = y; ay > 0; --ay)
	dec	-2 (ix)
	jr	00121$
;tetris.c:135: for (uint8_t x = 0; x < W; ++x)
00151$:
	ld	d, #0x00
00124$:
	ld	a, d
	sub	a, #0x0b
	jr	NC, 00106$
;tetris.c:136: board->grid[x] = 0;
	ld	l, d
	ld	h, #0x00
	add	hl, bc
	ld	(hl), #0x00
;tetris.c:135: for (uint8_t x = 0; x < W; ++x)
	inc	d
	jr	00124$
00106$:
;tetris.c:138: ++y;
	inc	-4 (ix)
;tetris.c:139: ofs += W;
	ld	a, e
	add	a, #0x0b
	ld	e, a
00128$:
;tetris.c:119: for (uint8_t y = H - 1; y > 0; --y, ofs-=W)
	dec	-4 (ix)
	ld	a, e
	add	a, #0xf5
	ld	e, a
	jp	00127$
00109$:
;tetris.c:142: if (full_rows > 0)
	ld	a, -3 (ix)
	or	a, a
	jr	Z, 00135$
;tetris.c:144: uint8_t ofs = 0;
	ld	e, #0x00
;tetris.c:145: for (uint8_t by = 0; by < H; ++by)
	ld	-3 (ix), #0x00
00133$:
	ld	a, -3 (ix)
	sub	a, #0x10
	jr	NC, 00135$
;tetris.c:147: word y= ((word)by) << 4;
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
;tetris.c:148: for (uint8_t bx = 0; bx < W; ++bx, ++ofs)
	ld	-2 (ix), #0x00
	ld	-1 (ix), e
00130$:
	ld	a, -2 (ix)
	sub	a, #0x0b
	jr	NC, 00161$
;tetris.c:150: word x = ((word)(bx + L)) << 4;
	ld	e, -2 (ix)
	ld	d, #0x00
	ld	hl, #0x0007
	add	hl, de
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
;tetris.c:151: draw_cube(x, y, board->grid[ofs]);
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
;tetris.c:148: for (uint8_t bx = 0; bx < W; ++bx, ++ofs)
	inc	-2 (ix)
	inc	-1 (ix)
	jr	00130$
00161$:
	ld	e, -1 (ix)
;tetris.c:145: for (uint8_t by = 0; by < H; ++by)
	inc	-3 (ix)
	jr	00133$
00135$:
;tetris.c:155: }
	ld	sp, ix
	pop	ix
	ret
;tetris.c:176: void place_piece(Board* board, Piece* piece)
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
;tetris.c:178: for (uint8_t i = 0; i < 4; ++i)
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
;tetris.c:180: uint8_t x = piece->offsets[i * 2 + 0] + piece->cx;
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
;tetris.c:181: uint8_t y = piece->offsets[i * 2 + 1] + piece->cy;
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
;tetris.c:182: board->grid[y * W + x] = piece->color;
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
;tetris.c:178: for (uint8_t i = 0; i < 4; ++i)
	inc	-1 (ix)
	jr	00103$
00101$:
;tetris.c:184: piece->valid = 0;
	ld	hl, #0x000b
	add	hl, de
	ld	(hl), #0x00
;tetris.c:185: }
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
;tetris.c:187: uint8_t generate_piece(Piece* piece)
;	---------------------------------
; Function generate_piece
; ---------------------------------
_generate_piece::
	push	ix
	ld	ix,#0
	add	ix,sp
	push	af
	push	af
	dec	sp
;tetris.c:190: piece->cx = W/2;
	ld	c, l
	ld	b, h
	ld	(hl), #0x05
;tetris.c:191: piece->cy = 2;
	ld	l, c
;	spillPairReg hl
;	spillPairReg hl
	ld	h, b
;	spillPairReg hl
;	spillPairReg hl
	inc	hl
	ld	(hl), #0x02
;tetris.c:192: uint8_t type = random() & 7;
	push	bc
	call	_random
	pop	bc
	ld	a, e
	and	a, #0x07
;tetris.c:193: if (type < 7)
	cp	a, #0x07
	jr	NC, 00103$
;tetris.c:195: uint8_t base = type << 3;
	ld	e, a
	add	a, a
	add	a, a
	add	a, a
	ld	-5 (ix), a
;tetris.c:196: for (i = 0; i < 8; ++i)
	ld	hl, #0x0002
	add	hl, bc
	ld	-4 (ix), l
	ld	-3 (ix), h
	ld	d, #0x00
00104$:
;tetris.c:197: piece->offsets[i] = offsets[base + i];
	ld	a, -4 (ix)
	add	a, d
	ld	-2 (ix), a
	ld	a, -3 (ix)
	adc	a, #0x00
	ld	-1 (ix), a
	ld	a, -5 (ix)
	add	a, d
	add	a, #<(_offsets)
	ld	l, a
;	spillPairReg hl
;	spillPairReg hl
	ld	a, #0x00
	adc	a, #>(_offsets)
	ld	h, a
	ld	a, (hl)
	ld	l, -2 (ix)
	ld	h, -1 (ix)
	ld	(hl), a
;tetris.c:196: for (i = 0; i < 8; ++i)
	inc	d
	ld	a, d
	sub	a, #0x08
	jr	C, 00104$
;tetris.c:198: piece->color = type+1;
	ld	hl, #0x000a
	add	hl, bc
	inc	e
	ld	(hl), e
;tetris.c:199: piece->valid = 1;
	ld	hl, #0x000b
	add	hl, bc
;tetris.c:200: return 1;
	ld	a,#0x01
	ld	(hl),a
	jr	00106$
00103$:
;tetris.c:202: return 0;
	xor	a, a
00106$:
;tetris.c:203: }
	ld	sp, ix
	pop	ix
	ret
;tetris.c:205: void draw_piece(Piece* piece, uint8_t erase)
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
;tetris.c:207: uint8_t color = erase ? 0 : piece->color;
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
;tetris.c:208: for (uint8_t i = 0; i < 4; ++i)
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
;tetris.c:210: uint8_t bx = piece->cx + piece->offsets[i * 2 + 0];
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
;tetris.c:211: uint8_t by = piece->cy + piece->offsets[i * 2 + 1];
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
;tetris.c:212: bx += L;
	ld	a, -2 (ix)
	add	a, #0x07
;tetris.c:213: word x = bx << 4;
	ld	h, #0x00
;	spillPairReg hl
;	spillPairReg hl
	ld	l, a
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
;tetris.c:214: word y = by << 4;
	ld	d, #0x00
	ex	de, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
;tetris.c:215: draw_cube(x, y, color);
	push	bc
	ex	de, hl
	ld	a, -7 (ix)
	push	af
	inc	sp
	call	_draw_cube
	pop	bc
;tetris.c:208: for (uint8_t i = 0; i < 4; ++i)
	inc	-1 (ix)
	jr	00103$
00105$:
;tetris.c:217: }
	ld	sp, ix
	pop	ix
	pop	hl
	inc	sp
	jp	(hl)
;tetris.c:219: uint8_t move_piece(Board* board, Piece* piece, uint8_t dx, uint8_t dy)
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
;tetris.c:221: for (uint8_t i = 0; i < 4; ++i)
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
;tetris.c:223: uint8_t x = piece->offsets[i * 2 + 0] + piece->cx + dx;
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
;tetris.c:224: uint8_t y = piece->offsets[i * 2 + 1] + piece->cy + dy;
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
;tetris.c:225: if (!board_position_free(board, x, y))
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
;tetris.c:226: return 0;
	xor	a, a
	jr	00107$
00106$:
;tetris.c:221: for (uint8_t i = 0; i < 4; ++i)
	inc	-1 (ix)
	jr	00105$
00103$:
;tetris.c:228: draw_piece(piece, 1);
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
;tetris.c:229: piece->cx += dx;
	ld	a, (de)
	add	a, 4 (ix)
	ld	(de), a
;tetris.c:230: piece->cy += dy;
	ld	l, -8 (ix)
	ld	h, -7 (ix)
	ld	a, (hl)
	add	a, 5 (ix)
	pop	bc
	pop	hl
	push	hl
	push	bc
	ld	(hl), a
;tetris.c:231: draw_piece(piece, 0);
	xor	a, a
	push	af
	inc	sp
	ex	de, hl
	call	_draw_piece
;tetris.c:232: return 1;
	ld	a, #0x01
00107$:
;tetris.c:233: }
	ld	sp, ix
	pop	ix
	pop	hl
	pop	bc
	jp	(hl)
;tetris.c:235: uint8_t rotate_piece(Board* board, Piece* piece)
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
;tetris.c:238: uint8_t j=0;
	ld	e, #0x00
;tetris.c:239: for (uint8_t i = 0; i < 4; ++i, j+=2)
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
;tetris.c:241: offsets[j] = -piece->offsets[j+1];
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
;tetris.c:242: offsets[j+1] = piece->offsets[j];
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
;tetris.c:243: uint8_t x = offsets[j] + piece->cx;
	ld	l, -3 (ix)
	ld	h, -2 (ix)
	ld	a, (hl)
	add	a, -4 (ix)
	ld	-4 (ix), a
;tetris.c:244: uint8_t y = offsets[j+1] + piece->cy;
	ld	l, -9 (ix)
	ld	h, -8 (ix)
	inc	hl
	ld	a, (hl)
	add	a, e
;tetris.c:245: if (!board_position_free(board, x, y))
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
;tetris.c:246: return 0;
	or	a,a
	jr	Z, 00111$
;tetris.c:239: for (uint8_t i = 0; i < 4; ++i, j+=2)
	inc	-1 (ix)
	ld	e, -5 (ix)
	inc	e
	inc	e
	jp	00106$
00103$:
;tetris.c:248: draw_piece(piece, 1);
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
;tetris.c:249: for (uint8_t i = 0; i < 8; ++i)
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
;tetris.c:250: piece->offsets[i] = offsets[i];
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
;tetris.c:249: for (uint8_t i = 0; i < 8; ++i)
	inc	-1 (ix)
	jr	00109$
00104$:
;tetris.c:251: draw_piece(piece, 0);
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
;tetris.c:252: return 1;
	ld	a, #0x01
00111$:
;tetris.c:253: }
	ld	sp, ix
	pop	ix
	ret
;tetris.c:255: void draw_frame()
;	---------------------------------
; Function draw_frame
; ---------------------------------
_draw_frame::
;tetris.c:259: for (word y = 0; y < H; ++y)
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
;tetris.c:261: draw_cube(x0, y * 16, 63);
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
;tetris.c:259: for (word y = 0; y < H; ++y)
	inc	bc
	jr	00104$
00101$:
;tetris.c:265: for (word x = L-1; x <= (L+W); ++x)
	ld	bc, #0x0006
00107$:
	ld	a, #0x12
	cp	a, c
	ld	a, #0x00
	sbc	a, b
	ret	C
;tetris.c:267: draw_cube(x*16, y1, 63);
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
;tetris.c:265: for (word x = L-1; x <= (L+W); ++x)
	inc	bc
;tetris.c:269: }
	jr	00107$
;tetris.c:271: void game()
;	---------------------------------
; Function game
; ---------------------------------
_game::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	hl, #-190
	add	hl, sp
	ld	sp, hl
;tetris.c:276: cls();
	call	_cls
;tetris.c:277: initialize_board(&board);
	ld	hl, #0
	add	hl, sp
	call	_initialize_board
;tetris.c:278: piece.valid = 0;
	ld	-3 (ix), #0x00
;tetris.c:279: draw_frame();
	call	_draw_frame
;tetris.c:280: word last_timer=0;
	xor	a, a
	ld	-2 (ix), a
	ld	-1 (ix), a
;tetris.c:281: while (1)
00125$:
;tetris.c:283: if (piece.valid == 0)
	ld	a, -3 (ix)
	or	a, a
	jr	NZ, 00107$
;tetris.c:285: while (!generate_piece(&piece));
00101$:
	ld	hl, #176
	add	hl, sp
	call	_generate_piece
	or	a, a
	jr	Z, 00101$
;tetris.c:286: if (piece.valid)
	ld	a, -3 (ix)
	or	a, a
	jr	Z, 00107$
;tetris.c:287: draw_piece(&piece, 0);
	xor	a, a
	push	af
	inc	sp
	ld	hl, #177
	add	hl, sp
	call	_draw_piece
00107$:
;tetris.c:289: uint8_t key = wait_key();
	call	_wait_key
;tetris.c:290: if (key == '4')
	ld	c, a
	sub	a, #0x34
	jr	NZ, 00122$
;tetris.c:291: move_piece(&board, &piece, 0xFF, 0);
	ld	hl, #0xff
	push	hl
	ld	hl, #178
	add	hl, sp
	ex	de, hl
	ld	hl, #2
	add	hl, sp
	call	_move_piece
	jr	00125$
00122$:
;tetris.c:293: if (key == '6')
	ld	a, c
	sub	a, #0x36
	jr	NZ, 00119$
;tetris.c:294: move_piece(&board, &piece, 1, 0);
	ld	hl, #0x01
	push	hl
	ld	hl, #178
	add	hl, sp
	ex	de, hl
	ld	hl, #2
	add	hl, sp
	call	_move_piece
	jr	00125$
00119$:
;tetris.c:296: if (key == '2')
	ld	a, c
	sub	a, #0x32
	jr	NZ, 00116$
;tetris.c:297: move_piece(&board, &piece, 0, 1);
	ld	hl, #0x100
	push	hl
	ld	hl, #178
	add	hl, sp
	ex	de, hl
	ld	hl, #2
	add	hl, sp
	call	_move_piece
	jr	00125$
00116$:
;tetris.c:299: if (key == '5')
	ld	a, c
	sub	a, #0x35
	jr	NZ, 00113$
;tetris.c:300: rotate_piece(&board, &piece);
	ld	hl, #176
	add	hl, sp
	ex	de, hl
	ld	hl, #0
	add	hl, sp
	call	_rotate_piece
	jr	00125$
00113$:
;tetris.c:303: word cur_timer = system_call(2); /* timer */
	ld	a, #0x02
	call	_system_call
;tetris.c:304: word diff = cur_timer - last_timer;
	ld	a, e
	sub	a, -2 (ix)
	ld	c, a
	ld	a, d
	sbc	a, -1 (ix)
;tetris.c:305: if (diff > 50)
	ld	b, a
	ld	a, #0x32
	cp	a, c
	ld	a, #0x00
	sbc	a, b
	jp	NC, 00125$
;tetris.c:307: last_timer=cur_timer;
	ld	-2 (ix), e
	ld	-1 (ix), d
;tetris.c:308: if (!move_piece(&board, &piece, 0, 1))
	ld	a, #0x01
	push	af
	inc	sp
	xor	a, a
	push	af
	inc	sp
	ld	hl, #178
	add	hl, sp
	ex	de, hl
	ld	hl, #2
	add	hl, sp
	call	_move_piece
	or	a, a
	jp	NZ, 00125$
;tetris.c:310: place_piece(&board, &piece);
	ld	hl, #176
	add	hl, sp
	ex	de, hl
	ld	hl, #0
	add	hl, sp
	call	_place_piece
;tetris.c:311: remove_full_rows(&board);
	ld	hl, #0
	add	hl, sp
	call	_remove_full_rows
;tetris.c:316: }
	jp	00125$
	.area _APP
	.area _INITIALIZER
	.area _CABS (ABS)
