;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 4.2.0 #13081 (MINGW64)
;--------------------------------------------------------
	.module zos
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _main
	.globl _process_input
	.globl _backspace
	.globl _print_char
	.globl _process_command
	.globl _cat_file
	.globl _dir
	.globl _load_program
	.globl _print_prompt
	.globl _close_file
	.globl _read_file
	.globl _open_file
	.globl _list_next
	.globl _list_dir
	.globl _gpu_clear
	.globl _gpu_flush
	.globl _newline
	.globl _strncmp
	.globl _strcmp
	.globl _input_read
	.globl _input_empty
	.globl _print_word
	.globl _print_text
	.globl _cls
	.globl _command_pos
	.globl _command_buffer
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
;zos.c:7: void print_prompt()
;	---------------------------------
; Function print_prompt
; ---------------------------------
_print_prompt::
;zos.c:9: const char* os_prompt="zOS>";
;zos.c:10: print_text(os_prompt);
	ld	hl, #___str_0
;zos.c:11: }
	jp	_print_text
___str_0:
	.ascii "zOS>"
	.db 0x00
;zos.c:14: void load_program(const char* filename)
;	---------------------------------
; Function load_program
; ---------------------------------
_load_program::
;zos.c:16: byte handle = open_file(filename,0);
	xor	a, a
	push	af
	inc	sp
	call	_open_file
;zos.c:17: if (handle != 0xFF)
	ld	c, a
	inc	a
	jr	Z, 00102$
;zos.c:20: read_file(handle, program_buffer, 0xE000);
	push	bc
	ld	hl, #0xe000
	push	hl
	ld	de, #0x1000
	ld	a, c
	call	_read_file
	pop	bc
;zos.c:21: close_file(handle);
	ld	a, c
	jp	_close_file
00102$:
;zos.c:25: print_text("File not found");
	ld	hl, #___str_1
;zos.c:27: }
	jp	_print_text
___str_1:
	.ascii "File not found"
	.db 0x00
;zos.c:30: void dir()
;	---------------------------------
; Function dir
; ---------------------------------
_dir::
	push	ix
	ld	ix,#0
	add	ix,sp
	push	af
;zos.c:33: byte rc=list_dir("/",command_buffer,&size);
	ld	hl, #0
	add	hl, sp
	push	hl
	ld	de, #_command_buffer
	ld	hl, #___str_2
	call	_list_dir
	ld	c, a
;zos.c:34: while (rc==200)
00101$:
	ld	a, c
	sub	a, #0xc8
	jr	NZ, 00104$
;zos.c:36: print_text(command_buffer);
	ld	hl, #_command_buffer
	call	_print_text
;zos.c:37: print_text("  ");
	ld	hl, #___str_3
	call	_print_text
;zos.c:38: print_word(size);
	pop	hl
	push	hl
	call	_print_word
;zos.c:39: newline();
	call	_newline
;zos.c:40: gpu_flush();
	call	_gpu_flush
;zos.c:41: rc=list_next(command_buffer,&size);
	ld	hl, #0
	add	hl, sp
	ex	de, hl
	ld	hl, #_command_buffer
	call	_list_next
	ld	c, a
	jr	00101$
00104$:
;zos.c:43: }
	ld	sp, ix
	pop	ix
	ret
___str_2:
	.ascii "/"
	.db 0x00
___str_3:
	.ascii "  "
	.db 0x00
;zos.c:45: void cat_file(const char* filename)
;	---------------------------------
; Function cat_file
; ---------------------------------
_cat_file::
;zos.c:47: byte handle = open_file(filename,0);
	xor	a, a
	push	af
	inc	sp
	call	_open_file
;zos.c:48: if (handle != 0xFF)
	ld	c, a
	inc	a
	ret	Z
;zos.c:50: word act=1;
	ld	de, #0x0001
;zos.c:51: while (act>0)
00103$:
	ld	a, d
	or	a, e
	jr	Z, 00105$
;zos.c:53: act = read_file(handle, command_buffer, 30);
	push	bc
	ld	hl, #0x001e
	push	hl
	ld	de, #_command_buffer
	ld	a, c
	call	_read_file
	pop	bc
;zos.c:54: if (act>0)
	ld	a, d
	or	a, e
	jr	Z, 00103$
;zos.c:56: command_buffer[act]=0;
	ld	hl, #_command_buffer
	add	hl, de
	ld	(hl), #0x00
;zos.c:57: print_text(command_buffer);
	push	bc
	push	de
	ld	hl, #_command_buffer
	call	_print_text
	pop	de
	pop	bc
	jr	00103$
00105$:
;zos.c:60: close_file(handle);
	ld	a, c
	call	_close_file
;zos.c:61: gpu_flush();
;zos.c:63: }
	jp	_gpu_flush
;zos.c:65: void process_command()
;	---------------------------------
; Function process_command
; ---------------------------------
_process_command::
;zos.c:69: if (strcmp(command_buffer, "run") == 0)
	ld	de, #___str_4
	ld	hl, #_command_buffer
	call	_strcmp
	ld	c, a
	or	a, a
;zos.c:70: user_program();
	jp	Z,0x1000
;zos.c:72: if (strcmp(command_buffer, "cls") == 0)
	ld	de, #___str_5
	ld	hl, #_command_buffer
	call	_strcmp
	or	a, a
;zos.c:73: cls();
	jp	Z,_cls
;zos.c:75: if (strcmp(command_buffer, "dir") == 0)
	ld	de, #___str_6
	ld	hl, #_command_buffer
	call	_strcmp
	or	a, a
;zos.c:76: dir();
	jp	Z,_dir
;zos.c:78: if (command_pos>4 && strncmp(command_buffer, "cat ", 4)==0)
	ld	a, #0x04
	ld	hl, #_command_pos
	sub	a, (hl)
	jr	NC, 00106$
	ld	a, #0x04
	push	af
	inc	sp
	ld	de, #___str_7
	ld	hl, #_command_buffer
	call	_strncmp
	or	a, a
	jr	NZ, 00106$
;zos.c:79: cat_file(command_buffer+4);
	ld	hl, #(_command_buffer + 4)
	jp	_cat_file
00106$:
;zos.c:81: if (command_pos>5 && strncmp(command_buffer, "load ", 5)==0)
	ld	a, #0x05
	ld	hl, #_command_pos
	sub	a, (hl)
	jr	NC, 00102$
	ld	a, #0x05
	push	af
	inc	sp
	ld	de, #___str_8
	ld	hl, #_command_buffer
	call	_strncmp
	or	a, a
	jr	NZ, 00102$
;zos.c:82: load_program(command_buffer+5);
	ld	hl, #(_command_buffer + 5)
	jp	_load_program
00102$:
;zos.c:85: print_text("Unknown Command");
	ld	hl, #___str_9
	call	_print_text
;zos.c:86: newline();
;zos.c:88: }
	jp	_newline
___str_4:
	.ascii "run"
	.db 0x00
___str_5:
	.ascii "cls"
	.db 0x00
___str_6:
	.ascii "dir"
	.db 0x00
___str_7:
	.ascii "cat "
	.db 0x00
___str_8:
	.ascii "load "
	.db 0x00
___str_9:
	.ascii "Unknown Command"
	.db 0x00
;zos.c:90: void print_char(byte b)
;	---------------------------------
; Function print_char
; ---------------------------------
_print_char::
	push	af
	ld	c, a
;zos.c:93: text[0]=b;
	ld	hl, #0
	add	hl, sp
	ex	de, hl
	ld	a, c
	ld	(de), a
;zos.c:94: text[1]=0;
	ld	c, e
	ld	b, d
	inc	bc
	xor	a, a
	ld	(bc), a
;zos.c:95: print_text(text);
	ex	de, hl
	call	_print_text
;zos.c:96: }
	pop	af
	ret
;zos.c:98: void backspace()
;	---------------------------------
; Function backspace
; ---------------------------------
_backspace::
;zos.c:99: {}
	ret
;zos.c:101: byte process_input()
;	---------------------------------
; Function process_input
; ---------------------------------
_process_input::
;zos.c:103: if (!input_empty())
	call	_input_empty
	or	a, a
	jr	NZ, 00111$
;zos.c:105: byte data = input_read();
	call	_input_read
;zos.c:106: if (data==10 || data==13)
	ld	c, a
	sub	a, #0x0a
	jr	Z, 00101$
	ld	a, c
	sub	a, #0x0d
	jr	NZ, 00102$
00101$:
;zos.c:108: newline();
	call	_newline
;zos.c:109: process_command();
	call	_process_command
;zos.c:110: command_pos=0;
	ld	hl, #_command_pos
	ld	(hl), #0x00
;zos.c:111: return 1;
	ld	a, #0x01
	ret
00102$:
;zos.c:113: if (data == 8 && command_pos>0)
	ld	a, c
	sub	a, #0x08
	jr	NZ, 00105$
	ld	a, (_command_pos+0)
	or	a, a
	jr	Z, 00105$
;zos.c:115: backspace();
	call	_backspace
;zos.c:116: --command_pos;
	ld	hl, #_command_pos
	dec	(hl)
;zos.c:117: return 0;
	xor	a, a
	ret
00105$:
;zos.c:119: if (data>=32 && command_pos < 30)
	ld	a, c
	sub	a, #0x20
	jr	C, 00111$
	ld	a, (_command_pos+0)
	sub	a, #0x1e
	jr	NC, 00111$
;zos.c:121: command_buffer[command_pos++]=data;
	ld	de, #_command_buffer+0
	ld	a, (_command_pos+0)
	ld	b, a
	ld	hl, #_command_pos
	inc	(hl)
	ld	l, b
	ld	h, #0x00
	add	hl, de
	ld	(hl), c
;zos.c:122: print_char(data);
	push	de
	ld	a, c
	call	_print_char
	call	_gpu_flush
	pop	de
;zos.c:124: command_buffer[command_pos]=0;
	ld	hl, (_command_pos)
	ld	h, #0x00
	add	hl, de
	ld	(hl), #0x00
00111$:
;zos.c:127: return 0;
	xor	a, a
;zos.c:128: }
	ret
;zos.c:130: void main()
;	---------------------------------
; Function main
; ---------------------------------
_main::
;zos.c:132: gpu_clear();
	call	_gpu_clear
;zos.c:133: command_pos=0;
	ld	hl, #_command_pos
	ld	(hl), #0x00
;zos.c:134: cls();
	call	_cls
;zos.c:135: while (1)
00105$:
;zos.c:137: print_prompt();
	call	_print_prompt
;zos.c:138: gpu_flush();
	call	_gpu_flush
;zos.c:139: while (!process_input());
00101$:
	call	_process_input
	or	a, a
	jr	NZ, 00105$
;zos.c:141: }
	jr	00101$
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
