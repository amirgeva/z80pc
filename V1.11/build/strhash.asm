;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 4.2.0 #13081 (MINGW64)
;--------------------------------------------------------
	.module strhash
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _compare_n
	.globl _copy_n
	.globl _release
	.globl _allocate
	.globl _vector_access
	.globl _vector_push
	.globl _vector_size
	.globl _vector_shut
	.globl _vector_new
	.globl _strlen
	.globl _sh_init
	.globl _sh_shut
	.globl _sh_get
	.globl _sh_text
	.globl _sh_temp
	.globl _sh_size
;--------------------------------------------------------
; special function registers
;--------------------------------------------------------
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _DATA
_sh_temp_hex_65536_82:
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
;strhash.c:128: static const char* hex = "0123456789ABCDEF";
	ld	hl, #___str_0+0
	ld	(_sh_temp_hex_65536_82), hl
;--------------------------------------------------------
; Home
;--------------------------------------------------------
	.area _HOME
	.area _HOME
;--------------------------------------------------------
; code
;--------------------------------------------------------
	.area _CODE
;strhash.c:8: void copy_n(char* dst, const char* src, int n)
;	---------------------------------
; Function copy_n
; ---------------------------------
_copy_n::
	push	ix
	ld	ix,#0
	add	ix,sp
;strhash.c:10: for (int i = 0; i < n; ++i, ++src, ++dst)
	ld	bc, #0x0000
00105$:
	ld	a, c
	sub	a, 4 (ix)
	ld	a, b
	sbc	a, 5 (ix)
	jp	PO, 00125$
	xor	a, #0x80
00125$:
	jp	P, 00107$
;strhash.c:12: *dst = *src;
	ld	a, (de)
	ld	(hl), a
;strhash.c:13: if (*src == 0) break;
	ld	a, (de)
	or	a, a
	jr	Z, 00107$
;strhash.c:10: for (int i = 0; i < n; ++i, ++src, ++dst)
	inc	hl
	inc	bc
	inc	de
	jr	00105$
00107$:
;strhash.c:15: }
	pop	ix
	pop	hl
	pop	af
	jp	(hl)
;strhash.c:17: int compare_n(const char* a, const char* b, int n)
;	---------------------------------
; Function compare_n
; ---------------------------------
_compare_n::
	push	ix
	ld	ix,#0
	add	ix,sp
	push	af
	push	af
	ld	-2 (ix), l
	ld	-1 (ix), h
	inc	sp
	inc	sp
	push	de
;strhash.c:19: for (int i = 0; i < n; ++i)
	ld	bc, #0x0000
00110$:
	ld	a, c
	sub	a, 4 (ix)
	ld	a, b
	sbc	a, 5 (ix)
	jp	PO, 00144$
	xor	a, #0x80
00144$:
	jp	P, 00108$
;strhash.c:21: if (*a < *b) return -1;
	ld	l, -2 (ix)
	ld	h, -1 (ix)
	ld	e, (hl)
	pop	hl
	push	hl
	ld	d, (hl)
	ld	a, e
	sub	a, d
	jr	NC, 00102$
	ld	de, #0xffff
	jr	00112$
00102$:
;strhash.c:22: if (*a > *b) return 1;
	ld	a, d
	sub	a, e
	jr	NC, 00104$
	ld	de, #0x0001
	jr	00112$
00104$:
;strhash.c:23: if (*a == 0 && *b == 0) return 0;
	ld	a, e
	or	a,a
	jr	NZ, 00111$
	or	a,d
	jr	NZ, 00111$
	ld	de, #0x0000
	jr	00112$
00111$:
;strhash.c:19: for (int i = 0; i < n; ++i)
	inc	bc
	jr	00110$
00108$:
;strhash.c:25: return 0;
	ld	de, #0x0000
00112$:
;strhash.c:26: }
	ld	sp, ix
	pop	ix
	pop	hl
	pop	af
	jp	(hl)
;strhash.c:29: static word calculate_crc16(const byte* buffer, int len)
;	---------------------------------
; Function calculate_crc16
; ---------------------------------
_calculate_crc16:
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	iy, #-9
	add	iy, sp
	ld	sp, iy
	ld	-2 (ix), l
	ld	-1 (ix), h
	ld	-4 (ix), e
	ld	-3 (ix), d
;strhash.c:31: word result = 0;
	ld	hl, #0x0000
	ex	(sp), hl
;strhash.c:32: for (int i = 0; i < len; ++i)
	ld	bc, #0x0000
00103$:
	ld	a, c
	sub	a, -4 (ix)
	ld	a, b
	sbc	a, -3 (ix)
	jp	PO, 00118$
	xor	a, #0x80
00118$:
	jp	P, 00101$
;strhash.c:34: byte data = buffer[i] ^ (byte)(result & 0xFF);
	ld	l, -2 (ix)
	ld	h, -1 (ix)
	add	hl, bc
	ld	a, (hl)
	ld	e, -9 (ix)
	xor	a, e
;strhash.c:35: data = data ^ (data << 4);
	ld	e, a
	add	a, a
	add	a, a
	add	a, a
	add	a, a
	xor	a, e
;strhash.c:36: result = (((word)data << 8) | (result >> 8)) ^ (data >> 4) ^ ((word)data << 3);
	ld	-7 (ix), a
	ld	-6 (ix), a
	ld	-5 (ix), #0x00
	ld	d, -6 (ix)
	ld	e, #0x00
	ld	l, -8 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, #0x00
;	spillPairReg hl
;	spillPairReg hl
	ld	a, e
	or	a, l
	ld	e, a
	ld	a, d
	or	a, h
	ld	d, a
	ld	a, -7 (ix)
	rlca
	rlca
	rlca
	rlca
	and	a, #0x0f
	ld	l, #0x00
;	spillPairReg hl
;	spillPairReg hl
	xor	a, e
	ld	e, a
	ld	a, l
	xor	a, d
	ld	d, a
	ld	l, -6 (ix)
	ld	h, -5 (ix)
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	a, e
	xor	a, l
	ld	e, a
	ld	a, d
	xor	a, h
	ld	d, a
	inc	sp
	inc	sp
	push	de
;strhash.c:32: for (int i = 0; i < len; ++i)
	inc	bc
	jr	00103$
00101$:
;strhash.c:38: return result;
	pop	de
	push	de
;strhash.c:39: }
	ld	sp, ix
	pop	ix
	ret
;strhash.c:41: static byte checksum(const char* text)
;	---------------------------------
; Function checksum
; ---------------------------------
_checksum:
;strhash.c:44: byte res = 0xFF;
	ld	c, #0xff
;strhash.c:47: return res;
00103$:
;strhash.c:45: for (; *bytes; ++bytes)
	ld	a, (hl)
	or	a, a
	jr	Z, 00101$
;strhash.c:46: res += *bytes;
;strhash.c:45: for (; *bytes; ++bytes)
	inc	hl
	add	a, c
	ld	c, a
	jr	00103$
00101$:
;strhash.c:47: return res;
	ld	a, c
;strhash.c:48: }
	ret
;strhash.c:64: StrHash* sh_init()
;	---------------------------------
; Function sh_init
; ---------------------------------
_sh_init::
;strhash.c:66: StrHash* sh = (StrHash*)allocate(sizeof(StrHash));
	ld	hl, #0x0004
	call	_allocate
;strhash.c:67: sh->strings = vector_new(sizeof(TextNode));
	push	de
	ld	hl, #0x0010
	call	_vector_new
	ld	c, e
	ld	b, d
	pop	de
	ld	l, e
	ld	h, d
	ld	(hl), c
	inc	hl
	ld	(hl), b
;strhash.c:68: sh->last_temporary = 0;
	ld	c, e
	ld	b, d
	inc	bc
	inc	bc
	xor	a, a
	ld	(bc), a
	inc	bc
	ld	(bc), a
;strhash.c:69: return sh;
;strhash.c:70: }
	ret
;strhash.c:72: void sh_shut(StrHash* sh)
;	---------------------------------
; Function sh_shut
; ---------------------------------
_sh_shut::
;strhash.c:74: vector_shut(sh->strings);
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	dec	hl
	ex	de, hl
	push	de
	call	_vector_shut
	pop	hl
;strhash.c:75: release(sh);
;strhash.c:76: }
	jp	_release
;strhash.c:78: word sh_get(StrHash* sh, const char* text)
;	---------------------------------
; Function sh_get
; ---------------------------------
_sh_get::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	iy, #-26
	add	iy, sp
	ld	sp, iy
	ld	-4 (ix), l
	ld	-3 (ix), h
	ld	c, e
	ld	b, d
;strhash.c:80: const size_t n=strlen(text);
	push	bc
	ld	l, c
;	spillPairReg hl
;	spillPairReg hl
	ld	h, b
;	spillPairReg hl
;	spillPairReg hl
	call	_strlen
	pop	bc
	ld	-10 (ix), e
	ld	-9 (ix), d
;strhash.c:81: if (n >= MAX_LENGTH) return 0;
	ld	a, -10 (ix)
	sub	a, #0x0d
	ld	a, -9 (ix)
	sbc	a, #0x00
	jr	C, 00102$
	ld	de, #0x0000
	jp	00115$
00102$:
;strhash.c:82: const word crc = calculate_crc16(text, n);
	push	bc
	ld	e, -10 (ix)
	ld	d, -9 (ix)
	ld	l, c
;	spillPairReg hl
;	spillPairReg hl
	ld	h, b
;	spillPairReg hl
;	spillPairReg hl
	call	_calculate_crc16
	pop	bc
	ld	-8 (ix), e
;strhash.c:83: if (crc == 0) return 0;
	ld	-7 (ix), d
	ld	a, d
	or	a, -8 (ix)
	jr	NZ, 00104$
	ld	de, #0x0000
	jp	00115$
00104$:
;strhash.c:84: const word m = vector_size(sh->strings);
	ld	l, -4 (ix)
	ld	h, -3 (ix)
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	push	bc
	ex	de, hl
	call	_vector_size
	pop	bc
	ld	-6 (ix), e
	ld	-5 (ix), d
;strhash.c:86: for (word i = 0; i < m; ++i)
	xor	a, a
	ld	-2 (ix), a
	ld	-1 (ix), a
00113$:
	ld	a, -2 (ix)
	sub	a, -6 (ix)
	ld	a, -1 (ix)
	sbc	a, -5 (ix)
	jr	NC, 00109$
;strhash.c:88: cur = (TextNode*)vector_access(sh->strings, i);
	ld	l, -4 (ix)
	ld	h, -3 (ix)
	ld	a, (hl)
	inc	hl
	ld	h, (hl)
;	spillPairReg hl
	ld	l, a
;	spillPairReg hl
;	spillPairReg hl
	push	bc
	ld	e, -2 (ix)
	ld	d, -1 (ix)
	call	_vector_access
	pop	bc
;strhash.c:89: if (cur->id == crc)
	ld	l, e
	ld	h, d
	ld	a, (hl)
	inc	hl
	ld	h, (hl)
;	spillPairReg hl
;	spillPairReg hl
;	spillPairReg hl
	sub	a, -8 (ix)
	jr	NZ, 00114$
	ld	a, h
	sub	a, -7 (ix)
	jr	NZ, 00114$
;strhash.c:91: if (compare_n(text, cur->text, MAX_LENGTH) != 0)
	inc	de
	inc	de
	ld	hl, #0x000d
	push	hl
	ld	l, c
;	spillPairReg hl
;	spillPairReg hl
	ld	h, b
;	spillPairReg hl
;	spillPairReg hl
	call	_compare_n
	ld	a, d
	or	a, e
	jr	Z, 00106$
;strhash.c:97: return 0;
	ld	de, #0x0000
	jr	00115$
00106$:
;strhash.c:99: return crc;
	ld	e, -8 (ix)
	ld	d, -7 (ix)
	jr	00115$
00114$:
;strhash.c:86: for (word i = 0; i < m; ++i)
	inc	-2 (ix)
	jr	NZ, 00113$
	inc	-1 (ix)
	jr	00113$
00109$:
;strhash.c:103: copy_n(new_node.text, text, n);
	ld	l, -10 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -9 (ix)
;	spillPairReg hl
;	spillPairReg hl
	push	hl
	ld	e, c
	ld	d, b
	ld	hl, #4
	add	hl, sp
	call	_copy_n
;strhash.c:104: new_node.text[n] = 0;
	ld	e, -10 (ix)
	ld	d, -9 (ix)
	ld	hl, #2
	add	hl, sp
	add	hl, de
	ld	(hl), #0x00
;strhash.c:105: new_node.id = crc;
	ld	a, -8 (ix)
	ld	-26 (ix), a
	ld	a, -7 (ix)
	ld	-25 (ix), a
;strhash.c:106: if (!vector_push(sh->strings, &new_node)) return 0;
	ld	hl, #0
	add	hl, sp
	ex	de, hl
	ld	l, -4 (ix)
	ld	h, -3 (ix)
	ld	c, (hl)
	inc	hl
	ld	h, (hl)
;	spillPairReg hl
	ld	l, c
;	spillPairReg hl
;	spillPairReg hl
	call	_vector_push
	or	a, a
	jr	NZ, 00111$
	ld	de, #0x0000
	jr	00115$
00111$:
;strhash.c:107: return crc;
	ld	e, -8 (ix)
	ld	d, -7 (ix)
00115$:
;strhash.c:108: }
	ld	sp, ix
	pop	ix
	ret
;strhash.c:110: byte sh_text(StrHash* sh, char* text, word id)
;	---------------------------------
; Function sh_text
; ---------------------------------
_sh_text::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	iy, #-8
	add	iy, sp
	ld	sp, iy
	ld	-4 (ix), l
	ld	-3 (ix), h
	ld	-6 (ix), e
	ld	-5 (ix), d
;strhash.c:112: const word m = vector_size(sh->strings);
	ld	l, -4 (ix)
	ld	h, -3 (ix)
	ld	c, (hl)
	inc	hl
	ld	h, (hl)
;	spillPairReg hl
	ld	l, c
;	spillPairReg hl
;	spillPairReg hl
	call	_vector_size
	inc	sp
	inc	sp
	push	de
;strhash.c:114: for (word i = 0; i < m; ++i)
	xor	a, a
	ld	-2 (ix), a
	ld	-1 (ix), a
00105$:
	ld	a, -2 (ix)
	sub	a, -8 (ix)
	ld	a, -1 (ix)
	sbc	a, -7 (ix)
	jr	NC, 00103$
;strhash.c:116: cur = (TextNode*)vector_access(sh->strings, i);
	ld	l, -4 (ix)
	ld	h, -3 (ix)
	ld	c, (hl)
	inc	hl
	ld	h, (hl)
;	spillPairReg hl
	ld	e, -2 (ix)
	ld	d, -1 (ix)
	ld	l, c
;	spillPairReg hl
;	spillPairReg hl
	call	_vector_access
;strhash.c:117: if (cur->id == id)
	ld	l, e
	ld	h, d
	ld	c, (hl)
	inc	hl
	ld	b, (hl)
	ld	l, 4 (ix)
	ld	h, 5 (ix)
	cp	a, a
	sbc	hl, bc
	jr	NZ, 00106$
;strhash.c:119: copy_n(text, cur->text, MAX_LENGTH);
	inc	de
	inc	de
	ld	hl, #0x000d
	push	hl
	ld	l, -6 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -5 (ix)
;	spillPairReg hl
;	spillPairReg hl
	call	_copy_n
;strhash.c:120: return 1;
	ld	a, #0x01
	jr	00107$
00106$:
;strhash.c:114: for (word i = 0; i < m; ++i)
	inc	-2 (ix)
	jr	NZ, 00105$
	inc	-1 (ix)
	jr	00105$
00103$:
;strhash.c:123: return 0;
	xor	a, a
00107$:
;strhash.c:124: }
	ld	sp, ix
	pop	ix
	pop	hl
	pop	bc
	jp	(hl)
;strhash.c:126: word sh_temp(StrHash* sh)
;	---------------------------------
; Function sh_temp
; ---------------------------------
_sh_temp::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	iy, #-20
	add	iy, sp
	ld	sp, iy
	ld	-2 (ix), l
	ld	-1 (ix), h
;strhash.c:129: word id = 0;
	ld	bc, #0x0000
;strhash.c:131: copy_n(temp_name, "TEMP", 4);
	push	bc
	ld	hl, #0x0004
	push	hl
	ld	de, #___str_1
	ld	hl, #4
	add	hl, sp
	call	_copy_n
	pop	bc
;strhash.c:132: while (id == 0)
	ld	a, -2 (ix)
	add	a, #0x02
	ld	-10 (ix), a
	ld	a, -1 (ix)
	adc	a, #0x00
	ld	-9 (ix), a
	ld	a, -10 (ix)
	ld	-8 (ix), a
	ld	a, -9 (ix)
	ld	-7 (ix), a
00102$:
	ld	a, b
	or	a, c
	jp	NZ, 00104$
;strhash.c:134: ++(sh->last_temporary);
	ld	l, -10 (ix)
	ld	h, -9 (ix)
	ld	c, (hl)
	inc	hl
	ld	b, (hl)
	inc	bc
	ld	l, -10 (ix)
	ld	h, -9 (ix)
	ld	(hl), c
	inc	hl
	ld	(hl), b
;strhash.c:135: byte shift = 12;
;strhash.c:136: for (byte i = 0; i < 4; ++i)
	ld	de, #0xc
00106$:
;strhash.c:138: temp_name[4 + i] = hex[(sh->last_temporary >> shift) & 15];
	ld	a,d
	cp	a,#0x04
	jr	NC, 00101$
	add	a, #0x04
	ld	c, a
	rlca
	sbc	a, a
	ld	b, a
	ld	hl, #0
	add	hl, sp
	add	hl, bc
	ld	-6 (ix), l
	ld	-5 (ix), h
	ld	l, -8 (ix)
	ld	h, -7 (ix)
	ld	a, (hl)
	inc	hl
	ld	h, (hl)
;	spillPairReg hl
	ld	l, a
;	spillPairReg hl
;	spillPairReg hl
	ld	b, e
	inc	b
	jr	00132$
00131$:
	srl	h
	rr	l
00132$:
	djnz	00131$
	ld	a, l
	and	a, #0x0f
	ld	-4 (ix), a
	ld	-3 (ix), #0x00
	ld	a, -4 (ix)
	ld	hl, #_sh_temp_hex_65536_82
	add	a, (hl)
	ld	c, a
	ld	a, -3 (ix)
	inc	hl
	adc	a, (hl)
	ld	b, a
	ld	a, (bc)
	ld	l, -6 (ix)
	ld	h, -5 (ix)
	ld	(hl), a
;strhash.c:139: shift -= 4;
	ld	a, e
	add	a, #0xfc
	ld	e, a
;strhash.c:136: for (byte i = 0; i < 4; ++i)
	inc	d
	jr	00106$
00101$:
;strhash.c:141: temp_name[8] = 0;
	ld	-12 (ix), #0x00
;strhash.c:142: id = sh_get(sh, temp_name);
	ld	hl, #0
	add	hl, sp
	ex	de, hl
	ld	l, -2 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -1 (ix)
;	spillPairReg hl
;	spillPairReg hl
	call	_sh_get
	ld	c, e
	ld	b, d
	jp	00102$
00104$:
;strhash.c:144: return id;
	ld	e, c
	ld	d, b
;strhash.c:145: }
	ld	sp, ix
	pop	ix
	ret
___str_0:
	.ascii "0123456789ABCDEF"
	.db 0x00
___str_1:
	.ascii "TEMP"
	.db 0x00
;strhash.c:147: word sh_size(StrHash* sh)
;	---------------------------------
; Function sh_size
; ---------------------------------
_sh_size::
;strhash.c:149: return vector_size(sh->strings);
	ld	c, (hl)
	inc	hl
	ld	h, (hl)
;	spillPairReg hl
	ld	l, c
;	spillPairReg hl
;	spillPairReg hl
;strhash.c:150: }
	jp	_vector_size
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
