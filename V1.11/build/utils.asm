;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 4.2.0 #13081 (MINGW64)
;--------------------------------------------------------
	.module utils
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _exit
	.globl _multiply
	.globl _error_exit
	.globl _min
	.globl _max
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
;utils.c:5: word multiply(word a, word b)
;	---------------------------------
; Function multiply
; ---------------------------------
_multiply::
	ld	c, l
	ld	b, h
;utils.c:7: if (a == 0 || b == 0) return 0;
	ld	a, b
	or	a, c
	jr	Z, 00101$
	ld	a, d
	or	a, e
	jr	NZ, 00102$
00101$:
	ld	de, #0x0000
	ret
00102$:
;utils.c:8: word res = 0;
	ld	hl, #0x0000
;utils.c:9: while (b > 0)
00106$:
	ld	a, d
	or	a, e
	jr	Z, 00108$
;utils.c:11: if (b & 1) res += a;
	bit	0, e
	jr	Z, 00105$
	add	hl, bc
00105$:
;utils.c:12: b = b >> 1;
	srl	d
	rr	e
;utils.c:13: a = a << 1;
	sla	c
	rl	b
	jr	00106$
00108$:
;utils.c:15: return res;
	ex	de, hl
;utils.c:16: }
	ret
;utils.c:18: void error_exit(word line, const char* msg, int rc)
;	---------------------------------
; Function error_exit
; ---------------------------------
_error_exit::
;utils.c:27: exit(rc);
	pop	de
	pop	hl
	push	hl
	push	de
	call	_exit
;utils.c:28: }
	pop	hl
	pop	af
	jp	(hl)
;utils.c:30: word min(word a, word b)
;	---------------------------------
; Function min
; ---------------------------------
_min::
	ld	c, l
;utils.c:32: return a < b ? a : b;
	ld	a, c
	sub	a, e
	ld	a, h
	sbc	a, d
	jr	NC, 00103$
	ld	d, h
	jr	00104$
00103$:
	ld	c, e
00104$:
	ld	e, c
;utils.c:33: }
	ret
;utils.c:35: word max(word a, word b)
;	---------------------------------
; Function max
; ---------------------------------
_max::
	ld	c, l
;utils.c:37: return a > b ? a : b;
	ld	a, e
	sub	a, c
	ld	a, d
	sbc	a, h
	jr	NC, 00103$
	ld	d, h
	jr	00104$
00103$:
	ld	c, e
00104$:
	ld	e, c
;utils.c:38: }
	ret
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
