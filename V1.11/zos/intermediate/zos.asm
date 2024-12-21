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
	.globl _lsp_file
	.globl _dir
	.globl _load_program
	.globl _print_prompt
	.globl _load_sprites
	.globl _close_file
	.globl _read_file
	.globl _open_file
	.globl _list_next
	.globl _list_dir
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
	call	_print_text
;zos.c:26: newline();
;zos.c:28: }
	jp	_newline
___str_1:
	.ascii "File not found"
	.db 0x00
;zos.c:31: void dir()
;	---------------------------------
; Function dir
; ---------------------------------
_dir::
	push	ix
	ld	ix,#0
	add	ix,sp
	push	af
;zos.c:34: byte rc=list_dir("/",command_buffer,&size);
	ld	hl, #0
	add	hl, sp
	push	hl
	ld	de, #_command_buffer
	ld	hl, #___str_2
	call	_list_dir
;zos.c:35: if (rc!=200)
	ld	c, a
	sub	a, #0xc8
	jr	Z, 00110$
;zos.c:37: print_text("Cannot read directory");
	push	bc
	ld	hl, #___str_3
	call	_print_text
	call	_newline
	pop	bc
;zos.c:40: while (rc==200)
00110$:
00103$:
	ld	a, c
	sub	a, #0xc8
	jr	NZ, 00106$
;zos.c:42: print_text(command_buffer);
	ld	hl, #_command_buffer
	call	_print_text
;zos.c:43: print_text("  ");
	ld	hl, #___str_4
	call	_print_text
;zos.c:44: print_word(size);
	pop	hl
	push	hl
	call	_print_word
;zos.c:45: newline();
	call	_newline
;zos.c:46: rc=list_next(command_buffer,&size);
	ld	hl, #0
	add	hl, sp
	ex	de, hl
	ld	hl, #_command_buffer
	call	_list_next
	ld	c, a
	jr	00103$
00106$:
;zos.c:48: }
	ld	sp, ix
	pop	ix
	ret
___str_2:
	.ascii "/"
	.db 0x00
___str_3:
	.ascii "Cannot read directory"
	.db 0x00
___str_4:
	.ascii "  "
	.db 0x00
;zos.c:50: void lsp_file(const char* filename)
;	---------------------------------
; Function lsp_file
; ---------------------------------
_lsp_file::
;zos.c:52: load_sprites(filename,0);
	xor	a, a
	push	af
	inc	sp
	call	_load_sprites
;zos.c:53: }
	ret
;zos.c:55: void cat_file(const char* filename)
;	---------------------------------
; Function cat_file
; ---------------------------------
_cat_file::
;zos.c:57: byte handle = open_file(filename,0);
	xor	a, a
	push	af
	inc	sp
	call	_open_file
;zos.c:58: if (handle != 0xFF)
	ld	c, a
	inc	a
	ret	Z
;zos.c:60: word act=1;
	ld	de, #0x0001
;zos.c:61: while (act>0)
00103$:
	ld	a, d
	or	a, e
	jr	Z, 00105$
;zos.c:63: act = read_file(handle, command_buffer, 30);
	push	bc
	ld	hl, #0x001e
	push	hl
	ld	de, #_command_buffer
	ld	a, c
	call	_read_file
	pop	bc
;zos.c:64: if (act>0)
	ld	a, d
	or	a, e
	jr	Z, 00103$
;zos.c:66: command_buffer[act]=0;
	ld	hl, #_command_buffer
	add	hl, de
	ld	(hl), #0x00
;zos.c:67: print_text(command_buffer);
	push	bc
	push	de
	ld	hl, #_command_buffer
	call	_print_text
	pop	de
	pop	bc
	jr	00103$
00105$:
;zos.c:70: close_file(handle);
	ld	a, c
;zos.c:72: }
	jp	_close_file
;zos.c:74: void process_command()
;	---------------------------------
; Function process_command
; ---------------------------------
_process_command::
;zos.c:78: if (strcmp(command_buffer, "run") == 0)
	ld	de, #___str_5
	ld	hl, #_command_buffer
	call	_strcmp
	ld	c, a
	or	a, a
;zos.c:79: user_program();
	jp	Z,0x1000
;zos.c:81: if (strcmp(command_buffer, "cls") == 0)
	ld	de, #___str_6
	ld	hl, #_command_buffer
	call	_strcmp
	or	a, a
;zos.c:82: cls();
	jp	Z,_cls
;zos.c:84: if (strcmp(command_buffer, "dir") == 0)
	ld	de, #___str_7
	ld	hl, #_command_buffer
	call	_strcmp
	or	a, a
;zos.c:85: dir();
	jp	Z,_dir
;zos.c:88: lsp_file(command_buffer+4);
;zos.c:87: if (command_pos>4 && strncmp(command_buffer, "lsp ", 4)==0)
	ld	a, #0x04
	ld	hl, #_command_pos
	sub	a, (hl)
	jr	NC, 00110$
	ld	a, #0x04
	push	af
	inc	sp
	ld	de, #___str_8
	ld	hl, #_command_buffer
	call	_strncmp
	or	a, a
	jr	NZ, 00110$
;zos.c:88: lsp_file(command_buffer+4);
	ld	hl, #(_command_buffer + 4)
	jp	_lsp_file
00110$:
;zos.c:90: if (command_pos>4 && strncmp(command_buffer, "cat ", 4)==0)
	ld	a, #0x04
	ld	hl, #_command_pos
	sub	a, (hl)
	jr	NC, 00106$
	ld	a, #0x04
	push	af
	inc	sp
	ld	de, #___str_9
	ld	hl, #_command_buffer
	call	_strncmp
	or	a, a
	jr	NZ, 00106$
;zos.c:91: cat_file(command_buffer+4);
	ld	hl, #(_command_buffer + 4)
	jp	_cat_file
00106$:
;zos.c:93: if (command_pos>5 && strncmp(command_buffer, "load ", 5)==0)
	ld	a, #0x05
	ld	hl, #_command_pos
	sub	a, (hl)
	jr	NC, 00102$
	ld	a, #0x05
	push	af
	inc	sp
	ld	de, #___str_10
	ld	hl, #_command_buffer
	call	_strncmp
	or	a, a
	jr	NZ, 00102$
;zos.c:94: load_program(command_buffer+5);
	ld	hl, #(_command_buffer + 5)
	jp	_load_program
00102$:
;zos.c:97: print_text("Unknown Command");
	ld	hl, #___str_11
	call	_print_text
;zos.c:98: newline();
;zos.c:100: }
	jp	_newline
___str_5:
	.ascii "run"
	.db 0x00
___str_6:
	.ascii "cls"
	.db 0x00
___str_7:
	.ascii "dir"
	.db 0x00
___str_8:
	.ascii "lsp "
	.db 0x00
___str_9:
	.ascii "cat "
	.db 0x00
___str_10:
	.ascii "load "
	.db 0x00
___str_11:
	.ascii "Unknown Command"
	.db 0x00
;zos.c:102: void print_char(byte b)
;	---------------------------------
; Function print_char
; ---------------------------------
_print_char::
	push	af
	ld	c, a
;zos.c:105: text[0]=b;
	ld	hl, #0
	add	hl, sp
	ex	de, hl
	ld	a, c
	ld	(de), a
;zos.c:106: text[1]=0;
	ld	c, e
	ld	b, d
	inc	bc
	xor	a, a
	ld	(bc), a
;zos.c:107: print_text(text);
	ex	de, hl
	call	_print_text
;zos.c:108: }
	pop	af
	ret
;zos.c:110: void backspace()
;	---------------------------------
; Function backspace
; ---------------------------------
_backspace::
;zos.c:111: {}
	ret
;zos.c:113: byte process_input()
;	---------------------------------
; Function process_input
; ---------------------------------
_process_input::
;zos.c:115: if (!input_empty())
	call	_input_empty
	or	a, a
	jr	NZ, 00111$
;zos.c:117: byte data = input_read();
	call	_input_read
;zos.c:118: if (data==10 || data==13)
	ld	c, a
	sub	a, #0x0a
	jr	Z, 00101$
	ld	a, c
	sub	a, #0x0d
	jr	NZ, 00102$
00101$:
;zos.c:120: newline();
	call	_newline
;zos.c:121: process_command();
	call	_process_command
;zos.c:122: command_pos=0;
	ld	hl, #_command_pos
	ld	(hl), #0x00
;zos.c:123: return 1;
	ld	a, #0x01
	ret
00102$:
;zos.c:125: if (data == 8 && command_pos>0)
	ld	a, c
	sub	a, #0x08
	jr	NZ, 00105$
	ld	a, (_command_pos+0)
	or	a, a
	jr	Z, 00105$
;zos.c:127: backspace();
	call	_backspace
;zos.c:128: --command_pos;
	ld	hl, #_command_pos
	dec	(hl)
;zos.c:129: return 0;
	xor	a, a
	ret
00105$:
;zos.c:131: if (data>=32 && command_pos < 30)
	ld	a, c
	sub	a, #0x20
	jr	C, 00111$
	ld	a, (_command_pos+0)
	sub	a, #0x1e
	jr	NC, 00111$
;zos.c:133: command_buffer[command_pos++]=data;
	ld	de, #_command_buffer+0
	ld	a, (_command_pos+0)
	ld	b, a
	ld	hl, #_command_pos
	inc	(hl)
	ld	l, b
	ld	h, #0x00
	add	hl, de
	ld	(hl), c
;zos.c:134: print_char(data);
	push	de
	ld	a, c
	call	_print_char
	pop	de
;zos.c:135: command_buffer[command_pos]=0;
	ld	hl, (_command_pos)
	ld	h, #0x00
	add	hl, de
	ld	(hl), #0x00
00111$:
;zos.c:138: return 0;
	xor	a, a
;zos.c:139: }
	ret
;zos.c:141: void main()
;	---------------------------------
; Function main
; ---------------------------------
_main::
;zos.c:143: command_pos=0;
	ld	hl, #_command_pos
	ld	(hl), #0x00
;zos.c:144: cls();
	call	_cls
;zos.c:145: while (1)
00105$:
;zos.c:147: print_prompt();
	call	_print_prompt
;zos.c:148: while (!process_input());
00101$:
	call	_process_input
	or	a, a
	jr	NZ, 00105$
;zos.c:150: }
	jr	00101$
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
