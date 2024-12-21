;--------------------------------------------------------
; File Created by SDCC : free open source ISO C Compiler 
; Version 4.2.2 #13407 (MINGW64)
;--------------------------------------------------------
	.module ll
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _cls
	.globl _println
	.globl _print
	.globl _printc
	.globl _send_command
	.globl _strlen
	.globl _sendchar
	.globl _strcmp
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
;ll.c:4: char strcmp(const byte* s1, const byte* s2)
;	---------------------------------
; Function strcmp
; ---------------------------------
_strcmp::
	push	ix
	ld	ix,#0
	add	ix,sp
	dec	sp
	ld	c, l
	ld	b, h
;ll.c:6: while (1)
00113$:
;ll.c:8: byte b1=*s1;
	ld	a, (bc)
	ld	l, a
;	spillPairReg hl
;	spillPairReg hl
;ll.c:9: byte b2=*s2;
	ld	a, (de)
	ld	-1 (ix), a
;ll.c:10: byte e1=(b1==0);
	ld	a, l
	or	a, a
	ld	a, #0x01
	jr	Z, 00153$
	xor	a, a
00153$:
	ld	h, a
;	spillPairReg hl
;	spillPairReg hl
;ll.c:11: byte e2=(b2==0);
	ld	a, -1 (ix)
	or	a, a
	ld	a, #0x01
	jr	Z, 00155$
	xor	a, a
00155$:
;ll.c:12: if (e1 && e2) return 0;
	inc	h
	dec	h
	jr	Z, 00102$
	or	a, a
	jr	Z, 00102$
	xor	a, a
	jr	00115$
00102$:
;ll.c:13: if (e1) return -1;
	inc	h
	dec	h
	jr	Z, 00105$
	ld	a, #0xff
	jr	00115$
00105$:
;ll.c:14: if (e2) return 1;
	or	a, a
	jr	Z, 00107$
	ld	a, #0x01
	jr	00115$
00107$:
;ll.c:15: if (b1>b2) return 1;
	ld	a, -1 (ix)
	sub	a, l
	jr	NC, 00109$
	ld	a, #0x01
	jr	00115$
00109$:
;ll.c:16: if (b2>b1) return -1;
	ld	a, l
	sub	a, -1 (ix)
	jr	NC, 00111$
	ld	a, #0xff
	jr	00115$
00111$:
;ll.c:17: ++s1;
	inc	bc
;ll.c:18: ++s2;
	inc	de
	jr	00113$
00115$:
;ll.c:20: }
	inc	sp
	pop	ix
	ret
;ll.c:22: void sendchar(byte b)
;	---------------------------------
; Function sendchar
; ---------------------------------
_sendchar::
;ll.c:27: __endasm;
	out	(0),a
;ll.c:28: }
	ret
;ll.c:30: byte strlen(const byte* s)
;	---------------------------------
; Function strlen
; ---------------------------------
_strlen::
;ll.c:34: return res;
	ld	c, #0x00
00103$:
;ll.c:33: for(;*s;++s,++res);
	ld	a, (hl)
	or	a, a
	jr	Z, 00101$
	inc	hl
	inc	c
	jr	00103$
00101$:
;ll.c:34: return res;
	ld	a, c
;ll.c:35: }
	ret
;ll.c:37: void send_command(const byte* data, byte len)
;	---------------------------------
; Function send_command
; ---------------------------------
_send_command::
;ll.c:44: __endasm;
	ld	b,a
	otir
;ll.c:45: }
	pop	hl
	inc	sp
	jp	(hl)
;ll.c:47: void printc(byte c)
;	---------------------------------
; Function printc
; ---------------------------------
_printc::
;ll.c:50: {
	ld	c, a
	sub	a, #0x0d
	jr	NZ, 00102$
;ll.c:52: }
	ld	a, #0x04
	jp	_sendchar
00102$:
;ll.c:56: 
	push	bc
	ld	a, #0x1e
	call	_sendchar
	ld	a, #0x01
	call	_sendchar
	pop	bc
;ll.c:58: {
	ld	a, c
;ll.c:60: header[0]=30;
	jp	_sendchar
;ll.c:63: send_command(s,header[1]);
;	---------------------------------
; Function print
; ---------------------------------
_print::
	push	ix
	ld	ix,#0
	add	ix,sp
	push	af
	ex	de, hl
;ll.c:66: void println(const byte* s)
	ld	-2 (ix), #0x1e
;ll.c:67: {
;	spillPairReg hl
;	spillPairReg hl
	ex	de, hl
	push	hl
;	spillPairReg hl
;	spillPairReg hl
	call	_strlen
;ll.c:68: print(s);
	ld	-1 (ix), a
	ld	a, #0x02
	push	af
	inc	sp
	ld	hl, #3
	add	hl, sp
	call	_send_command
	pop	de
;ll.c:69: sendchar(4);
	ld	a, -1 (ix)
	push	af
	inc	sp
	ex	de, hl
	call	_send_command
;ll.c:70: }
	ld	sp, ix
	pop	ix
	ret
;ll.c:72: 
;	---------------------------------
; Function println
; ---------------------------------
_println::
;ll.c:74: {
	call	_print
;ll.c:75: byte cmd[2];
	ld	a, #0x04
;ll.c:76: cmd[0]=0;
	jp	_sendchar
;ll.c:79: }
;	---------------------------------
; Function cls
; ---------------------------------
_cls::
	push	af
;ll.c:82: ERROR: no line number 82 in file ll.c
	ld	hl, #0
	add	hl, sp
	ex	de, hl
	xor	a, a
	ld	(de), a
;ll.c:83: ERROR: no line number 83 in file ll.c
	ld	l, e
;	spillPairReg hl
;	spillPairReg hl
	ld	h, d
;	spillPairReg hl
;	spillPairReg hl
	inc	hl
	ld	(hl), #0x01
;ll.c:84: ERROR: no line number 84 in file ll.c
	ld	a, #0x02
	push	af
	inc	sp
	ex	de, hl
	call	_send_command
;ll.c:85: ERROR: no line number 85 in file ll.c
	pop	af
	ret
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
