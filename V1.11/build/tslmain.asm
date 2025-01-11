;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 4.2.0 #13081 (MINGW64)
;--------------------------------------------------------
	.module tslmain
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _main
	.globl _event_loop
	.globl _clipboard_paste
	.globl _clipboard_cut
	.globl _clipboard_copy
	.globl _move_y
	.globl _getkey
	.globl _add_char
	.globl _add_enter
	.globl _backspace
	.globl _do_delete
	.globl _delete_selection
	.globl _delete_single_line_selection
	.globl _join_prev_line
	.globl _is_move_key
	.globl _move_x_cursor
	.globl _visual_to_logical
	.globl _draw_screen
	.globl _draw_cursor_position
	.globl _draw_number
	.globl _decimal_string
	.globl _place_cursor
	.globl _calculate_new_offset
	.globl _redraw_all
	.globl _eod_cursor
	.globl _cursor_in_view
	.globl _visual_cursor
	.globl _draw_line
	.globl _draw_frame
	.globl _draw_brackets
	.globl _draw_status
	.globl _draw_menu
	.globl _draw_status_item
	.globl _draw_menu_item
	.globl _draw_str
	.globl _load_file
	.globl _append_line
	.globl _get_line
	.globl _round_up
	.globl _clear
	.globl _extend_select
	.globl _start_select
	.globl _clear_select
	.globl _redraw_range
	.globl _redraw_from
	.globl _redraw_line
	.globl _valid_select
	.globl _cursor_lt
	.globl _logical_to_visual
	.globl _visual_mapping
	.globl _in_selection
	.globl _init_state
	.globl _alloc_init
	.globl _div_mod
	.globl _close_file
	.globl _read_file
	.globl _open_file
	.globl _max
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
	.globl _hal_getkey
	.globl _hal_blink
	.globl _hal_color
	.globl _hal_rept_char
	.globl _hal_draw_char
	.globl _hal_move
	.globl _hal_shutdown
	.globl _hal_init
	.globl _insert
	.globl _bg
	.globl _fg
	.globl _redraw_stop
	.globl _redraw_start
	.globl _select_stop
	.globl _select_start
	.globl _offset
	.globl _cursor
	.globl _line_mapping
	.globl _clipboard
	.globl _document
	.globl _VERT
	.globl _HORZ
	.globl _BR
	.globl _BL
	.globl _TR
	.globl _TL
;--------------------------------------------------------
; special function registers
;--------------------------------------------------------
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _DATA
_document::
	.ds 2
_clipboard::
	.ds 2
_line_mapping::
	.ds 320
_cursor::
	.ds 4
_offset::
	.ds 4
_select_start::
	.ds 4
_select_stop::
	.ds 4
_redraw_start::
	.ds 2
_redraw_stop::
	.ds 2
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _INITIALIZED
_fg::
	.ds 1
_bg::
	.ds 1
_insert::
	.ds 1
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
;tslmain.c:44: void init_state()
;	---------------------------------
; Function init_state
; ---------------------------------
_init_state::
;tslmain.c:46: fg = 0xFF;
	ld	hl, #_fg
	ld	(hl), #0xff
;tslmain.c:47: bg = 0;
	ld	hl, #_bg
	ld	(hl), #0x00
;tslmain.c:48: redraw_start = 0;
	ld	hl, #0x0000
	ld	(_redraw_start), hl
;tslmain.c:49: redraw_stop = 0x7000;
	ld	h, #0x70
	ld	(_redraw_stop), hl
;tslmain.c:50: insert = 1;
	ld	iy, #_insert
	ld	0 (iy), #0x01
;tslmain.c:51: document = 0;
	ld	h, l
	ld	(_document), hl
;tslmain.c:52: cursor.x = 0;
	ld	(_cursor), hl
;tslmain.c:53: cursor.y = 0;
	ld	((_cursor + 2)), hl
;tslmain.c:54: offset.x = 0;
	ld	(_offset), hl
;tslmain.c:55: offset.y = 0;
	ld	((_offset + 2)), hl
;tslmain.c:56: select_start.x = 0;
	ld	(_select_start), hl
;tslmain.c:57: select_start.y = 0;
	ld	((_select_start + 2)), hl
;tslmain.c:58: select_stop.x = 0;
	ld	(_select_stop), hl
;tslmain.c:59: select_stop.y = 0;
	ld	((_select_stop + 2)), hl
;tslmain.c:60: }
	ret
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
;tslmain.c:62: byte in_selection(short x, short y)
;	---------------------------------
; Function in_selection
; ---------------------------------
_in_selection::
	ld	c, l
	ld	b, h
;tslmain.c:64: if (y > select_start.y || (y == select_start.y && x >= select_start.x))
	ld	hl, (#_select_start + 2)
	ld	a, l
	sub	a, e
	ld	a, h
	sbc	a, d
	jp	PO, 00131$
	xor	a, #0x80
00131$:
	jp	M, 00105$
	cp	a, a
	sbc	hl, de
	jr	NZ, 00106$
	ld	hl, (#_select_start + 0)
	ld	a, c
	sub	a, l
	ld	a, b
	sbc	a, h
	jp	PO, 00134$
	xor	a, #0x80
00134$:
	jp	M, 00106$
00105$:
;tslmain.c:66: if (y < select_stop.y || (y == select_stop.y && x < select_stop.x))
	ld	hl, (#_select_stop + 2)
	ld	a, e
	sub	a, l
	ld	a, d
	sbc	a, h
	jp	PO, 00135$
	xor	a, #0x80
00135$:
	jp	M, 00101$
	cp	a, a
	sbc	hl, de
	jr	NZ, 00106$
	ld	hl, (#_select_stop + 0)
	ld	a, c
	sub	a, l
	ld	a, b
	sbc	a, h
	jp	PO, 00138$
	xor	a, #0x80
00138$:
	jp	P, 00106$
00101$:
;tslmain.c:68: return 1;
	ld	a, #0x01
	ret
00106$:
;tslmain.c:71: return 0;
	xor	a, a
;tslmain.c:72: }
	ret
;tslmain.c:74: byte visual_mapping(Vector* line, Mapping* mapping, short start, short stop)
;	---------------------------------
; Function visual_mapping
; ---------------------------------
_visual_mapping::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	iy, #-13
	add	iy, sp
	ld	sp, iy
	ld	-9 (ix), e
	ld	-8 (ix), d
;tslmain.c:76: short n = vector_size(line);
	push	hl
	call	_vector_size
	pop	hl
	inc	sp
	inc	sp
	push	de
;tslmain.c:77: const byte* data = vector_access(line, 0);
	ld	de, #0x0000
	call	_vector_access
	ld	-11 (ix), e
	ld	-10 (ix), d
;tslmain.c:78: short visual = -offset.x;
	ld	hl, (#_offset + 0)
	xor	a, a
	sub	a, l
	ld	c, a
	sbc	a, a
	sub	a, h
	ld	-7 (ix), c
	ld	-6 (ix), a
;tslmain.c:79: short x = 0;
	xor	a, a
	ld	-5 (ix), a
	ld	-4 (ix), a
;tslmain.c:82: for (short logical = 0; logical < n; ++logical)
	ld	-3 (ix), #0x00
	xor	a, a
	ld	-2 (ix), a
	ld	-1 (ix), a
00113$:
	ld	a, -2 (ix)
	sub	a, -13 (ix)
	ld	a, -1 (ix)
	sbc	a, -12 (ix)
	jp	PO, 00163$
	xor	a, #0x80
00163$:
	jp	P, 00111$
;tslmain.c:84: if (visual >= 0 && visual < (W - 2) && logical >= start && logical < stop)
	ld	b, -6 (ix)
	bit	7, b
	jr	NZ, 00102$
	ld	a, -7 (ix)
	sub	a, #0x4e
	ld	a, -6 (ix)
	rla
	ccf
	rra
	sbc	a, #0x80
	jr	NC, 00102$
	ld	a, -2 (ix)
	sub	a, 4 (ix)
	ld	a, -1 (ix)
	sbc	a, 5 (ix)
	jp	PO, 00164$
	xor	a, #0x80
00164$:
	jp	M, 00102$
	ld	a, -2 (ix)
	sub	a, 6 (ix)
	ld	a, -1 (ix)
	sbc	a, 7 (ix)
	jp	PO, 00165$
	xor	a, #0x80
00165$:
	jp	P, 00102$
;tslmain.c:86: mapping[index].logical = logical;
	ld	l, -3 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, #0x00
;	spillPairReg hl
;	spillPairReg hl
	add	hl, hl
	add	hl, hl
	ld	e, -9 (ix)
	ld	d, -8 (ix)
	add	hl, de
	ld	a, -2 (ix)
	ld	(hl), a
	inc	hl
	ld	a, -1 (ix)
	ld	(hl), a
;tslmain.c:87: mapping[index].visual = visual;
	inc	hl
	ld	a, -7 (ix)
	ld	(hl), a
	inc	hl
	ld	a, -6 (ix)
	ld	(hl), a
;tslmain.c:88: index++;
	inc	-3 (ix)
00102$:
;tslmain.c:90: ++visual;
	inc	-7 (ix)
	jr	NZ, 00166$
	inc	-6 (ix)
00166$:
;tslmain.c:91: ++x;
	inc	-5 (ix)
	jr	NZ, 00167$
	inc	-4 (ix)
00167$:
;tslmain.c:92: if (data[logical] == 9)
	ld	a, -11 (ix)
	add	a, -2 (ix)
	ld	c, a
	ld	a, -10 (ix)
	adc	a, -1 (ix)
	ld	b, a
	ld	a, (bc)
	sub	a, #0x09
	jr	NZ, 00114$
;tslmain.c:94: while ((x & 3) != 0)
	ld	c, -7 (ix)
	ld	b, -6 (ix)
	ld	e, -5 (ix)
	ld	d, -4 (ix)
00106$:
	ld	a, e
	and	a, #0x03
	jr	Z, 00125$
;tslmain.c:96: ++visual;
	inc	bc
;tslmain.c:97: ++x;
	inc	de
	jr	00106$
00125$:
	ld	-7 (ix), c
	ld	-6 (ix), b
	ld	-5 (ix), e
	ld	-4 (ix), d
00114$:
;tslmain.c:82: for (short logical = 0; logical < n; ++logical)
	inc	-2 (ix)
	jp	NZ,00113$
	inc	-1 (ix)
	jp	00113$
00111$:
;tslmain.c:101: return index;
	ld	a, -3 (ix)
;tslmain.c:102: }
	ld	sp, ix
	pop	ix
	pop	hl
	pop	bc
	pop	bc
	jp	(hl)
;tslmain.c:104: short logical_to_visual(Vector* line, word logical)
;	---------------------------------
; Function logical_to_visual
; ---------------------------------
_logical_to_visual::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	iy, #-8
	add	iy, sp
	ld	sp, iy
	ld	c, e
	ld	b, d
;tslmain.c:106: word n = min(logical, vector_size(line));
	push	hl
	push	bc
	call	_vector_size
;	spillPairReg hl
;	spillPairReg hl
	pop	hl
;	spillPairReg hl
;	spillPairReg hl
	call	_min
	pop	hl
	inc	sp
	inc	sp
	push	de
;tslmain.c:107: const byte* data = vector_access(line, 0);
	ld	de, #0x0000
	call	_vector_access
	ld	-6 (ix), e
	ld	-5 (ix), d
;tslmain.c:108: short x = 0;
	ld	bc, #0x0000
;tslmain.c:109: for (word i = 0; i < n; ++i)
	xor	a, a
	ld	-4 (ix), a
	ld	-3 (ix), a
00108$:
	ld	a, -4 (ix)
	sub	a, -8 (ix)
	ld	a, -3 (ix)
	sbc	a, -7 (ix)
	jr	NC, 00106$
;tslmain.c:111: ++x;
	inc	bc
;tslmain.c:112: if (data[i] == 9)
	ld	a, -6 (ix)
	add	a, -4 (ix)
	ld	e, a
	ld	a, -5 (ix)
	adc	a, -3 (ix)
	ld	d, a
	ld	a, (de)
	sub	a, #0x09
	jr	NZ, 00109$
;tslmain.c:114: while ((x & 3) != 0) ++x;
	ld	-2 (ix), c
	ld	-1 (ix), b
00101$:
	ld	a, -2 (ix)
	and	a, #0x03
	jr	Z, 00116$
	inc	-2 (ix)
	jr	NZ, 00101$
	inc	-1 (ix)
	jr	00101$
00116$:
	ld	c, -2 (ix)
	ld	b, -1 (ix)
00109$:
;tslmain.c:109: for (word i = 0; i < n; ++i)
	inc	-4 (ix)
	jr	NZ, 00108$
	inc	-3 (ix)
	jr	00108$
00106$:
;tslmain.c:117: return x - offset.x;
	ld	hl, (#_offset + 0)
	ld	a, c
	sub	a, l
	ld	e, a
	ld	a, b
	sbc	a, h
	ld	d, a
;tslmain.c:118: }
	ld	sp, ix
	pop	ix
	ret
;tslmain.c:120: byte cursor_lt(Cursor* a, Cursor* b)
;	---------------------------------
; Function cursor_lt
; ---------------------------------
_cursor_lt::
	push	ix
	ld	ix,#0
	add	ix,sp
	push	af
	push	af
	ld	-2 (ix), l
	ld	-1 (ix), h
	inc	sp
	inc	sp
	pop	hl
	push	hl
	inc	hl
	inc	hl
	push	de
	ld	c, (hl)
	inc	hl
	ld	b, (hl)
	pop	hl
	push	hl
	inc	hl
	inc	hl
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	ld	l, e
	ld	h, d
	cp	a, a
	sbc	hl, bc
	jr	NZ, 00102$
	ld	l, -2 (ix)
	ld	h, -1 (ix)
	ld	c, (hl)
	inc	hl
	ld	b, (hl)
	pop	hl
	push	hl
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	ld	a, c
	sub	a, e
	ld	a, b
	sbc	a, d
	jp	PO, 00112$
	xor	a, #0x80
00112$:
	rlca
	and	a,#0x01
	jr	00103$
00102$:
;tslmain.c:123: return a->y < b->y;
	ld	a, c
	sub	a, e
	ld	a, b
	sbc	a, d
	jp	PO, 00113$
	xor	a, #0x80
00113$:
	rlca
	and	a,#0x01
00103$:
;tslmain.c:124: }
	ld	sp, ix
	pop	ix
	ret
;tslmain.c:126: byte valid_select()
;	---------------------------------
; Function valid_select
; ---------------------------------
_valid_select::
;tslmain.c:128: if (select_start.y == select_stop.y) return select_start.x < select_stop.x;
	ld	bc, (#_select_start + 2)
	ld	de, (#_select_stop + 2)
	ld	l, e
	ld	h, d
	cp	a, a
	sbc	hl, bc
	jr	NZ, 00102$
	ld	bc, (#_select_start + 0)
	ld	hl, (#_select_stop + 0)
	ld	a, c
	sub	a, l
	ld	a, b
	sbc	a, h
	jp	PO, 00112$
	xor	a, #0x80
00112$:
	rlca
	and	a,#0x01
	ret
00102$:
;tslmain.c:129: return select_start.y < select_stop.y;
	ld	a, c
	sub	a, e
	ld	a, b
	sbc	a, d
	jp	PO, 00113$
	xor	a, #0x80
00113$:
	rlca
	and	a,#0x01
;tslmain.c:130: }
	ret
;tslmain.c:132: void redraw_line(short y)
;	---------------------------------
; Function redraw_line
; ---------------------------------
_redraw_line::
;tslmain.c:134: redraw_start = y;
	ld	(_redraw_start), hl
;tslmain.c:135: redraw_stop = y + 1;
	inc	hl
	ld	(_redraw_stop), hl
;tslmain.c:136: }
	ret
;tslmain.c:138: void redraw_from(short y)
;	---------------------------------
; Function redraw_from
; ---------------------------------
_redraw_from::
	ld	(_redraw_start), hl
;tslmain.c:141: redraw_stop = 0x7000;
	ld	hl, #0x7000
	ld	(_redraw_stop), hl
;tslmain.c:142: }
	ret
;tslmain.c:144: void redraw_range(short y1, short y2)
;	---------------------------------
; Function redraw_range
; ---------------------------------
_redraw_range::
	ld	c, e
	ld	b, d
;tslmain.c:146: redraw_start = min(y1, y2);
	push	hl
	push	bc
	ld	e, c
	ld	d, b
	call	_min
	pop	bc
	pop	hl
	ld	(_redraw_start), de
;tslmain.c:147: redraw_stop = max(y1, y2) + 1;
	ld	e, c
	ld	d, b
	call	_max
	inc	de
	ld	(_redraw_stop), de
;tslmain.c:148: }
	ret
;tslmain.c:150: void clear_select()
;	---------------------------------
; Function clear_select
; ---------------------------------
_clear_select::
;tslmain.c:152: redraw_start = select_start.y;
	ld	hl, #(_select_start + 2)
	ld	a, (hl)
	inc	hl
	ld	(_redraw_start+0), a
	ld	a, (hl)
	ld	(_redraw_start+1), a
;tslmain.c:153: redraw_stop = select_stop.y+1;
	ld	hl, (#(_select_stop + 2) + 0)
	inc	hl
	ld	(_redraw_stop), hl
;tslmain.c:154: select_start.x = 0;
	ld	hl, #0x0000
	ld	(_select_start), hl
;tslmain.c:155: select_start.y = 0;
	ld	((_select_start + 2)), hl
;tslmain.c:156: select_stop.x = 0;
	ld	(_select_stop), hl
;tslmain.c:157: select_stop.y = 0;
	ld	((_select_stop + 2)), hl
;tslmain.c:158: }
	ret
;tslmain.c:160: void start_select()
;	---------------------------------
; Function start_select
; ---------------------------------
_start_select::
;tslmain.c:162: select_stop = select_start = cursor;
	ld	de, #_select_start
	ld	hl, #_cursor
	ld	bc, #0x0004
	ldir
	ld	de, #_select_stop
	ld	hl, #_select_start
	ld	bc, #0x0004
	ldir
;tslmain.c:163: }
	ret
;tslmain.c:165: void extend_select()
;	---------------------------------
; Function extend_select
; ---------------------------------
_extend_select::
	push	ix
	ld	ix,#0
	add	ix,sp
	dec	sp
;tslmain.c:167: if (cursor_lt(&cursor, &select_start))
	ld	de, #_select_start
	ld	hl, #_cursor
	call	_cursor_lt
	ld	-1 (ix), a
	or	a, a
	jr	Z, 00102$
;tslmain.c:168: select_start = cursor;
	ld	de, #_select_start
	ld	hl, #_cursor
	ld	bc, #0x0004
	ldir
	jr	00104$
00102$:
;tslmain.c:170: select_stop = cursor;
	ld	de, #_select_stop
	ld	hl, #_cursor
	ld	bc, #0x0004
	ldir
00104$:
;tslmain.c:171: }
	inc	sp
	pop	ix
	ret
;tslmain.c:173: void clear()
;	---------------------------------
; Function clear
; ---------------------------------
_clear::
	push	ix
	ld	ix,#0
	add	ix,sp
	push	af
	push	af
;tslmain.c:175: word n = vector_size(document);
	ld	hl, (_document)
	call	_vector_size
	ld	-2 (ix), e
	ld	-1 (ix), d
;tslmain.c:177: for (word i = 0; i < n; ++i)
	ld	bc, #0x0000
00103$:
	ld	a, c
	sub	a, -2 (ix)
	ld	a, b
	sbc	a, -1 (ix)
	jr	NC, 00101$
;tslmain.c:179: vector_get(document, i, &line);
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
;tslmain.c:177: for (word i = 0; i < n; ++i)
	inc	bc
	jr	00103$
00101$:
;tslmain.c:182: vector_clear(document);
	ld	hl, (_document)
	call	_vector_clear
;tslmain.c:183: }
	ld	sp, ix
	pop	ix
	ret
;tslmain.c:185: word round_up(word value, word margin)
;	---------------------------------
; Function round_up
; ---------------------------------
_round_up::
;tslmain.c:187: return (value + margin) & ~(margin-1);
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
;tslmain.c:188: }
	ret
;tslmain.c:190: Vector* get_line(word line_index)
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
;tslmain.c:192: word size = vector_size(document);
	ld	hl, (_document)
	call	_vector_size
	ld	-2 (ix), e
	ld	-1 (ix), d
;tslmain.c:193: if (line_index < size)
	ld	a, -4 (ix)
	sub	a, -2 (ix)
	ld	a, -3 (ix)
	sbc	a, -1 (ix)
	jr	NC, 00102$
;tslmain.c:196: vector_get(document, line_index, &line);
	ld	hl, #2
	add	hl, sp
	push	hl
	ld	e, -4 (ix)
	ld	d, -3 (ix)
	ld	hl, (_document)
	call	_vector_get
;tslmain.c:197: return line;
	pop	hl
	pop	de
	push	de
	push	hl
	jp	00106$
00102$:
;tslmain.c:199: vector_reserve(document, round_up(line_index + 1, 16));
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
;tslmain.c:200: vector_resize(document, line_index + 1);
	ld	e, -6 (ix)
	ld	d, -5 (ix)
	ld	hl, (_document)
	call	_vector_resize
;tslmain.c:201: word new_size = vector_size(document);
	ld	hl, (_document)
	call	_vector_size
	ld	-6 (ix), e
	ld	-5 (ix), d
;tslmain.c:202: while (size < new_size)
00103$:
	ld	a, -2 (ix)
	sub	a, -6 (ix)
	ld	a, -1 (ix)
	sbc	a, -5 (ix)
	jr	NC, 00105$
;tslmain.c:204: Vector* new_line = vector_new(1);
	ld	hl, #0x0001
	call	_vector_new
	ld	-8 (ix), e
	ld	-7 (ix), d
;tslmain.c:205: vector_set(document, size++, &new_line);
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
;tslmain.c:208: vector_get(document, line_index, &line);
	ld	hl, #2
	add	hl, sp
	push	hl
	ld	e, -4 (ix)
	ld	d, -3 (ix)
	ld	hl, (_document)
	call	_vector_get
;tslmain.c:209: return line;
	pop	hl
	pop	de
	push	de
	push	hl
00106$:
;tslmain.c:210: }
	ld	sp, ix
	pop	ix
	ret
;tslmain.c:212: void append_line(Vector* line, byte b)
;	---------------------------------
; Function append_line
; ---------------------------------
_append_line::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	c, l
	ld	b, h
;tslmain.c:214: vector_push(line, &b);
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
;tslmain.c:215: }
	pop	ix
	pop	hl
	inc	sp
	jp	(hl)
;tslmain.c:217: void load_file(const char* filename)
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
;tslmain.c:220: clear();
	push	hl
	call	_clear
	pop	hl
;tslmain.c:221: byte handle = open_file(filename, 0);
	xor	a, a
	push	af
	inc	sp
	call	_open_file
;tslmain.c:222: if (handle == 0xFF) return;
	ld	c, a
	inc	a
	jp	Z,00118$
	jr	00102$
00102$:
;tslmain.c:224: word line_index = 0;
	xor	a, a
	ld	-2 (ix), a
	ld	-1 (ix), a
;tslmain.c:225: do
00112$:
;tslmain.c:227: act = read_file(handle, buffer, 256);
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
;tslmain.c:228: for (word i = 0; i < act; ++i)
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
;tslmain.c:230: if (buffer[i] == 10)
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
;tslmain.c:231: ++line_index;
	inc	de
	jr	00117$
00109$:
;tslmain.c:233: if (buffer[i] >= 32 || buffer[i]==9)
	cp	a, #0x20
	jr	NC, 00105$
	sub	a, #0x09
	jr	NZ, 00117$
00105$:
;tslmain.c:235: Vector* line = get_line(line_index);
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
;tslmain.c:236: if (line)
	ld	a, h
	or	a, l
	jr	Z, 00117$
;tslmain.c:237: append_line(line, buffer[i]);
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
;tslmain.c:228: for (word i = 0; i < act; ++i)
	inc	-2 (ix)
	jr	NZ, 00116$
	inc	-1 (ix)
	jr	00116$
00128$:
	ld	-2 (ix), e
	ld	-1 (ix), d
;tslmain.c:240: } while (act > 0);
	ld	a, -7 (ix)
	or	a, -8 (ix)
	jp	NZ, 00112$
;tslmain.c:241: close_file(handle);
	ld	a, c
	call	_close_file
00118$:
;tslmain.c:242: }
	ld	sp, ix
	pop	ix
	ret
;tslmain.c:254: void draw_str(const char* s)
;	---------------------------------
; Function draw_str
; ---------------------------------
_draw_str::
00103$:
;tslmain.c:256: for (; *s; ++s)
	ld	c, (hl)
	ld	a, c
	or	a, a
	ret	Z
;tslmain.c:257: hal_draw_char(*s);
	push	hl
	ld	a, c
	call	_hal_draw_char
	pop	hl
;tslmain.c:256: for (; *s; ++s)
	inc	hl
;tslmain.c:258: }
	jr	00103$
;tslmain.c:260: void  draw_menu_item(const char* s)
;	---------------------------------
; Function draw_menu_item
; ---------------------------------
_draw_menu_item::
;tslmain.c:262: hal_color(5, 173);
	push	hl
	ld	l, #0xad
;	spillPairReg hl
;	spillPairReg hl
	ld	a, #0x05
	call	_hal_color
	ld	a, #0x20
	call	_hal_draw_char
	ld	a, #0x20
	call	_hal_draw_char
	pop	de
;tslmain.c:265: hal_draw_char(*s);
	ld	a, (de)
	ld	c, a
	push	de
	ld	a, c
	call	_hal_draw_char
	pop	de
;tslmain.c:266: ++s;
	inc	de
;tslmain.c:267: if (*s)
	ld	a, (de)
	or	a, a
	ret	Z
;tslmain.c:269: hal_color(0, 173);
	push	de
	ld	l, #0xad
;	spillPairReg hl
;	spillPairReg hl
	xor	a, a
	call	_hal_color
	pop	de
;tslmain.c:270: draw_str(s);
	ex	de, hl
;tslmain.c:272: }
	jp	_draw_str
;tslmain.c:274: void draw_status_item(const char* key, const char* name)
;	---------------------------------
; Function draw_status_item
; ---------------------------------
_draw_status_item::
;tslmain.c:276: hal_color(5, 173);
	push	hl
	push	de
	ld	l, #0xad
;	spillPairReg hl
;	spillPairReg hl
	ld	a, #0x05
	call	_hal_color
	ld	a, #0x20
	call	_hal_draw_char
	pop	de
	pop	hl
;tslmain.c:278: draw_str(key);
	push	de
	call	_draw_str
	ld	a, #0x20
	call	_hal_draw_char
	ld	l, #0xad
;	spillPairReg hl
;	spillPairReg hl
	xor	a, a
	call	_hal_color
	pop	de
;tslmain.c:281: draw_str(name);
	ex	de, hl
	call	_draw_str
;tslmain.c:282: hal_draw_char(' ');
	ld	a, #0x20
;tslmain.c:283: }
	jp	_hal_draw_char
;tslmain.c:285: void  draw_menu()
;	---------------------------------
; Function draw_menu
; ---------------------------------
_draw_menu::
;tslmain.c:287: hal_move(0, 0);
	ld	de, #0x0000
	ld	hl, #0x0000
	call	_hal_move
;tslmain.c:288: hal_color(0, 173);
	ld	l, #0xad
;	spillPairReg hl
;	spillPairReg hl
	xor	a, a
	call	_hal_color
;tslmain.c:289: hal_rept_char(' ', W);
	ld	l, #0x50
;	spillPairReg hl
;	spillPairReg hl
	ld	a, #0x20
	call	_hal_rept_char
;tslmain.c:290: hal_move(0, 0);
	ld	de, #0x0000
	ld	hl, #0x0000
	call	_hal_move
;tslmain.c:291: draw_menu_item("\xF0");
	ld	hl, #___str_0
	call	_draw_menu_item
;tslmain.c:292: draw_menu_item("File");
	ld	hl, #___str_1
	call	_draw_menu_item
;tslmain.c:293: draw_menu_item("Edit");
	ld	hl, #___str_2
	call	_draw_menu_item
;tslmain.c:294: draw_menu_item("Search");
	ld	hl, #___str_3
	call	_draw_menu_item
;tslmain.c:295: draw_menu_item("Run");
	ld	hl, #___str_4
	call	_draw_menu_item
;tslmain.c:296: draw_menu_item("Compile");
	ld	hl, #___str_5
;tslmain.c:297: }
	jp	_draw_menu_item
___str_0:
	.db 0xf0
	.db 0x00
___str_1:
	.ascii "File"
	.db 0x00
___str_2:
	.ascii "Edit"
	.db 0x00
___str_3:
	.ascii "Search"
	.db 0x00
___str_4:
	.ascii "Run"
	.db 0x00
___str_5:
	.ascii "Compile"
	.db 0x00
;tslmain.c:299: void draw_status()
;	---------------------------------
; Function draw_status
; ---------------------------------
_draw_status::
;tslmain.c:301: hal_move(0, H - 1);
	ld	de, #0x001d
	ld	hl, #0x0000
	call	_hal_move
;tslmain.c:302: hal_color(0, 173);
	ld	l, #0xad
;	spillPairReg hl
;	spillPairReg hl
	xor	a, a
	call	_hal_color
;tslmain.c:303: hal_rept_char(' ', W);
	ld	l, #0x50
;	spillPairReg hl
;	spillPairReg hl
	ld	a, #0x20
	call	_hal_rept_char
;tslmain.c:304: hal_move(0, H - 1);
	ld	de, #0x001d
	ld	hl, #0x0000
	call	_hal_move
;tslmain.c:305: draw_status_item("F1", "Help");
	ld	de, #___str_7
	ld	hl, #___str_6
	call	_draw_status_item
;tslmain.c:306: draw_status_item("F2", "Save");
	ld	de, #___str_9
	ld	hl, #___str_8
	call	_draw_status_item
;tslmain.c:307: draw_status_item("F3", "Open");
	ld	de, #___str_11
	ld	hl, #___str_10
	call	_draw_status_item
;tslmain.c:308: draw_status_item("F9", "Compile");
	ld	de, #___str_13
	ld	hl, #___str_12
;tslmain.c:309: }
	jp	_draw_status_item
___str_6:
	.ascii "F1"
	.db 0x00
___str_7:
	.ascii "Help"
	.db 0x00
___str_8:
	.ascii "F2"
	.db 0x00
___str_9:
	.ascii "Save"
	.db 0x00
___str_10:
	.ascii "F3"
	.db 0x00
___str_11:
	.ascii "Open"
	.db 0x00
___str_12:
	.ascii "F9"
	.db 0x00
___str_13:
	.ascii "Compile"
	.db 0x00
;tslmain.c:311: void draw_brackets(byte b)
;	---------------------------------
; Function draw_brackets
; ---------------------------------
_draw_brackets::
	ld	c, a
;tslmain.c:313: hal_draw_char('[');
	push	bc
	ld	a, #0x5b
	call	_hal_draw_char
	ld	l, #0x80
;	spillPairReg hl
;	spillPairReg hl
	ld	a, #0x7a
	call	_hal_color
	pop	bc
;tslmain.c:315: hal_draw_char(b);
	ld	a, c
	call	_hal_draw_char
;tslmain.c:316: hal_color(255, 128);
	ld	l, #0x80
;	spillPairReg hl
;	spillPairReg hl
	ld	a, #0xff
	call	_hal_color
;tslmain.c:317: hal_draw_char(']');
	ld	a, #0x5d
;tslmain.c:318: }
	jp	_hal_draw_char
;tslmain.c:320: void draw_frame()
;	---------------------------------
; Function draw_frame
; ---------------------------------
_draw_frame::
;tslmain.c:322: draw_menu();
	call	_draw_menu
;tslmain.c:323: fg = 255;
	ld	hl, #_fg
	ld	(hl), #0xff
;tslmain.c:324: bg = 128;
	ld	hl, #_bg
;tslmain.c:326: hal_color(255, 128);
	ld	(hl), #0x80
	ld	l, (hl)
;	spillPairReg hl
;	spillPairReg hl
	ld	a, #0xff
	call	_hal_color
;tslmain.c:327: hal_move(0, 1);
	ld	de, #0x0001
	ld	hl, #0x0000
	call	_hal_move
;tslmain.c:328: hal_draw_char(TL);
	ld	a, (_TL+0)
	call	_hal_draw_char
;tslmain.c:329: hal_draw_char(HORZ);
	ld	a, (_HORZ+0)
	call	_hal_draw_char
;tslmain.c:330: draw_brackets(254);
	ld	a, #0xfe
	call	_draw_brackets
;tslmain.c:331: hal_rept_char(HORZ, W - 10);
	ld	a, (_HORZ+0)
;	spillPairReg hl
;	spillPairReg hl
	ld	l, #0x46
	call	_hal_rept_char
;tslmain.c:332: draw_brackets(0x12);
	ld	a, #0x12
	call	_draw_brackets
;tslmain.c:333: hal_draw_char(HORZ);
	ld	a, (_HORZ+0)
	call	_hal_draw_char
;tslmain.c:334: hal_draw_char(TR);
	ld	a, (_TR+0)
	call	_hal_draw_char
;tslmain.c:339: for (i = 2; i < (H - 2); ++i)
	ld	c, #0x02
00111$:
;tslmain.c:341: hal_color(255, 128);
	push	bc
	ld	l, #0x80
;	spillPairReg hl
;	spillPairReg hl
	ld	a, #0xff
	call	_hal_color
	pop	bc
;tslmain.c:342: hal_move(0, i);
	ld	e, c
	ld	d, #0x00
	push	bc
	ld	hl, #0x0000
	call	_hal_move
	pop	bc
;tslmain.c:343: hal_draw_char(VERT);
	ld	a, (_VERT+0)
	ld	b, a
	push	bc
	ld	a, b
	call	_hal_draw_char
	ld	l, #0x4e
;	spillPairReg hl
;	spillPairReg hl
	ld	a, #0x20
	call	_hal_rept_char
	ld	l, #0xa8
;	spillPairReg hl
;	spillPairReg hl
	ld	a, #0x80
	call	_hal_color
	pop	bc
;tslmain.c:346: if (i == 2) hal_draw_char(0x1E);
	ld	a, c
	sub	a, #0x02
	jr	NZ, 00108$
	push	bc
	ld	a, #0x1e
	call	_hal_draw_char
	pop	bc
	jr	00112$
00108$:
;tslmain.c:347: else if (i == 3) hal_draw_char(0xFE);
	ld	a, c
	sub	a, #0x03
	jr	NZ, 00105$
	push	bc
	ld	a, #0xfe
	call	_hal_draw_char
	pop	bc
	jr	00112$
00105$:
;tslmain.c:348: else if (i == (H - 3)) hal_draw_char(0x1F);
	ld	a, c
	sub	a, #0x1b
	jr	NZ, 00102$
	push	bc
	ld	a, #0x1f
	call	_hal_draw_char
	pop	bc
	jr	00112$
00102$:
;tslmain.c:349: else   hal_draw_char(0xB1);
	push	bc
	ld	a, #0xb1
	call	_hal_draw_char
	pop	bc
00112$:
;tslmain.c:339: for (i = 2; i < (H - 2); ++i)
	inc	c
	ld	a, c
	sub	a, #0x1c
	jr	C, 00111$
;tslmain.c:352: hal_color(255, 128);
	ld	l, #0x80
;	spillPairReg hl
;	spillPairReg hl
	ld	a, #0xff
	call	_hal_color
;tslmain.c:353: hal_move(0, H-2);
	ld	de, #0x001c
	ld	hl, #0x0000
	call	_hal_move
;tslmain.c:354: hal_draw_char(BL);
	ld	a, (_BL+0)
	call	_hal_draw_char
;tslmain.c:355: hal_rept_char(HORZ,20);
	ld	a, (_HORZ+0)
;	spillPairReg hl
;	spillPairReg hl
	ld	l, #0x14
	call	_hal_rept_char
;tslmain.c:356: hal_color(128, 168);
	ld	l, #0xa8
;	spillPairReg hl
;	spillPairReg hl
	ld	a, #0x80
	call	_hal_color
;tslmain.c:357: hal_draw_char(0x11);
	ld	a, #0x11
	call	_hal_draw_char
;tslmain.c:358: hal_draw_char(0xFE);
	ld	a, #0xfe
	call	_hal_draw_char
;tslmain.c:359: hal_rept_char(0xB1,W-26);
	ld	l, #0x36
;	spillPairReg hl
;	spillPairReg hl
	ld	a, #0xb1
	call	_hal_rept_char
;tslmain.c:360: hal_draw_char(0x10);
	ld	a, #0x10
	call	_hal_draw_char
;tslmain.c:361: hal_color(168, 128);
	ld	l, #0x80
;	spillPairReg hl
;	spillPairReg hl
	ld	a, #0xa8
	call	_hal_color
;tslmain.c:362: hal_draw_char(0xC4);
	ld	a, #0xc4
	call	_hal_draw_char
;tslmain.c:363: hal_draw_char(0xD9);
	ld	a, #0xd9
	call	_hal_draw_char
;tslmain.c:365: draw_status();
	call	_draw_status
;tslmain.c:366: hal_color(fg, bg);
	ld	a, (_bg+0)
	ld	l, a
;	spillPairReg hl
;	spillPairReg hl
	ld	a, (_fg+0)
;tslmain.c:367: }
	jp	_hal_color
;tslmain.c:373: byte draw_line(short logical_y)
;	---------------------------------
; Function draw_line
; ---------------------------------
_draw_line::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	iy, #-11
	add	iy, sp
	ld	sp, iy
	ld	-6 (ix), l
;tslmain.c:375: if (logical_y < 0 || logical_y >= vector_size(document)) return 0;
	ld	-5 (ix), h
	ld	b, h
	bit	7, b
	jr	NZ, 00101$
	ld	hl, (_document)
	call	_vector_size
	ld	l, -6 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -5 (ix)
;	spillPairReg hl
;	spillPairReg hl
	xor	a, a
	sbc	hl, de
	jr	C, 00102$
00101$:
	xor	a, a
	jp	00128$
00102$:
;tslmain.c:376: short visual_y = logical_y - offset.y;
	ld	hl, (#(_offset + 2) + 0)
	ld	a, -6 (ix)
	sub	a, l
	ld	c, a
	ld	a, -5 (ix)
	sbc	a, h
	ld	b, a
;tslmain.c:377: if (visual_y < 0 || visual_y >= (H - 4)) return 0;
	ld	-2 (ix), c
	ld	-1 (ix), b
	bit	7, -1 (ix)
	jr	NZ, 00104$
	ld	a, c
	sub	a, #0x1a
	ld	a, b
	rla
	ccf
	rra
	sbc	a, #0x80
	jr	C, 00105$
00104$:
	xor	a, a
	jp	00128$
00105$:
;tslmain.c:379: if (in_selection(0, logical_y))
	ld	e, -6 (ix)
	ld	d, -5 (ix)
	ld	hl, #0x0000
	call	_in_selection
	or	a, a
	jr	Z, 00108$
;tslmain.c:380: hal_color(bg, fg);
	ld	a, (_fg+0)
	ld	l, a
;	spillPairReg hl
;	spillPairReg hl
	ld	a, (_bg+0)
	call	_hal_color
00108$:
;tslmain.c:381: Vector* line = get_line(logical_y);
	ld	l, -6 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -5 (ix)
;	spillPairReg hl
;	spillPairReg hl
	call	_get_line
	ld	c, e
	ld	b, d
;tslmain.c:382: byte* data = vector_access(line, 0);
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
	inc	sp
	inc	sp
	push	de
;tslmain.c:384: hal_move(1, visual_y + 2);
	ld	e, -2 (ix)
	ld	d, -1 (ix)
	inc	de
	inc	de
	push	bc
	ld	hl, #0x0001
	call	_hal_move
	pop	bc
;tslmain.c:385: if (data)
	ld	a, -10 (ix)
	or	a, -11 (ix)
	jr	Z, 00110$
;tslmain.c:387: n = visual_mapping(line, line_mapping, 0, 0x7000);
	ld	hl, #0x7000
	push	hl
	ld	h, l
	push	hl
	ld	de, #_line_mapping
	ld	l, c
;	spillPairReg hl
;	spillPairReg hl
	ld	h, b
;	spillPairReg hl
;	spillPairReg hl
	call	_visual_mapping
	ld	-9 (ix), a
	jr	00111$
00110$:
;tslmain.c:391: hal_rept_char(' ', W - 2);
	ld	l, #0x4e
;	spillPairReg hl
;	spillPairReg hl
	ld	a, #0x20
	call	_hal_rept_char
;tslmain.c:392: return 1;
	ld	a, #0x01
	jp	00128$
00111$:
;tslmain.c:395: short x = 0, i = 0;
	xor	a, a
	ld	-4 (ix), a
	ld	-3 (ix), a
;tslmain.c:396: while (x<(W-2))
	xor	a, a
	ld	-2 (ix), a
	ld	-1 (ix), a
00125$:
	ld	a, -4 (ix)
	sub	a, #0x4e
	ld	a, -3 (ix)
	rla
	ccf
	rra
	sbc	a, #0x80
	jp	NC, 00127$
;tslmain.c:398: if (i < n)
	ld	c, -9 (ix)
	ld	b, #0x00
;tslmain.c:402: byte m = (byte)(line_mapping[i].visual - x);
	ld	e, -4 (ix)
;tslmain.c:398: if (i < n)
	ld	a, -2 (ix)
	sub	a, c
	ld	a, -1 (ix)
	sbc	a, b
	jp	PO, 00202$
	xor	a, #0x80
00202$:
	jp	P, 00123$
;tslmain.c:400: if (x < line_mapping[i].visual)
	ld	l, -2 (ix)
	ld	h, -1 (ix)
	add	hl, hl
	add	hl, hl
	ld	a, l
	add	a, #<(_line_mapping)
	ld	c, a
	ld	a, h
	adc	a, #>(_line_mapping)
	ld	b, a
	push	bc
	pop	iy
	ld	d, 2 (iy)
	ld	l, 3 (iy)
	inc	iy
	inc	iy
;	spillPairReg hl
	ld	a, -4 (ix)
	sub	a, d
	ld	a, -3 (ix)
	sbc	a, l
	jp	PO, 00203$
	xor	a, #0x80
00203$:
	jp	P, 00113$
;tslmain.c:402: byte m = (byte)(line_mapping[i].visual - x);
	ld	a, d
	sub	a, e
	ld	l, a
;	spillPairReg hl
;	spillPairReg hl
;tslmain.c:403: hal_rept_char(' ', m);
	push	bc
	push	iy
	ld	a, #0x20
	call	_hal_rept_char
	pop	iy
	pop	bc
;tslmain.c:404: x = line_mapping[i].visual;
	ld	a, 0 (iy)
	ld	-4 (ix), a
	ld	a, 1 (iy)
	ld	-3 (ix), a
00113$:
;tslmain.c:406: if (select_start.x == line_mapping[i].logical && select_start.y == logical_y)
	ld	de, (#_select_start + 0)
	ld	l, c
	ld	h, b
	ld	a, (hl)
	inc	hl
	ld	h, (hl)
;	spillPairReg hl
	ld	l, a
;	spillPairReg hl
;	spillPairReg hl
	cp	a, a
	sbc	hl, de
	jr	NZ, 00115$
	ld	hl, (#(_select_start + 2) + 0)
	ld	e, -6 (ix)
	ld	d, -5 (ix)
	cp	a, a
	sbc	hl, de
	jr	NZ, 00115$
;tslmain.c:407: hal_color(bg, fg);
	push	bc
	ld	a, (_fg+0)
	ld	l, a
;	spillPairReg hl
;	spillPairReg hl
	ld	a, (_bg+0)
	call	_hal_color
	pop	bc
00115$:
;tslmain.c:408: if (select_stop.x == line_mapping[i].logical && select_stop.y == logical_y)
	ld	de, (#_select_stop + 0)
	ld	l, c
	ld	h, b
	ld	a, (hl)
	inc	hl
	ld	h, (hl)
;	spillPairReg hl
	ld	l, a
;	spillPairReg hl
;	spillPairReg hl
	cp	a, a
	sbc	hl, de
	jr	NZ, 00118$
	ld	hl, (#(_select_stop + 2) + 0)
	ld	e, -6 (ix)
	ld	d, -5 (ix)
	cp	a, a
	sbc	hl, de
	jr	NZ, 00118$
;tslmain.c:409: hal_color(fg, bg);
	push	bc
	ld	a, (_bg+0)
	ld	l, a
;	spillPairReg hl
;	spillPairReg hl
	ld	a, (_fg+0)
	call	_hal_color
	pop	bc
00118$:
;tslmain.c:410: byte c = data[line_mapping[i].logical];
	ld	l, c
	ld	h, b
	ld	c, (hl)
	inc	hl
	ld	b, (hl)
	pop	hl
	push	hl
	add	hl, bc
	ld	a, (hl)
;tslmain.c:411: hal_draw_char(c>=32?c:' ');
	cp	a, #0x20
	jr	C, 00130$
	ld	-8 (ix), a
	ld	-7 (ix), #0x00
	jr	00131$
00130$:
	ld	-8 (ix), #0x20
	ld	-7 (ix), #0
00131$:
	ld	a, -8 (ix)
	call	_hal_draw_char
;tslmain.c:412: ++x;
	inc	-4 (ix)
	jr	NZ, 00212$
	inc	-3 (ix)
00212$:
;tslmain.c:413: ++i;
	inc	-2 (ix)
	jp	NZ,00125$
	inc	-1 (ix)
	jp	00125$
00123$:
;tslmain.c:417: if (select_stop.y == logical_y)
	ld	hl, (#(_select_stop + 2) + 0)
	ld	c, -6 (ix)
	ld	b, -5 (ix)
	cp	a, a
	sbc	hl, bc
	jr	NZ, 00121$
;tslmain.c:418: hal_color(fg, bg);
	push	de
	ld	a, (_bg+0)
	ld	l, a
;	spillPairReg hl
;	spillPairReg hl
	ld	a, (_fg+0)
	call	_hal_color
	pop	de
00121$:
;tslmain.c:419: hal_rept_char(' ', (byte)(W - 2 - x));
	ld	a, #0x4e
	sub	a, e
	ld	l, a
;	spillPairReg hl
;	spillPairReg hl
	ld	a, #0x20
	call	_hal_rept_char
;tslmain.c:420: break;
00127$:
;tslmain.c:423: return 1;
	ld	a, #0x01
00128$:
;tslmain.c:424: }
	ld	sp, ix
	pop	ix
	ret
;tslmain.c:426: void visual_cursor(byte with_offset, Cursor* vc)
;	---------------------------------
; Function visual_cursor
; ---------------------------------
_visual_cursor::
	push	ix
	ld	ix,#0
	add	ix,sp
	push	af
	dec	sp
	ld	-1 (ix), a
	inc	sp
	inc	sp
	push	de
;tslmain.c:428: Vector* line = get_line(cursor.y);
	ld	hl, (#(_cursor + 2) + 0)
	call	_get_line
	ld	c, e
	ld	b, d
;tslmain.c:429: short visual_x = logical_to_visual(line, cursor.x);
	ld	de, (#_cursor + 0)
	ld	l, c
;	spillPairReg hl
;	spillPairReg hl
	ld	h, b
;	spillPairReg hl
;	spillPairReg hl
	call	_logical_to_visual
;tslmain.c:430: vc->x = visual_x;
	pop	hl
	push	hl
	ld	(hl), e
	inc	hl
	ld	(hl), d
;tslmain.c:431: vc->y = cursor.y;
	pop	bc
	push	bc
	inc	bc
	inc	bc
	ld	de, (#(_cursor + 2) + 0)
	ld	l, c
	ld	h, b
	ld	(hl), e
	inc	hl
	ld	(hl), d
;tslmain.c:432: if (with_offset)
	ld	a, -1 (ix)
	or	a, a
	jr	Z, 00103$
;tslmain.c:434: vc->x -= offset.x;
	pop	hl
	push	hl
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	ld	hl, (#_offset + 0)
	ld	a, e
	sub	a, l
	ld	e, a
	ld	a, d
	sbc	a, h
	ld	d, a
	pop	hl
	push	hl
	ld	(hl), e
	inc	hl
	ld	(hl), d
;tslmain.c:435: vc->y -= offset.y;
	ld	l, c
	ld	h, b
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	ld	hl, (#(_offset + 2) + 0)
	ld	a, e
	sub	a, l
	ld	e, a
	ld	a, d
	sbc	a, h
	ld	d, a
	ld	a, e
	ld	(bc), a
	inc	bc
	ld	a, d
	ld	(bc), a
00103$:
;tslmain.c:437: }
	ld	sp, ix
	pop	ix
	ret
;tslmain.c:439: byte cursor_in_view()
;	---------------------------------
; Function cursor_in_view
; ---------------------------------
_cursor_in_view::
	push	ix
	ld	ix,#0
	add	ix,sp
	push	af
	push	af
;tslmain.c:442: visual_cursor(1, &v);
	ld	hl, #0
	add	hl, sp
	ld	e, l
	ld	d, h
	push	hl
	ld	a, #0x01
	call	_visual_cursor
	pop	hl
;tslmain.c:443: if (v.x >= 0 && v.y >= 0 && v.x < (W - 2) && v.y < (H - 4))
	ld	c, (hl)
	inc	hl
	ld	b, (hl)
	dec	hl
	ld	d, b
	bit	7, d
	jr	NZ, 00102$
	inc	hl
	inc	hl
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, d
;	spillPairReg hl
;	spillPairReg hl
	bit	7, h
	jr	NZ, 00102$
	ld	a, c
	sub	a, #0x4e
	ld	a, b
	rla
	ccf
	rra
	sbc	a, #0x80
	jr	NC, 00102$
	ld	a, e
	sub	a, #0x1a
	ld	a, d
	rla
	ccf
	rra
	sbc	a, #0x80
	jr	NC, 00102$
;tslmain.c:444: return 1;
	ld	a, #0x01
	jr	00106$
00102$:
;tslmain.c:445: return 0;
	xor	a, a
00106$:
;tslmain.c:446: }
	ld	sp, ix
	pop	ix
	ret
;tslmain.c:448: void eod_cursor(Cursor* c)
;	---------------------------------
; Function eod_cursor
; ---------------------------------
_eod_cursor::
;tslmain.c:450: c->x = 0;
	ld	(hl), #0x00
	inc	hl
	ld	(hl), #0x00
;tslmain.c:451: c->y = vector_size(document);
	inc	hl
	push	hl
	ld	hl, (_document)
	call	_vector_size
	pop	hl
	ld	(hl), e
	inc	hl
	ld	(hl), d
;tslmain.c:452: }
	ret
;tslmain.c:454: void redraw_all()
;	---------------------------------
; Function redraw_all
; ---------------------------------
_redraw_all::
;tslmain.c:456: redraw_start = 0;
	ld	hl, #0x0000
	ld	(_redraw_start), hl
;tslmain.c:457: redraw_stop = 0x7000;
	ld	h, #0x70
	ld	(_redraw_stop), hl
;tslmain.c:458: }
	ret
;tslmain.c:460: void calculate_new_offset()
;	---------------------------------
; Function calculate_new_offset
; ---------------------------------
_calculate_new_offset::
	push	ix
	ld	ix,#0
	add	ix,sp
	push	af
	push	af
;tslmain.c:463: visual_cursor(0,&v);
	ld	hl, #0
	add	hl, sp
	ex	de, hl
	xor	a, a
	call	_visual_cursor
;tslmain.c:464: if (v.x < (W >> 1)) v.x = 0;
	pop	bc
	push	bc
	ld	a, c
	sub	a, #0x28
	ld	a, b
	rla
	ccf
	rra
	sbc	a, #0x80
	jr	NC, 00102$
	xor	a, a
	ld	-4 (ix), a
	ld	-3 (ix), a
	jr	00103$
00102$:
;tslmain.c:465: else offset.x = v.x - (W >> 1);
	ld	a, c
	add	a, #0xd8
	ld	c, a
	ld	a, b
	adc	a, #0xff
	ld	b, a
	ld	(_offset), bc
00103$:
;tslmain.c:466: if (v.y < (H >> 1)) offset.y = 0;
	pop	hl
	pop	bc
	push	bc
	push	hl
	ld	a, c
	sub	a, #0x0f
	ld	a, b
	rla
	ccf
	rra
	sbc	a, #0x80
	jr	NC, 00105$
	ld	hl, #0x0000
	ld	((_offset + 2)), hl
	jr	00106$
00105$:
;tslmain.c:467: else offset.y = v.y - (H >> 1);
	ld	a, c
	add	a, #0xf1
	ld	c, a
	ld	a, b
	adc	a, #0xff
	ld	b, a
	ld	((_offset + 2)), bc
00106$:
;tslmain.c:468: draw_frame();
	call	_draw_frame
;tslmain.c:469: redraw_all();
	call	_redraw_all
;tslmain.c:470: }
	ld	sp, ix
	pop	ix
	ret
;tslmain.c:472: void place_cursor()
;	---------------------------------
; Function place_cursor
; ---------------------------------
_place_cursor::
	push	ix
	ld	ix,#0
	add	ix,sp
	push	af
	push	af
;tslmain.c:474: if (cursor_in_view() == 0) calculate_new_offset();
	call	_cursor_in_view
	or	a, a
	jr	NZ, 00102$
	call	_calculate_new_offset
00102$:
;tslmain.c:476: visual_cursor(1,&v);
	ld	hl, #0
	add	hl, sp
	ex	de, hl
	ld	a, #0x01
	call	_visual_cursor
;tslmain.c:477: hal_move(v.x + 1, v.y + 2);
	pop	hl
	pop	de
	push	de
	push	hl
	inc	de
	inc	de
	pop	hl
	push	hl
	inc	hl
	call	_hal_move
;tslmain.c:478: }
	ld	sp, ix
	pop	ix
	ret
;tslmain.c:480: void decimal_string(byte* buffer, short length, word value)
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
;tslmain.c:482: short index = length - 1;
	dec	de
;tslmain.c:483: while (value > 0)
00101$:
	ld	a, 5 (ix)
	or	a, 4 (ix)
	jr	Z, 00112$
;tslmain.c:486: dm.a = value;
	ld	a, 4 (ix)
	ld	-5 (ix), a
	ld	a, 5 (ix)
	ld	-4 (ix), a
;tslmain.c:487: dm.b = 10;
	ld	-3 (ix), #0x0a
;tslmain.c:488: div_mod(&dm);
	push	bc
	push	de
	ld	hl, #4
	add	hl, sp
	call	_div_mod
	pop	de
	pop	bc
;tslmain.c:489: buffer[index--] = (byte)(48 + dm.b);
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
;tslmain.c:490: value=dm.a;
	ld	a, -5 (ix)
	ld	4 (ix), a
	ld	a, -4 (ix)
	ld	5 (ix), a
	jr	00101$
;tslmain.c:492: while (index >= 0)
00112$:
00104$:
;	spillPairReg hl
;	spillPairReg hl
	ld	h, d
;	spillPairReg hl
;	spillPairReg hl
	bit	7, h
	jr	NZ, 00107$
;tslmain.c:493: buffer[index--] = 48;
	ld	l, c
	ld	h, b
	add	hl, de
	dec	de
	ld	(hl), #0x30
	jr	00104$
00107$:
;tslmain.c:494: }
	ld	sp, ix
	pop	ix
	pop	hl
	pop	af
	jp	(hl)
;tslmain.c:496: void draw_number(word value)
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
;tslmain.c:499: buffer[7] = 0;
	ld	-1 (ix), #0x00
;tslmain.c:500: decimal_string(buffer, 7, value);
	push	de
	ld	de, #0x0007
	ld	hl, #2
	add	hl, sp
	call	_decimal_string
;tslmain.c:501: byte* ptr = buffer;
	ld	hl, #0
	add	hl, sp
;tslmain.c:504: hal_draw_char(*ptr);
00104$:
;tslmain.c:502: for (; *ptr == 48; ++ptr);
	ld	a, (hl)
	sub	a, #0x30
	jr	NZ, 00114$
	inc	hl
	jr	00104$
00114$:
00107$:
;tslmain.c:503: for (; *ptr; ++ptr)
	ld	c, (hl)
	ld	a, c
	or	a, a
	jr	Z, 00109$
;tslmain.c:504: hal_draw_char(*ptr);
	push	hl
	ld	a, c
	call	_hal_draw_char
	pop	hl
;tslmain.c:503: for (; *ptr; ++ptr)
	inc	hl
	jr	00107$
00109$:
;tslmain.c:505: }
	ld	sp, ix
	pop	ix
	ret
;tslmain.c:507: void draw_cursor_position()
;	---------------------------------
; Function draw_cursor_position
; ---------------------------------
_draw_cursor_position::
;tslmain.c:509: hal_move(5, H - 2);
	ld	de, #0x001c
	ld	hl, #0x0005
	call	_hal_move
;tslmain.c:511: hal_draw_char(' ');
	ld	a, #0x20
	call	_hal_draw_char
;tslmain.c:512: draw_number(cursor.x + 1);
	ld	hl, (#_cursor + 0)
	inc	hl
	call	_draw_number
;tslmain.c:513: hal_draw_char(':');
	ld	a, #0x3a
	call	_hal_draw_char
;tslmain.c:514: draw_number(cursor.y + 1);
	ld	hl, (#(_cursor + 2) + 0)
	inc	hl
	call	_draw_number
;tslmain.c:515: hal_draw_char(' ');
	ld	a, #0x20
	call	_hal_draw_char
;tslmain.c:517: for (byte i = 0; i < 5; ++i)
	ld	c, #0x00
00103$:
	ld	a, c
	sub	a, #0x05
	ret	NC
;tslmain.c:518: hal_draw_char(HORZ);
	ld	a, (_HORZ+0)
	ld	b, a
	push	bc
	ld	a, b
	call	_hal_draw_char
	pop	bc
;tslmain.c:517: for (byte i = 0; i < 5; ++i)
	inc	c
;tslmain.c:519: }
	jr	00103$
;tslmain.c:521: void draw_screen()
;	---------------------------------
; Function draw_screen
; ---------------------------------
_draw_screen::
;tslmain.c:523: if (offset.y > redraw_start)
	ld	bc, (#(_offset + 2) + 0)
	ld	hl, #_redraw_start
	ld	a, (hl)
	inc	hl
	sub	a, c
	ld	a, (hl)
	sbc	a, b
	jp	PO, 00132$
	xor	a, #0x80
00132$:
	jp	P, 00102$
;tslmain.c:525: redraw_start = offset.y;
	ld	(_redraw_start), bc
00102$:
;tslmain.c:527: for (short y = redraw_start; y < redraw_stop; ++y)
	ld	bc, (_redraw_start)
00107$:
	ld	hl, #_redraw_stop
	ld	a, c
	sub	a, (hl)
	inc	hl
	ld	a, b
	sbc	a, (hl)
	jp	PO, 00133$
	xor	a, #0x80
00133$:
	jp	P, 00105$
;tslmain.c:529: if (!draw_line(y)) break;
	push	bc
	ld	l, c
;	spillPairReg hl
;	spillPairReg hl
	ld	h, b
;	spillPairReg hl
;	spillPairReg hl
	call	_draw_line
	pop	bc
	or	a, a
	jr	Z, 00105$
;tslmain.c:527: for (short y = redraw_start; y < redraw_stop; ++y)
	inc	bc
	jr	00107$
00105$:
;tslmain.c:531: redraw_stop = redraw_start;
	ld	hl, (_redraw_start)
	ld	(_redraw_stop), hl
;tslmain.c:532: draw_cursor_position();
	call	_draw_cursor_position
;tslmain.c:533: place_cursor();
;tslmain.c:534: }
	jp	_place_cursor
;tslmain.c:536: word visual_to_logical(Vector* line, word visual)
;	---------------------------------
; Function visual_to_logical
; ---------------------------------
_visual_to_logical::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	iy, #-10
	add	iy, sp
	ld	sp, iy
	ld	-6 (ix), e
	ld	-5 (ix), d
;tslmain.c:538: word n = vector_size(line);
	push	hl
	call	_vector_size
	pop	hl
	inc	sp
	inc	sp
	push	de
;tslmain.c:539: const byte* data = vector_access(line, 0);
	ld	de, #0x0000
	call	_vector_access
	ld	-8 (ix), e
	ld	-7 (ix), d
;tslmain.c:540: word x = 0;
	ld	bc, #0x0000
;tslmain.c:541: for (word i = 0; i < n; ++i)
	xor	a, a
	ld	-2 (ix), a
	ld	-1 (ix), a
	xor	a, a
	ld	-4 (ix), a
	ld	-3 (ix), a
00110$:
	ld	a, -4 (ix)
	sub	a, -10 (ix)
	ld	a, -3 (ix)
	sbc	a, -9 (ix)
	jr	NC, 00108$
;tslmain.c:543: if (x >= visual) return i;
	ld	a, c
	sub	a, -6 (ix)
	ld	a, b
	sbc	a, -5 (ix)
	jr	C, 00102$
	ld	e, -2 (ix)
	ld	d, -1 (ix)
	jr	00112$
00102$:
;tslmain.c:544: ++x;
	inc	bc
;tslmain.c:545: if (data[i] == 9)
	ld	a, -4 (ix)
	add	a, -8 (ix)
	ld	e, a
	ld	a, -3 (ix)
	adc	a, -7 (ix)
	ld	d, a
	ld	a, (de)
	sub	a, #0x09
	jr	NZ, 00111$
;tslmain.c:547: while ((x & 3) != 0) ++x;
	ld	-2 (ix), c
	ld	-1 (ix), b
00103$:
	ld	a, -2 (ix)
	and	a, #0x03
	jr	Z, 00119$
	inc	-2 (ix)
	jr	NZ, 00103$
	inc	-1 (ix)
	jr	00103$
00119$:
	ld	c, -2 (ix)
	ld	b, -1 (ix)
00111$:
;tslmain.c:541: for (word i = 0; i < n; ++i)
	inc	-4 (ix)
	jr	NZ, 00148$
	inc	-3 (ix)
00148$:
	ld	a, -4 (ix)
	ld	-2 (ix), a
	ld	a, -3 (ix)
	ld	-1 (ix), a
	jr	00110$
00108$:
;tslmain.c:550: return n;
	pop	de
	push	de
00112$:
;tslmain.c:551: }
	ld	sp, ix
	pop	ix
	ret
;tslmain.c:553: void move_x_cursor(short dx)
;	---------------------------------
; Function move_x_cursor
; ---------------------------------
_move_x_cursor::
	ld	c, l
	ld	b, h
;tslmain.c:555: if (dx==0 || cursor.y<0 || cursor.y >= vector_size(document)) return;
	ld	a, b
	or	a, c
	ret	Z
	ld	hl, (#(_cursor + 2) + 0)
	ld	d, h
	bit	7, d
	ret	NZ
	push	hl
	push	bc
	ld	hl, (_document)
	call	_vector_size
	pop	bc
	pop	hl
	xor	a, a
	sbc	hl, de
	ret	NC
;tslmain.c:556: Vector* line = get_line(cursor.y);
	ld	hl, (#(_cursor + 2) + 0)
	push	bc
	call	_get_line
	pop	bc
;tslmain.c:557: cursor.x += dx;
	ld	hl, (#_cursor + 0)
	add	hl, bc
	ld	c, l
	ld	b, h
	ld	(_cursor), bc
;tslmain.c:558: if (cursor.x < 0) cursor.x = 0;
	bit	7, b
	jr	Z, 00106$
	ld	hl, #0x0000
	ld	(_cursor), hl
00106$:
;tslmain.c:559: short n = vector_size(line);
	ex	de, hl
	call	_vector_size
;tslmain.c:560: if (cursor.x >= n) cursor.x = n;
	ld	hl, (#_cursor + 0)
	ld	a, l
	sub	a, e
	ld	a, h
	sbc	a, d
	jp	PO, 00131$
	xor	a, #0x80
00131$:
	jp	M,_place_cursor
	ld	(_cursor), de
;tslmain.c:561: place_cursor();
;tslmain.c:562: }
	jp	_place_cursor
;tslmain.c:577: byte is_move_key(word key)
;	---------------------------------
; Function is_move_key
; ---------------------------------
_is_move_key::
;tslmain.c:579: if (key >= 0x100)
;tslmain.c:581: byte b = (key >> 8) & 0x3F;
	ld	a,h
	cp	a,#0x01
	jr	C, 00102$
;tslmain.c:582: return (b > 0 && b < 9);
	and	a,#0x3f
	jr	Z, 00105$
	sub	a, #0x09
	jr	C, 00106$
00105$:
	xor	a, a
	ret
00106$:
	ld	a, #0x01
	ret
00102$:
;tslmain.c:584: return 0;
	xor	a, a
;tslmain.c:585: }
	ret
;tslmain.c:587: void join_prev_line()
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
;tslmain.c:589: Vector* prev_line = get_line(cursor.y - 1);
	ld	hl, (#(_cursor + 2) + 0)
	dec	hl
	call	_get_line
	inc	sp
	inc	sp
	push	de
;tslmain.c:590: Vector* cur_line = get_line(cursor.y);
	ld	hl, (#(_cursor + 2) + 0)
	call	_get_line
;tslmain.c:591: word m = vector_size(prev_line);
	pop	hl
	push	hl
	push	de
	call	_vector_size
	pop	hl
	ld	-6 (ix), e
	ld	-5 (ix), d
;tslmain.c:592: word n = vector_size(cur_line);
	push	hl
	call	_vector_size
	pop	hl
	ld	-4 (ix), e
	ld	-3 (ix), d
;tslmain.c:593: byte* data = vector_access(cur_line, 0);
	push	hl
	ld	de, #0x0000
	call	_vector_access
	pop	hl
	ld	-2 (ix), e
	ld	-1 (ix), d
;tslmain.c:594: for (word i = 0; i < n; ++i)
	ld	bc, #0x0000
00103$:
	ld	a, c
	sub	a, -4 (ix)
	ld	a, b
	sbc	a, -3 (ix)
	jr	NC, 00101$
;tslmain.c:595: vector_push(prev_line, &data[i]);
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
;tslmain.c:594: for (word i = 0; i < n; ++i)
	inc	bc
	jr	00103$
00101$:
;tslmain.c:596: vector_shut(cur_line);
	call	_vector_shut
;tslmain.c:597: vector_erase(document, cursor.y);
	ld	de, (#(_cursor + 2) + 0)
	ld	hl, (_document)
	call	_vector_erase
;tslmain.c:598: cursor.y--;
	ld	bc, (#(_cursor + 2) + 0)
	dec	bc
	ld	((_cursor + 2)), bc
;tslmain.c:599: cursor.x = logical_to_visual(prev_line, m);
	pop	hl
	pop	de
	push	de
	push	hl
	call	_logical_to_visual
	ld	(_cursor), de
;tslmain.c:600: }
	ld	sp, ix
	pop	ix
	ret
;tslmain.c:602: byte delete_single_line_selection()
;	---------------------------------
; Function delete_single_line_selection
; ---------------------------------
_delete_single_line_selection::
;tslmain.c:604: Vector* line = get_line(select_start.y);
	ld	hl, (#(_select_start + 2) + 0)
	call	_get_line
	ld	c, e
	ld	b, d
;tslmain.c:605: vector_erase_range(line, select_start.x, select_stop.x);
	ld	de, (#_select_stop + 0)
	ld	hl, (#_select_start + 0)
	ex	de, hl
	push	hl
	ld	l, c
;	spillPairReg hl
;	spillPairReg hl
	ld	h, b
;	spillPairReg hl
;	spillPairReg hl
	call	_vector_erase_range
;tslmain.c:606: cursor = select_start;
	ld	de, #_cursor
	ld	hl, #_select_start
	ld	bc, #0x0004
	ldir
;tslmain.c:607: redraw_line(select_start.y);
	ld	hl, (#(_select_start + 2) + 0)
	call	_redraw_line
;tslmain.c:608: select_stop = select_start;
	ld	de, #_select_stop
	ld	hl, #_select_start
	ld	bc, #0x0004
	ldir
;tslmain.c:609: return 1;
	ld	a, #0x01
;tslmain.c:610: }
	ret
;tslmain.c:612: byte delete_selection()
;	---------------------------------
; Function delete_selection
; ---------------------------------
_delete_selection::
	push	ix
	ld	ix,#0
	add	ix,sp
	push	af
;tslmain.c:614: if (select_start.y == select_stop.y)
	ld	bc, (#(_select_start + 2) + 0)
	ld	hl, (#(_select_stop + 2) + 0)
	cp	a, a
	sbc	hl, bc
	jr	NZ, 00102$
;tslmain.c:615: return delete_single_line_selection();
	call	_delete_single_line_selection
	jp	00113$
00102$:
;tslmain.c:616: Vector* line = get_line(select_start.y);
	ld	l, c
;	spillPairReg hl
;	spillPairReg hl
	ld	h, b
;	spillPairReg hl
;	spillPairReg hl
	call	_get_line
	ld	c, e
	ld	b, d
;tslmain.c:617: word n = vector_size(line);
	push	bc
	ld	l, c
;	spillPairReg hl
;	spillPairReg hl
	ld	h, b
;	spillPairReg hl
;	spillPairReg hl
	call	_vector_size
	pop	bc
;tslmain.c:618: vector_erase_range(line, select_start.x, n);
	ld	hl, (#_select_start + 0)
	ex	de, hl
	push	hl
	ld	l, c
;	spillPairReg hl
;	spillPairReg hl
	ld	h, b
;	spillPairReg hl
;	spillPairReg hl
	call	_vector_erase_range
;tslmain.c:619: if ((select_stop.y - select_start.y) > 1)
	ld	bc, (#(_select_stop + 2) + 0)
	ld	hl, #(_select_start + 2)
	ld	a, (hl)
	ld	-2 (ix), a
	inc	hl
	ld	a, (hl)
	ld	-1 (ix), a
	ld	a, c
	sub	a, -2 (ix)
	ld	c, a
	ld	a, b
	sbc	a, -1 (ix)
	ld	b, a
	ld	a, #0x01
	cp	a, c
	ld	a, #0x00
	sbc	a, b
	jp	PO, 00148$
	xor	a, #0x80
00148$:
	jp	P, 00105$
;tslmain.c:621: for (short y = select_start.y + 1; y < select_stop.y; ++y)
	pop	bc
	push	bc
	inc	bc
	inc	sp
	inc	sp
	push	bc
00111$:
	ld	bc, (#(_select_stop + 2) + 0)
	ld	a, -2 (ix)
	sub	a, c
	ld	a, -1 (ix)
	sbc	a, b
	jp	PO, 00149$
	xor	a, #0x80
00149$:
	jp	P, 00103$
;tslmain.c:623: line = get_line(y);
	pop	hl
	push	hl
	call	_get_line
;tslmain.c:624: vector_shut(line);
	ex	de, hl
	call	_vector_shut
;tslmain.c:621: for (short y = select_start.y + 1; y < select_stop.y; ++y)
	inc	-2 (ix)
	jr	NZ, 00111$
	inc	-1 (ix)
	jr	00111$
00103$:
;tslmain.c:626: vector_erase_range(document, select_start.y + 1, select_stop.y);
	ld	de, (#(_select_start + 2) + 0)
	inc	de
	push	bc
	ld	hl, (_document)
	call	_vector_erase_range
;tslmain.c:627: select_stop.y = select_start.y + 1;
	ld	bc, (#(_select_start + 2) + 0)
	inc	bc
	ld	((_select_stop + 2)), bc
00105$:
;tslmain.c:629: if (select_stop.x > 0)
	ld	hl, (#_select_stop + 0)
	xor	a, a
	cp	a, l
	sbc	a, h
	jp	PO, 00151$
	xor	a, #0x80
00151$:
	jp	P, 00107$
;tslmain.c:631: line = get_line(select_stop.y);
	ld	hl, (#(_select_stop + 2) + 0)
	call	_get_line
	ld	c, e
	ld	b, d
;tslmain.c:632: n = vector_size(line);
	push	bc
	ld	l, c
;	spillPairReg hl
;	spillPairReg hl
	ld	h, b
;	spillPairReg hl
;	spillPairReg hl
	call	_vector_size
	pop	bc
;tslmain.c:633: vector_erase_range(line, 0, select_stop.x);
	ld	hl, (#_select_stop + 0)
	push	hl
	ld	de, #0x0000
	ld	l, c
;	spillPairReg hl
;	spillPairReg hl
	ld	h, b
;	spillPairReg hl
;	spillPairReg hl
	call	_vector_erase_range
00107$:
;tslmain.c:614: if (select_start.y == select_stop.y)
	ld	hl, #(_select_stop + 2)
	ld	a, (hl)
	ld	-2 (ix), a
	inc	hl
	ld	a, (hl)
	ld	-1 (ix), a
;tslmain.c:635: if (select_stop.y > select_start.y)
	ld	hl, (#(_select_start + 2) + 0)
	ld	a, l
	sub	a, -2 (ix)
	ld	a, h
	sbc	a, -1 (ix)
	jp	PO, 00152$
	xor	a, #0x80
00152$:
	jp	P, 00109$
;tslmain.c:637: cursor.y = select_stop.y;
	ld	hl, #(_cursor + 2)
	ld	a, -2 (ix)
	ld	(hl), a
	inc	hl
	ld	a, -1 (ix)
	ld	(hl), a
;tslmain.c:638: cursor.x = 0;
	ld	hl, #0x0000
	ld	(_cursor), hl
;tslmain.c:639: join_prev_line();
	call	_join_prev_line
00109$:
;tslmain.c:641: cursor = select_start;
	ld	de, #_cursor
	ld	hl, #_select_start
	ld	bc, #0x0004
	ldir
;tslmain.c:642: redraw_start = 0;
	ld	hl, #0x0000
	ld	(_redraw_start), hl
;tslmain.c:643: redraw_stop = 0x7000;
	ld	h, #0x70
	ld	(_redraw_stop), hl
;tslmain.c:644: select_stop = select_start;
	ld	de, #_select_stop
	ld	hl, #_select_start
	ld	bc, #0x0004
	ldir
;tslmain.c:645: return 0;
	xor	a, a
00113$:
;tslmain.c:646: }
	ld	sp, ix
	pop	ix
	ret
;tslmain.c:648: byte do_delete()
;	---------------------------------
; Function do_delete
; ---------------------------------
_do_delete::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	hl, #-10
	add	hl, sp
	ld	sp, hl
;tslmain.c:650: if (valid_select()) return delete_selection();
	call	_valid_select
	ld	-1 (ix), a
	or	a, a
	jr	Z, 00102$
	call	_delete_selection
	jp	00112$
00102$:
;tslmain.c:651: Vector* line = get_line(cursor.y);
	ld	hl, (#(_cursor + 2) + 0)
	call	_get_line
	inc	sp
	inc	sp
	push	de
;tslmain.c:652: if (cursor.x < vector_size(line))
	ld	hl, (#_cursor + 0)
	ex	de,hl
	pop	hl
	push	hl
	push	de
	call	_vector_size
	pop	hl
	xor	a, a
	sbc	hl, de
	jr	NC, 00107$
;tslmain.c:654: vector_erase(line, cursor.x);
	ld	de, (#_cursor + 0)
	pop	hl
	push	hl
	call	_vector_erase
	jp	00108$
00107$:
;tslmain.c:657: if (cursor.y < (vector_size(document)-1))
	ld	hl, (#(_cursor + 2) + 0)
	push	hl
	ld	hl, (_document)
	call	_vector_size
	pop	hl
	dec	de
	xor	a, a
	sbc	hl, de
	jr	NC, 00108$
;tslmain.c:659: Vector* next_line = get_line(cursor.y + 1);
	ld	hl, (#(_cursor + 2) + 0)
	inc	hl
	call	_get_line
	ld	-8 (ix), e
	ld	-7 (ix), d
;tslmain.c:660: word n = vector_size(next_line);
	pop	de
	pop	hl
	push	hl
	push	de
	call	_vector_size
	ld	-6 (ix), e
	ld	-5 (ix), d
;tslmain.c:661: byte* data = vector_access(next_line, 0);
	ld	de, #0x0000
	ld	l, -8 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -7 (ix)
;	spillPairReg hl
;	spillPairReg hl
	call	_vector_access
	ld	-4 (ix), e
	ld	-3 (ix), d
;tslmain.c:662: for (word j = 0; j < n; ++j)
	xor	a, a
	ld	-2 (ix), a
	ld	-1 (ix), a
00110$:
	ld	a, -2 (ix)
	sub	a, -6 (ix)
	ld	a, -1 (ix)
	sbc	a, -5 (ix)
	jr	NC, 00103$
;tslmain.c:663: vector_push(line, &data[j]);
	ld	a, -4 (ix)
	add	a, -2 (ix)
	ld	e, a
	ld	a, -3 (ix)
	adc	a, -1 (ix)
	ld	d, a
	pop	hl
	push	hl
	call	_vector_push
;tslmain.c:662: for (word j = 0; j < n; ++j)
	inc	-2 (ix)
	jr	NZ, 00110$
	inc	-1 (ix)
	jr	00110$
00103$:
;tslmain.c:664: vector_shut(next_line);
	pop	de
	pop	hl
	push	hl
	push	de
	call	_vector_shut
;tslmain.c:665: vector_erase(document, cursor.y + 1);
	ld	de, (#(_cursor + 2) + 0)
	inc	de
	ld	hl, (_document)
	call	_vector_erase
;tslmain.c:666: return 0; /* Indicate redraw from line to end of screen */
	xor	a, a
	jr	00112$
00108$:
;tslmain.c:668: return 1;
	ld	a, #0x01
00112$:
;tslmain.c:669: }
	ld	sp, ix
	pop	ix
	ret
;tslmain.c:671: void backspace()
;	---------------------------------
; Function backspace
; ---------------------------------
_backspace::
;tslmain.c:673: move_x_cursor(-1);
	ld	hl, #0xffff
	call	_move_x_cursor
;tslmain.c:674: do_delete();
;tslmain.c:675: }
	jp	_do_delete
;tslmain.c:677: void add_enter()
;	---------------------------------
; Function add_enter
; ---------------------------------
_add_enter::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	hl, #-6
	add	hl, sp
	ld	sp, hl
;tslmain.c:679: if (insert)
	ld	a, (_insert+0)
	or	a, a
	jp	Z, 00107$
;tslmain.c:681: Vector* cur_line = get_line(cursor.y);
	ld	hl, (#(_cursor + 2) + 0)
	call	_get_line
	ld	c, e
	ld	b, d
;tslmain.c:682: word n = vector_size(cur_line);
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
;tslmain.c:683: byte* data = vector_access(cur_line, 0);
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
;tslmain.c:684: Vector* next_line = vector_new(1);
	push	bc
	ld	hl, #0x0001
	call	_vector_new
	pop	bc
	inc	sp
	inc	sp
	push	de
;tslmain.c:685: vector_insert(document, cursor.y + 1, &next_line);
	ld	de, (#(_cursor + 2) + 0)
	inc	de
	push	bc
	ld	hl, #2
	add	hl, sp
	push	hl
	ld	hl, (_document)
	call	_vector_insert
	pop	bc
;tslmain.c:686: for (word j = cursor.x; j < n; ++j)
	ld	hl, (#_cursor + 0)
00105$:
	ld	a, l
	sub	a, -4 (ix)
	ld	a, h
	sbc	a, -3 (ix)
	jr	NC, 00101$
;tslmain.c:687: vector_push(next_line, &data[j]);
	ld	a, -2 (ix)
	add	a, l
	ld	e, a
	ld	a, -1 (ix)
	adc	a, h
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
;tslmain.c:686: for (word j = cursor.x; j < n; ++j)
	inc	hl
	jr	00105$
00101$:
;tslmain.c:688: vector_erase_range(cur_line, cursor.x, n);
	ld	de, (#_cursor + 0)
	ld	l, -4 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -3 (ix)
;	spillPairReg hl
;	spillPairReg hl
	push	hl
	ld	l, c
;	spillPairReg hl
;	spillPairReg hl
	ld	h, b
;	spillPairReg hl
;	spillPairReg hl
	call	_vector_erase_range
;tslmain.c:689: cursor.y++;
	ld	bc, (#(_cursor + 2) + 0)
	inc	bc
	ld	((_cursor + 2)), bc
;tslmain.c:690: cursor.x = 0;
	ld	hl, #0x0000
	ld	(_cursor), hl
00107$:
;tslmain.c:692: }
	ld	sp, ix
	pop	ix
	ret
;tslmain.c:694: void add_char(byte c)
;	---------------------------------
; Function add_char
; ---------------------------------
_add_char::
	push	ix
	ld	ix,#0
	add	ix,sp
	dec	sp
;tslmain.c:696: if (c == 10 || c == 13)
	ld	-1 (ix), a
	sub	a, #0x0a
	jr	Z, 00107$
	ld	a, -1 (ix)
	sub	a, #0x0d
	jr	NZ, 00108$
00107$:
;tslmain.c:698: add_enter();
	call	_add_enter
	jr	00111$
00108$:
;tslmain.c:702: Vector* line = get_line(cursor.y);
	ld	hl, (#_cursor + 2)
	call	_get_line
	ld	c, e
	ld	b, d
;tslmain.c:703: if (cursor.x >= vector_size(line)) vector_push(line, &c);
	ld	hl, (#_cursor + 0)
	push	hl
	push	bc
	ld	l, c
;	spillPairReg hl
;	spillPairReg hl
	ld	h, b
;	spillPairReg hl
;	spillPairReg hl
	call	_vector_size
	pop	bc
	pop	hl
	xor	a, a
	sbc	hl, de
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
	jr	00106$
00105$:
	ld	de, (#_cursor + 0)
;tslmain.c:706: if (insert)
	ld	a, (_insert+0)
	or	a, a
	jr	Z, 00102$
;tslmain.c:708: vector_insert(line, cursor.x, &c);
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
	jr	00106$
00102$:
;tslmain.c:712: vector_set(line, cursor.x, &c);
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
00106$:
;tslmain.c:715: ++cursor.x;
	ld	bc, (#_cursor + 0)
	inc	bc
	ld	(_cursor), bc
00111$:
;tslmain.c:717: }
	inc	sp
	pop	ix
	ret
;tslmain.c:719: word getkey()
;	---------------------------------
; Function getkey
; ---------------------------------
_getkey::
;tslmain.c:724: return hal_getkey();
;tslmain.c:725: }
	jp	_hal_getkey
;tslmain.c:727: void move_y(short dy)
;	---------------------------------
; Function move_y
; ---------------------------------
_move_y::
	ld	c, l
	ld	b, h
;tslmain.c:729: Vector* line = get_line(cursor.y);
	ld	hl, (#(_cursor + 2) + 0)
	push	bc
	call	_get_line
	pop	bc
	push	de
	pop	iy
;tslmain.c:730: short vx = logical_to_visual(line, cursor.x);
	ld	de, (#_cursor + 0)
	push	bc
	push	iy
	pop	hl
	call	_logical_to_visual
	pop	bc
;tslmain.c:731: cursor.y += dy;
	ld	hl, (#(_cursor + 2) + 0)
	add	hl, bc
	ld	c, l
	ld	b, h
	ld	((_cursor + 2)), bc
;tslmain.c:732: line = get_line(cursor.y);
	push	de
	ld	l, c
;	spillPairReg hl
;	spillPairReg hl
	ld	h, b
;	spillPairReg hl
;	spillPairReg hl
	call	_get_line
	ex	de, hl
	pop	de
;tslmain.c:733: cursor.x = visual_to_logical(line, vx);
	call	_visual_to_logical
	ld	(_cursor), de
;tslmain.c:734: }
	ret
;tslmain.c:736: void clipboard_copy()
;	---------------------------------
; Function clipboard_copy
; ---------------------------------
_clipboard_copy::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	hl, #-9
	add	hl, sp
	ld	sp, hl
;tslmain.c:738: if (!valid_select()) return;
	call	_valid_select
	or	a, a
	jp	Z,00120$
;tslmain.c:739: vector_clear(clipboard);
	ld	hl, (_clipboard)
	call	_vector_clear
;tslmain.c:740: for (short y = select_start.y; y <= select_stop.y; ++y)
	ld	hl, #(_select_start + 2)
	ld	a, (hl)
	ld	-2 (ix), a
	inc	hl
	ld	a, (hl)
	ld	-1 (ix), a
00119$:
	ld	hl, (#(_select_stop + 2) + 0)
	ld	a, l
	sub	a, -2 (ix)
	ld	a, h
	sbc	a, -1 (ix)
	jp	PO, 00174$
	xor	a, #0x80
00174$:
	jp	M, 00120$
;tslmain.c:742: Vector* line = get_line(y);
	ld	l, -2 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -1 (ix)
;	spillPairReg hl
;	spillPairReg hl
	call	_get_line
	ld	-8 (ix), e
;tslmain.c:743: if (!line) continue;
	ld	-7 (ix), d
	ld	a, d
	or	a, -8 (ix)
	jp	Z, 00113$
;tslmain.c:744: short start = 0, stop=vector_size(line);
	xor	a, a
	ld	-6 (ix), a
	ld	-5 (ix), a
	ld	l, -8 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -7 (ix)
;	spillPairReg hl
;	spillPairReg hl
	call	_vector_size
	ld	-4 (ix), e
	ld	-3 (ix), d
;tslmain.c:745: if (y == select_start.y)
	ld	hl, (#(_select_start + 2) + 0)
	ld	c, -2 (ix)
	ld	b, -1 (ix)
	cp	a, a
	sbc	hl, bc
	jr	NZ, 00106$
;tslmain.c:747: start = select_start.x;
	ld	hl, #_select_start
	ld	a, (hl)
	ld	-6 (ix), a
	inc	hl
	ld	a, (hl)
	ld	-5 (ix), a
00106$:
;tslmain.c:749: if (y == select_stop.y && select_stop.x < stop)
	ld	hl, (#(_select_stop + 2) + 0)
	ld	c, -2 (ix)
	ld	b, -1 (ix)
	cp	a, a
	sbc	hl, bc
	jr	NZ, 00108$
	ld	hl, (#_select_stop + 0)
	ld	a, l
	sub	a, -4 (ix)
	ld	a, h
	sbc	a, -3 (ix)
	jp	PO, 00179$
	xor	a, #0x80
00179$:
	jp	P, 00108$
;tslmain.c:750: stop = select_stop.x;
	ld	-4 (ix), l
	ld	-3 (ix), h
00108$:
;tslmain.c:751: byte* data = vector_access(line, 0);
	ld	de, #0x0000
	ld	l, -8 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -7 (ix)
;	spillPairReg hl
;	spillPairReg hl
	call	_vector_access
	ex	de, hl
;tslmain.c:752: for (short x = start; x < stop; ++x)
	ld	c, -6 (ix)
	ld	b, -5 (ix)
00116$:
	ld	a, c
	sub	a, -4 (ix)
	ld	a, b
	sbc	a, -3 (ix)
	jp	PO, 00180$
	xor	a, #0x80
00180$:
	jp	P, 00110$
;tslmain.c:754: vector_push(clipboard, &(data[x]));
	ld	a, l
	add	a, c
	ld	e, a
	ld	a, h
	adc	a, b
	ld	d, a
	push	hl
	push	bc
	ld	hl, (_clipboard)
	call	_vector_push
	pop	bc
	pop	hl
;tslmain.c:752: for (short x = start; x < stop; ++x)
	inc	bc
	jr	00116$
00110$:
;tslmain.c:756: if (y < select_stop.y)
	ld	hl, (#(_select_stop + 2) + 0)
	ld	a, -2 (ix)
	sub	a, l
	ld	a, -1 (ix)
	sbc	a, h
	jp	PO, 00181$
	xor	a, #0x80
00181$:
	jp	P, 00113$
;tslmain.c:758: byte enter = 10;
	ld	-9 (ix), #0x0a
;tslmain.c:759: vector_push(clipboard, &enter);
	ld	hl, #0
	add	hl, sp
	ex	de, hl
	ld	hl, (_clipboard)
	call	_vector_push
00113$:
;tslmain.c:740: for (short y = select_start.y; y <= select_stop.y; ++y)
	inc	-2 (ix)
	jp	NZ,00119$
	inc	-1 (ix)
	jp	00119$
00120$:
;tslmain.c:762: }
	ld	sp, ix
	pop	ix
	ret
;tslmain.c:764: void clipboard_cut()
;	---------------------------------
; Function clipboard_cut
; ---------------------------------
_clipboard_cut::
;tslmain.c:766: if (!valid_select()) return;
	call	_valid_select
	or	a, a
	ret	Z
;tslmain.c:767: clipboard_copy();
	call	_clipboard_copy
;tslmain.c:768: do_delete();
;tslmain.c:769: }
	jp	_do_delete
;tslmain.c:771: void clipboard_paste()
;	---------------------------------
; Function clipboard_paste
; ---------------------------------
_clipboard_paste::
;tslmain.c:773: if (valid_select())
	call	_valid_select
	or	a, a
	jr	Z, 00102$
;tslmain.c:774: do_delete();
	call	_do_delete
00102$:
;tslmain.c:775: word n = vector_size(clipboard);
	ld	hl, (_clipboard)
	call	_vector_size
;tslmain.c:776: const byte* data = vector_access(clipboard, 0);
	push	de
	ld	de, #0x0000
	ld	hl, (_clipboard)
	call	_vector_access
	pop	bc
	push	de
	pop	iy
;tslmain.c:777: for (word i = 0; i < n; ++i)
	ld	de, #0x0000
00105$:
	ld	a, e
	sub	a, c
	ld	a, d
	sbc	a, b
	jr	NC, 00103$
;tslmain.c:779: add_char(data[i]);
	push	iy
	pop	hl
	add	hl, de
	ld	l, (hl)
;	spillPairReg hl
	push	bc
	push	de
	push	iy
	ld	a, l
	call	_add_char
	pop	iy
	pop	de
	pop	bc
;tslmain.c:777: for (word i = 0; i < n; ++i)
	inc	de
	jr	00105$
00103$:
;tslmain.c:781: redraw_start = 0;
	ld	hl, #0x0000
	ld	(_redraw_start), hl
;tslmain.c:782: redraw_stop = 0x7000;
	ld	h, #0x70
	ld	(_redraw_stop), hl
;tslmain.c:783: }
	ret
;tslmain.c:785: void event_loop()
;	---------------------------------
; Function event_loop
; ---------------------------------
_event_loop::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	hl, #-15
	add	hl, sp
	ld	sp, hl
;tslmain.c:787: byte done = 0;
	ld	-11 (ix), #0x00
;tslmain.c:788: const word total_lines = vector_size(document);
	ld	hl, (_document)
	call	_vector_size
	ld	-10 (ix), e
	ld	-9 (ix), d
;tslmain.c:789: while (!done)
00179$:
	ld	a, -11 (ix)
	or	a, a
	jp	NZ, 00182$
;tslmain.c:792: prev_cursor.x = cursor.x;
	ld	hl, #_cursor
	ld	a, (hl)
	ld	-2 (ix), a
	inc	hl
	ld	a, (hl)
	ld	-1 (ix), a
	ld	a, -2 (ix)
	ld	-15 (ix), a
	ld	a, -1 (ix)
	ld	-14 (ix), a
;tslmain.c:793: prev_cursor.y = cursor.y;
	ld	bc, (#(_cursor + 2) + 0)
	ld	-13 (ix), c
	ld	-12 (ix), b
;tslmain.c:794: Vector* line = get_line(cursor.y);
	ld	hl, (#(_cursor + 2) + 0)
	call	_get_line
;tslmain.c:795: word n = vector_size(line);
;	spillPairReg hl
;	spillPairReg hl
	ld	-2 (ix), e
	ld	-1 (ix), d
	ex	de,hl
;	spillPairReg hl
;	spillPairReg hl
	call	_vector_size
	ld	-2 (ix), e
	ld	-1 (ix), d
	ld	a, -2 (ix)
	ld	-8 (ix), a
	ld	a, -1 (ix)
	ld	-7 (ix), a
;tslmain.c:796: word key = getkey();
	call	_getkey
	ld	-2 (ix), e
	ld	-1 (ix), d
	ld	a, -2 (ix)
	ld	-6 (ix), a
	ld	a, -1 (ix)
	ld	-5 (ix), a
;tslmain.c:797: byte moving = is_move_key(key);
	ld	l, -6 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -5 (ix)
;	spillPairReg hl
;	spillPairReg hl
	call	_is_move_key
	ld	-1 (ix), a
	ld	-4 (ix), a
;tslmain.c:798: byte shifted = ((key & SHIFT) != 0 ? 1 : 0);
	ld	a, -6 (ix)
	ld	-2 (ix), a
	ld	a, -5 (ix)
	ld	-1 (ix), a
	bit	6, -1 (ix)
	jr	Z, 00184$
	ld	bc, #0x0001
	jr	00185$
00184$:
	ld	bc, #0x0000
00185$:
	ld	-3 (ix), c
;tslmain.c:799: byte ctrl = ((key & CTRL) != 0 ? 1 : 0);
	ld	h, -5 (ix)
;	spillPairReg hl
;	spillPairReg hl
	add	hl, hl
	jr	NC, 00186$
	ld	-2 (ix), #0x01
	ld	-1 (ix), #0
	jr	00187$
00186$:
	xor	a, a
	ld	-2 (ix), a
	ld	-1 (ix), a
00187$:
	ld	c, -2 (ix)
;tslmain.c:800: key &= ~CTRL;
	ld	e, -6 (ix)
	ld	d, -5 (ix)
	res	7, d
	ld	-2 (ix), e
	ld	-1 (ix), d
;tslmain.c:801: if (moving)
	ld	a, -4 (ix)
	or	a, a
	jr	Z, 00107$
;tslmain.c:803: if (shifted)
	ld	a, -3 (ix)
	or	a, a
	jr	Z, 00104$
;tslmain.c:805: if (!valid_select())
	push	bc
	call	_valid_select
	pop	bc
	or	a, a
	jr	NZ, 00102$
;tslmain.c:806: start_select();
	push	bc
	call	_start_select
	pop	bc
00102$:
;tslmain.c:807: key &= ~SHIFT;
	ld	a, -2 (ix)
	ld	b, -1 (ix)
	res	6, b
	ld	-2 (ix), a
	ld	-1 (ix), b
	jr	00107$
00104$:
;tslmain.c:810: clear_select();
	push	bc
	call	_clear_select
	pop	bc
00107$:
;tslmain.c:812: switch (key)
	ld	a, -2 (ix)
	sub	a, #0x03
	or	a, -1 (ix)
	jp	Z,00150$
	ld	e, -2 (ix)
	ld	d, -1 (ix)
	ld	a, e
	sub	a, #0x08
	or	a, d
	jp	Z,00154$
	ld	a, e
	sub	a, #0x09
	or	a, d
	jp	Z,00153$
	ld	a, e
	sub	a, #0x0a
	or	a, d
	jp	Z,00168$
	ld	a, e
	sub	a, #0x0d
	or	a, d
	jp	Z,00168$
	ld	a, -2 (ix)
	sub	a, #0x16
	or	a, -1 (ix)
	jp	Z,00152$
	ld	a, -2 (ix)
	sub	a, #0x18
	or	a, -1 (ix)
	jp	Z,00151$
	ld	a, e
	sub	a, #0x1b
	or	a, d
	jp	Z,00143$
	ld	a, e
	or	a, a
	jr	NZ, 00433$
	ld	a, d
	dec	a
	jp	Z,00138$
00433$:
	ld	a, e
	or	a, a
	jr	NZ, 00434$
	ld	a, d
	sub	a, #0x02
	jp	Z,00142$
00434$:
	ld	a, e
	or	a, a
	jr	NZ, 00435$
	ld	a, d
	sub	a, #0x03
	jp	Z,00134$
00435$:
	ld	a, e
	or	a, a
	jr	NZ, 00436$
	ld	a, d
	sub	a, #0x04
	jp	Z,00130$
00436$:
	ld	a, e
	or	a, a
	jr	NZ, 00437$
	ld	a, d
	sub	a, #0x05
	jr	Z, 00108$
00437$:
	ld	a, e
	or	a, a
	jr	NZ, 00438$
	ld	a, d
	sub	a, #0x06
	jr	Z, 00112$
00438$:
	ld	a, e
	or	a, a
	jr	NZ, 00439$
	ld	a, d
	sub	a, #0x07
	jr	Z, 00111$
00439$:
	ld	a, e
	or	a, a
	jr	NZ, 00440$
	ld	a, d
	sub	a, #0x08
	jr	Z, 00120$
00440$:
	ld	a, e
	or	a, a
	jr	NZ, 00441$
	ld	a, d
	sub	a, #0x0d
	jp	Z,00144$
00441$:
	ld	a, e
	or	a, a
	jp	NZ,00169$
	ld	a, d
	sub	a, #0x0e
	jp	Z,00160$
	jp	00169$
;tslmain.c:814: case LEFT: if (cursor.x > 0) move_x_cursor(-1); break;
00108$:
	ld	hl, (#_cursor + 0)
	xor	a, a
	cp	a, l
	sbc	a, h
	jp	PO, 00443$
	xor	a, #0x80
00443$:
	jp	P, 00173$
	ld	hl, #0xffff
	call	_move_x_cursor
	jp	00173$
;tslmain.c:815: case RIGHT: move_x_cursor(1); break;
00111$:
	ld	hl, #0x0001
	call	_move_x_cursor
	jp	00173$
;tslmain.c:816: case UP:
00112$:
;tslmain.c:818: if (ctrl)
	ld	a, c
	or	a, a
	jr	Z, 00118$
;tslmain.c:820: if (offset.y > 0)
	ld	bc, (#(_offset + 2) + 0)
	ld	e, c
	ld	d, b
	xor	a, a
	cp	a, e
	sbc	a, d
	jp	PO, 00444$
	xor	a, #0x80
00444$:
	jp	P, 00173$
;tslmain.c:822: --offset.y;
	dec	bc
	ld	((_offset + 2)), bc
;tslmain.c:823: redraw_all();
	call	_redraw_all
	jp	00173$
00118$:
;tslmain.c:828: if (cursor.y > 0)
	ld	hl, (#(_cursor + 2) + 0)
	xor	a, a
	cp	a, l
	sbc	a, h
	jp	PO, 00445$
	xor	a, #0x80
00445$:
	jp	P, 00173$
;tslmain.c:829: move_y(-1);
	ld	hl, #0xffff
	call	_move_y
;tslmain.c:831: break;
	jp	00173$
;tslmain.c:833: case DOWN:
00120$:
;tslmain.c:835: if (ctrl)
	ld	a, c
	or	a, a
	jr	Z, 00128$
;tslmain.c:837: if (offset.y < vector_size(document))
	ld	hl, (#(_offset + 2) + 0)
	push	hl
	ld	hl, (_document)
	call	_vector_size
	pop	hl
	xor	a, a
	sbc	hl, de
	jp	NC, 00173$
;tslmain.c:839: ++offset.y;
	ld	bc, (#(_offset + 2) + 0)
	inc	bc
	ld	((_offset + 2)), bc
;tslmain.c:840: if (!cursor_in_view())
	call	_cursor_in_view
	or	a, a
	jr	NZ, 00122$
;tslmain.c:841: move_y(1);
	ld	hl, #0x0001
	call	_move_y
00122$:
;tslmain.c:842: redraw_all();
	call	_redraw_all
	jp	00173$
00128$:
;tslmain.c:847: if (cursor.y < total_lines)
	ld	hl, (#(_cursor + 2) + 0)
	ld	a, l
	sub	a, -10 (ix)
	ld	a, h
	sbc	a, -9 (ix)
	jp	NC, 00173$
;tslmain.c:848: move_y(1);
	ld	hl, #0x0001
	call	_move_y
;tslmain.c:850: break;
	jp	00173$
;tslmain.c:852: case HOME:
00130$:
;tslmain.c:854: if (ctrl)
	ld	a, c
	or	a, a
	jr	Z, 00132$
;tslmain.c:856: cursor.y = 0;
	ld	hl, #0x0000
	ld	((_cursor + 2)), hl
;tslmain.c:857: cursor.x = 0;
	ld	(_cursor), hl
	jp	00173$
00132$:
;tslmain.c:860: cursor.x = 0;
	ld	hl, #0x0000
	ld	(_cursor), hl
;tslmain.c:861: break;
	jp	00173$
;tslmain.c:863: case END:
00134$:
;tslmain.c:865: if (ctrl)
	ld	a, c
	or	a, a
	jr	Z, 00136$
;tslmain.c:867: cursor.y = vector_size(document) - 1;
	ld	hl, (_document)
	call	_vector_size
	dec	de
	ld	((_cursor + 2)), de
;tslmain.c:868: Vector* end_line = get_line(cursor.y);
	ex	de, hl
	call	_get_line
;tslmain.c:869: cursor.x = vector_size(end_line);
	ex	de, hl
	call	_vector_size
	ld	(_cursor), de
	jp	00173$
00136$:
;tslmain.c:872: cursor.x = n;
	ld	hl, #_cursor
	ld	a, -8 (ix)
	ld	(hl), a
	inc	hl
	ld	a, -7 (ix)
	ld	(hl), a
;tslmain.c:873: break;
	jp	00173$
;tslmain.c:875: case PGUP: if (cursor.y < 25) cursor.y = 0; else cursor.y -= 25; break;
00138$:
	ld	hl, (#(_cursor + 2) + 0)
	ld	a, l
	sub	a, #0x19
	ld	a, h
	rla
	ccf
	rra
	sbc	a, #0x80
	jr	NC, 00140$
	ld	hl, #0x0000
	ld	((_cursor + 2)), hl
	jp	00173$
00140$:
	ld	bc, #0xffe7
	add	hl,bc
	ld	c, l
	ld	b, h
	ld	((_cursor + 2)), bc
	jp	00173$
;tslmain.c:876: case PGDN: cursor.y = min(cursor.y + 25, total_lines); break;
00142$:
	ld	hl, (#(_cursor + 2) + 0)
	ld	bc, #0x0019
	add	hl, bc
	ld	e, -10 (ix)
	ld	d, -9 (ix)
	call	_min
	ld	((_cursor + 2)), de
	jp	00173$
;tslmain.c:877: case 27: done = 1; break;
00143$:
	ld	-11 (ix), #0x01
	jp	00173$
;tslmain.c:878: case INSERT:
00144$:
;tslmain.c:880: if (ctrl) clipboard_copy();
	ld	a, c
	or	a, a
	jr	Z, 00148$
	call	_clipboard_copy
	jp	00173$
00148$:
;tslmain.c:881: else if (shifted) clipboard_paste();
	ld	a, -3 (ix)
	or	a, a
	jp	Z, 00173$
	call	_clipboard_paste
;tslmain.c:882: break;
	jp	00173$
;tslmain.c:884: case CONTROL('C'): clipboard_copy(); break;
00150$:
	call	_clipboard_copy
	jp	00173$
;tslmain.c:885: case CONTROL('X'): clipboard_cut(); break;
00151$:
	call	_clipboard_cut
	jp	00173$
;tslmain.c:886: case CONTROL('V'): clipboard_paste(); break;
00152$:
	call	_clipboard_paste
	jp	00173$
;tslmain.c:887: case 9:
00153$:
;tslmain.c:889: add_char(9);
	ld	a, #0x09
	call	_add_char
;tslmain.c:890: redraw_line(cursor.y);
	ld	hl, (#(_cursor + 2) + 0)
	call	_redraw_line
;tslmain.c:891: break;
	jr	00173$
;tslmain.c:893: case 8:
00154$:
;tslmain.c:895: if (cursor.x > 0)
	ld	hl, (#_cursor + 0)
	xor	a, a
	cp	a, l
	sbc	a, h
	jp	PO, 00446$
	xor	a, #0x80
00446$:
	jp	P, 00158$
;tslmain.c:897: backspace();
	call	_backspace
;tslmain.c:898: redraw_line(cursor.y);
	ld	hl, (#(_cursor + 2) + 0)
	call	_redraw_line
	jr	00173$
00158$:
;tslmain.c:901: if (cursor.y>0)
	ld	hl, (#(_cursor + 2) + 0)
	xor	a, a
	cp	a, l
	sbc	a, h
	jp	PO, 00447$
	xor	a, #0x80
00447$:
	jp	P, 00173$
;tslmain.c:903: join_prev_line();
	call	_join_prev_line
;tslmain.c:905: break;
	jr	00173$
;tslmain.c:907: case DEL:
00160$:
;tslmain.c:909: if (ctrl) clipboard_cut();
	ld	a, c
	or	a, a
	jr	Z, 00165$
	call	_clipboard_cut
	jr	00173$
00165$:
;tslmain.c:911: if (do_delete())
	call	_do_delete
	or	a, a
	jr	Z, 00162$
;tslmain.c:912: redraw_line(cursor.y);
	ld	hl, (#(_cursor + 2) + 0)
	call	_redraw_line
	jr	00173$
00162$:
;tslmain.c:915: redraw_from(cursor.y);
	ld	hl, (#(_cursor + 2) + 0)
	call	_redraw_from
;tslmain.c:917: break;
	jr	00173$
;tslmain.c:920: case 10:
00168$:
;tslmain.c:922: add_enter();
	push	de
	call	_add_enter
	pop	de
;tslmain.c:923: redraw_from(prev_cursor.y);
	ld	l, -13 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -12 (ix)
;	spillPairReg hl
;	spillPairReg hl
	push	de
	call	_redraw_from
	pop	de
;tslmain.c:925: default:
00169$:
;tslmain.c:927: if (key >= 32 && key < 127)
	ld	a, e
	sub	a, #0x20
	ld	a, d
	sbc	a, #0x00
	jr	C, 00173$
	ld	a, e
	sub	a, #0x7f
	ld	a, d
	sbc	a, #0x00
	jr	NC, 00173$
;tslmain.c:929: add_char((byte)key);
	ld	a, -2 (ix)
	call	_add_char
;tslmain.c:930: redraw_line(cursor.y);
	ld	hl, (#(_cursor + 2) + 0)
	call	_redraw_line
;tslmain.c:933: }
00173$:
;tslmain.c:934: line = get_line(cursor.y);
	ld	hl, (#(_cursor + 2) + 0)
	call	_get_line
;tslmain.c:935: n = vector_size(line);
	ex	de, hl
	call	_vector_size
	ld	-2 (ix), e
	ld	-1 (ix), d
;tslmain.c:936: if (cursor.x > n) 
	ld	hl, (#_cursor + 0)
	ld	a, -2 (ix)
	sub	a, l
	ld	a, -1 (ix)
	sbc	a, h
	jr	NC, 00175$
;tslmain.c:937: cursor.x = n;
	ld	hl, #_cursor
	ld	a, -2 (ix)
	ld	(hl), a
	inc	hl
	ld	a, -1 (ix)
	ld	(hl), a
00175$:
;tslmain.c:938: if (moving && shifted)
	ld	a, -4 (ix)
	or	a, a
	jr	Z, 00177$
	ld	a, -3 (ix)
	or	a, a
	jr	Z, 00177$
;tslmain.c:940: extend_select();
	call	_extend_select
;tslmain.c:941: redraw_range(prev_cursor.y, cursor.y);
	ld	de, (#(_cursor + 2) + 0)
	ld	l, -13 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -12 (ix)
;	spillPairReg hl
;	spillPairReg hl
	call	_redraw_range
00177$:
;tslmain.c:943: place_cursor();
	call	_place_cursor
;tslmain.c:944: draw_screen();
	call	_draw_screen
;tslmain.c:945: draw_cursor_position();
	call	_draw_cursor_position
;tslmain.c:946: place_cursor();
	call	_place_cursor
	jp	00179$
00182$:
;tslmain.c:948: }
	ld	sp, ix
	pop	ix
	ret
;tslmain.c:956: int MAIN(char** args)
;	---------------------------------
; Function main
; ---------------------------------
_main::
;tslmain.c:958: init_state();
	push	hl
	call	_init_state
	call	_alloc_init
	call	_hal_init
	ld	hl, #0x0001
	call	_vector_new
	pop	hl
	ld	(_clipboard), de
;tslmain.c:962: vector_reserve(clipboard, 256);
	push	hl
	ld	de, #0x0100
	ld	hl, (_clipboard)
	call	_vector_reserve
	ld	hl, #0x0002
	call	_vector_new
	pop	hl
	ld	(_document), de
;tslmain.c:964: if (args[0])
	ld	c, (hl)
	inc	hl
	ld	h, (hl)
;	spillPairReg hl
	ld	a, h
	or	a, c
	jr	Z, 00102$
;tslmain.c:966: load_file(args[0]);
	ld	l, c
;	spillPairReg hl
;	spillPairReg hl
	call	_load_file
00102$:
;tslmain.c:968: fg = 0x3F;
	ld	hl, #_fg
	ld	(hl), #0x3f
;tslmain.c:969: bg = 0x40;
	ld	hl, #_bg
	ld	(hl), #0x40
;tslmain.c:970: draw_frame();
	call	_draw_frame
;tslmain.c:971: draw_screen();
	call	_draw_screen
;tslmain.c:972: hal_blink(1);
	ld	a, #0x01
	call	_hal_blink
;tslmain.c:973: event_loop();
	call	_event_loop
;tslmain.c:974: hal_shutdown();
	call	_hal_shutdown
;tslmain.c:975: clear();
	call	_clear
;tslmain.c:976: vector_shut(document);
	ld	hl, (_document)
	call	_vector_shut
;tslmain.c:977: return 0;
	ld	de, #0x0000
;tslmain.c:978: }
	ret
	.area _CODE
	.area _INITIALIZER
__xinit__fg:
	.db #0xff	; 255
__xinit__bg:
	.db #0x00	; 0
__xinit__insert:
	.db #0x01	; 1
	.area _CABS (ABS)
