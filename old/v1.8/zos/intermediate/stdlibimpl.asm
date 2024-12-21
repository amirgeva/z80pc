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
	.globl _div_mod
	.globl _print_char
	.globl _strcmp_impl
	.globl _strncmp_impl
	.globl _testabi
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
;../stdlib/stdlibimpl.c:3: byte testabi(byte a, const char* name, word b)
;	---------------------------------
; Function testabi
; ---------------------------------
_testabi::
	ld	c, a
;../stdlib/stdlibimpl.c:5: byte w=name[0];
	ld	a, (de)
;../stdlib/stdlibimpl.c:6: return w+b+a;
	ld	iy, #2
	add	iy, sp
	ld	b, 0 (iy)
	add	a, b
	add	a, c
;../stdlib/stdlibimpl.c:7: }
	pop	hl
	pop	bc
	jp	(hl)
;../stdlib/stdlibimpl.c:9: char strncmp_impl(const char* a, const char* b, byte n)
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
;../stdlib/stdlibimpl.c:11: if (!a && !b) return 0;
	ld	a, -2 (ix)
	or	a, -3 (ix)
	jr	NZ, 00102$
	ld	a, -4 (ix)
	or	a, -5 (ix)
	jr	NZ, 00102$
	xor	a, a
	jr	00121$
00102$:
;../stdlib/stdlibimpl.c:12: if (!a) return 1;
	ld	a, -2 (ix)
	or	a, -3 (ix)
	jr	NZ, 00105$
	ld	a, #0x01
	jr	00121$
00105$:
;../stdlib/stdlibimpl.c:13: if (!b) return -1;
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
;../stdlib/stdlibimpl.c:14: for(;n>0;--n)
	ld	a, -1 (ix)
	or	a, a
	jr	Z, 00118$
;../stdlib/stdlibimpl.c:16: if (*a==0 && *b==0) return 0;
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
;../stdlib/stdlibimpl.c:17: if (*a==0) return 1;
	or	a, a
	jr	NZ, 00112$
	ld	a, #0x01
	jr	00121$
00112$:
;../stdlib/stdlibimpl.c:18: if (*b==0) return -1;
	ld	e, (hl)
	inc	e
	dec	e
	jr	NZ, 00114$
	ld	a, #0xff
	jr	00121$
00114$:
;../stdlib/stdlibimpl.c:19: if (*a==*b) 
	cp	a, e
	jr	NZ, 00116$
;../stdlib/stdlibimpl.c:21: ++a;
;../stdlib/stdlibimpl.c:22: ++b;
	inc	hl
	inc	bc
;../stdlib/stdlibimpl.c:23: continue;
	jr	00117$
00116$:
;../stdlib/stdlibimpl.c:25: return *a<*b?-1:1;
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
;../stdlib/stdlibimpl.c:14: for(;n>0;--n)
	dec	-1 (ix)
	jr	00120$
00118$:
;../stdlib/stdlibimpl.c:27: return 0;
	xor	a, a
00121$:
;../stdlib/stdlibimpl.c:28: }
	ld	sp, ix
	pop	ix
	pop	hl
	inc	sp
	jp	(hl)
;../stdlib/stdlibimpl.c:30: char strcmp_impl(const char* a, const char* b)
;	---------------------------------
; Function strcmp_impl
; ---------------------------------
_strcmp_impl::
;../stdlib/stdlibimpl.c:32: return strncmp_impl(a,b,255);
	ld	a, #0xff
	push	af
	inc	sp
	call	_strncmp_impl
;../stdlib/stdlibimpl.c:33: }
	ret
;../stdlib/stdlibimpl.c:44: void print_word_impl(word* pw)
;	---------------------------------
; Function print_word_impl
; ---------------------------------
_print_word_impl::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	iy, #-8
	add	iy, sp
	ld	sp, iy
;../stdlib/stdlibimpl.c:46: word w=*pw;
	ld	c, (hl)
	inc	hl
	ld	b, (hl)
;../stdlib/stdlibimpl.c:48: if (w==0) print_char('0');
	ld	a, b
	or	a, c
	jr	NZ, 00114$
	ld	a, #0x30
	call	_print_char
	jr	00110$
;../stdlib/stdlibimpl.c:54: while (w>0)
00114$:
	ld	e, #0x00
00101$:
	ld	a, b
	or	a, c
	jr	Z, 00115$
;../stdlib/stdlibimpl.c:56: dm.a=w;
	inc	sp
	inc	sp
	push	bc
;../stdlib/stdlibimpl.c:57: dm.b=10;
	ld	-6 (ix), #0x0a
;../stdlib/stdlibimpl.c:58: div_mod(&dm);
	push	de
	ld	hl, #2
	add	hl, sp
	call	_div_mod
	pop	de
;../stdlib/stdlibimpl.c:59: text[i++]=48+dm.b;
	push	de
	ld	d, #0x00
	ld	hl, #5
	add	hl, sp
	add	hl, de
	pop	de
	ld	c, l
	ld	b, h
	inc	e
	ld	a, -6 (ix)
	add	a, #0x30
	ld	(bc), a
;../stdlib/stdlibimpl.c:60: w=dm.a;
	pop	bc
	push	bc
	jr	00101$
;../stdlib/stdlibimpl.c:62: do
00115$:
	ld	hl, #3
	add	hl, sp
	ld	c, l
	ld	b, h
00104$:
;../stdlib/stdlibimpl.c:64: print_char(text[--i]);
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
;../stdlib/stdlibimpl.c:65: } while (i>0);
	ld	a, e
	or	a, a
	jr	NZ, 00104$
00110$:
;../stdlib/stdlibimpl.c:67: }
	ld	sp, ix
	pop	ix
	ret
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
