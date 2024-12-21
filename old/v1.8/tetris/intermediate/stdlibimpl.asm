;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 4.2.0 #13081 (MINGW64)
;--------------------------------------------------------
	.module stdlibimpl
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _strcmp_impl
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
;../stdlib/stdlibimpl.c:4: char strcmp_impl(const char* a, const char* b)
;	---------------------------------
; Function strcmp_impl
; ---------------------------------
_strcmp_impl::
	push	ix
	ld	ix,#0
	add	ix,sp
	push	af
	ld	c, l
	ld	b, h
	inc	sp
	inc	sp
	push	de
;../stdlib/stdlibimpl.c:6: if (!a && !b) return 0;
	ld	a, b
	or	a, c
	jr	NZ, 00102$
	ld	a, -1 (ix)
	or	a, -2 (ix)
	jr	NZ, 00102$
	xor	a, a
	jr	00120$
00102$:
;../stdlib/stdlibimpl.c:7: if (!a) return 1;
	ld	a, b
	or	a, c
	jr	NZ, 00105$
	ld	a, #0x01
	jr	00120$
00105$:
;../stdlib/stdlibimpl.c:8: if (!b) return -1;
	ld	a, -1 (ix)
	or	a, -2 (ix)
	jr	NZ, 00133$
	ld	a, #0xff
	jr	00120$
;../stdlib/stdlibimpl.c:9: while (1)
00133$:
	pop	hl
	push	hl
00118$:
;../stdlib/stdlibimpl.c:11: if (*a==0 && *b==0) return 0;
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
;../stdlib/stdlibimpl.c:12: if (*a==0) return 1;
	or	a, a
	jr	NZ, 00112$
	ld	a, #0x01
	jr	00120$
00112$:
;../stdlib/stdlibimpl.c:13: if (*b==0) return -1;
	ld	e, (hl)
	inc	e
	dec	e
	jr	NZ, 00114$
	ld	a, #0xff
	jr	00120$
00114$:
;../stdlib/stdlibimpl.c:14: if (*a==*b) 
	cp	a, e
	jr	NZ, 00116$
;../stdlib/stdlibimpl.c:16: ++a;
;../stdlib/stdlibimpl.c:17: ++b;
	inc	hl
	inc	bc
;../stdlib/stdlibimpl.c:18: continue;
	jr	00118$
00116$:
;../stdlib/stdlibimpl.c:20: return *a<*b?-1:1;
	sub	a, e
	jr	NC, 00122$
	ld	bc, #0xffff
	jr	00123$
00122$:
	ld	bc, #0x0001
00123$:
	ld	a, c
00120$:
;../stdlib/stdlibimpl.c:22: }
	ld	sp, ix
	pop	ix
	ret
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
