;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 4.2.0 #13081 (MINGW64)
;--------------------------------------------------------
	.module vector
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _ensure_capacity
	.globl _copy
	.globl _multiply
	.globl _release
	.globl _allocate
	.globl _vector_new
	.globl _vector_init
	.globl _vector_shut
	.globl _vector_size
	.globl _vector_clear
	.globl _vector_resize
	.globl _vector_reserve
	.globl _vector_insert
	.globl _vector_push
	.globl _vector_pop
	.globl _vector_access
	.globl _vector_set
	.globl _vector_get
	.globl _vector_erase
	.globl _vector_erase_range
	.globl _vector_capacity
	.globl _vector_element_size
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
;vector.c:5: void copy(void* dest, void* src, int size)
;	---------------------------------
; Function copy
; ---------------------------------
_copy::
	push	ix
	ld	ix,#0
	add	ix,sp
	push	af
	push	af
	ld	c, l
	ld	b, h
;vector.c:7: if (size > 0)
	xor	a, a
	cp	a, 4 (ix)
	sbc	a, 5 (ix)
	jp	PO, 00170$
	xor	a, #0x80
00170$:
	jp	P, 00121$
;vector.c:9: char* cdst = (char*)dest;
;vector.c:10: char* csrc = (char*)src;
;vector.c:11: byte reverse = 0;
	ld	-2 (ix), #0x00
;vector.c:12: if ((csrc < cdst && (csrc + size)>cdst) ||
	ld	a, e
	sub	a, c
	ld	a, d
	sbc	a, b
	ld	a, #0x00
	rla
	ld	-1 (ix), a
	or	a, a
	jr	Z, 00107$
	ld	l, 4 (ix)
	ld	h, 5 (ix)
	add	hl, de
	ld	a, c
	sub	a, l
	ld	a, b
	sbc	a, h
	jr	C, 00103$
00107$:
;vector.c:13: (cdst < csrc && (cdst + size)>csrc))
	ld	a, c
	sub	a, e
	ld	a, b
	sbc	a, d
	jr	NC, 00104$
	ld	l, 4 (ix)
	ld	h, 5 (ix)
	add	hl, bc
	ld	a, e
	sub	a, l
	ld	a, d
	sbc	a, h
	jr	NC, 00104$
00103$:
;vector.c:15: if (csrc < cdst) reverse = 1;
	ld	a, -1 (ix)
	or	a, a
	jr	Z, 00104$
	ld	-2 (ix), #0x01
00104$:
;vector.c:17: if (reverse)
	ld	a, -2 (ix)
	or	a, a
	jr	Z, 00131$
;vector.c:19: for (int i = size-1; i >= 0; --i)
	ld	a, 4 (ix)
	add	a, #0xff
	ld	-2 (ix), a
	ld	a, 5 (ix)
	adc	a, #0xff
	ld	-1 (ix), a
00116$:
	bit	7, -1 (ix)
	jr	NZ, 00121$
;vector.c:20: cdst[i] = csrc[i];
	ld	a, -2 (ix)
	add	a, c
	ld	-4 (ix), a
	ld	a, -1 (ix)
	adc	a, b
	ld	-3 (ix), a
	ld	l, -2 (ix)
	ld	h, -1 (ix)
	add	hl, de
	ld	a, (hl)
	pop	hl
	push	hl
	ld	(hl), a
;vector.c:19: for (int i = size-1; i >= 0; --i)
	ld	l, -2 (ix)
	ld	h, -1 (ix)
	dec	hl
	ld	-2 (ix), l
	ld	-1 (ix), h
	jr	00116$
;vector.c:24: for (int i = 0; i < size; ++i)
00131$:
	xor	a, a
	ld	-2 (ix), a
	ld	-1 (ix), a
00119$:
	ld	a, -2 (ix)
	sub	a, 4 (ix)
	ld	a, -1 (ix)
	sbc	a, 5 (ix)
	jp	PO, 00171$
	xor	a, #0x80
00171$:
	jp	P, 00121$
;vector.c:25: cdst[i] = csrc[i];
	ld	a, -2 (ix)
	add	a, c
	ld	-4 (ix), a
	ld	a, -1 (ix)
	adc	a, b
	ld	-3 (ix), a
	ld	l, -2 (ix)
	ld	h, -1 (ix)
	add	hl, de
	ld	a, (hl)
	pop	hl
	push	hl
	ld	(hl), a
;vector.c:24: for (int i = 0; i < size; ++i)
	inc	-2 (ix)
	jr	NZ, 00119$
	inc	-1 (ix)
	jr	00119$
00121$:
;vector.c:28: }
	ld	sp, ix
	pop	ix
	pop	hl
	pop	af
	jp	(hl)
;vector.c:38: Vector* vector_new(word element_size)
;	---------------------------------
; Function vector_new
; ---------------------------------
_vector_new::
;vector.c:40: Vector* res = (Vector*)allocate(sizeof(Vector));
	push	hl
	ld	hl, #0x0008
	call	_allocate
	ex	de, hl
	pop	de
;vector.c:41: if (!res) return 0;
	ld	a, h
	or	a, l
	jr	NZ, 00102$
	ld	de, #0x0000
	ret
00102$:
;vector.c:42: vector_init(res, element_size);
	push	hl
	call	_vector_init
	pop	hl
;vector.c:43: return res;
	ex	de, hl
;vector.c:44: }
	ret
;vector.c:46: byte		vector_init(Vector* v, word element_size)
;	---------------------------------
; Function vector_init
; ---------------------------------
_vector_init::
	ld	c, l
	ld	b, h
;vector.c:48: if (!v) return 0;
	ld	a, b
	or	a,c
	ret	Z
;vector.c:49: v->element_size = element_size;
	ld	l, c
	ld	h, b
	ld	(hl), e
	inc	hl
	ld	(hl), d
;vector.c:50: v->capacity = 0;
	ld	e, c
	ld	d, b
	inc	de
	inc	de
	xor	a, a
	ld	(de), a
	inc	de
	ld	(de), a
;vector.c:51: v->size = 0;
	ld	hl, #0x0004
	add	hl, bc
	xor	a, a
	ld	(hl), a
	inc	hl
	ld	(hl), a
;vector.c:52: v->data = 0;
	ld	hl, #0x0006
	add	hl, bc
	xor	a, a
	ld	(hl), a
	inc	hl
	ld	(hl), a
;vector.c:53: return 1;
	ld	a, #0x01
;vector.c:54: }
	ret
;vector.c:56: void		vector_shut(Vector* v)
;	---------------------------------
; Function vector_shut
; ---------------------------------
_vector_shut::
	ex	de, hl
;vector.c:58: if (v->data)
	push	de
	pop	iy
	ld	l, 6 (iy)
;	spillPairReg hl
	ld	h, 7 (iy)
;	spillPairReg hl
	ld	a, h
	or	a, l
	jr	Z, 00102$
;vector.c:59: release(v->data);
	push	de
	call	_release
	pop	de
00102$:
;vector.c:60: if (v)
	ld	a, d
	or	a, e
	ret	Z
;vector.c:61: release(v);
	ex	de, hl
;vector.c:62: }
	jp	_release
;vector.c:64: static byte vector_reallocate(Vector* v, word new_size)
;	---------------------------------
; Function vector_reallocate
; ---------------------------------
_vector_reallocate:
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	iy, #-8
	add	iy, sp
	ld	sp, iy
	ld	-2 (ix), l
	ld	-1 (ix), h
	ld	-4 (ix), e
	ld	-3 (ix), d
;vector.c:66: if (!v) return 0;
	ld	a, -1 (ix)
	or	a, -2 (ix)
	jr	NZ, 00102$
	xor	a, a
	jp	00107$
00102$:
;vector.c:67: char* buffer = (char*)allocate(multiply(new_size, v->element_size));
	ld	l, -2 (ix)
	ld	h, -1 (ix)
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	ld	l, -4 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -3 (ix)
;	spillPairReg hl
;	spillPairReg hl
	call	_multiply
	ex	de, hl
	call	_allocate
	inc	sp
	inc	sp
	push	de
;vector.c:68: if (!buffer) return 0;
	ld	a, -7 (ix)
	or	a, -8 (ix)
	jr	NZ, 00104$
	xor	a, a
	jp	00107$
00104$:
;vector.c:69: if (v->data)
	ld	a, -2 (ix)
	add	a, #0x06
	ld	-6 (ix), a
	ld	a, -1 (ix)
	adc	a, #0x00
	ld	-5 (ix), a
	ld	l, -6 (ix)
	ld	h, -5 (ix)
	ld	a, (hl)
	inc	hl
	or	a, (hl)
	jr	Z, 00106$
;vector.c:71: copy(buffer, v->data, multiply(v->size, v->element_size));
	ld	l, -2 (ix)
	ld	h, -1 (ix)
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	ld	c, -2 (ix)
	ld	b, -1 (ix)
	ld	hl, #4
	add	hl, bc
	ld	a, (hl)
	inc	hl
	ld	h, (hl)
;	spillPairReg hl
	ld	l, a
;	spillPairReg hl
;	spillPairReg hl
	call	_multiply
	ld	c, e
	ld	b, d
	ld	l, -6 (ix)
	ld	h, -5 (ix)
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	pop	hl
	push	hl
	push	bc
	call	_copy
;vector.c:72: release(v->data);
	ld	l, -6 (ix)
	ld	h, -5 (ix)
	ld	c, (hl)
	inc	hl
	ld	h, (hl)
;	spillPairReg hl
	ld	l, c
;	spillPairReg hl
;	spillPairReg hl
	call	_release
00106$:
;vector.c:74: v->data = buffer;
	pop	bc
	pop	hl
	push	hl
	push	bc
	ld	a, -8 (ix)
	ld	(hl), a
	inc	hl
	ld	a, -7 (ix)
	ld	(hl), a
;vector.c:75: v->capacity = new_size;
	ld	a, -2 (ix)
	add	a, #0x02
	ld	-6 (ix), a
	ld	a, -1 (ix)
	adc	a, #0x00
	ld	-5 (ix), a
	pop	bc
	pop	hl
	push	hl
	push	bc
	ld	a, -4 (ix)
	ld	(hl), a
	inc	hl
	ld	a, -3 (ix)
	ld	(hl), a
;vector.c:76: return 1;
	ld	a, #0x01
00107$:
;vector.c:77: }
	ld	sp, ix
	pop	ix
	ret
;vector.c:79: word		vector_size(Vector* v)
;	---------------------------------
; Function vector_size
; ---------------------------------
_vector_size::
;vector.c:81: if (!v) return 0;
	ld	a, h
	or	a, l
	jr	NZ, 00102$
	ld	de, #0x0000
	ret
00102$:
;vector.c:82: return v->size;
	ld	de, #0x0004
	add	hl, de
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
;vector.c:83: }
	ret
;vector.c:85: byte		vector_clear(Vector* v)
;	---------------------------------
; Function vector_clear
; ---------------------------------
_vector_clear::
;vector.c:87: if (!v) return 0;
	ld	a, h
	or	a,l
	ret	Z
;vector.c:88: v->size = 0;
	ld	bc, #0x0004
	add	hl, bc
	xor	a, a
	ld	(hl), a
	inc	hl
	ld	(hl), a
;vector.c:89: return 1;
	ld	a, #0x01
;vector.c:90: }
	ret
;vector.c:92: byte		vector_resize(Vector* v, word size)
;	---------------------------------
; Function vector_resize
; ---------------------------------
_vector_resize::
	push	ix
	ld	ix,#0
	add	ix,sp
	push	af
	ld	c, l
	ld	b, h
	inc	sp
	inc	sp
	push	de
;vector.c:94: if (!v) return 0;
	ld	a, b
	or	a,c
	jr	Z, 00107$
;vector.c:95: if (size > v->capacity)
	ld	l, c
;	spillPairReg hl
;	spillPairReg hl
	ld	h, b
;	spillPairReg hl
;	spillPairReg hl
	inc	hl
	inc	hl
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	ld	a, e
	sub	a, -2 (ix)
	ld	a, d
	sbc	a, -1 (ix)
	jr	NC, 00106$
;vector.c:97: if (!vector_reallocate(v, size)) return 0;
	push	bc
	pop	hl
	pop	de
	push	de
	push	hl
	ld	l, c
;	spillPairReg hl
;	spillPairReg hl
	ld	h, b
;	spillPairReg hl
;	spillPairReg hl
	call	_vector_reallocate
	pop	bc
	or	a,a
	jr	Z, 00107$
00106$:
;vector.c:99: v->size = size;
	inc	bc
	inc	bc
	inc	bc
	inc	bc
	ld	a, -2 (ix)
	ld	(bc), a
	inc	bc
	ld	a, -1 (ix)
	ld	(bc), a
;vector.c:100: return 1;
	ld	a, #0x01
00107$:
;vector.c:101: }
	ld	sp, ix
	pop	ix
	ret
;vector.c:103: byte		vector_reserve(Vector* v, word size)
;	---------------------------------
; Function vector_reserve
; ---------------------------------
_vector_reserve::
	ld	c, l
	ld	b, h
;vector.c:105: if (!v) return 0;
	ld	a, b
	or	a,c
	ret	Z
;vector.c:106: if (size <= v->capacity) return 1;
	ld	l, c
;	spillPairReg hl
;	spillPairReg hl
	ld	h, b
;	spillPairReg hl
;	spillPairReg hl
	inc	hl
	inc	hl
	ld	a, (hl)
	inc	hl
	ld	h, (hl)
;	spillPairReg hl
	ld	l, a
;	spillPairReg hl
;	spillPairReg hl
	xor	a, a
	sbc	hl, de
	jr	C, 00104$
	ld	a, #0x01
	ret
00104$:
;vector.c:107: return vector_reallocate(v, size);
	ld	l, c
;	spillPairReg hl
;	spillPairReg hl
	ld	h, b
;	spillPairReg hl
;	spillPairReg hl
;vector.c:108: }
	jp	_vector_reallocate
;vector.c:110: byte ensure_capacity(Vector* v)
;	---------------------------------
; Function ensure_capacity
; ---------------------------------
_ensure_capacity::
	push	ix
	ld	ix,#0
	add	ix,sp
	push	af
	ex	(sp), hl
;vector.c:112: if (v->size >= v->capacity)
	pop	bc
	push	bc
	ld	hl, #4
	add	hl, bc
	ld	c, (hl)
	inc	hl
	ld	b, (hl)
	pop	hl
	push	hl
	inc	hl
	inc	hl
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	ld	a, c
	sub	a, e
	ld	a, b
	sbc	a, d
	jr	C, 00106$
;vector.c:114: word new_size = 10;
	ld	hl, #0x000a
;vector.c:115: if (v->size > 0)
	ld	a, b
	or	a, c
	jr	Z, 00102$
;vector.c:116: new_size = v->size << 1;
	ld	l, c
	ld	h, b
	add	hl, hl
00102$:
;vector.c:117: if (!vector_reallocate(v, new_size)) return 0;
	ex	de, hl
	pop	hl
	push	hl
	call	_vector_reallocate
	or	a,a
	jr	Z, 00107$
00106$:
;vector.c:119: return 1;
	ld	a, #0x01
00107$:
;vector.c:120: }
	ld	sp, ix
	pop	ix
	ret
;vector.c:122: byte		vector_insert(Vector* v, word index, void* element)
;	---------------------------------
; Function vector_insert
; ---------------------------------
_vector_insert::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	iy, #-14
	add	iy, sp
	ld	sp, iy
	ld	-2 (ix), l
	ld	-1 (ix), h
	ld	-4 (ix), e
	ld	-3 (ix), d
;vector.c:124: if (!v) return 0;
	ld	a, -1 (ix)
	or	a, -2 (ix)
	jr	NZ, 00102$
	xor	a, a
	jp	00105$
00102$:
;vector.c:125: if (index >= v->size) return vector_push(v, element);
	ld	a, -2 (ix)
	add	a, #0x04
	ld	-12 (ix), a
	ld	a, -1 (ix)
	adc	a, #0x00
	ld	-11 (ix), a
	ld	l, -12 (ix)
	ld	h, -11 (ix)
	ld	c, (hl)
	inc	hl
	ld	b, (hl)
	ld	a, -4 (ix)
	sub	a, c
	ld	a, -3 (ix)
	sbc	a, b
	jr	C, 00104$
	ld	e, 4 (ix)
	ld	d, 5 (ix)
	ld	l, -2 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -1 (ix)
;	spillPairReg hl
;	spillPairReg hl
	call	_vector_push
	jp	00105$
00104$:
;vector.c:126: ensure_capacity(v);
	ld	l, -2 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -1 (ix)
;	spillPairReg hl
;	spillPairReg hl
	call	_ensure_capacity
;vector.c:127: char* dst = v->data + multiply(index + 1, v->element_size);
	ld	c, -2 (ix)
	ld	b, -1 (ix)
	ld	hl, #6
	add	hl, bc
	ld	a, (hl)
	ld	-10 (ix), a
	inc	hl
	ld	a, (hl)
	ld	-9 (ix), a
	ld	l, -2 (ix)
	ld	h, -1 (ix)
	ld	a, (hl)
	ld	-8 (ix), a
	inc	hl
	ld	a, (hl)
	ld	-7 (ix), a
	ld	a, -4 (ix)
	ld	-14 (ix), a
	ld	a, -3 (ix)
	ld	-13 (ix), a
	ld	a, -14 (ix)
	add	a, #0x01
	ld	-6 (ix), a
	ld	a, -13 (ix)
	adc	a, #0x00
	ld	-5 (ix), a
	ld	e, -8 (ix)
	ld	d, -7 (ix)
	ld	l, -6 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -5 (ix)
;	spillPairReg hl
;	spillPairReg hl
	call	_multiply
	ld	-8 (ix), e
	ld	-7 (ix), d
	ld	a, -8 (ix)
	add	a, -10 (ix)
	ld	-6 (ix), a
	ld	a, -7 (ix)
	adc	a, -9 (ix)
	ld	-5 (ix), a
	ld	l, -2 (ix)
	ld	h, -1 (ix)
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
;vector.c:128: char* src = dst - v->element_size;
	ld	a, -6 (ix)
	sub	a, e
	ld	c, a
	ld	a, -5 (ix)
	sbc	a, d
	ld	-8 (ix), c
	ld	-7 (ix), a
;vector.c:129: copy(dst, src, multiply(v->size - index, v->element_size));
	ld	l, -12 (ix)
	ld	h, -11 (ix)
	ld	c, (hl)
	inc	hl
	ld	b, (hl)
	ld	a, c
	sub	a, -4 (ix)
	ld	l, a
;	spillPairReg hl
;	spillPairReg hl
	ld	a, b
	sbc	a, -3 (ix)
	ld	h, a
;	spillPairReg hl
;	spillPairReg hl
	call	_multiply
;	spillPairReg hl
;	spillPairReg hl
	ld	-10 (ix), e
	ld	-9 (ix), d
;	spillPairReg hl
;	spillPairReg hl
	push	de
	ld	e, -8 (ix)
	ld	d, -7 (ix)
	ld	l, -6 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -5 (ix)
;	spillPairReg hl
;	spillPairReg hl
	call	_copy
;vector.c:130: v->size++;
	ld	l, -12 (ix)
	ld	h, -11 (ix)
	ld	c, (hl)
	inc	hl
	ld	b, (hl)
	inc	bc
	ld	-6 (ix), c
	ld	-5 (ix), b
	pop	bc
	pop	hl
	push	hl
	push	bc
	ld	a, -6 (ix)
	ld	(hl), a
	inc	hl
	ld	a, -5 (ix)
	ld	(hl), a
;vector.c:131: vector_set(v, index, element);
	ld	l, 4 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, 5 (ix)
;	spillPairReg hl
;	spillPairReg hl
	push	hl
	ld	e, -4 (ix)
	ld	d, -3 (ix)
	ld	l, -2 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -1 (ix)
;	spillPairReg hl
;	spillPairReg hl
	call	_vector_set
;vector.c:132: return 1;
	ld	a, #0x01
00105$:
;vector.c:133: }
	ld	sp, ix
	pop	ix
	pop	hl
	pop	bc
	jp	(hl)
;vector.c:135: byte		vector_push(Vector* v, void* element)
;	---------------------------------
; Function vector_push
; ---------------------------------
_vector_push::
	push	ix
	ld	ix,#0
	add	ix,sp
	push	af
	push	af
	ld	c, l
	ld	b, h
	ld	-2 (ix), e
	ld	-1 (ix), d
;vector.c:137: if (!v) return 0;
	ld	a, b
	or	a,c
	jr	Z, 00103$
;vector.c:138: ensure_capacity(v);
	push	bc
	ld	l, c
;	spillPairReg hl
;	spillPairReg hl
	ld	h, b
;	spillPairReg hl
;	spillPairReg hl
	call	_ensure_capacity
	pop	bc
;vector.c:139: copy(v->data + multiply(v->size, v->element_size), element, v->element_size);
	ld	l, c
	ld	h, b
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	push	de
	pop	iy
	ld	l, c
;	spillPairReg hl
;	spillPairReg hl
	ld	h, b
;	spillPairReg hl
;	spillPairReg hl
	push	bc
	ld	bc, #0x0006
	add	hl, bc
	pop	bc
	ld	a, (hl)
	ld	-4 (ix), a
	inc	hl
	ld	a, (hl)
	ld	-3 (ix), a
	inc	bc
	inc	bc
	inc	bc
	inc	bc
	ld	l, c
	ld	h, b
	ld	a, (hl)
	inc	hl
	ld	h, (hl)
;	spillPairReg hl
	ld	l, a
;	spillPairReg hl
;	spillPairReg hl
	push	bc
	push	iy
	call	_multiply
	pop	iy
	pop	bc
	pop	hl
	push	hl
	add	hl, de
	push	bc
	push	iy
	ld	e, -2 (ix)
	ld	d, -1 (ix)
	call	_copy
	pop	bc
;vector.c:140: v->size++;
	ld	l, c
	ld	h, b
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	inc	de
	ld	a, e
	ld	(bc), a
	inc	bc
	ld	a, d
	ld	(bc), a
;vector.c:141: return 1;
	ld	a, #0x01
00103$:
;vector.c:142: }
	ld	sp, ix
	pop	ix
	ret
;vector.c:144: byte		vector_pop(Vector* v, void* element)
;	---------------------------------
; Function vector_pop
; ---------------------------------
_vector_pop::
	push	ix
	ld	ix,#0
	add	ix,sp
	push	af
	push	af
	ld	c, l
	ld	b, h
	ld	-2 (ix), e
	ld	-1 (ix), d
;vector.c:146: if (!v) return 0;
	ld	a, b
	or	a,c
	jr	Z, 00107$
;vector.c:147: if (v->size > 0)
	ld	hl, #0x0004
	add	hl, bc
	ex	(sp), hl
	pop	hl
	push	hl
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	ld	a, d
	or	a, e
	jr	Z, 00106$
;vector.c:149: v->size--;
	dec	de
	pop	hl
	push	hl
	ld	(hl), e
	inc	hl
	ld	(hl), d
;vector.c:150: if (element)
	ld	a, -1 (ix)
	or	a, -2 (ix)
	jr	Z, 00104$
;vector.c:151: copy(element, v->data + multiply(v->size, v->element_size), v->element_size);
	ld	l, c
	ld	h, b
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	push	de
	pop	iy
	ld	hl, #6
	add	hl, bc
	ld	c, (hl)
	inc	hl
	ld	b, (hl)
	pop	hl
	push	hl
	ld	a, (hl)
	inc	hl
	ld	h, (hl)
;	spillPairReg hl
	ld	l, a
;	spillPairReg hl
;	spillPairReg hl
	push	bc
	push	iy
	call	_multiply
	ex	de, hl
	pop	iy
	pop	bc
	add	hl, bc
	push	iy
	ex	de, hl
	ld	l, -2 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -1 (ix)
;	spillPairReg hl
;	spillPairReg hl
	call	_copy
00104$:
;vector.c:152: return 1;
	ld	a, #0x01
	jr	00107$
00106$:
;vector.c:154: return 0;
	xor	a, a
00107$:
;vector.c:155: }
	ld	sp, ix
	pop	ix
	ret
;vector.c:157: void*		vector_access(Vector* v, word index)
;	---------------------------------
; Function vector_access
; ---------------------------------
_vector_access::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	iy, #-10
	add	iy, sp
	ld	sp, iy
	ld	-2 (ix), l
	ld	-1 (ix), h
	ld	-4 (ix), e
	ld	-3 (ix), d
;vector.c:159: if (!v) return 0;
	ld	a, -1 (ix)
	or	a, -2 (ix)
	jr	NZ, 00102$
	ld	de, #0x0000
	jr	00105$
00102$:
;vector.c:160: if (index >= v->size) return 0;
	ld	c, -2 (ix)
	ld	b, -1 (ix)
	ld	hl, #4
	add	hl, bc
	ld	c, (hl)
	inc	hl
	ld	b, (hl)
	ld	a, -4 (ix)
	sub	a, c
	ld	a, -3 (ix)
	sbc	a, b
	jr	C, 00104$
	ld	de, #0x0000
	jr	00105$
00104$:
;vector.c:161: return v->data + multiply(index, v->element_size);
	ld	c, -2 (ix)
	ld	b, -1 (ix)
	ld	hl, #6
	add	hl, bc
	ld	a, (hl)
	ld	-10 (ix), a
	inc	hl
	ld	a, (hl)
	ld	-9 (ix), a
	ld	l, -2 (ix)
	ld	h, -1 (ix)
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	ld	l, -4 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -3 (ix)
;	spillPairReg hl
;	spillPairReg hl
	call	_multiply
	ld	-8 (ix), e
	ld	-7 (ix), d
	ld	a, -8 (ix)
	add	a, -10 (ix)
	ld	-6 (ix), a
	ld	a, -7 (ix)
	adc	a, -9 (ix)
	ld	-5 (ix), a
	ld	e, -6 (ix)
	ld	d, -5 (ix)
00105$:
;vector.c:162: }
	ld	sp, ix
	pop	ix
	ret
;vector.c:164: byte		vector_set(Vector* v, word index, void* element)
;	---------------------------------
; Function vector_set
; ---------------------------------
_vector_set::
	push	ix
	ld	ix,#0
	add	ix,sp
;vector.c:166: if (v)
	ld	a, h
	or	a, l
	jr	Z, 00105$
;vector.c:168: void* dst = vector_access(v, index);
	push	hl
	call	_vector_access
	ld	c, e
	ld	b, d
	pop	hl
;vector.c:169: if (element && dst)
	ld	a, 5 (ix)
	or	a, 4 (ix)
	jr	Z, 00105$
	ld	a, b
	or	a, c
	jr	Z, 00105$
;vector.c:171: copy(dst, element, v->element_size);
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	push	de
	ld	e, 4 (ix)
	ld	d, 5 (ix)
	ld	l, c
;	spillPairReg hl
;	spillPairReg hl
	ld	h, b
;	spillPairReg hl
;	spillPairReg hl
	call	_copy
;vector.c:172: return 1;
	ld	a, #0x01
	jr	00106$
00105$:
;vector.c:175: return 0;
	xor	a, a
00106$:
;vector.c:176: }
	pop	ix
	pop	hl
	pop	bc
	jp	(hl)
;vector.c:178: byte		vector_get(Vector* v, word index, void* element)
;	---------------------------------
; Function vector_get
; ---------------------------------
_vector_get::
	push	ix
	ld	ix,#0
	add	ix,sp
;vector.c:180: if (!v) return 0;
	ld	a, h
	or	a, l
	jr	NZ, 00102$
	xor	a, a
	jr	00106$
00102$:
;vector.c:181: void* src = vector_access(v, index);
	push	hl
	call	_vector_access
	pop	hl
;vector.c:182: if (element && src)
	ld	a, 5 (ix)
	or	a, 4 (ix)
	jr	Z, 00104$
	ld	a, d
	or	a, e
	jr	Z, 00104$
;vector.c:184: copy(element, src, v->element_size);
	ld	c, (hl)
	inc	hl
	ld	b, (hl)
	push	bc
	ld	l, 4 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, 5 (ix)
;	spillPairReg hl
;	spillPairReg hl
	call	_copy
;vector.c:185: return 1;
	ld	a, #0x01
	jr	00106$
00104$:
;vector.c:187: return 0;
	xor	a, a
00106$:
;vector.c:188: }
	pop	ix
	pop	hl
	pop	bc
	jp	(hl)
;vector.c:190: byte		vector_erase(Vector* v, word index)
;	---------------------------------
; Function vector_erase
; ---------------------------------
_vector_erase::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	iy, #-8
	add	iy, sp
	ld	sp, iy
	ld	c, l
	ld	b, h
	ld	-2 (ix), e
	ld	-1 (ix), d
;vector.c:192: if (!v) return 0;
	ld	a, b
	or	a,c
	jp	Z,00107$
;vector.c:193: if (index >= v->size) return 0;
	ld	hl, #0x0004
	add	hl, bc
	ex	(sp), hl
	pop	hl
	push	hl
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	ld	a, -2 (ix)
	sub	a, e
	ld	a, -1 (ix)
	sbc	a, d
	jr	C, 00104$
	xor	a, a
	jr	00107$
00104$:
;vector.c:194: if (index < (v->size - 1))
	ld	l, e
;	spillPairReg hl
;	spillPairReg hl
	ld	h, d
;	spillPairReg hl
;	spillPairReg hl
	dec	hl
	ld	a, -2 (ix)
	ld	-6 (ix), a
	ld	a, -1 (ix)
	ld	-5 (ix), a
	ld	a, -6 (ix)
	sub	a, l
	ld	a, -5 (ix)
	sbc	a, h
	jr	NC, 00106$
;vector.c:198: multiply(v->element_size, (v->size - index - 1)));
	ld	a, e
	sub	a, -2 (ix)
	ld	e, a
	ld	a, d
	sbc	a, -1 (ix)
	ld	d, a
	dec	de
	ld	l, c
	ld	h, b
	ld	a, (hl)
	inc	hl
	ld	h, (hl)
;	spillPairReg hl
	ld	l, a
;	spillPairReg hl
;	spillPairReg hl
	push	bc
	call	_multiply
	pop	bc
	ld	-4 (ix), e
	ld	-3 (ix), d
;vector.c:197: vector_access(v, index + 1),
	pop	hl
	pop	de
	push	de
	push	hl
	inc	de
	push	bc
	ld	l, c
;	spillPairReg hl
;	spillPairReg hl
	ld	h, b
;	spillPairReg hl
;	spillPairReg hl
	call	_vector_access
	ex	de, hl
	pop	bc
;vector.c:196: copy(vector_access(v, index),
	push	hl
	push	bc
	ld	e, -2 (ix)
	ld	d, -1 (ix)
	ld	l, c
;	spillPairReg hl
;	spillPairReg hl
	ld	h, b
;	spillPairReg hl
;	spillPairReg hl
	call	_vector_access
	push	de
	pop	iy
	pop	bc
	pop	hl
	push	bc
	ld	e, -4 (ix)
	ld	d, -3 (ix)
	ex	de, hl
	push	hl
	push	iy
	pop	hl
	call	_copy
	pop	bc
00106$:
;vector.c:200: vector_resize(v, v->size - 1);
	pop	hl
	push	hl
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	dec	de
	ld	l, c
;	spillPairReg hl
;	spillPairReg hl
	ld	h, b
;	spillPairReg hl
;	spillPairReg hl
	call	_vector_resize
;vector.c:201: return 1;
	ld	a, #0x01
00107$:
;vector.c:202: }
	ld	sp, ix
	pop	ix
	ret
;vector.c:204: byte		vector_erase_range(Vector* v, word begin, word end)
;	---------------------------------
; Function vector_erase_range
; ---------------------------------
_vector_erase_range::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	iy, #-10
	add	iy, sp
	ld	sp, iy
	ld	-2 (ix), l
	ld	-1 (ix), h
	ld	-4 (ix), e
	ld	-3 (ix), d
;vector.c:206: if (!v) return 0;
	ld	a, -1 (ix)
	or	a, -2 (ix)
	jr	NZ, 00102$
	xor	a, a
	jp	00109$
00102$:
;vector.c:207: if (begin >= v->size || end>v->size || begin>=end) return 0;
	ld	a, -2 (ix)
	add	a, #0x04
	ld	-6 (ix), a
	ld	a, -1 (ix)
	adc	a, #0x00
	ld	-5 (ix), a
	ld	l, -6 (ix)
	ld	h, -5 (ix)
	ld	c, (hl)
	inc	hl
	ld	b, (hl)
	ld	a, -4 (ix)
	sub	a, c
	ld	a, -3 (ix)
	sbc	a, b
	jr	NC, 00103$
	ld	a, c
	sub	a, 4 (ix)
	ld	a, b
	sbc	a, 5 (ix)
	jr	C, 00103$
	ld	a, -4 (ix)
	sub	a, 4 (ix)
	ld	a, -3 (ix)
	sbc	a, 5 (ix)
	jr	C, 00104$
00103$:
	xor	a, a
	jp	00109$
00104$:
;vector.c:208: word n=end-begin;
	ld	a, 4 (ix)
	sub	a, -4 (ix)
	ld	e, a
	ld	a, 5 (ix)
	sbc	a, -3 (ix)
	ld	-10 (ix), e
	ld	-9 (ix), a
;vector.c:209: if (end < v->size)
	ld	a, 4 (ix)
	sub	a, c
	ld	a, 5 (ix)
	sbc	a, b
	jr	NC, 00108$
;vector.c:213: multiply(v->element_size, (v->size - end)));
	ld	a, c
	sub	a, 4 (ix)
	ld	e, a
	ld	a, b
	sbc	a, 5 (ix)
	ld	d, a
	ld	l, -2 (ix)
	ld	h, -1 (ix)
	ld	a, (hl)
	inc	hl
	ld	h, (hl)
;	spillPairReg hl
	ld	l, a
;	spillPairReg hl
;	spillPairReg hl
	call	_multiply
;vector.c:212: vector_access(v, end), 
	push	de
	ld	e, 4 (ix)
	ld	d, 5 (ix)
	ld	l, -2 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -1 (ix)
;	spillPairReg hl
;	spillPairReg hl
	call	_vector_access
	ex	de, hl
	pop	bc
;vector.c:211: copy(vector_access(v, begin), 
	push	hl
	push	bc
	ld	e, -4 (ix)
	ld	d, -3 (ix)
	ld	l, -2 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -1 (ix)
;	spillPairReg hl
;	spillPairReg hl
	call	_vector_access
	push	de
	pop	iy
	pop	bc
	pop	hl
	push	bc
	push	iy
	ex	de, hl
	pop	hl
	call	_copy
00108$:
;vector.c:215: vector_resize(v, v->size-n);
	ld	l, -6 (ix)
	ld	h, -5 (ix)
	ld	a, (hl)
	ld	-8 (ix), a
	inc	hl
	ld	a, (hl)
	ld	-7 (ix), a
	ld	a, -8 (ix)
	sub	a, -10 (ix)
	ld	-6 (ix), a
	ld	a, -7 (ix)
	sbc	a, -9 (ix)
	ld	-5 (ix), a
	ld	e, -6 (ix)
	ld	d, -5 (ix)
	ld	l, -2 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -1 (ix)
;	spillPairReg hl
;	spillPairReg hl
	call	_vector_resize
;vector.c:216: return 1;
	ld	a, #0x01
00109$:
;vector.c:217: }
	ld	sp, ix
	pop	ix
	pop	hl
	pop	bc
	jp	(hl)
;vector.c:219: word		vector_capacity(Vector* v)
;	---------------------------------
; Function vector_capacity
; ---------------------------------
_vector_capacity::
;vector.c:221: if (!v) return 0;
	ld	a, h
	or	a, l
	jr	NZ, 00102$
	ld	de, #0x0000
	ret
00102$:
;vector.c:222: return v->capacity;
	inc	hl
	inc	hl
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
;vector.c:223: }
	ret
;vector.c:225: word		vector_element_size(Vector* v)
;	---------------------------------
; Function vector_element_size
; ---------------------------------
_vector_element_size::
;vector.c:227: if (!v) return 0;
	ld	a, h
	or	a, l
	jr	NZ, 00102$
	ld	de, #0x0000
	ret
00102$:
;vector.c:228: return v->element_size;
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
;vector.c:229: }
	ret
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
