;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 4.2.0 #13081 (MINGW64)
;--------------------------------------------------------
	.module stdlibimpl
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _print_word_impl
	.globl _print_char
	.globl _strcmp_impl
	.globl _strncmp_impl
	.globl _testabi
	.globl _div_mod
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
;stdlibimpl.c:3: byte testabi(byte a, const char* name, word b)
;	---------------------------------
; Function testabi
; ---------------------------------
_testabi::
	ld	c, a
;stdlibimpl.c:5: byte w=name[0];
	ld	a, (de)
;stdlibimpl.c:6: return w+b+a;
	ld	iy, #2
	add	iy, sp
	ld	b, 0 (iy)
	add	a, b
	add	a, c
;stdlibimpl.c:7: }
	pop	hl
	pop	bc
	jp	(hl)
;stdlibimpl.c:9: char strncmp_impl(const char* a, const char* b, byte n)
;	---------------------------------
; Function strncmp_impl
; ---------------------------------
_strncmp_impl::
	push	ix
	ld	ix,#0
	add	ix,sp
	push	af
	push	af
	dec	sp
	ld	-3 (ix), l
	ld	-2 (ix), h
	inc	sp
	inc	sp
	push	de
;stdlibimpl.c:11: if (!a && !b) return 0;
	ld	a, -2 (ix)
	or	a, -3 (ix)
	jr	NZ, 00102$
	ld	a, -4 (ix)
	or	a, -5 (ix)
	jr	NZ, 00102$
	xor	a, a
	jr	00121$
00102$:
;stdlibimpl.c:12: if (!a) return 1;
	ld	a, -2 (ix)
	or	a, -3 (ix)
	jr	NZ, 00105$
	ld	a, #0x01
	jr	00121$
00105$:
;stdlibimpl.c:13: if (!b) return -1;
	ld	a, -4 (ix)
	or	a, -5 (ix)
	jr	NZ, 00138$
	ld	a, #0xff
	jr	00121$
00138$:
	pop	hl
	pop	bc
	push	bc
	push	hl
	ld	a, 4 (ix)
	ld	-1 (ix), a
00120$:
;stdlibimpl.c:14: for(;n>0;--n)
	ld	a, -1 (ix)
	or	a, a
	jr	Z, 00118$
;stdlibimpl.c:16: if (*a==0 && *b==0) return 0;
	ld	a, (bc)
	or	a, a
	jr	NZ, 00109$
	ld	e, (hl)
	inc	e
	dec	e
	jr	NZ, 00109$
	xor	a, a
	jr	00121$
00109$:
;stdlibimpl.c:17: if (*a==0) return 1;
	or	a, a
	jr	NZ, 00112$
	ld	a, #0x01
	jr	00121$
00112$:
;stdlibimpl.c:18: if (*b==0) return -1;
	ld	e, (hl)
	inc	e
	dec	e
	jr	NZ, 00114$
	ld	a, #0xff
	jr	00121$
00114$:
;stdlibimpl.c:19: if (*a==*b) 
	cp	a, e
	jr	NZ, 00116$
;stdlibimpl.c:21: ++a;
;stdlibimpl.c:22: ++b;
	inc	hl
	inc	bc
;stdlibimpl.c:23: continue;
	jr	00117$
00116$:
;stdlibimpl.c:25: return *a<*b?-1:1;
	sub	a, e
	jr	NC, 00125$
	ld	bc, #0xffff
	jr	00126$
00125$:
	ld	bc, #0x0001
00126$:
	ld	a, c
	jr	00121$
00117$:
;stdlibimpl.c:14: for(;n>0;--n)
	dec	-1 (ix)
	jr	00120$
00118$:
;stdlibimpl.c:27: return 0;
	xor	a, a
00121$:
;stdlibimpl.c:28: }
	ld	sp, ix
	pop	ix
	pop	hl
	inc	sp
	jp	(hl)
;stdlibimpl.c:30: char strcmp_impl(const char* a, const char* b)
;	---------------------------------
; Function strcmp_impl
; ---------------------------------
_strcmp_impl::
;stdlibimpl.c:32: return strncmp_impl(a,b,255);
	ld	a, #0xff
	push	af
	inc	sp
	call	_strncmp_impl
;stdlibimpl.c:33: }
	ret
;stdlibimpl.c:37: void print_word_impl(word w)
;	---------------------------------
; Function print_word_impl
; ---------------------------------
_print_word_impl::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	iy, #-9
	add	iy, sp
	ld	sp, iy
	ex	de, hl
;stdlibimpl.c:40: if (w==0) print_char('0');
	ld	a, d
	or	a, e
	jr	NZ, 00114$
	ld	a, #0x30
	call	_print_char
	jr	00110$
;stdlibimpl.c:46: while (w>0)
00114$:
	ld	-1 (ix), #0x00
00101$:
	ld	a, d
	or	a, e
	jr	Z, 00115$
;stdlibimpl.c:48: dm.a=w;
	inc	sp
	inc	sp
	push	de
;stdlibimpl.c:49: dm.b=10;
	ld	-7 (ix), #0x0a
;stdlibimpl.c:50: div_mod(&dm);
	ld	hl, #0
	add	hl, sp
	call	_div_mod
;stdlibimpl.c:51: text[i++]=48+dm.b;
	ld	e, -1 (ix)
	ld	d, #0x00
	ld	hl, #3
	add	hl, sp
	add	hl, de
	ex	de, hl
	inc	-1 (ix)
	ld	a, -7 (ix)
	add	a, #0x30
	ld	(de), a
;stdlibimpl.c:52: w=dm.a;
	pop	de
	push	de
	jr	00101$
;stdlibimpl.c:54: do
00115$:
	ld	hl, #3
	add	hl, sp
	ld	c, l
	ld	b, h
	ld	e, -1 (ix)
00104$:
;stdlibimpl.c:56: print_char(text[--i]);
	dec	e
	ld	l, e
	ld	h, #0x00
	add	hl, bc
	ld	d, (hl)
	push	bc
	push	de
	ld	a, d
	call	_print_char
	pop	de
	pop	bc
;stdlibimpl.c:57: } while (i>0);
	ld	a, e
	or	a, a
	jr	NZ, 00104$
00110$:
;stdlibimpl.c:59: }
	ld	sp, ix
	pop	ix
	ret
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
