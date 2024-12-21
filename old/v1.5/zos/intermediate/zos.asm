;--------------------------------------------------------
; File Created by SDCC : free open source ISO C Compiler 
; Version 4.2.2 #13407 (MINGW64)
;--------------------------------------------------------
	.module zos
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _process_command
	.globl _print_text
	.globl _main
	.globl _service6
	.globl _service5
	.globl _service4
	.globl _service3
	.globl _service2
	.globl _service1
	.globl _command_pos
	.globl _command_buffer
	.globl _gdata
	.globl _input_empty
	.globl _input_read
	.globl _strlen
	.globl _strcmp
	.globl _cls
	.globl _print_prompt
	.globl _process_input
;--------------------------------------------------------
; special function registers
;--------------------------------------------------------
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _DATA
_command_buffer::
	.ds 32
_command_pos::
	.ds 1
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
;zos.c:5: byte service1()
;	---------------------------------
; Function service1
; ---------------------------------
_service1::
;zos.c:7: return 0;
	xor	a, a
;zos.c:8: }
	ret
_gdata:
	.db #0x0c	; 12
	.db #0x4d	; 77	'M'
	.db #0x41	; 65	'A'
	.db #0xff	; 255
;zos.c:10: byte service2(byte data)
;	---------------------------------
; Function service2
; ---------------------------------
_service2::
;zos.c:13: return 0;
	xor	a, a
;zos.c:14: }
	ret
;zos.c:16: byte service3(byte* pointer)
;	---------------------------------
; Function service3
; ---------------------------------
_service3::
;zos.c:19: return 0;
	xor	a, a
;zos.c:20: }
	ret
;zos.c:22: byte service4(byte* pointer, byte data)
;	---------------------------------
; Function service4
; ---------------------------------
_service4::
;zos.c:26: return 0;
	xor	a, a
;zos.c:27: }
	pop	hl
	inc	sp
	jp	(hl)
;zos.c:29: byte service5()
;	---------------------------------
; Function service5
; ---------------------------------
_service5::
;zos.c:31: return 0;
	xor	a, a
;zos.c:32: }
	ret
;zos.c:34: byte service6()
;	---------------------------------
; Function service6
; ---------------------------------
_service6::
;zos.c:36: return 0;
	xor	a, a
;zos.c:37: }
	ret
;zos.c:43: void main()
;	---------------------------------
; Function main
; ---------------------------------
_main::
;zos.c:45: command_pos=0;
	ld	hl, #_command_pos
	ld	(hl), #0x00
;zos.c:46: cls();
	call	_cls
;zos.c:47: while (1)
00105$:
;zos.c:49: print_prompt();
	call	_print_prompt
;zos.c:50: while (!process_input());
00101$:
	call	_process_input
	or	a, a
	jr	NZ, 00105$
;zos.c:52: }
	jr	00101$
;zos.c:54: byte input_empty() __naked
;	---------------------------------
; Function input_empty
; ---------------------------------
_input_empty::
;zos.c:64: __endasm;
	LD	A,(#0xF1)
	LD	HL,#0xF0
	SUB	(HL)
	LD	A,#1
	RET	Z
	XOR	A
	RET
;zos.c:65: }
;zos.c:67: byte input_read() __naked
;	---------------------------------
; Function input_read
; ---------------------------------
_input_read::
;zos.c:77: __endasm;
	LD	A,(#0xF1)
	LD	H,#1
	LD	L,A
	LD	A,(HL)
	LD	HL,#0xF1
	INC	(HL)
	RET
;zos.c:78: }
;zos.c:80: byte strlen(const byte* text)
;	---------------------------------
; Function strlen
; ---------------------------------
_strlen::
;zos.c:84: return res;
	ld	c, #0x00
00103$:
;zos.c:83: for(;*text;++text,++res);
	ld	a, (hl)
	or	a, a
	jr	Z, 00101$
	inc	hl
	inc	c
	jr	00103$
00101$:
;zos.c:84: return res;
	ld	a, c
;zos.c:85: }
	ret
;zos.c:87: char strcmp(const char* a, const char* b)
;	---------------------------------
; Function strcmp
; ---------------------------------
_strcmp::
	push	ix
	ld	ix,#0
	add	ix,sp
	push	af
	ld	c, l
	ld	b, h
	inc	sp
	inc	sp
	push	de
;zos.c:89: if (!a && !b) return 0;
	ld	a, b
	or	a, c
	jr	NZ, 00102$
	ld	a, -1 (ix)
	or	a, -2 (ix)
	jr	NZ, 00102$
	xor	a, a
	jr	00120$
00102$:
;zos.c:90: if (!a) return 1;
	ld	a, b
	or	a, c
	jr	NZ, 00105$
	ld	a, #0x01
	jr	00120$
00105$:
;zos.c:91: if (!b) return -1;
	ld	a, -1 (ix)
	or	a, -2 (ix)
	jr	NZ, 00133$
	ld	a, #0xff
	jr	00120$
;zos.c:92: while (1)
00133$:
	pop	hl
	push	hl
00118$:
;zos.c:94: if (*a==0 && *b==0) return 0;
	ld	a, (bc)
	or	a, a
	jr	NZ, 00109$
	ld	e, (hl)
	inc	e
	dec	e
	jr	NZ, 00109$
	ld	a, e
	jr	00120$
00109$:
;zos.c:95: if (*a==0) return 1;
	or	a, a
	jr	NZ, 00112$
	ld	a, #0x01
	jr	00120$
00112$:
;zos.c:96: if (*b==0) return -1;
	ld	e, (hl)
	inc	e
	dec	e
	jr	NZ, 00114$
	ld	a, #0xff
	jr	00120$
00114$:
;zos.c:97: if (*a==*b) 
	cp	a, e
	jr	NZ, 00116$
;zos.c:99: ++a;
;zos.c:100: ++b;
	inc	hl
	inc	bc
;zos.c:101: continue;
	jr	00118$
00116$:
;zos.c:103: return *a<*b?-1:1;
	sub	a, e
	jr	NC, 00122$
	ld	bc, #0xffff
	jr	00123$
00122$:
	ld	bc, #0x0001
00123$:
	ld	a, c
;zos.c:105: return 0;
00120$:
;zos.c:106: }
	ld	sp, ix
	pop	ix
	ret
;zos.c:108: void print_text(const char* text)
;	---------------------------------
; Function print_text
; ---------------------------------
_print_text::
;zos.c:120: __endasm;
	LD	A,#30
	OUT	(0),A
	push	HL
	call	_strlen
	pop	HL
	OUT	(0),A
	LD	B,A
	OTIR
;zos.c:121: }
	ret
;zos.c:123: void cls()
;	---------------------------------
; Function cls
; ---------------------------------
_cls::
;zos.c:128: __endasm;
	LD	A,#1
	OUT	(0),A
;zos.c:129: }
	ret
;zos.c:131: void print_prompt()
;	---------------------------------
; Function print_prompt
; ---------------------------------
_print_prompt::
;zos.c:133: const char* os_prompt="zOS>";
;zos.c:134: print_text(os_prompt);
	ld	hl, #___str_0
;zos.c:135: }
	jp	_print_text
___str_0:
	.ascii "zOS>"
	.db 0x00
;zos.c:137: void process_command()
;	---------------------------------
; Function process_command
; ---------------------------------
_process_command::
;zos.c:141: if (strcmp(command_buffer, "run") == 0)
	ld	de, #___str_1
	ld	hl, #_command_buffer
	call	_strcmp
	or	a, a
;zos.c:142: user_program();
	jp	Z,0x1000
;zos.c:143: }
	ret
___str_1:
	.ascii "run"
	.db 0x00
;zos.c:145: byte process_input()
;	---------------------------------
; Function process_input
; ---------------------------------
_process_input::
;zos.c:147: if (!input_empty())
	call	_input_empty
	or	a, a
	jr	NZ, 00107$
;zos.c:149: byte data = input_read();
	call	_input_read
;zos.c:150: if (data==10 || data==13)
	ld	c, a
	sub	a, #0x0a
	jr	Z, 00101$
	ld	a, c
	sub	a, #0x0d
	jr	NZ, 00102$
00101$:
;zos.c:152: process_command();
	call	_process_command
;zos.c:153: command_pos=0;
	ld	hl, #_command_pos
	ld	(hl), #0x00
;zos.c:154: return 1;
	ld	a, #0x01
	ret
00102$:
;zos.c:156: if (command_pos < 30)
	ld	a, (_command_pos+0)
	sub	a, #0x1e
	jr	NC, 00107$
;zos.c:158: command_buffer[command_pos++]=data;
	ld	de, #_command_buffer+0
	ld	a, (_command_pos+0)
	ld	b, a
	ld	hl, #_command_pos
	inc	(hl)
	ld	l, b
	ld	h, #0x00
	add	hl, de
	ld	(hl), c
;zos.c:159: command_buffer[command_pos]=0;
	ld	hl, (_command_pos)
	ld	h, #0x00
	add	hl, de
	ld	(hl), #0x00
00107$:
;zos.c:162: return 0;
	xor	a, a
;zos.c:163: }
	ret
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
