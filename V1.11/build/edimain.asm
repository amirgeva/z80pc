;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 4.2.0 #13081 (MINGW64)
;--------------------------------------------------------
	.module edimain
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _main
	.globl _event_loop
	.globl _getkey
	.globl _add_enter
	.globl _join_prev_line
	.globl _add_char
	.globl _backspace
	.globl _do_delete
	.globl _move_x_cursor
	.globl _visual_to_logical
	.globl _logical_to_visual
	.globl _draw_screen
	.globl _draw_cursor_position
	.globl _draw_number
	.globl _decimal_string
	.globl _place_cursor
	.globl _calculate_new_offset
	.globl _cursor_in_view
	.globl _draw_line
	.globl _draw_frame
	.globl _draw_str
	.globl _load_file
	.globl _append_line
	.globl _get_line
	.globl _round_up
	.globl _clear
	.globl _init_state
	.globl _alloc_init
	.globl _div_mod
	.globl _close_file
	.globl _read_file
	.globl _open_file
	.globl _input_read
	.globl _input_empty
	.globl _min
	.globl _vector_erase_range
	.globl _vector_erase
	.globl _vector_access
	.globl _vector_get
	.globl _vector_set
	.globl _vector_insert
	.globl _vector_push
	.globl _vector_reserve
	.globl _vector_resize
	.globl _vector_clear
	.globl _vector_size
	.globl _vector_shut
	.globl _vector_new
	.globl _hal_blink
	.globl _hal_color
	.globl _hal_rept_char
	.globl _hal_draw_char
	.globl _hal_move
	.globl _hal_shutdown
	.globl _hal_init
	.globl _offset_y
	.globl _offset_x
	.globl _cursor_y
	.globl _cursor_x
	.globl _insert
	.globl _full_redraw
	.globl _bg
	.globl _fg
	.globl _document
	.globl _VERT
	.globl _HORZ
	.globl _BR
	.globl _BL
	.globl _TR
	.globl _TL
	.globl _H
	.globl _W
;--------------------------------------------------------
; special function registers
;--------------------------------------------------------
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _DATA
_document::
	.ds 2
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _INITIALIZED
_fg::
	.ds 1
_bg::
	.ds 1
_full_redraw::
	.ds 1
_insert::
	.ds 1
_cursor_x::
	.ds 2
_cursor_y::
	.ds 2
_offset_x::
	.ds 2
_offset_y::
	.ds 2
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
;edimain.c:25: void init_state()
;	---------------------------------
; Function init_state
; ---------------------------------
_init_state::
;edimain.c:27: fg=0xFF;
	ld	hl, #_fg
	ld	(hl), #0xff
;edimain.c:28: bg=0;
	ld	hl, #_bg
	ld	(hl), #0x00
;edimain.c:29: full_redraw=1;
	ld	hl, #_full_redraw
	ld	(hl), #0x01
;edimain.c:30: insert=1;
	ld	hl, #_insert
	ld	(hl), #0x01
;edimain.c:31: document=0;
	ld	hl, #0x0000
	ld	(_document), hl
;edimain.c:32: cursor_x=0;
	ld	(_cursor_x), hl
;edimain.c:33: cursor_y=0;
	ld	(_cursor_y), hl
;edimain.c:34: offset_x=0;
	ld	(_offset_x), hl
;edimain.c:35: offset_y=0;
	ld	(_offset_y), hl
;edimain.c:36: }
	ret
_W:
	.db #0x50	; 80	'P'
_H:
	.db #0x1e	; 30
_TL:
	.db #0xc9	; 201
_TR:
	.db #0xbb	; 187
_BL:
	.db #0xc8	; 200
_BR:
	.db #0xbc	; 188
_HORZ:
	.db #0xcd	; 205
_VERT:
	.db #0xba	; 186
;edimain.c:40: void clear()
;	---------------------------------
; Function clear
; ---------------------------------
_clear::
	push	ix
	ld	ix,#0
	add	ix,sp
	push	af
	push	af
;edimain.c:42: word n = vector_size(document);
	ld	hl, (_document)
	call	_vector_size
	ld	-2 (ix), e
	ld	-1 (ix), d
;edimain.c:44: for (word i = 0; i < n; ++i)
	ld	bc, #0x0000
00103$:
	ld	a, c
	sub	a, -2 (ix)
	ld	a, b
	sbc	a, -1 (ix)
	jr	NC, 00101$
;edimain.c:46: vector_get(document, i, &line);
	push	bc
	ld	hl, #2
	add	hl, sp
	push	hl
	ld	e, c
	ld	d, b
	ld	hl, (_document)
	call	_vector_get
	pop	de
	pop	hl
	push	hl
	push	de
	call	_vector_shut
	pop	bc
;edimain.c:44: for (word i = 0; i < n; ++i)
	inc	bc
	jr	00103$
00101$:
;edimain.c:49: vector_clear(document);
	ld	hl, (_document)
	call	_vector_clear
;edimain.c:50: }
	ld	sp, ix
	pop	ix
	ret
;edimain.c:52: word round_up(word value, word margin)
;	---------------------------------
; Function round_up
; ---------------------------------
_round_up::
;edimain.c:54: return (value + margin) & ~(margin-1);
	add	hl, de
	dec	de
	ld	a, e
	cpl
	ld	c, a
	ld	a, d
	cpl
	ld	b, a
	ld	a, l
	and	a, c
	ld	e, a
	ld	a, h
	and	a, b
	ld	d, a
;edimain.c:55: }
	ret
;edimain.c:57: Vector* get_line(word line_index)
;	---------------------------------
; Function get_line
; ---------------------------------
_get_line::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	iy, #-10
	add	iy, sp
	ld	sp, iy
	ld	-4 (ix), l
	ld	-3 (ix), h
;edimain.c:59: word size = vector_size(document);
	ld	hl, (_document)
	call	_vector_size
	ld	-2 (ix), e
	ld	-1 (ix), d
;edimain.c:60: if (line_index < size)
	ld	a, -4 (ix)
	sub	a, -2 (ix)
	ld	a, -3 (ix)
	sbc	a, -1 (ix)
	jr	NC, 00102$
;edimain.c:63: vector_get(document, line_index, &line);
	ld	hl, #2
	add	hl, sp
	push	hl
	ld	e, -4 (ix)
	ld	d, -3 (ix)
	ld	hl, (_document)
	call	_vector_get
;edimain.c:64: return line;
	pop	hl
	pop	de
	push	de
	push	hl
	jp	00106$
00102$:
;edimain.c:66: vector_reserve(document, round_up(line_index + 1, 16));
	ld	a, -4 (ix)
	ld	-10 (ix), a
	ld	a, -3 (ix)
	ld	-9 (ix), a
	ld	a, -10 (ix)
	add	a, #0x01
	ld	-6 (ix), a
	ld	a, -9 (ix)
	adc	a, #0x00
	ld	-5 (ix), a
	ld	de, #0x0010
	ld	l, -6 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -5 (ix)
;	spillPairReg hl
;	spillPairReg hl
	call	_round_up
	ld	hl, (_document)
	call	_vector_reserve
;edimain.c:67: vector_resize(document, line_index + 1);
	ld	e, -6 (ix)
	ld	d, -5 (ix)
	ld	hl, (_document)
	call	_vector_resize
;edimain.c:68: word new_size = vector_size(document);
	ld	hl, (_document)
	call	_vector_size
	ld	-6 (ix), e
	ld	-5 (ix), d
;edimain.c:69: while (size < new_size)
00103$:
	ld	a, -2 (ix)
	sub	a, -6 (ix)
	ld	a, -1 (ix)
	sbc	a, -5 (ix)
	jr	NC, 00105$
;edimain.c:71: Vector* new_line = vector_new(1);
	ld	hl, #0x0001
	call	_vector_new
	ld	-8 (ix), e
	ld	-7 (ix), d
;edimain.c:72: vector_set(document, size++, &new_line);
	ld	e, -2 (ix)
	ld	d, -1 (ix)
	inc	-2 (ix)
	jr	NZ, 00124$
	inc	-1 (ix)
00124$:
	ld	hl, #2
	add	hl, sp
	push	hl
	ld	hl, (_document)
	call	_vector_set
	jr	00103$
00105$:
;edimain.c:75: vector_get(document, line_index, &line);
	ld	hl, #2
	add	hl, sp
	push	hl
	ld	e, -4 (ix)
	ld	d, -3 (ix)
	ld	hl, (_document)
	call	_vector_get
;edimain.c:76: return line;
	pop	hl
	pop	de
	push	de
	push	hl
00106$:
;edimain.c:77: }
	ld	sp, ix
	pop	ix
	ret
;edimain.c:79: void append_line(Vector* line, byte b)
;	---------------------------------
; Function append_line
; ---------------------------------
_append_line::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	c, l
	ld	b, h
;edimain.c:81: vector_push(line, &b);
	ld	hl, #4
	add	hl, sp
	ex	de, hl
	ld	l, c
;	spillPairReg hl
;	spillPairReg hl
	ld	h, b
;	spillPairReg hl
;	spillPairReg hl
	call	_vector_push
;edimain.c:82: }
	pop	ix
	pop	hl
	inc	sp
	jp	(hl)
;edimain.c:84: void load_file(const char* filename)
;	---------------------------------
; Function load_file
; ---------------------------------
_load_file::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	iy, #-264
	add	iy, sp
	ld	sp, iy
;edimain.c:87: clear();
	push	hl
	call	_clear
	pop	hl
;edimain.c:88: byte handle = open_file(filename, 0);
	xor	a, a
	push	af
	inc	sp
	call	_open_file
;edimain.c:89: if (handle == 0xFF) return;
	ld	c, a
	inc	a
	jp	Z,00118$
	jr	00102$
00102$:
;edimain.c:91: word line_index = 0;
	xor	a, a
	ld	-2 (ix), a
	ld	-1 (ix), a
;edimain.c:92: do
00112$:
;edimain.c:94: act = read_file(handle, buffer, 256);
	push	bc
	ld	hl, #0x0100
	push	hl
	ld	hl, #4
	add	hl, sp
	ex	de, hl
	ld	a, c
	call	_read_file
	pop	bc
	ld	-8 (ix), e
	ld	-7 (ix), d
;edimain.c:95: for (word i = 0; i < act; ++i)
	ld	e, -2 (ix)
	ld	d, -1 (ix)
	xor	a, a
	ld	-2 (ix), a
	ld	-1 (ix), a
00116$:
	ld	a, -2 (ix)
	sub	a, -8 (ix)
	ld	a, -1 (ix)
	sbc	a, -7 (ix)
	jr	NC, 00128$
;edimain.c:97: if (buffer[i] == 10)
	push	de
	ld	e, -2 (ix)
	ld	d, -1 (ix)
	ld	hl, #2
	add	hl, sp
	add	hl, de
	pop	de
	ld	-6 (ix), l
	ld	-5 (ix), h
	ld	a, (hl)
	cp	a, #0x0a
	jr	NZ, 00109$
;edimain.c:98: ++line_index;
	inc	de
	jr	00117$
00109$:
;edimain.c:100: if (buffer[i] >= 32 || buffer[i]==9)
	cp	a, #0x20
	jr	NC, 00105$
	sub	a, #0x09
	jr	NZ, 00117$
00105$:
;edimain.c:102: Vector* line = get_line(line_index);
	push	bc
;	spillPairReg hl
;	spillPairReg hl
	ex	de, hl
	push	hl
;	spillPairReg hl
;	spillPairReg hl
	call	_get_line
	ex	de, hl
	pop	de
	pop	bc
	ld	-4 (ix), l
	ld	-3 (ix), h
;edimain.c:103: if (line)
	ld	a, h
	or	a, l
	jr	Z, 00117$
;edimain.c:104: append_line(line, buffer[i]);
	ld	l, -6 (ix)
	ld	h, -5 (ix)
	ld	a, (hl)
	push	bc
	push	de
	push	af
	inc	sp
	ld	l, -4 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -3 (ix)
;	spillPairReg hl
;	spillPairReg hl
	call	_append_line
	pop	de
	pop	bc
00117$:
;edimain.c:95: for (word i = 0; i < act; ++i)
	inc	-2 (ix)
	jr	NZ, 00116$
	inc	-1 (ix)
	jr	00116$
00128$:
	ld	-2 (ix), e
	ld	-1 (ix), d
;edimain.c:107: } while (act > 0);
	ld	a, -7 (ix)
	or	a, -8 (ix)
	jp	NZ, 00112$
;edimain.c:108: close_file(handle);
	ld	a, c
	call	_close_file
00118$:
;edimain.c:109: }
	ld	sp, ix
	pop	ix
	ret
;edimain.c:111: void draw_str(const char* s)
;	---------------------------------
; Function draw_str
; ---------------------------------
_draw_str::
00103$:
;edimain.c:113: for (; *s; ++s)
	ld	c, (hl)
	ld	a, c
	or	a, a
	ret	Z
;edimain.c:115: hal_draw_char(*s);
	push	hl
	ld	a, c
	call	_hal_draw_char
	pop	hl
;edimain.c:113: for (; *s; ++s)
	inc	hl
;edimain.c:117: }
	jr	00103$
;edimain.c:119: void draw_frame()
;	---------------------------------
; Function draw_frame
; ---------------------------------
_draw_frame::
	dec	sp
;edimain.c:122: hal_color(fg, bg);
	ld	a, (_bg+0)
	ld	l, a
;	spillPairReg hl
;	spillPairReg hl
	ld	a, (_fg+0)
	call	_hal_color
;edimain.c:123: hal_move(0, 0);
	ld	de, #0x0000
	ld	hl, #0x0000
	call	_hal_move
;edimain.c:124: hal_draw_char(TL);
	ld	a, (_TL+0)
	call	_hal_draw_char
;edimain.c:125: hal_rept_char(HORZ, W-2);
	ld	a, (_W+0)
	ld	l, a
;	spillPairReg hl
;	spillPairReg hl
	dec	l
	dec	l
	ld	a, (_HORZ+0)
	call	_hal_rept_char
;edimain.c:126: hal_draw_char(TR);
	ld	a, (_TR+0)
	call	_hal_draw_char
;edimain.c:127: for (i = 1; i < (H - 1); ++i)
	ld	iy, #0
	add	iy, sp
	ld	0 (iy), #0x01
00103$:
	ld	a, (_H+0)
	ld	b, #0x00
	ld	c, a
	dec	bc
	ld	hl, #0
	add	hl, sp
	ld	e, (hl)
	ld	d, #0x00
	ld	a, e
	sub	a, c
	ld	a, d
	sbc	a, b
	jp	PO, 00118$
	xor	a, #0x80
00118$:
	jp	P, 00101$
;edimain.c:129: hal_move(0, i);
	ld	hl, #0x0000
	call	_hal_move
;edimain.c:130: hal_draw_char(VERT);
	ld	a, (_VERT+0)
	call	_hal_draw_char
;edimain.c:131: hal_rept_char(' ',W-2);
	ld	a, (_W+0)
	ld	l, a
;	spillPairReg hl
;	spillPairReg hl
	dec	l
	dec	l
	ld	a, #0x20
	call	_hal_rept_char
;edimain.c:132: hal_draw_char(VERT);
	ld	a, (_VERT+0)
	call	_hal_draw_char
;edimain.c:127: for (i = 1; i < (H - 1); ++i)
	ld	iy, #0
	add	iy, sp
	inc	0 (iy)
	jr	00103$
00101$:
;edimain.c:134: hal_move(0, H-1);
	ld	e, c
	ld	d, b
	ld	hl, #0x0000
	call	_hal_move
;edimain.c:135: hal_draw_char(BL);
	ld	a, (_BL+0)
	call	_hal_draw_char
;edimain.c:136: hal_rept_char(HORZ,W-2);
	ld	a, (_W+0)
	ld	l, a
;	spillPairReg hl
;	spillPairReg hl
	dec	l
	dec	l
	ld	a, (_HORZ+0)
	call	_hal_rept_char
;edimain.c:137: hal_draw_char(BR);
	ld	a, (_BR+0)
	ld	c, a
	inc	sp
	jp	_hal_draw_char
;edimain.c:138: }
	inc	sp
	ret
;edimain.c:140: byte draw_line(short visual_y)
;	---------------------------------
; Function draw_line
; ---------------------------------
_draw_line::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	iy, #-13
	add	iy, sp
	ld	sp, iy
	ld	-5 (ix), l
	ld	-4 (ix), h
;edimain.c:142: if (visual_y < 0 || visual_y >= (H - 2)) return 1;
	ld	a, -5 (ix)
	ld	-7 (ix), a
	ld	a, -4 (ix)
	ld	-6 (ix), a
	bit	7, -6 (ix)
	jr	NZ, 00101$
	ld	a, (_H+0)
	ld	-1 (ix), a
	ld	-9 (ix), a
	ld	-8 (ix), #0x00
	ld	a, -9 (ix)
	add	a, #0xfe
	ld	-2 (ix), a
	ld	a, -8 (ix)
	adc	a, #0xff
	ld	-1 (ix), a
	ld	a, -7 (ix)
	sub	a, -2 (ix)
	ld	a, -6 (ix)
	sbc	a, -1 (ix)
	jp	PO, 00177$
	xor	a, #0x80
00177$:
	jp	M, 00102$
00101$:
	ld	a, #0x01
	jp	00122$
00102$:
;edimain.c:143: short visual_x = -offset_x;
	ld	hl, #_offset_x
	xor	a, a
	sub	a, (hl)
	ld	-9 (ix), a
	inc	hl
	sbc	a, a
	sub	a, (hl)
	ld	-8 (ix), a
	ld	a, -9 (ix)
	ld	-3 (ix), a
	ld	a, -8 (ix)
	ld	-2 (ix), a
;edimain.c:144: short logical_y = visual_y + offset_y;
	ld	a, (_offset_y+0)
	add	a, -5 (ix)
	ld	-9 (ix), a
	ld	a, (_offset_y+1)
	adc	a, -4 (ix)
	ld	-8 (ix), a
	ld	a, -9 (ix)
	ld	-13 (ix), a
	ld	a, -8 (ix)
	ld	-12 (ix), a
;edimain.c:145: if (logical_y >= vector_size(document))
	ld	hl, (_document)
	call	_vector_size
	ld	-11 (ix), e
	ld	-10 (ix), d
	ld	a, -13 (ix)
	ld	-9 (ix), a
	ld	a, -12 (ix)
	ld	-8 (ix), a
	ld	a, -9 (ix)
	sub	a, -11 (ix)
	ld	a, -8 (ix)
	sbc	a, -10 (ix)
	jr	C, 00105$
;edimain.c:147: return logical_y > 0x8000;
	ld	a, -13 (ix)
	ld	-2 (ix), a
	ld	a, -12 (ix)
	ld	-1 (ix), a
	xor	a, a
	cp	a, -2 (ix)
	ld	a, #0x80
	sbc	a, -1 (ix)
	ld	a, #0x00
	rla
	jp	00122$
00105$:
;edimain.c:149: hal_move(visual_x + 1, visual_y + 1);
	ld	a, -7 (ix)
	add	a, #0x01
	ld	-11 (ix), a
	ld	a, -6 (ix)
	adc	a, #0x00
	ld	-10 (ix), a
	ld	a, -3 (ix)
	ld	-9 (ix), a
	ld	a, -2 (ix)
	ld	-8 (ix), a
	ld	a, -9 (ix)
	add	a, #0x01
	ld	-7 (ix), a
	ld	a, -8 (ix)
	adc	a, #0x00
	ld	-6 (ix), a
	pop	hl
	pop	de
	push	de
	push	hl
	ld	l, -7 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -6 (ix)
;	spillPairReg hl
;	spillPairReg hl
	call	_hal_move
;edimain.c:150: Vector* line = get_line(logical_y);
	pop	hl
	push	hl
	call	_get_line
;edimain.c:151: word n = vector_size(line);
;	spillPairReg hl
;	spillPairReg hl
	ld	-9 (ix), e
	ld	-8 (ix), d
	ex	de,hl
;	spillPairReg hl
;	spillPairReg hl
	call	_vector_size
	ld	-7 (ix), e
	ld	-6 (ix), d
	ld	a, -7 (ix)
	ld	-12 (ix), a
	ld	a, -6 (ix)
	ld	-11 (ix), a
;edimain.c:152: byte* data = vector_access(line, 0);
	ld	de, #0x0000
	ld	l, -9 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -8 (ix)
;	spillPairReg hl
;	spillPairReg hl
	call	_vector_access
	ld	-7 (ix), e
	ld	-6 (ix), d
	ld	a, -7 (ix)
	ld	-10 (ix), a
	ld	a, -6 (ix)
	ld	-9 (ix), a
;edimain.c:153: for (byte i = 0; i < n; ++i)
	ld	-1 (ix), #0x00
00120$:
	ld	a, -1 (ix)
	ld	b, #0x00
	sub	a, -12 (ix)
	ld	a, b
	sbc	a, -11 (ix)
	jr	NC, 00133$
;edimain.c:155: if (visual_x >= (W - 2)) break;
	ld	a, (_W+0)
	ld	b, #0x00
	ld	c, a
	dec	bc
	dec	bc
;edimain.c:149: hal_move(visual_x + 1, visual_y + 1);
	ld	a, -3 (ix)
	ld	-8 (ix), a
	ld	a, -2 (ix)
	ld	-7 (ix), a
;edimain.c:155: if (visual_x >= (W - 2)) break;
	ld	a, -8 (ix)
	sub	a, c
	ld	a, -7 (ix)
	sbc	a, b
	jp	PO, 00178$
	xor	a, #0x80
00178$:
	jp	P, 00133$
;edimain.c:156: if (data[i] == 9)
	ld	a, -10 (ix)
	add	a, -1 (ix)
	ld	c, a
	ld	a, -9 (ix)
	adc	a, #0x00
	ld	b, a
	ld	a, (bc)
	ld	-6 (ix), a
;edimain.c:158: for (byte j = 0; j < 4; ++j)
	sub	a,#0x09
	jr	NZ, 00110$
	ld	c,a
00117$:
	ld	a, c
	sub	a, #0x04
	jr	NC, 00108$
;edimain.c:159: hal_draw_char(' ');
	push	bc
	ld	a, #0x20
	call	_hal_draw_char
	pop	bc
;edimain.c:158: for (byte j = 0; j < 4; ++j)
	inc	c
	jr	00117$
00108$:
;edimain.c:160: visual_x += 4;
	ld	l, -8 (ix)
	ld	h, -7 (ix)
	ld	de, #0x0004
	add	hl, de
	ld	-3 (ix), l
	ld	-2 (ix), h
	jr	00121$
00110$:
;edimain.c:164: hal_draw_char(data[i]);
	ld	a, -6 (ix)
	call	_hal_draw_char
;edimain.c:165: ++visual_x;
	inc	-3 (ix)
	jr	NZ, 00181$
	inc	-2 (ix)
00181$:
00121$:
;edimain.c:153: for (byte i = 0; i < n; ++i)
	inc	-1 (ix)
	jr	00120$
;edimain.c:168: while (visual_x < (W - 2))
00133$:
	ld	c, -3 (ix)
	ld	b, -2 (ix)
00113$:
	ld	a, (_W+0)
	ld	d, #0x00
	ld	e, a
	dec	de
	dec	de
	ld	l, c
;	spillPairReg hl
;	spillPairReg hl
	ld	h, b
;	spillPairReg hl
;	spillPairReg hl
	ld	a, l
	sub	a, e
	ld	a, h
	sbc	a, d
	jp	PO, 00182$
	xor	a, #0x80
00182$:
	jp	P, 00115$
;edimain.c:170: hal_draw_char(' ');
	push	bc
	ld	a, #0x20
	call	_hal_draw_char
	pop	bc
;edimain.c:171: ++visual_x;
	inc	bc
	jr	00113$
00115$:
;edimain.c:173: return 1;
	ld	a, #0x01
00122$:
;edimain.c:174: }
	ld	sp, ix
	pop	ix
	ret
;edimain.c:176: byte cursor_in_view()
;	---------------------------------
; Function cursor_in_view
; ---------------------------------
_cursor_in_view::
;edimain.c:178: word visual_x = cursor_x - offset_x;
	ld	bc, (_offset_x)
	ld	hl, (_cursor_x)
	cp	a, a
	sbc	hl, bc
	ld	c, l
	ld	b, h
;edimain.c:179: word visual_y = cursor_y - offset_y;
	ld	de, (_offset_y)
	ld	hl, (_cursor_y)
	cp	a, a
	sbc	hl, de
	ex	de, hl
;edimain.c:180: if (cursor_x < offset_x || visual_x >= (W - 2) || cursor_y < offset_y || visual_y >= (H - 2))
	ld	hl, #_offset_x
	ld	a, (_cursor_x+0)
	sub	a, (hl)
	inc	hl
	ld	a, (_cursor_x+1)
	sbc	a, (hl)
	jp	PO, 00123$
	xor	a, #0x80
00123$:
	jp	M, 00101$
	ld	a, (_W+0)
	ld	l, a
;	spillPairReg hl
;	spillPairReg hl
	ld	h, #0x00
;	spillPairReg hl
;	spillPairReg hl
	dec	hl
	dec	hl
	ld	a, c
	sub	a, l
	ld	a, b
	sbc	a, h
	jr	NC, 00101$
	ld	hl, #_offset_y
	ld	a, (_cursor_y+0)
	sub	a, (hl)
	inc	hl
	ld	a, (_cursor_y+1)
	sbc	a, (hl)
	jp	PO, 00124$
	xor	a, #0x80
00124$:
	jp	M, 00101$
	ld	a, (_H+0)
	ld	c, a
	ld	b, #0x00
	dec	bc
	dec	bc
	ld	a, e
	sub	a, c
	ld	a, d
	sbc	a, b
	jr	C, 00102$
00101$:
;edimain.c:181: return 0;
	xor	a, a
	ret
00102$:
;edimain.c:182: return 1;
	ld	a, #0x01
;edimain.c:183: }
	ret
;edimain.c:185: void calculate_new_offset()
;	---------------------------------
; Function calculate_new_offset
; ---------------------------------
_calculate_new_offset::
;edimain.c:187: if (cursor_x < (W >> 1)) offset_x = 0;
	ld	a, (_W+0)
	ld	c, a
	srl	c
	ld	b, c
	ld	e, #0x00
	ld	a, (_cursor_x+0)
	sub	a, b
	ld	a, (_cursor_x+1)
	sbc	a, e
	jp	PO, 00119$
	xor	a, #0x80
00119$:
	jp	P, 00102$
	ld	hl, #0x0000
	ld	(_offset_x), hl
	jr	00103$
00102$:
;edimain.c:188: else offset_x = cursor_x - (W >> 1);
	ld	b, #0x00
	ld	hl, (_cursor_x)
	cp	a, a
	sbc	hl, bc
	ld	(_offset_x), hl
00103$:
;edimain.c:189: if (cursor_y < (H >> 1)) offset_y = 0;
	ld	a, (_H+0)
	ld	c, a
	srl	c
	ld	b, c
	ld	e, #0x00
	ld	a, (_cursor_y+0)
	sub	a, b
	ld	a, (_cursor_y+1)
	sbc	a, e
	jp	PO, 00120$
	xor	a, #0x80
00120$:
	jp	P, 00105$
	ld	hl, #0x0000
	ld	(_offset_y), hl
	jr	00106$
00105$:
;edimain.c:190: else offset_y = cursor_y - (H >> 1);
	ld	b, #0x00
	ld	hl, (_cursor_y)
	cp	a, a
	sbc	hl, bc
	ld	(_offset_y), hl
00106$:
;edimain.c:191: full_redraw = 1;
	ld	hl, #_full_redraw
	ld	(hl), #0x01
;edimain.c:192: }
	ret
;edimain.c:194: void place_cursor()
;	---------------------------------
; Function place_cursor
; ---------------------------------
_place_cursor::
;edimain.c:196: if (cursor_in_view() == 0) calculate_new_offset();
	call	_cursor_in_view
	or	a, a
	jr	NZ, 00102$
	call	_calculate_new_offset
00102$:
;edimain.c:197: hal_move(cursor_x - offset_x + 1, cursor_y - offset_y + 1);
	ld	bc, (_offset_y)
	ld	hl, (_cursor_y)
	cp	a, a
	sbc	hl, bc
	ex	de, hl
	inc	de
	ld	bc, (_offset_x)
	ld	hl, (_cursor_x)
	cp	a, a
	sbc	hl, bc
	inc	hl
;edimain.c:198: }
	jp	_hal_move
;edimain.c:200: void decimal_string(byte* buffer, short length, word value)
;	---------------------------------
; Function decimal_string
; ---------------------------------
_decimal_string::
	push	ix
	ld	ix,#0
	add	ix,sp
	push	af
	push	af
	dec	sp
	ld	c, l
	ld	b, h
;edimain.c:202: short index = length - 1;
	dec	de
;edimain.c:203: while (value > 0)
00101$:
	ld	a, 5 (ix)
	or	a, 4 (ix)
	jr	Z, 00112$
;edimain.c:206: dm.a = value;
	ld	a, 4 (ix)
	ld	-5 (ix), a
	ld	a, 5 (ix)
	ld	-4 (ix), a
;edimain.c:207: dm.b = 10;
	ld	-3 (ix), #0x0a
;edimain.c:208: div_mod(&dm);
	push	bc
	push	de
	ld	hl, #4
	add	hl, sp
	call	_div_mod
	pop	de
	pop	bc
;edimain.c:209: buffer[index--] = (byte)(48 + dm.b);
	ld	a, c
	add	a, e
	ld	-2 (ix), a
	ld	a, b
	adc	a, d
	ld	-1 (ix), a
	dec	de
	ld	a, -3 (ix)
	add	a, #0x30
	ld	l, -2 (ix)
	ld	h, -1 (ix)
	ld	(hl), a
;edimain.c:210: value=dm.a;
	ld	a, -5 (ix)
	ld	4 (ix), a
	ld	a, -4 (ix)
	ld	5 (ix), a
	jr	00101$
;edimain.c:212: while (index >= 0)
00112$:
00104$:
;	spillPairReg hl
;	spillPairReg hl
	ld	h, d
;	spillPairReg hl
;	spillPairReg hl
	bit	7, h
	jr	NZ, 00107$
;edimain.c:213: buffer[index--] = 48;
	ld	l, c
	ld	h, b
	add	hl, de
	dec	de
	ld	(hl), #0x30
	jr	00104$
00107$:
;edimain.c:214: }
	ld	sp, ix
	pop	ix
	pop	hl
	pop	af
	jp	(hl)
;edimain.c:216: void draw_number(word value)
;	---------------------------------
; Function draw_number
; ---------------------------------
_draw_number::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	iy, #-8
	add	iy, sp
	ld	sp, iy
	ex	de, hl
;edimain.c:219: buffer[7] = 0;
	ld	-1 (ix), #0x00
;edimain.c:220: decimal_string(buffer, 7, value);
	push	de
	ld	de, #0x0007
	ld	hl, #2
	add	hl, sp
	call	_decimal_string
;edimain.c:221: byte* ptr = buffer;
	ld	hl, #0
	add	hl, sp
;edimain.c:224: hal_draw_char(*ptr);
00104$:
;edimain.c:222: for (; *ptr == 48; ++ptr);
	ld	a, (hl)
	sub	a, #0x30
	jr	NZ, 00114$
	inc	hl
	jr	00104$
00114$:
00107$:
;edimain.c:223: for (; *ptr; ++ptr)
	ld	c, (hl)
	ld	a, c
	or	a, a
	jr	Z, 00109$
;edimain.c:224: hal_draw_char(*ptr);
	push	hl
	ld	a, c
	call	_hal_draw_char
	pop	hl
;edimain.c:223: for (; *ptr; ++ptr)
	inc	hl
	jr	00107$
00109$:
;edimain.c:225: }
	ld	sp, ix
	pop	ix
	ret
;edimain.c:227: void draw_cursor_position()
;	---------------------------------
; Function draw_cursor_position
; ---------------------------------
_draw_cursor_position::
;edimain.c:229: hal_move(5, H - 1);
	ld	a, (_H+0)
	ld	d, #0x00
	ld	e, a
	dec	de
	ld	hl, #0x0005
	call	_hal_move
;edimain.c:230: hal_draw_char(0xB9);
	ld	a, #0xb9
	call	_hal_draw_char
;edimain.c:231: draw_number(cursor_x + 1);
	ld	hl, (_cursor_x)
	inc	hl
	call	_draw_number
;edimain.c:232: hal_draw_char(',');
	ld	a, #0x2c
	call	_hal_draw_char
;edimain.c:233: draw_number(cursor_y + 1);
	ld	hl, (_cursor_y)
	inc	hl
	call	_draw_number
;edimain.c:234: hal_draw_char(0xCC);
	ld	a, #0xcc
	call	_hal_draw_char
;edimain.c:235: for (byte i = 0; i < 20; ++i)
	ld	c, #0x00
00103$:
	ld	a, c
	sub	a, #0x14
	ret	NC
;edimain.c:236: hal_draw_char(HORZ);
	ld	a, (_HORZ+0)
	ld	b, a
	push	bc
	ld	a, b
	call	_hal_draw_char
	pop	bc
;edimain.c:235: for (byte i = 0; i < 20; ++i)
	inc	c
;edimain.c:237: }
	jr	00103$
;edimain.c:239: void draw_screen()
;	---------------------------------
; Function draw_screen
; ---------------------------------
_draw_screen::
;edimain.c:241: full_redraw = 0;
	ld	hl, #_full_redraw
	ld	(hl), #0x00
;edimain.c:242: draw_frame();
	call	_draw_frame
;edimain.c:243: for (word visual_y = 0; visual_y < (H - 2); ++visual_y)
	ld	hl, #0x0000
00105$:
	ld	a, (_H+0)
	ld	e, a
	ld	d, #0x00
	dec	de
	dec	de
	ld	c, l
	ld	b, h
	ld	a, c
	sub	a, e
	ld	a, b
	sbc	a, d
	jr	NC, 00103$
;edimain.c:245: if (!draw_line(visual_y)) break;
	push	hl
	call	_draw_line
	pop	hl
	or	a, a
	jr	Z, 00103$
;edimain.c:243: for (word visual_y = 0; visual_y < (H - 2); ++visual_y)
	inc	hl
	jr	00105$
00103$:
;edimain.c:247: draw_cursor_position();
	call	_draw_cursor_position
;edimain.c:248: place_cursor();
;edimain.c:249: }
	jp	_place_cursor
;edimain.c:251: word logical_to_visual(Vector* line, word logical)
;	---------------------------------
; Function logical_to_visual
; ---------------------------------
_logical_to_visual::
	push	ix
	ld	ix,#0
	add	ix,sp
	push	af
	push	af
	ld	c, e
	ld	b, d
;edimain.c:253: word n = min(logical,vector_size(line));
	push	hl
	push	bc
	call	_vector_size
;	spillPairReg hl
;	spillPairReg hl
	pop	hl
;	spillPairReg hl
;	spillPairReg hl
	call	_min
	ld	c, e
	ld	b, d
	pop	hl
;edimain.c:254: const byte* data = vector_access(line, 0);
	push	bc
	ld	de, #0x0000
	call	_vector_access
	pop	bc
	inc	sp
	inc	sp
	push	de
;edimain.c:255: word x = 0;
	ld	de, #0x0000
;edimain.c:256: for (word i = 0; i < n; ++i)
	xor	a, a
	ld	-2 (ix), a
	ld	-1 (ix), a
00106$:
	ld	a, -2 (ix)
	sub	a, c
	ld	a, -1 (ix)
	sbc	a, b
	jr	NC, 00104$
;edimain.c:258: if (data[i] == 9) x += 4;
	ld	a, -4 (ix)
	add	a, -2 (ix)
	ld	l, a
;	spillPairReg hl
;	spillPairReg hl
	ld	a, -3 (ix)
	adc	a, -1 (ix)
	ld	h, a
	ld	a, (hl)
	sub	a, #0x09
	jr	NZ, 00102$
	inc	de
	inc	de
	inc	de
	inc	de
	jr	00107$
00102$:
;edimain.c:259: else ++x;
	inc	de
00107$:
;edimain.c:256: for (word i = 0; i < n; ++i)
	inc	-2 (ix)
	jr	NZ, 00106$
	inc	-1 (ix)
	jr	00106$
00104$:
;edimain.c:261: return x;
;edimain.c:262: }
	ld	sp, ix
	pop	ix
	ret
;edimain.c:264: word visual_to_logical(Vector* line, word visual)
;	---------------------------------
; Function visual_to_logical
; ---------------------------------
_visual_to_logical::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	iy, #-12
	add	iy, sp
	ld	sp, iy
	ld	-6 (ix), e
	ld	-5 (ix), d
;edimain.c:266: word n = vector_size(line);
	push	hl
	call	_vector_size
	pop	hl
	inc	sp
	inc	sp
	push	de
;edimain.c:267: const byte* data = vector_access(line, 0);
	ld	de, #0x0000
	call	_vector_access
	ld	-10 (ix), e
	ld	-9 (ix), d
;edimain.c:268: word x = 0;
	xor	a, a
	ld	-4 (ix), a
	ld	-3 (ix), a
;edimain.c:269: for (word i = 0; i < n; ++i)
	xor	a, a
	ld	-8 (ix), a
	ld	-7 (ix), a
	xor	a, a
	ld	-2 (ix), a
	ld	-1 (ix), a
00108$:
	ld	a, -2 (ix)
	sub	a, -12 (ix)
	ld	a, -1 (ix)
	sbc	a, -11 (ix)
	jr	NC, 00106$
;edimain.c:271: if (x >= visual) return i;
	ld	a, -4 (ix)
	sub	a, -6 (ix)
	ld	a, -3 (ix)
	sbc	a, -5 (ix)
	jr	C, 00102$
	ld	e, -8 (ix)
	ld	d, -7 (ix)
	jr	00110$
00102$:
;edimain.c:272: if (data[i] == 9) x += 4;
	ld	a, -10 (ix)
	add	a, -2 (ix)
	ld	c, a
	ld	a, -9 (ix)
	adc	a, -1 (ix)
	ld	b, a
	ld	a, (bc)
	sub	a, #0x09
	jr	NZ, 00104$
	ld	c, -4 (ix)
	ld	b, -3 (ix)
	inc	bc
	inc	bc
	inc	bc
	inc	bc
	ld	-4 (ix), c
	ld	-3 (ix), b
	jr	00109$
00104$:
;edimain.c:273: else ++x;
	inc	-4 (ix)
	jr	NZ, 00134$
	inc	-3 (ix)
00134$:
00109$:
;edimain.c:269: for (word i = 0; i < n; ++i)
	inc	-2 (ix)
	jr	NZ, 00135$
	inc	-1 (ix)
00135$:
	ld	a, -2 (ix)
	ld	-8 (ix), a
	ld	a, -1 (ix)
	ld	-7 (ix), a
	jr	00108$
00106$:
;edimain.c:275: return n;
	pop	de
	push	de
00110$:
;edimain.c:276: }
	ld	sp, ix
	pop	ix
	ret
;edimain.c:278: void move_x_cursor(short dx)
;	---------------------------------
; Function move_x_cursor
; ---------------------------------
_move_x_cursor::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	iy, #-8
	add	iy, sp
	ld	sp, iy
	ld	-6 (ix), l
;edimain.c:280: if (dx==0 || cursor_y >= vector_size(document)) return;
	ld	-5 (ix), h
	ld	a, h
	or	a, -6 (ix)
	jp	Z,00125$
	ld	hl, (_document)
	call	_vector_size
	ld	-4 (ix), e
	ld	-3 (ix), d
	ld	hl, (_cursor_y)
	ld	-2 (ix), l
	ld	-1 (ix), h
	ld	a, -2 (ix)
	sub	a, -4 (ix)
	ld	a, -1 (ix)
	sbc	a, -3 (ix)
	jp	NC,00125$
;edimain.c:281: Vector* line = get_line(cursor_y);
	ld	hl, (_cursor_y)
	call	_get_line
	ld	-2 (ix), e
	ld	-1 (ix), d
	ld	a, -2 (ix)
	ld	-8 (ix), a
	ld	a, -1 (ix)
	ld	-7 (ix), a
;edimain.c:282: word n = vector_size(line);
	pop	hl
	push	hl
	call	_vector_size
	ld	-2 (ix), e
	ld	-1 (ix), d
	ld	a, -2 (ix)
	ld	-4 (ix), a
	ld	a, -1 (ix)
	ld	-3 (ix), a
;edimain.c:283: word i = visual_to_logical(line, cursor_x);
	ld	de, (_cursor_x)
	pop	hl
	push	hl
	call	_visual_to_logical
	ld	-2 (ix), e
	ld	-1 (ix), d
;edimain.c:284: byte* data = vector_access(line, 0);
	ld	de, #0x0000
	pop	hl
	push	hl
	call	_vector_access
	inc	sp
	inc	sp
;edimain.c:285: if (dx > 0)
	ex	de,hl
	pop	bc
	push	bc
	push	hl
	xor	a, a
	cp	a, c
	sbc	a, b
	jp	PO, 00179$
	xor	a, #0x80
00179$:
	jp	P, 00135$
;edimain.c:287: for (short steps = 0; steps < dx; ++steps, ++i)
	ld	bc, #0x0000
00120$:
;edimain.c:290: if (data[i] == 9) cursor_x += 4;
	ld	hl, (_cursor_x)
;edimain.c:287: for (short steps = 0; steps < dx; ++steps, ++i)
	ld	a, c
	sub	a, -6 (ix)
	ld	a, b
	sbc	a, -5 (ix)
	jp	PO, 00180$
	xor	a, #0x80
00180$:
	jp	P, 00116$
;edimain.c:289: if (i >= n) break;
	ld	a, -2 (ix)
	sub	a, -4 (ix)
	ld	a, -1 (ix)
	sbc	a, -3 (ix)
	jp	NC, 00116$
;edimain.c:290: if (data[i] == 9) cursor_x += 4;
	ld	a, -8 (ix)
	add	a, -2 (ix)
	ld	e, a
	ld	a, -7 (ix)
	adc	a, -1 (ix)
	ld	d, a
	ld	a, (de)
	sub	a, #0x09
	jr	NZ, 00107$
	ld	de, #0x0004
	add	hl, de
	ld	(_cursor_x), hl
	jr	00121$
00107$:
;edimain.c:291: else cursor_x++;
	ld	hl, (_cursor_x)
	inc	hl
	ld	(_cursor_x), hl
00121$:
;edimain.c:287: for (short steps = 0; steps < dx; ++steps, ++i)
	inc	bc
	inc	-2 (ix)
	jr	NZ, 00120$
	inc	-1 (ix)
	jr	00120$
;edimain.c:296: for (short steps = 0; steps > dx; --steps)
00135$:
	ld	a, -2 (ix)
	ld	-4 (ix), a
	ld	a, -1 (ix)
	ld	-3 (ix), a
	xor	a, a
	ld	-2 (ix), a
	ld	-1 (ix), a
00123$:
;edimain.c:290: if (data[i] == 9) cursor_x += 4;
	ld	hl, (_cursor_x)
;edimain.c:296: for (short steps = 0; steps > dx; --steps)
	ld	a, -6 (ix)
	sub	a, -2 (ix)
	ld	a, -5 (ix)
	sbc	a, -1 (ix)
	jp	PO, 00184$
	xor	a, #0x80
00184$:
	jp	P, 00116$
;edimain.c:298: if (data[--i] == 9) cursor_x -= 4;
	ld	a, -4 (ix)
	add	a, #0xff
	ld	-4 (ix), a
	ld	a, -3 (ix)
	adc	a, #0xff
	ld	-3 (ix), a
	ld	a, -8 (ix)
	add	a, -4 (ix)
	ld	c, a
	ld	a, -7 (ix)
	adc	a, -3 (ix)
	ld	b, a
	ld	a, (bc)
	sub	a, #0x09
	jr	NZ, 00111$
	ld	a, l
	add	a, #0xfc
	ld	l, a
;	spillPairReg hl
;	spillPairReg hl
	ld	a, h
	adc	a, #0xff
	ld	h, a
;	spillPairReg hl
;	spillPairReg hl
	ld	(_cursor_x), hl
	jr	00124$
00111$:
;edimain.c:299: else --cursor_x;
	ld	hl, (_cursor_x)
	dec	hl
	ld	(_cursor_x), hl
00124$:
;edimain.c:296: for (short steps = 0; steps > dx; --steps)
	ld	l, -2 (ix)
	ld	h, -1 (ix)
	dec	hl
	ld	-2 (ix), l
	ld	-1 (ix), h
	jr	00123$
00116$:
;edimain.c:302: if (cursor_x < 0) cursor_x = 0;
	bit	7, h
	jr	Z, 00118$
	ld	hl, #0x0000
	ld	(_cursor_x), hl
00118$:
;edimain.c:303: place_cursor();
	call	_place_cursor
00125$:
;edimain.c:304: }
	ld	sp, ix
	pop	ix
	ret
;edimain.c:316: void do_delete()
;	---------------------------------
; Function do_delete
; ---------------------------------
_do_delete::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	hl, #-6
	add	hl, sp
	ld	sp, hl
;edimain.c:318: Vector* line = get_line(cursor_y);
	ld	hl, (_cursor_y)
	call	_get_line
	inc	sp
	inc	sp
	push	de
;edimain.c:319: word i = visual_to_logical(line, cursor_x);
	ld	de, (_cursor_x)
	pop	hl
	push	hl
	call	_visual_to_logical
;edimain.c:320: if (i < vector_size(line))
	push	de
	ld	l, -6 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -5 (ix)
;	spillPairReg hl
;	spillPairReg hl
	call	_vector_size
	ex	de, hl
	pop	de
	ld	a, e
	sub	a, l
	ld	a, d
	sbc	a, h
	jr	NC, 00105$
;edimain.c:321: vector_erase(line, i);
	pop	hl
	push	hl
	call	_vector_erase
	jr	00110$
00105$:
;edimain.c:323: if (cursor_y < (vector_size(document)-1))
	ld	hl, (_document)
	call	_vector_size
	dec	de
	ld	hl, (_cursor_y)
	xor	a, a
	sbc	hl, de
	jr	NC, 00110$
;edimain.c:325: Vector* next_line = get_line(cursor_y + 1);
	ld	hl, (_cursor_y)
	inc	hl
	call	_get_line
	ld	c, e
	ld	b, d
;edimain.c:326: word n = vector_size(next_line);
	push	bc
	ld	l, c
;	spillPairReg hl
;	spillPairReg hl
	ld	h, b
;	spillPairReg hl
;	spillPairReg hl
	call	_vector_size
	pop	bc
	ld	-4 (ix), e
	ld	-3 (ix), d
;edimain.c:327: byte* data = vector_access(next_line, 0);
	push	bc
	ld	de, #0x0000
	ld	l, c
;	spillPairReg hl
;	spillPairReg hl
	ld	h, b
;	spillPairReg hl
;	spillPairReg hl
	call	_vector_access
	pop	bc
	ex	de, hl
;edimain.c:328: for (word j = 0; j < n; ++j)
	xor	a, a
	ld	-2 (ix), a
	ld	-1 (ix), a
00108$:
	ld	a, -2 (ix)
	sub	a, -4 (ix)
	ld	a, -1 (ix)
	sbc	a, -3 (ix)
	jr	NC, 00101$
;edimain.c:329: vector_push(line, &data[j]);
	ld	a, l
	add	a, -2 (ix)
	ld	e, a
	ld	a, h
	adc	a, -1 (ix)
	ld	d, a
	push	hl
	push	bc
	ld	l, -6 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -5 (ix)
;	spillPairReg hl
;	spillPairReg hl
	call	_vector_push
	pop	bc
	pop	hl
;edimain.c:328: for (word j = 0; j < n; ++j)
	inc	-2 (ix)
	jr	NZ, 00108$
	inc	-1 (ix)
	jr	00108$
00101$:
;edimain.c:330: vector_shut(next_line);
	ld	l, c
;	spillPairReg hl
;	spillPairReg hl
	ld	h, b
;	spillPairReg hl
;	spillPairReg hl
	call	_vector_shut
;edimain.c:331: vector_erase(document, cursor_y + 1);
	ld	de, (_cursor_y)
	inc	de
	ld	hl, (_document)
	call	_vector_erase
;edimain.c:332: draw_screen();
	call	_draw_screen
00110$:
;edimain.c:334: }
	ld	sp, ix
	pop	ix
	ret
;edimain.c:336: void backspace()
;	---------------------------------
; Function backspace
; ---------------------------------
_backspace::
;edimain.c:338: move_x_cursor(-1);
	ld	hl, #0xffff
	call	_move_x_cursor
;edimain.c:339: do_delete();
;edimain.c:340: }
	jp	_do_delete
;edimain.c:342: void add_char(byte c)
;	---------------------------------
; Function add_char
; ---------------------------------
_add_char::
	push	ix
	ld	ix,#0
	add	ix,sp
	dec	sp
	ld	-1 (ix), a
;edimain.c:344: Vector* line = get_line(cursor_y);
	ld	hl, (_cursor_y)
	call	_get_line
	ld	c, e
	ld	b, d
;edimain.c:345: word i = visual_to_logical(line, cursor_x);
	push	bc
	ld	de, (_cursor_x)
	ld	l, c
;	spillPairReg hl
;	spillPairReg hl
	ld	h, b
;	spillPairReg hl
;	spillPairReg hl
	call	_visual_to_logical
	pop	bc
;edimain.c:346: if (i >= vector_size(line)) vector_push(line, &c);
	push	bc
	push	de
	ld	l, c
;	spillPairReg hl
;	spillPairReg hl
	ld	h, b
;	spillPairReg hl
;	spillPairReg hl
	call	_vector_size
	ex	de, hl
	pop	de
	pop	bc
	ld	a, e
	sub	a, l
	ld	a, d
	sbc	a, h
	jr	C, 00105$
	ld	hl, #0
	add	hl, sp
	ex	de, hl
	ld	l, c
;	spillPairReg hl
;	spillPairReg hl
	ld	h, b
;	spillPairReg hl
;	spillPairReg hl
	call	_vector_push
	jr	00107$
00105$:
;edimain.c:349: if (insert)
	ld	a, (_insert+0)
	or	a, a
	jr	Z, 00102$
;edimain.c:351: vector_insert(line, i, &c);
	ld	hl, #0
	add	hl, sp
	push	hl
	ld	l, c
;	spillPairReg hl
;	spillPairReg hl
	ld	h, b
;	spillPairReg hl
;	spillPairReg hl
	call	_vector_insert
	jr	00107$
00102$:
;edimain.c:355: vector_set(line, i, &c);
	ld	hl, #0
	add	hl, sp
	push	hl
	ld	l, c
;	spillPairReg hl
;	spillPairReg hl
	ld	h, b
;	spillPairReg hl
;	spillPairReg hl
	call	_vector_set
00107$:
;edimain.c:358: }
	inc	sp
	pop	ix
	ret
;edimain.c:360: void join_prev_line()
;	---------------------------------
; Function join_prev_line
; ---------------------------------
_join_prev_line::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	hl, #-8
	add	hl, sp
	ld	sp, hl
;edimain.c:362: Vector* prev_line = get_line(cursor_y - 1);
	ld	hl, (_cursor_y)
	dec	hl
	call	_get_line
	inc	sp
	inc	sp
	push	de
;edimain.c:363: Vector* cur_line = get_line(cursor_y);
	ld	hl, (_cursor_y)
	call	_get_line
;edimain.c:364: word m = vector_size(prev_line);
	pop	hl
	push	hl
	push	de
	call	_vector_size
	pop	hl
	ld	-6 (ix), e
	ld	-5 (ix), d
;edimain.c:365: word n = vector_size(cur_line);
	push	hl
	call	_vector_size
	pop	hl
	ld	-4 (ix), e
	ld	-3 (ix), d
;edimain.c:366: byte* data = vector_access(cur_line, 0);
	push	hl
	ld	de, #0x0000
	call	_vector_access
	pop	hl
	ld	-2 (ix), e
	ld	-1 (ix), d
;edimain.c:367: for (word i = 0; i < n; ++i)
	ld	bc, #0x0000
00103$:
	ld	a, c
	sub	a, -4 (ix)
	ld	a, b
	sbc	a, -3 (ix)
	jr	NC, 00101$
;edimain.c:368: vector_push(prev_line, &data[i]);
	ld	a, -2 (ix)
	add	a, c
	ld	e, a
	ld	a, -1 (ix)
	adc	a, b
	ld	d, a
	push	hl
	push	bc
	ld	l, -8 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -7 (ix)
;	spillPairReg hl
;	spillPairReg hl
	call	_vector_push
	pop	bc
	pop	hl
;edimain.c:367: for (word i = 0; i < n; ++i)
	inc	bc
	jr	00103$
00101$:
;edimain.c:369: vector_shut(cur_line);
	call	_vector_shut
;edimain.c:370: vector_erase(document, cursor_y);
	ld	de, (_cursor_y)
	ld	hl, (_document)
	call	_vector_erase
;edimain.c:371: cursor_y--;
	ld	hl, (_cursor_y)
	dec	hl
	ld	(_cursor_y), hl
;edimain.c:372: cursor_x = logical_to_visual(prev_line, m);
	pop	hl
	pop	de
	push	de
	push	hl
	call	_logical_to_visual
	ld	(_cursor_x), de
;edimain.c:373: }
	ld	sp, ix
	pop	ix
	ret
;edimain.c:375: void add_enter()
;	---------------------------------
; Function add_enter
; ---------------------------------
_add_enter::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	hl, #-8
	add	hl, sp
	ld	sp, hl
;edimain.c:377: if (insert)
	ld	a, (_insert+0)
	or	a, a
	jp	Z, 00107$
;edimain.c:379: Vector* cur_line = get_line(cursor_y);
	ld	hl, (_cursor_y)
	call	_get_line
	ld	c, e
	ld	b, d
;edimain.c:380: word n = vector_size(cur_line);
	push	bc
	ld	l, c
;	spillPairReg hl
;	spillPairReg hl
	ld	h, b
;	spillPairReg hl
;	spillPairReg hl
	call	_vector_size
	pop	bc
	ld	-6 (ix), e
	ld	-5 (ix), d
;edimain.c:381: word i = visual_to_logical(cur_line, cursor_x);
	push	bc
	ld	de, (_cursor_x)
	ld	l, c
;	spillPairReg hl
;	spillPairReg hl
	ld	h, b
;	spillPairReg hl
;	spillPairReg hl
	call	_visual_to_logical
	pop	bc
	ld	-4 (ix), e
	ld	-3 (ix), d
;edimain.c:382: byte* data = vector_access(cur_line, 0);
	push	bc
	ld	de, #0x0000
	ld	l, c
;	spillPairReg hl
;	spillPairReg hl
	ld	h, b
;	spillPairReg hl
;	spillPairReg hl
	call	_vector_access
	pop	bc
	ld	-2 (ix), e
	ld	-1 (ix), d
;edimain.c:383: Vector* next_line = vector_new(1);
	push	bc
	ld	hl, #0x0001
	call	_vector_new
	pop	bc
	inc	sp
	inc	sp
	push	de
;edimain.c:384: vector_insert(document, cursor_y + 1, &next_line);
	ld	hl, #0
	add	hl, sp
	ld	de, (_cursor_y)
	inc	de
	push	bc
	push	hl
	ld	hl, (_document)
	call	_vector_insert
	pop	bc
;edimain.c:385: for (word j=i; j < n; ++j)
	ld	l, -4 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -3 (ix)
;	spillPairReg hl
;	spillPairReg hl
00105$:
	ld	a, l
	sub	a, -6 (ix)
	ld	a, h
	sbc	a, -5 (ix)
	jr	NC, 00101$
;edimain.c:386: vector_push(next_line, &data[j]);
	ld	a, -2 (ix)
	add	a, l
	ld	e, a
	ld	a, -1 (ix)
	adc	a, h
	ld	d, a
	push	hl
	push	bc
	ld	l, -8 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -7 (ix)
;	spillPairReg hl
;	spillPairReg hl
	call	_vector_push
	pop	bc
	pop	hl
;edimain.c:385: for (word j=i; j < n; ++j)
	inc	hl
	jr	00105$
00101$:
;edimain.c:387: vector_erase_range(cur_line, i, n);
	pop	de
	pop	hl
	push	hl
	push	de
	push	hl
	ld	e, -4 (ix)
	ld	d, -3 (ix)
	ld	l, c
;	spillPairReg hl
;	spillPairReg hl
	ld	h, b
;	spillPairReg hl
;	spillPairReg hl
	call	_vector_erase_range
;edimain.c:388: cursor_y++;
	ld	hl, (_cursor_y)
	inc	hl
	ld	(_cursor_y), hl
;edimain.c:389: cursor_x = 0;
	ld	hl, #0x0000
	ld	(_cursor_x), hl
00107$:
;edimain.c:391: }
	ld	sp, ix
	pop	ix
	ret
;edimain.c:393: word getkey()
;	---------------------------------
; Function getkey
; ---------------------------------
_getkey::
;edimain.c:395: while (input_empty());
00101$:
	call	_input_empty
	or	a, a
	jr	NZ, 00101$
;edimain.c:396: return input_read();
;edimain.c:397: }
	jp	_input_read
;edimain.c:399: void event_loop()
;	---------------------------------
; Function event_loop
; ---------------------------------
_event_loop::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	hl, #-12
	add	hl, sp
	ld	sp, hl
;edimain.c:401: byte done = 0;
	ld	-12 (ix), #0x00
;edimain.c:402: byte redraw_line = 0;
	ld	-11 (ix), #0x00
;edimain.c:403: const word total_lines = vector_size(document);
	ld	hl, (_document)
	call	_vector_size
	ld	-10 (ix), e
	ld	-9 (ix), d
;edimain.c:404: while (!done)
00140$:
	ld	a, -12 (ix)
	or	a, a
	jp	NZ, 00143$
;edimain.c:406: Vector* line = get_line(cursor_y);
	ld	hl, (_cursor_y)
	call	_get_line
;edimain.c:407: word n = vector_size(line);
;	spillPairReg hl
;	spillPairReg hl
	ld	-8 (ix), e
	ld	-7 (ix), d
	ex	de,hl
;	spillPairReg hl
;	spillPairReg hl
	call	_vector_size
	ld	-6 (ix), e
	ld	-5 (ix), d
;edimain.c:408: word key = getkey();
	call	_getkey
	ld	-4 (ix), e
	ld	-3 (ix), d
;edimain.c:409: switch (key)
	ld	a, -4 (ix)
	ld	-2 (ix), a
	ld	a, -3 (ix)
	ld	-1 (ix), a
	ld	a, -2 (ix)
	sub	a, #0x08
	or	a, -1 (ix)
	jp	Z,00120$
	ld	a, -2 (ix)
	sub	a, #0x09
	or	a, -1 (ix)
	jp	Z,00119$
	ld	a, -2 (ix)
	sub	a, #0x0a
	or	a, -1 (ix)
	jp	Z,00128$
	ld	a, -2 (ix)
	sub	a, #0x0d
	or	a, -1 (ix)
	jp	Z,00128$
	ld	a, -2 (ix)
	sub	a, #0x1b
	or	a, -1 (ix)
	jp	Z,00118$
	ld	a, -2 (ix)
	or	a, a
	jr	NZ, 00285$
	ld	a, -1 (ix)
	dec	a
	jp	Z,00113$
00285$:
	ld	a, -2 (ix)
	or	a, a
	jr	NZ, 00286$
	ld	a, -1 (ix)
	sub	a, #0x02
	jp	Z,00117$
00286$:
	ld	a, -2 (ix)
	or	a, a
	jr	NZ, 00287$
	ld	a, -1 (ix)
	sub	a, #0x03
	jp	Z,00112$
00287$:
	ld	a, -2 (ix)
	or	a, a
	jr	NZ, 00288$
	ld	a, -1 (ix)
	sub	a, #0x04
	jp	Z,00111$
00288$:
	ld	a, -2 (ix)
	or	a, a
	jr	NZ, 00289$
	ld	a, -1 (ix)
	sub	a, #0x05
	jr	Z, 00101$
00289$:
	ld	a, -2 (ix)
	or	a, a
	jr	NZ, 00290$
	ld	a, -1 (ix)
	sub	a, #0x06
	jr	Z, 00105$
00290$:
	ld	a, -2 (ix)
	or	a, a
	jr	NZ, 00291$
	ld	a, -1 (ix)
	sub	a, #0x07
	jr	Z, 00104$
00291$:
	ld	a, -2 (ix)
	or	a, a
	jr	NZ, 00292$
	ld	a, -1 (ix)
	sub	a, #0x08
	jr	Z, 00108$
00292$:
	ld	a, -2 (ix)
	or	a, a
	jp	NZ,00129$
	ld	a, -1 (ix)
	sub	a, #0x0e
	jp	Z,00126$
	jp	00129$
;edimain.c:411: case LEFT: if (cursor_x > 0) move_x_cursor(-1); break;
00101$:
	ld	hl, (_cursor_x)
	xor	a, a
	cp	a, l
	sbc	a, h
	jp	PO, 00294$
	xor	a, #0x80
00294$:
	jp	P, 00133$
	ld	hl, #0xffff
	call	_move_x_cursor
	jp	00133$
;edimain.c:412: case RIGHT: move_x_cursor(1); break;
00104$:
	ld	hl, #0x0001
	call	_move_x_cursor
	jp	00133$
;edimain.c:413: case UP: if (cursor_y > 0) --cursor_y; break;
00105$:
	ld	hl, (_cursor_y)
	xor	a, a
	cp	a, l
	sbc	a, h
	jp	PO, 00295$
	xor	a, #0x80
00295$:
	jp	P, 00133$
	ld	hl, (_cursor_y)
	dec	hl
	ld	(_cursor_y), hl
	jp	00133$
;edimain.c:414: case DOWN: if (cursor_y<total_lines) cursor_y++; break;
00108$:
	ld	hl, (_cursor_y)
	ld	a, l
	sub	a, -10 (ix)
	ld	a, h
	sbc	a, -9 (ix)
	jp	NC, 00133$
	ld	hl, (_cursor_y)
	inc	hl
	ld	(_cursor_y), hl
	jp	00133$
;edimain.c:415: case HOME: cursor_x = 0; break;
00111$:
	ld	hl, #0x0000
	ld	(_cursor_x), hl
	jp	00133$
;edimain.c:416: case END: cursor_x = logical_to_visual(line,n); break;
00112$:
	ld	e, -6 (ix)
	ld	d, -5 (ix)
	ld	l, -8 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -7 (ix)
;	spillPairReg hl
;	spillPairReg hl
	call	_logical_to_visual
	ld	(_cursor_x), de
	jp	00133$
;edimain.c:417: case PGUP: if (cursor_y < 25) cursor_y = 0; else cursor_y -= 25; break;
00113$:
	ld	hl, (_cursor_y)
	ld	a, l
	sub	a, #0x19
	ld	a, h
	rla
	ccf
	rra
	sbc	a, #0x80
	jr	NC, 00115$
	ld	hl, #0x0000
	ld	(_cursor_y), hl
	jp	00133$
00115$:
	ld	a, l
	add	a, #0xe7
	ld	l, a
;	spillPairReg hl
;	spillPairReg hl
	ld	a, h
	adc	a, #0xff
	ld	h, a
;	spillPairReg hl
;	spillPairReg hl
	ld	(_cursor_y), hl
	jp	00133$
;edimain.c:418: case PGDN: cursor_y = min(cursor_y + 25, total_lines); break;
00117$:
	ld	hl, (_cursor_y)
	ld	bc, #0x0019
	add	hl, bc
	ld	e, -10 (ix)
	ld	d, -9 (ix)
	call	_min
	ld	(_cursor_y), de
	jp	00133$
;edimain.c:419: case 27: done = 1; break;
00118$:
	ld	-12 (ix), #0x01
	jr	00133$
;edimain.c:420: case 9: add_char(9); redraw_line = 1; cursor_x += 4; break;
00119$:
	ld	a, #0x09
	call	_add_char
	ld	-11 (ix), #0x01
	ld	hl, (_cursor_x)
	ld	bc, #0x0004
	add	hl, bc
	ld	(_cursor_x), hl
	jr	00133$
;edimain.c:421: case 8:
00120$:
;edimain.c:423: if (cursor_x > 0)
	ld	hl, (_cursor_x)
	xor	a, a
	cp	a, l
	sbc	a, h
	jp	PO, 00296$
	xor	a, #0x80
00296$:
	jp	P, 00124$
;edimain.c:425: backspace();
	call	_backspace
;edimain.c:426: redraw_line = 1;
	ld	-11 (ix), #0x01
	jr	00133$
00124$:
;edimain.c:429: if (cursor_y>0)
	ld	hl, (_cursor_y)
	xor	a, a
	cp	a, l
	sbc	a, h
	jp	PO, 00297$
	xor	a, #0x80
00297$:
	jp	P, 00133$
;edimain.c:431: join_prev_line();
	call	_join_prev_line
;edimain.c:432: draw_screen();
	call	_draw_screen
;edimain.c:434: break;
	jr	00133$
;edimain.c:436: case DEL: do_delete(); redraw_line = 1; break;
00126$:
	call	_do_delete
	ld	-11 (ix), #0x01
	jr	00133$
;edimain.c:438: case 10: add_enter(); draw_screen(); break;
00128$:
	call	_add_enter
	call	_draw_screen
	jr	00133$
;edimain.c:439: default:
00129$:
;edimain.c:440: if (key >= 32 && key < 127)
	ld	a, -2 (ix)
	sub	a, #0x20
	ld	a, -1 (ix)
	sbc	a, #0x00
	jr	C, 00133$
	ld	a, -2 (ix)
	sub	a, #0x7f
	ld	a, -1 (ix)
	sbc	a, #0x00
	jr	NC, 00133$
;edimain.c:442: add_char((byte)key);
	ld	a, -4 (ix)
	call	_add_char
;edimain.c:443: ++cursor_x;
	ld	hl, (_cursor_x)
	inc	hl
	ld	(_cursor_x), hl
;edimain.c:444: redraw_line = 1;
	ld	-11 (ix), #0x01
;edimain.c:446: }
00133$:
;edimain.c:447: line = get_line(cursor_y);
	ld	hl, (_cursor_y)
	call	_get_line
	ex	de, hl
;edimain.c:448: n = vector_size(line);
	push	hl
	call	_vector_size
	pop	hl
	ld	-2 (ix), e
	ld	-1 (ix), d
;edimain.c:450: word i = visual_to_logical(line, cursor_x);
	push	hl
	ld	de, (_cursor_x)
	call	_visual_to_logical
	pop	hl
;edimain.c:451: if (i > n) cursor_x = logical_to_visual(line, n);
	ld	a, -2 (ix)
	sub	a, e
	ld	a, -1 (ix)
	sbc	a, d
	jr	NC, 00135$
	ld	e, -2 (ix)
	ld	d, -1 (ix)
	call	_logical_to_visual
	ld	(_cursor_x), de
00135$:
;edimain.c:453: if (redraw_line)
	ld	a, -11 (ix)
	or	a, a
	jr	Z, 00137$
;edimain.c:454: draw_line(cursor_y);
	ld	hl, (_cursor_y)
	call	_draw_line
00137$:
;edimain.c:455: draw_cursor_position();
	call	_draw_cursor_position
;edimain.c:456: place_cursor();
	call	_place_cursor
;edimain.c:457: if (full_redraw)
	ld	a, (_full_redraw+0)
	or	a, a
	jp	Z, 00140$
;edimain.c:459: draw_screen();
	call	_draw_screen
;edimain.c:460: place_cursor();
	call	_place_cursor
	jp	00140$
00143$:
;edimain.c:463: }
	ld	sp, ix
	pop	ix
	ret
;edimain.c:465: int main(char** args)
;	---------------------------------
; Function main
; ---------------------------------
_main::
;edimain.c:467: init_state();
	push	hl
	call	_init_state
	call	_alloc_init
	call	_hal_init
	ld	hl, #0x0002
	call	_vector_new
	pop	hl
	ld	(_document), de
;edimain.c:471: if (args[0])
	ld	c, (hl)
	inc	hl
	ld	h, (hl)
;	spillPairReg hl
	ld	a, h
	or	a, c
	jr	Z, 00102$
;edimain.c:473: load_file(args[0]);
	ld	l, c
;	spillPairReg hl
;	spillPairReg hl
	call	_load_file
00102$:
;edimain.c:475: fg = 0x3F;
	ld	hl, #_fg
	ld	(hl), #0x3f
;edimain.c:476: bg = 0x40;
	ld	hl, #_bg
	ld	(hl), #0x40
;edimain.c:477: if (full_redraw)
	ld	a, (_full_redraw+0)
	or	a, a
	jr	Z, 00104$
;edimain.c:478: draw_screen();
	call	_draw_screen
00104$:
;edimain.c:479: hal_blink(1);
	ld	a, #0x01
	call	_hal_blink
;edimain.c:480: event_loop();
	call	_event_loop
;edimain.c:481: hal_shutdown();
	call	_hal_shutdown
;edimain.c:482: clear();
	call	_clear
;edimain.c:483: vector_shut(document);
	ld	hl, (_document)
	call	_vector_shut
;edimain.c:484: return 0;
	ld	de, #0x0000
;edimain.c:485: }
	ret
	.area _CODE
	.area _INITIALIZER
__xinit__fg:
	.db #0xff	; 255
__xinit__bg:
	.db #0x00	; 0
__xinit__full_redraw:
	.db #0x01	; 1
__xinit__insert:
	.db #0x01	; 1
__xinit__cursor_x:
	.dw #0x0000
__xinit__cursor_y:
	.dw #0x0000
__xinit__offset_x:
	.dw #0x0000
__xinit__offset_y:
	.dw #0x0000
	.area _CABS (ABS)
