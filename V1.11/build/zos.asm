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
	.globl _load_run
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
	.globl _args_buffer
	.globl _command_buffer
;--------------------------------------------------------
; special function registers
;--------------------------------------------------------
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _DATA
_command_buffer::
	.ds 64
_args_buffer::
	.ds 16
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
;zos.c:10: void print_prompt()
;	---------------------------------
; Function print_prompt
; ---------------------------------
_print_prompt::
;zos.c:12: const char* os_prompt="zOS>";
;zos.c:13: print_text(os_prompt);
	ld	hl, #___str_0
;zos.c:14: }
	jp	_print_text
___str_0:
	.ascii "zOS>"
	.db 0x00
;zos.c:17: byte load_program(const char* filename)
;	---------------------------------
; Function load_program
; ---------------------------------
_load_program::
;zos.c:19: byte handle = open_file(filename,0);
	xor	a, a
	push	af
	inc	sp
	call	_open_file
;zos.c:20: if (handle != 0xFF)
	ld	c, a
	inc	a
	jr	Z, 00102$
;zos.c:23: read_file(handle, program_buffer, 0xE000);
	push	bc
	ld	hl, #0xe000
	push	hl
	ld	de, #0x1000
	ld	a, c
	call	_read_file
	pop	bc
;zos.c:24: close_file(handle);
	ld	a, c
	call	_close_file
;zos.c:25: return 1;
	ld	a, #0x01
	ret
00102$:
;zos.c:29: print_text("File not found");
	ld	hl, #___str_1
	call	_print_text
;zos.c:30: newline();
	call	_newline
;zos.c:32: return 0;
	xor	a, a
;zos.c:33: }
	ret
___str_1:
	.ascii "File not found"
	.db 0x00
;zos.c:36: void dir()
;	---------------------------------
; Function dir
; ---------------------------------
_dir::
	push	ix
	ld	ix,#0
	add	ix,sp
	push	af
;zos.c:39: byte rc=list_dir("/",command_buffer,&size);
	ld	hl, #0
	add	hl, sp
	push	hl
	ld	de, #_command_buffer
	ld	hl, #___str_2
	call	_list_dir
;zos.c:40: if (rc!=200)
	ld	c, a
	sub	a, #0xc8
	jr	Z, 00110$
;zos.c:42: print_text("Cannot read directory");
	push	bc
	ld	hl, #___str_3
	call	_print_text
	call	_newline
	pop	bc
;zos.c:45: while (rc==200)
00110$:
00103$:
	ld	a, c
	sub	a, #0xc8
	jr	NZ, 00106$
;zos.c:47: print_text(command_buffer);
	ld	hl, #_command_buffer
	call	_print_text
;zos.c:48: print_text("  ");
	ld	hl, #___str_4
	call	_print_text
;zos.c:49: print_word(size);
	pop	hl
	push	hl
	call	_print_word
;zos.c:50: newline();
	call	_newline
;zos.c:51: rc=list_next(command_buffer,&size);
	ld	hl, #0
	add	hl, sp
	ex	de, hl
	ld	hl, #_command_buffer
	call	_list_next
	ld	c, a
	jr	00103$
00106$:
;zos.c:53: }
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
;zos.c:55: void lsp_file(const char* filename)
;	---------------------------------
; Function lsp_file
; ---------------------------------
_lsp_file::
;zos.c:57: load_sprites(filename,0);
	xor	a, a
	push	af
	inc	sp
	call	_load_sprites
;zos.c:58: }
	ret
;zos.c:60: void cat_file(const char* filename)
;	---------------------------------
; Function cat_file
; ---------------------------------
_cat_file::
;zos.c:62: byte handle = open_file(filename,0);
	xor	a, a
	push	af
	inc	sp
	call	_open_file
;zos.c:63: if (handle != 0xFF)
	ld	c, a
	inc	a
	ret	Z
;zos.c:65: word act=1;
	ld	de, #0x0001
;zos.c:66: while (act>0)
00103$:
	ld	a, d
	or	a, e
	jr	Z, 00105$
;zos.c:68: act = read_file(handle, command_buffer, 30);
	push	bc
	ld	hl, #0x001e
	push	hl
	ld	de, #_command_buffer
	ld	a, c
	call	_read_file
	pop	bc
;zos.c:69: if (act>0)
	ld	a, d
	or	a, e
	jr	Z, 00103$
;zos.c:71: command_buffer[act]=0;
	ld	hl, #_command_buffer
	add	hl, de
	ld	(hl), #0x00
;zos.c:72: print_text(command_buffer);
	push	bc
	push	de
	ld	hl, #_command_buffer
	call	_print_text
	pop	de
	pop	bc
	jr	00103$
00105$:
;zos.c:75: close_file(handle);
	ld	a, c
;zos.c:77: }
	jp	_close_file
;zos.c:79: byte load_run()
;	---------------------------------
; Function load_run
; ---------------------------------
_load_run::
	push	ix
	ld	ix,#0
	add	ix,sp
	push	af
;zos.c:83: byte last_space=1;
	ld	c, #0x01
;zos.c:84: for(i=0;i<CMD_BUF_SIZE;++i)
	ld	-2 (ix), #0x00
	ld	-1 (ix), #0x00
00114$:
;zos.c:86: if (command_buffer[i]==0 || arg_index==7) break;
	ld	a, #<(_command_buffer)
	add	a, -1 (ix)
	ld	e, a
	ld	a, #>(_command_buffer)
	adc	a, #0x00
	ld	d, a
	ld	a, (de)
	ld	b, a
	or	a, a
	jr	Z, 00109$
	ld	a, -2 (ix)
	sub	a, #0x07
	jr	Z, 00109$
;zos.c:87: if (command_buffer[i]==32) /* Space */
	ld	a, b
	sub	a, #0x20
	jr	NZ, 00107$
;zos.c:89: command_buffer[i]=0;
	xor	a, a
	ld	(de), a
;zos.c:90: last_space=1;
	ld	c, #0x01
	jr	00115$
00107$:
;zos.c:94: if (last_space!=0)
	ld	a, c
	or	a, a
	jr	Z, 00105$
;zos.c:96: args_buffer[arg_index++] = &command_buffer[i];
	ld	l, -2 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, #0x00
;	spillPairReg hl
;	spillPairReg hl
	inc	-2 (ix)
	add	hl, hl
	ld	bc, #_args_buffer
	add	hl, bc
	ld	(hl), e
	inc	hl
	ld	(hl), d
00105$:
;zos.c:98: last_space=0;
	ld	c, #0x00
00115$:
;zos.c:84: for(i=0;i<CMD_BUF_SIZE;++i)
	inc	-1 (ix)
	ld	a, -1 (ix)
	sub	a, #0x40
	jr	C, 00114$
00109$:
;zos.c:101: args_buffer[arg_index]=0;
	ld	l, -2 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, #0x00
;	spillPairReg hl
;	spillPairReg hl
	add	hl, hl
	ld	de, #_args_buffer
	add	hl, de
	xor	a, a
	ld	(hl), a
	inc	hl
	ld	(hl), a
;zos.c:102: if (arg_index>0)
	ld	a, -2 (ix)
	or	a, a
	jr	Z, 00113$
;zos.c:104: if (load_program(args_buffer[0]))
	ld	hl, (#_args_buffer + 0)
	call	_load_program
	or	a, a
	jr	Z, 00113$
;zos.c:107: user_program(&args_buffer[1]);
	ld	hl, #(_args_buffer + 2)
	call	0x1000
;zos.c:108: return 1;
	ld	a, #0x01
	jr	00116$
00113$:
;zos.c:111: return 0;
	xor	a, a
00116$:
;zos.c:112: }
	ld	sp, ix
	pop	ix
	ret
;zos.c:114: void process_command()
;	---------------------------------
; Function process_command
; ---------------------------------
_process_command::
;zos.c:117: if (strcmp(command_buffer, "run") == 0)
	ld	de, #___str_5
	ld	hl, #_command_buffer
	call	_strcmp
	ld	c, a
	or	a, a
	jr	NZ, 00122$
;zos.c:119: args_buffer[0]=0;
	ld	hl, #0x0000
	ld	(_args_buffer), hl
;zos.c:120: user_program(args_buffer);
	ld	hl, #_args_buffer
	jp	0x1000
00122$:
;zos.c:123: if (strcmp(command_buffer, "cls") == 0)
	ld	de, #___str_6
	ld	hl, #_command_buffer
	call	_strcmp
	or	a, a
;zos.c:124: cls();
	jp	Z,_cls
;zos.c:126: if (strcmp(command_buffer, "dir") == 0)
	ld	de, #___str_7
	ld	hl, #_command_buffer
	call	_strcmp
	or	a, a
;zos.c:127: dir();
	jp	Z,_dir
;zos.c:130: lsp_file(command_buffer+4);
;zos.c:129: if (command_pos>4 && strncmp(command_buffer, "lsp ", 4)==0)
	ld	a, #0x04
	ld	hl, #_command_pos
	sub	a, (hl)
	jr	NC, 00112$
	ld	a, #0x04
	push	af
	inc	sp
	ld	de, #___str_8
	ld	hl, #_command_buffer
	call	_strncmp
	or	a, a
	jr	NZ, 00112$
;zos.c:130: lsp_file(command_buffer+4);
	ld	hl, #(_command_buffer + 4)
	jp	_lsp_file
00112$:
;zos.c:132: if (command_pos>4 && strncmp(command_buffer, "cat ", 4)==0)
	ld	a, #0x04
	ld	hl, #_command_pos
	sub	a, (hl)
	jr	NC, 00108$
	ld	a, #0x04
	push	af
	inc	sp
	ld	de, #___str_9
	ld	hl, #_command_buffer
	call	_strncmp
	or	a, a
	jr	NZ, 00108$
;zos.c:133: cat_file(command_buffer+4);
	ld	hl, #(_command_buffer + 4)
	jp	_cat_file
00108$:
;zos.c:135: if (command_pos>5 && strncmp(command_buffer, "load ", 5)==0)
	ld	a, #0x05
	ld	hl, #_command_pos
	sub	a, (hl)
	jr	NC, 00104$
	ld	a, #0x05
	push	af
	inc	sp
	ld	de, #___str_10
	ld	hl, #_command_buffer
	call	_strncmp
	or	a, a
	jr	NZ, 00104$
;zos.c:136: load_program(command_buffer+5);
	ld	hl, #(_command_buffer + 5)
	jp	_load_program
00104$:
;zos.c:138: if (!load_run())
	call	_load_run
	or	a, a
	ret	NZ
;zos.c:140: print_text("Unknown Command");
	ld	hl, #___str_11
	call	_print_text
;zos.c:141: newline();
;zos.c:143: }
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
;zos.c:145: void print_char(byte b)
;	---------------------------------
; Function print_char
; ---------------------------------
_print_char::
	push	af
	ld	c, a
;zos.c:148: text[0]=b;
	ld	hl, #0
	add	hl, sp
	ex	de, hl
	ld	a, c
	ld	(de), a
;zos.c:149: text[1]=0;
	ld	c, e
	ld	b, d
	inc	bc
	xor	a, a
	ld	(bc), a
;zos.c:150: print_text(text);
	ex	de, hl
	call	_print_text
;zos.c:151: }
	pop	af
	ret
;zos.c:153: void backspace()
;	---------------------------------
; Function backspace
; ---------------------------------
_backspace::
;zos.c:154: {}
	ret
;zos.c:156: byte process_input()
;	---------------------------------
; Function process_input
; ---------------------------------
_process_input::
;zos.c:158: if (!input_empty())
	call	_input_empty
	or	a, a
	jr	NZ, 00112$
;zos.c:160: word data = input_read();
	call	_input_read
;zos.c:161: if (data==10 || data==13)
	ld	c, e
	ld	b, d
	ld	a, c
	sub	a, #0x0a
	or	a, b
	jr	Z, 00101$
	ld	a, c
	sub	a, #0x0d
	or	a, b
	jr	NZ, 00102$
00101$:
;zos.c:163: newline();
	call	_newline
;zos.c:164: process_command();
	call	_process_command
;zos.c:165: command_pos=0;
	ld	hl, #_command_pos
	ld	(hl), #0x00
;zos.c:166: return 1;
	ld	a, #0x01
	ret
00102$:
;zos.c:168: if (data == 8 && command_pos>0)
	ld	a, c
	sub	a, #0x08
	or	a, b
	jr	NZ, 00105$
	ld	a, (_command_pos+0)
	or	a, a
	jr	Z, 00105$
;zos.c:170: backspace();
	call	_backspace
;zos.c:171: --command_pos;
	ld	hl, #_command_pos
	dec	(hl)
;zos.c:172: return 0;
	xor	a, a
	ret
00105$:
;zos.c:174: if (data>=32 && data<127 && command_pos < (CMD_BUF_SIZE-2))
	ld	a, c
	sub	a, #0x20
	ld	a, b
	sbc	a, #0x00
	jr	C, 00112$
	ld	a, c
	sub	a, #0x7f
	ld	a, b
	sbc	a, #0x00
	jr	NC, 00112$
	ld	a, (_command_pos+0)
	sub	a, #0x3e
	jr	NC, 00112$
;zos.c:176: byte ch=(byte)data;
;zos.c:177: command_buffer[command_pos++]=ch;
	ld	bc, #_command_buffer+0
	ld	a, (_command_pos+0)
	ld	d, a
	ld	hl, #_command_pos
	inc	(hl)
	ld	l, d
	ld	h, #0x00
	add	hl, bc
	ld	(hl), e
;zos.c:178: print_char(ch);
	push	bc
	ld	a, e
	call	_print_char
	pop	bc
;zos.c:179: command_buffer[command_pos]=0;
	ld	hl, (_command_pos)
	ld	h, #0x00
	add	hl, bc
	ld	(hl), #0x00
00112$:
;zos.c:182: return 0;
	xor	a, a
;zos.c:183: }
	ret
;zos.c:185: void main()
;	---------------------------------
; Function main
; ---------------------------------
_main::
;zos.c:187: command_pos=0;
	ld	hl, #_command_pos
	ld	(hl), #0x00
;zos.c:188: cls();
	call	_cls
;zos.c:189: while (1)
00105$:
;zos.c:191: print_prompt();
	call	_print_prompt
;zos.c:192: while (!process_input());
00101$:
	call	_process_input
	or	a, a
	jr	NZ, 00105$
;zos.c:194: }
	jr	00101$
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
