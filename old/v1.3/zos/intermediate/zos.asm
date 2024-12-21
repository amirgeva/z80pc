;--------------------------------------------------------
; File Created by SDCC : free open source ISO C Compiler 
; Version 4.2.2 #13407 (MINGW64)
;--------------------------------------------------------
	.module zos
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _receive
	.globl _process_command
	.globl _main
	.globl _service1
	.globl _rng
	.globl _cls
	.globl _println
	.globl _print
	.globl _printc
	.globl _strcmp
	.globl _user_program
	.globl _g
	.globl _scan_input
	.globl _get_key
	.globl _send_prompt
;--------------------------------------------------------
; special function registers
;--------------------------------------------------------
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _DATA
_g	=	0x1000
_user_program::
	.ds 2
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
;zos.c:15: word service1(byte call_type)
;	---------------------------------
; Function service1
; ---------------------------------
_service1::
;zos.c:17: switch (call_type)
	ld	c,a
	or	a,a
	jp	Z,_rng
	dec	a
	jp	Z,_get_key
	ld	a, c
	sub	a, #0x02
;zos.c:19: case 0:		return rng();
;zos.c:20: case 1:		return get_key();
;zos.c:21: case 2:		return g.timer;
	jr	NZ, 00104$
	ld	de, (#(_g + 292) + 0)
	ret
;zos.c:22: }
00104$:
;zos.c:23: return 0;
	ld	de, #0x0000
;zos.c:24: }
	ret
;zos.c:48: void main()
;	---------------------------------
; Function main
; ---------------------------------
_main::
;zos.c:50: g.in_write=0;
	ld	hl, #(_g + 288)
	ld	(hl), #0x00
;zos.c:51: g.in_read=0;
	ld	hl, #(_g + 289)
	ld	(hl), #0x00
;zos.c:52: g.cmd_pos=0;
	ld	hl, #(_g + 290)
	ld	(hl), #0x00
;zos.c:53: g.timer=0;
	ld	hl, #0x0000
	ld	((_g + 292)), hl
;zos.c:54: user_program = (func_ptr)USER_AREA;
	ld	h, #0x12
	ld	(_user_program), hl
;zos.c:59: __endasm;
	LD	SP,#0xFF00
	IM	1
	EI
;zos.c:60: cls();
	call	_cls
;zos.c:61: send_prompt();
	call	_send_prompt
;zos.c:62: while (1) scan_input();
00102$:
	call	_scan_input
;zos.c:63: }
	jr	00102$
;zos.c:65: void process_command()
;	---------------------------------
; Function process_command
; ---------------------------------
_process_command::
;zos.c:74: if (strcmp(g.cmd_buffer,"run") == 0)
	ld	de, #___str_0
	ld	hl, #(_g + 256)
	call	_strcmp
	or	a, a
	jr	NZ, 00102$
;zos.c:76: user_program();
	ld	hl, (_user_program)
	jp	(hl)
00102$:
;zos.c:79: println("Invalid command");
	ld	hl, #___str_1
;zos.c:80: }
	jp	_println
___str_0:
	.ascii "run"
	.db 0x00
___str_1:
	.ascii "Invalid command"
	.db 0x00
;zos.c:82: void scan_input()
;	---------------------------------
; Function scan_input
; ---------------------------------
_scan_input::
;zos.c:85: if (g.in_write==g.in_read) return;
	ld	hl, #_g+288
	ld	c, (hl)
	ld	a, (#(_g + 289) + 0)
	sub	a, c
	ret	Z
;zos.c:86: cur=g.input_buffer[g.in_read++];
	ld	hl, #_g+289
	ld	c, (hl)
	ld	a, c
	inc	a
	ld	(hl), a
	ld	b, #0x00
	ld	hl, #_g
	add	hl, bc
	ld	c, (hl)
;zos.c:87: printc(cur);
	push	bc
	ld	a, c
	call	_printc
	pop	bc
;zos.c:88: if (cur == 8)
	ld	a, c
	sub	a, #0x08
	jr	NZ, 00114$
;zos.c:90: if (g.cmd_pos>0) --g.cmd_pos;
	ld	a, (#(_g + 290) + 0)
	or	a, a
	ret	Z
	ld	bc, #_g+290
	ld	a, (bc)
	dec	a
	ld	(bc), a
	ret
00114$:
;zos.c:93: if (cur==10 || cur==13)
	ld	a,c
	cp	a,#0x0a
	jr	Z, 00109$
	sub	a, #0x0d
	jr	NZ, 00110$
00109$:
;zos.c:95: if (g.cmd_pos>0)
	ld	a, (#(_g + 290) + 0)
	or	a, a
	jp	Z,_send_prompt
;zos.c:97: g.cmd_buffer[g.cmd_pos]=0;
	ld	hl, #(_g + 290)
	ld	c, (hl)
	ld	hl, #(_g + 256)
	ld	b, #0x00
	add	hl, bc
	ld	(hl), #0x00
;zos.c:98: process_command();
	call	_process_command
;zos.c:99: g.cmd_pos=0;
	ld	hl, #(_g + 290)
;zos.c:101: send_prompt();
	ld	(hl), #0x00
	jp	_send_prompt
00110$:
;zos.c:104: if (g.cmd_pos < (CMD_BUFFER_SIZE-1))
	ld	a, (#(_g + 290) + 0)
	sub	a, #0x1f
	ret	NC
;zos.c:105: g.cmd_buffer[g.cmd_pos++]=cur;
	ld	hl, #_g+290
	ld	e, (hl)
	ld	a, e
	inc	a
	ld	(hl), a
	ld	hl, #(_g + 256)
	ld	d, #0x00
	add	hl, de
	ld	(hl), c
;zos.c:106: }
	ret
;zos.c:108: word get_key()
;	---------------------------------
; Function get_key
; ---------------------------------
_get_key::
;zos.c:110: word res=0x100;
	ld	de, #0x0100
;zos.c:111: if (g.in_write!=g.in_read)
	ld	hl, #_g+288
	ld	c, (hl)
	ld	a, (#(_g + 289) + 0)
	sub	a, c
	ret	Z
;zos.c:113: word key = g.input_buffer[g.in_read++];
	ld	hl, #_g+289
	ld	c, (hl)
	ld	a, c
	inc	a
	ld	(hl), a
	ld	b, #0x00
	ld	hl, #_g
	add	hl, bc
	ld	e, (hl)
	ld	d, #0x00
;zos.c:114: res=key;
;zos.c:116: return res;
;zos.c:117: }
	ret
;zos.c:119: byte receive(byte* data)
;	---------------------------------
; Function receive
; ---------------------------------
_receive::
	ex	de, hl
;zos.c:121: if (g.in_write==g.in_read) return 0;
	ld	hl, #_g+288
	ld	c, (hl)
	ld	a, (#(_g + 289) + 0)
	sub	a, c
	jr	NZ, 00102$
	xor	a, a
	ret
00102$:
;zos.c:122: *data = g.input_buffer[g.in_read++];
	ld	hl, #_g+289
	ld	c, (hl)
	ld	a, c
	inc	a
	ld	(hl), a
	ld	b, #0x00
	ld	hl, #_g
	add	hl, bc
	ld	a, (hl)
	ld	(de), a
;zos.c:123: return 1;
	ld	a, #0x01
;zos.c:124: }
	ret
;zos.c:126: void send_prompt()
;	---------------------------------
; Function send_prompt
; ---------------------------------
_send_prompt::
;zos.c:128: print("zOS>");
	ld	hl, #___str_2
;zos.c:129: }
	jp	_print
___str_2:
	.ascii "zOS>"
	.db 0x00
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
