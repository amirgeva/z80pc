;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 4.2.0 #13081 (MINGW64)
;--------------------------------------------------------
	.module memory
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _defrag
	.globl _unite_free_blocks
	.globl _sort_free_blocks
	.globl _find_free_block
	.globl _get_pointer
	.globl _get_offset
	.globl _check_heap
	.globl _alloc_init
	.globl _alloc_shut
	.globl _allocate
	.globl _release
	.globl _verify_heap
	.globl _get_total_allocated
	.globl _get_max_allocated
	.globl _print_leaked
;--------------------------------------------------------
; special function registers
;--------------------------------------------------------
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _DATA
_max_allocated:
	.ds 2
_total_allocated:
	.ds 2
_heap:
	.ds 2
_free_block:
	.ds 2
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _INITIALIZED
_static_heap:
	.ds 2
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
;memory.c:13: byte check_heap(word size)
;	---------------------------------
; Function check_heap
; ---------------------------------
_check_heap::
	ex	de, hl
;memory.c:15: return (heap + size) <= HEAP_SIZE;
	ld	hl, (_heap)
	add	hl, de
	xor	a, a
	cp	a, l
	ld	a, #0x70
	sbc	a, h
	ld	a, #0x00
	rla
	xor	a, #0x01
;memory.c:16: }
	ret
;memory.c:28: word get_offset(void* ptr)
;	---------------------------------
; Function get_offset
; ---------------------------------
_get_offset::
	ex	de, hl
;memory.c:30: return (word)(((byte*)ptr) - static_heap);
	ld	hl, #_static_heap
	ld	a, e
	sub	a, (hl)
	inc	hl
	ld	e, a
	ld	a, d
	sbc	a, (hl)
	ld	d, a
;memory.c:31: }
	ret
;memory.c:33: void* get_pointer(word offset)
;	---------------------------------
; Function get_pointer
; ---------------------------------
_get_pointer::
	ex	de, hl
;memory.c:35: return static_heap + offset;
	ld	hl, (_static_heap)
	add	hl, de
	ex	de, hl
;memory.c:36: }
	ret
;memory.c:38: void alloc_init()
;	---------------------------------
; Function alloc_init
; ---------------------------------
_alloc_init::
;memory.c:43: max_allocated = 0;
	ld	hl, #0x0000
	ld	(_max_allocated), hl
;memory.c:44: total_allocated = 0;
	ld	(_total_allocated), hl
;memory.c:45: heap=0;
	ld	(_heap), hl
;memory.c:46: free_block = 0xFFFF;
	ld	hl, #0xffff
	ld	(_free_block), hl
;memory.c:47: static_heap = (byte*)0x8000;
	ld	hl, #0x8000
	ld	(_static_heap), hl
;memory.c:49: }
	ret
;memory.c:51: void alloc_shut()
;	---------------------------------
; Function alloc_shut
; ---------------------------------
_alloc_shut::
;memory.c:57: }
	ret
;memory.c:59: void* find_free_block(word size)
;	---------------------------------
; Function find_free_block
; ---------------------------------
_find_free_block::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	iy, #-14
	add	iy, sp
	ld	sp, iy
	ld	-2 (ix), l
	ld	-1 (ix), h
;memory.c:61: word best=0xFFFF;
	ld	-4 (ix), #0xff
	ld	-3 (ix), #0xff
;memory.c:62: word best_prev=0xFFFF;
	ld	hl, #0xffff
	ex	(sp), hl
;memory.c:63: word best_diff=0xFFFF;
	ld	-6 (ix), #0xff
	ld	-5 (ix), #0xff
;memory.c:64: word prev = 0xFFFF;
	ld	-8 (ix), #0xff
	ld	-7 (ix), #0xff
;memory.c:65: word current = free_block;
	ld	bc, (_free_block)
;memory.c:66: word* best_ptr=0;
	xor	a, a
	ld	-12 (ix), a
	ld	-11 (ix), a
;memory.c:67: while (current != 0xFFFF)
00110$:
	ld	e, c
	ld	d, b
	ld	a, e
	and	a, d
	inc	a
	jr	Z, 00112$
;memory.c:69: word* ptr=(word*)get_pointer(current);
	push	bc
	ld	l, c
;	spillPairReg hl
;	spillPairReg hl
	ld	h, b
;	spillPairReg hl
;	spillPairReg hl
	call	_get_pointer
	pop	bc
	ex	de, hl
;memory.c:70: word block_size = *ptr;
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	dec	hl
;memory.c:71: if (block_size >= size)
	ld	a, e
	sub	a, -2 (ix)
	ld	a, d
	sbc	a, -1 (ix)
	jr	C, 00109$
;memory.c:73: word diff=block_size-size;
	ld	a, e
	sub	a, -2 (ix)
	ld	e, a
	ld	a, d
	sbc	a, -1 (ix)
;memory.c:74: if (diff == 0 || diff >= (2 * sizeof(word)))
	ld	d, a
	or	a, e
	jr	Z, 00105$
	ld	a, e
	sub	a, #0x04
	ld	a, d
	sbc	a, #0x00
	jr	C, 00109$
00105$:
;memory.c:76: if (diff < best_diff)
	ld	a, e
	sub	a, -6 (ix)
	ld	a, d
	sbc	a, -5 (ix)
	jr	NC, 00109$
;memory.c:78: best_ptr=ptr;
	ld	-12 (ix), l
	ld	-11 (ix), h
;memory.c:79: best_diff = diff;
	ld	-6 (ix), e
	ld	-5 (ix), d
;memory.c:80: best = current;
	ld	-4 (ix), c
	ld	-3 (ix), b
;memory.c:81: best_prev = prev;
	ld	a, -8 (ix)
	ld	-14 (ix), a
	ld	a, -7 (ix)
	ld	-13 (ix), a
;memory.c:82: if (best_diff==0) break;
	ld	a, d
	or	a, e
	jr	Z, 00112$
00109$:
;memory.c:86: prev=current;
	ld	-8 (ix), c
	ld	-7 (ix), b
;memory.c:87: current=ptr[1];
	inc	hl
	inc	hl
	ld	c, (hl)
	inc	hl
	ld	b, (hl)
	jr	00110$
00112$:
;memory.c:89: if (best == 0xFFFF) return 0;
	ld	a, -4 (ix)
	ld	b, -3 (ix)
	and	a, b
	inc	a
	jr	NZ, 00114$
	ld	de, #0x0000
	jp	00120$
00114$:
;memory.c:95: left_over[1]=best_ptr[1];
	ld	a, -12 (ix)
	add	a, #0x02
	ld	-10 (ix), a
	ld	a, -11 (ix)
	adc	a, #0x00
	ld	-9 (ix), a
;memory.c:90: if (best_diff > 0)
	ld	a, -5 (ix)
	or	a, -6 (ix)
	jr	Z, 00116$
;memory.c:93: word* left_over = (word*)get_pointer(best+size);
	ld	a, -4 (ix)
	add	a, -2 (ix)
	ld	-8 (ix), a
	ld	a, -3 (ix)
	adc	a, -1 (ix)
	ld	-7 (ix), a
	ld	l, -8 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -7 (ix)
;	spillPairReg hl
;	spillPairReg hl
	call	_get_pointer
	ld	-4 (ix), e
	ld	-3 (ix), d
	ld	a, -4 (ix)
	ld	-6 (ix), a
	ld	a, -3 (ix)
	ld	-5 (ix), a
;memory.c:94: left_over[0]=*best_ptr - size;
	ld	l, -12 (ix)
	ld	h, -11 (ix)
	ld	a, (hl)
	ld	-4 (ix), a
	inc	hl
	ld	a, (hl)
	ld	-3 (ix), a
	ld	a, -4 (ix)
	sub	a, -2 (ix)
	ld	c, a
	ld	a, -3 (ix)
	sbc	a, -1 (ix)
	ld	b, a
	ld	l, -6 (ix)
	ld	h, -5 (ix)
	ld	(hl), c
	inc	hl
	ld	(hl), b
;memory.c:95: left_over[1]=best_ptr[1];
	ld	c, -6 (ix)
	ld	b, -5 (ix)
	inc	bc
	inc	bc
	ld	l, -10 (ix)
	ld	h, -9 (ix)
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	ld	a, e
	ld	(bc), a
	inc	bc
	ld	a, d
	ld	(bc), a
;memory.c:96: best_ptr[1]=best+size;
	ld	l, -10 (ix)
	ld	h, -9 (ix)
	ld	a, -8 (ix)
	ld	(hl), a
	inc	hl
	ld	a, -7 (ix)
	ld	(hl), a
00116$:
;memory.c:98: if (best_prev != 0xFFFF)
	pop	bc
	push	bc
	ld	a, c
	and	a, b
	inc	a
	jr	Z, 00118$
;memory.c:100: word* prev_ptr = (word*)get_pointer(best_prev);
	pop	hl
	push	hl
	call	_get_pointer
	ld	-4 (ix), e
	ld	-3 (ix), d
;memory.c:101: prev_ptr[1]=best_ptr[1];
	ld	a, -4 (ix)
	add	a, #0x02
	ld	-6 (ix), a
	ld	a, -3 (ix)
	adc	a, #0x00
	ld	-5 (ix), a
	ld	l, -10 (ix)
	ld	h, -9 (ix)
	ld	a, (hl)
	ld	-4 (ix), a
	inc	hl
	ld	a, (hl)
	ld	-3 (ix), a
	ld	l, -6 (ix)
	ld	h, -5 (ix)
	ld	a, -4 (ix)
	ld	(hl), a
	inc	hl
	ld	a, -3 (ix)
	ld	(hl), a
	jr	00119$
00118$:
;memory.c:104: free_block = best_ptr[1];
	ld	l, -10 (ix)
	ld	h, -9 (ix)
	ld	a, (hl)
	inc	hl
	ld	(_free_block+0), a
	ld	a, (hl)
	ld	(_free_block+1), a
00119$:
;memory.c:105: return best_ptr;
	pop	hl
	pop	de
	push	de
	push	hl
00120$:
;memory.c:106: }
	ld	sp, ix
	pop	ix
	ret
;memory.c:108: void* allocate(word size)
;	---------------------------------
; Function allocate
; ---------------------------------
_allocate::
	push	ix
	ld	ix,#0
	add	ix,sp
	push	af
	ld	c, l
	ld	b, h
;memory.c:110: if (size==0) return 0;
	ld	a, b
	or	a, c
	jr	NZ, 00102$
	ld	de, #0x0000
	jr	00111$
00102$:
;memory.c:111: if (size<sizeof(word))
	ld	a, c
	sub	a, #0x02
	ld	a, b
	sbc	a, #0x00
	jr	NC, 00104$
;memory.c:112: size=sizeof(word); // minimum allocation is sizeof(word)
	ld	bc, #0x0002
00104$:
;memory.c:113: size += sizeof(word);
	inc	bc
	inc	bc
;memory.c:114: void* best_free_block=find_free_block(size);
	push	bc
	ld	l, c
;	spillPairReg hl
;	spillPairReg hl
	ld	h, b
;	spillPairReg hl
;	spillPairReg hl
	call	_find_free_block
	pop	bc
;memory.c:115: if (!best_free_block)
	ld	a, d
	or	a, e
	jr	NZ, 00108$
;memory.c:117: if (!check_heap(size)) return 0;
	push	bc
	ld	l, c
;	spillPairReg hl
;	spillPairReg hl
	ld	h, b
;	spillPairReg hl
;	spillPairReg hl
	call	_check_heap
	pop	bc
	or	a, a
	jr	NZ, 00106$
	ld	de, #0x0000
	jr	00111$
00106$:
;memory.c:118: best_free_block = get_pointer(heap);
	push	bc
	ld	hl, (_heap)
	call	_get_pointer
	pop	bc
;memory.c:119: heap += size;
	ld	a, c
	ld	iy, #_heap
	add	a, 0 (iy)
	ld	(_heap+0), a
	ld	a, b
	adc	a, 1 (iy)
	ld	(_heap+1), a
00108$:
;memory.c:121: word* header = (word*)best_free_block;
	inc	sp
	inc	sp
	push	de
;memory.c:122: *header = size;
	pop	hl
	push	hl
	ld	(hl), c
	inc	hl
	ld	(hl), b
;memory.c:123: total_allocated += size;
	ld	hl, #_total_allocated
	ld	a, (hl)
	add	a, c
	ld	(hl), a
	inc	hl
	ld	a, (hl)
	adc	a, b
	ld	(hl), a
;memory.c:124: if (heap > max_allocated)
	ld	hl, #_max_allocated
	ld	a, (hl)
	ld	iy, #_heap
	sub	a, 0 (iy)
	inc	hl
	ld	a, (hl)
	sbc	a, 1 (iy)
	jr	NC, 00110$
;memory.c:126: max_allocated=heap;
	ld	hl, (_heap)
	ld	(_max_allocated), hl
00110$:
;memory.c:128: word offset= get_offset(best_free_block);
	ex	de, hl
	call	_get_offset
;memory.c:133: return header + 1;
	pop	de
	push	de
	inc	de
	inc	de
00111$:
;memory.c:134: }
	ld	sp, ix
	pop	ix
	ret
;memory.c:136: void sort_free_blocks()
;	---------------------------------
; Function sort_free_blocks
; ---------------------------------
_sort_free_blocks::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	hl, #-10
	add	hl, sp
	ld	sp, hl
;memory.c:139: word swaps=1;
	ld	hl, #0x0001
	ex	(sp), hl
;memory.c:140: while (swaps > 0)
00109$:
	ld	a, -9 (ix)
	or	a, -10 (ix)
	jp	Z, 00112$
;memory.c:142: swaps=0;
	ld	hl, #0x0000
	ex	(sp), hl
;memory.c:143: word prev=0xFFFF;
	ld	-8 (ix), #0xff
	ld	-7 (ix), #0xff
;memory.c:144: word current = free_block;
	ld	hl, (_free_block)
	ld	-6 (ix), l
	ld	-5 (ix), h
;memory.c:145: while (current != 0xFFFF)
	xor	a, a
	ld	-2 (ix), a
	ld	-1 (ix), a
00106$:
	ld	a, -6 (ix)
	ld	-4 (ix), a
	ld	a, -5 (ix)
	ld	-3 (ix), a
	ld	a, -4 (ix)
	and	a, -3 (ix)
	inc	a
	jr	Z, 00109$
;memory.c:147: word* cur_ptr=(word*)get_pointer(current);
	ld	l, -6 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -5 (ix)
;	spillPairReg hl
;	spillPairReg hl
	call	_get_pointer
;memory.c:148: word next=cur_ptr[1];
	inc	de
	inc	de
	ld	a, (de)
	ld	-4 (ix), a
	inc	de
	ld	a, (de)
	ld	-3 (ix), a
	dec	de
;memory.c:149: if (next<current)
	ld	a, -4 (ix)
	sub	a, -6 (ix)
	ld	a, -3 (ix)
	sbc	a, -5 (ix)
	jr	NC, 00105$
;memory.c:151: word* next_ptr=(word*)get_pointer(next);
	push	de
	ld	l, -4 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -3 (ix)
;	spillPairReg hl
;	spillPairReg hl
	call	_get_pointer
	ld	c, e
	ld	b, d
	pop	de
;memory.c:152: if (prev==0xFFFF) free_block=next;
;	spillPairReg hl
;	spillPairReg hl
;	spillPairReg hl
;	spillPairReg hl
	ld	a, -8 (ix)
	ld	h, -7 (ix)
	and	a, h
	inc	a
	jr	NZ, 00102$
	ld	l, -4 (ix)
	ld	h, -3 (ix)
	ld	(_free_block), hl
	jr	00103$
00102$:
;memory.c:155: word* prev_ptr=(word*)get_pointer(prev);
	push	bc
	push	de
	ld	l, -8 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -7 (ix)
;	spillPairReg hl
;	spillPairReg hl
	call	_get_pointer
	ex	de, hl
;memory.c:156: prev_ptr[1]=next;
	inc	hl
	inc	hl
	pop	de
	pop	bc
	ld	a, -4 (ix)
	ld	(hl), a
	inc	hl
	ld	a, -3 (ix)
	ld	(hl), a
00103$:
;memory.c:158: cur_ptr[1]=next_ptr[1];
	inc	bc
	inc	bc
	ld	a, (bc)
	ld	-8 (ix), a
	inc	bc
	ld	a, (bc)
	ld	-7 (ix), a
	dec	bc
	ld	a, -8 (ix)
	ld	(de), a
	inc	de
	ld	a, -7 (ix)
	ld	(de), a
;memory.c:159: next_ptr[1]=current;
	ld	a, -6 (ix)
	ld	(bc), a
	inc	bc
	ld	a, -5 (ix)
	ld	(bc), a
;memory.c:160: swaps++;
	inc	-2 (ix)
	jr	NZ, 00147$
	inc	-1 (ix)
00147$:
	ld	a, -2 (ix)
	ld	-10 (ix), a
	ld	a, -1 (ix)
	ld	-9 (ix), a
00105$:
;memory.c:162: prev=current;
	ld	a, -6 (ix)
	ld	-8 (ix), a
	ld	a, -5 (ix)
	ld	-7 (ix), a
;memory.c:163: current=next;
	ld	a, -4 (ix)
	ld	-6 (ix), a
	ld	a, -3 (ix)
	ld	-5 (ix), a
	jp	00106$
00112$:
;memory.c:166: }
	ld	sp, ix
	pop	ix
	ret
;memory.c:168: void unite_free_blocks()
;	---------------------------------
; Function unite_free_blocks
; ---------------------------------
_unite_free_blocks::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	hl, #-10
	add	hl, sp
	ld	sp, hl
;memory.c:170: word current = free_block;
	ld	hl, (_free_block)
	ex	(sp), hl
;memory.c:171: word last = 0xFFFF;
	ld	-8 (ix), #0xff
	ld	-7 (ix), #0xff
;memory.c:172: while (current != 0xFFFF)
00109$:
	pop	bc
	push	bc
	ld	a, c
	and	a, b
	inc	a
	jp	Z,00112$
;memory.c:174: word* cur_ptr=(word*)get_pointer(current);
	pop	hl
	push	hl
	call	_get_pointer
;memory.c:175: while ((current + cur_ptr[0]) == cur_ptr[1]) // Consecutive blocks
00101$:
	ld	a, (de)
	ld	-6 (ix), a
	inc	de
	ld	a, (de)
	ld	-5 (ix), a
	dec	de
	ld	a, -6 (ix)
	add	a, -10 (ix)
	ld	c, a
	ld	a, -5 (ix)
	adc	a, -9 (ix)
	ld	b, a
	ld	hl, #0x0002
	add	hl, de
	ld	-4 (ix), l
	ld	-3 (ix), h
	ld	a, (hl)
	ld	-2 (ix), a
	inc	hl
	ld	a, (hl)
	ld	-1 (ix), a
	ld	l, -2 (ix)
	ld	h, -1 (ix)
	cp	a, a
	sbc	hl, bc
	jr	NZ, 00103$
;memory.c:177: word* next_ptr=(word*)get_pointer(cur_ptr[1]);
	push	de
	ld	l, -2 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -1 (ix)
;	spillPairReg hl
;	spillPairReg hl
	call	_get_pointer
	push	de
	pop	iy
	pop	de
;memory.c:178: cur_ptr[0]+=next_ptr[0];
	ld	l, e
	ld	h, d
	ld	c, (hl)
	inc	hl
	ld	b, (hl)
	ld	l, 0 (iy)
;	spillPairReg hl
	ld	h, 1 (iy)
;	spillPairReg hl
	add	hl, bc
	ld	c, l
	ld	b, h
	ld	l, e
	ld	h, d
	ld	(hl), c
	inc	hl
	ld	(hl), b
;memory.c:179: cur_ptr[1]=next_ptr[1];
	push	iy
	pop	hl
	inc	hl
	inc	hl
	ld	c, (hl)
	inc	hl
	ld	b, (hl)
	ld	l, -4 (ix)
	ld	h, -3 (ix)
	ld	(hl), c
	inc	hl
	ld	(hl), b
	jr	00101$
00103$:
;memory.c:181: if ((current + cur_ptr[0]) == heap) // Last block in heap
	ld	hl, (_heap)
	cp	a, a
	sbc	hl, bc
	jr	NZ, 00108$
;memory.c:183: heap -= cur_ptr[0];
	ld	hl, #_heap
	ld	a, (hl)
	sub	a, -6 (ix)
	ld	(hl), a
	inc	hl
	ld	a, (hl)
	sbc	a, -5 (ix)
	ld	(hl), a
;memory.c:184: if (last == 0xFFFF) free_block = 0xFFFF;
	ld	a, -8 (ix)
	ld	-2 (ix), a
	ld	a, -7 (ix)
	ld	-1 (ix), a
	ld	a, -2 (ix)
	and	a, -1 (ix)
	inc	a
	jr	NZ, 00105$
	ld	hl, #0xffff
	ld	(_free_block), hl
	jr	00112$
00105$:
;memory.c:187: word* prev_ptr = (word*)get_pointer(last);
	pop	de
	pop	hl
	push	hl
	push	de
	call	_get_pointer
	ld	-2 (ix), e
	ld	-1 (ix), d
	ld	a, -2 (ix)
	ld	-4 (ix), a
	ld	a, -1 (ix)
	ld	-3 (ix), a
;memory.c:188: prev_ptr[1] = 0xFFFF;
	ld	a, -4 (ix)
	add	a, #0x02
	ld	-2 (ix), a
	ld	a, -3 (ix)
	adc	a, #0x00
	ld	-1 (ix), a
	ld	l, -2 (ix)
	ld	h, -1 (ix)
	ld	(hl), #0xff
	inc	hl
	ld	(hl), #0xff
;memory.c:190: break;
	jr	00112$
00108$:
;memory.c:192: last = current;
	ld	a, -10 (ix)
	ld	-8 (ix), a
	ld	a, -9 (ix)
	ld	-7 (ix), a
;memory.c:193: current=cur_ptr[1];
	ld	a, -2 (ix)
	ld	-10 (ix), a
	ld	a, -1 (ix)
	ld	-9 (ix), a
	jp	00109$
00112$:
;memory.c:195: }
	ld	sp, ix
	pop	ix
	ret
;memory.c:197: void defrag()
;	---------------------------------
; Function defrag
; ---------------------------------
_defrag::
;memory.c:199: sort_free_blocks();
	call	_sort_free_blocks
;memory.c:200: unite_free_blocks();
;memory.c:201: }
	jp	_unite_free_blocks
;memory.c:203: void	release(void* ptr)
;	---------------------------------
; Function release
; ---------------------------------
_release::
	push	ix
	ld	ix,#0
	add	ix,sp
	push	af
	push	af
	ex	de, hl
;memory.c:205: if (!ptr) return;
	ld	a, d
	or	a, e
	jr	Z, 00106$
;memory.c:206: word* header = (word*)ptr;
;memory.c:207: --header;
	dec	de
	dec	de
;memory.c:212: word size=*header;
	ld	a, (de)
	ld	-4 (ix), a
	inc	de
	ld	a, (de)
	ld	-3 (ix), a
	dec	de
;memory.c:213: total_allocated -= size;
	ld	hl, #_total_allocated
	ld	a, (hl)
	sub	a, -4 (ix)
	ld	(hl), a
	inc	hl
	ld	a, (hl)
	sbc	a, -3 (ix)
	ld	(hl), a
;memory.c:214: word offset = get_offset(header);
	ld	l, e
;	spillPairReg hl
;	spillPairReg hl
	ld	h, d
;	spillPairReg hl
;	spillPairReg hl
	push	de
	call	_get_offset
	ex	de, hl
	pop	de
	ld	-2 (ix), l
	ld	-1 (ix), h
;memory.c:215: if ((offset + size) == heap)
	ld	a, -2 (ix)
	add	a, -4 (ix)
	ld	c, a
	ld	a, -1 (ix)
	adc	a, -3 (ix)
	ld	b, a
	ld	hl, (_heap)
	cp	a, a
	sbc	hl, bc
	jr	NZ, 00104$
;memory.c:217: heap -= size;
	ld	hl, #_heap
	ld	a, (hl)
	sub	a, -4 (ix)
	ld	(hl), a
	inc	hl
	ld	a, (hl)
	sbc	a, -3 (ix)
	ld	(hl), a
	jr	00106$
00104$:
;memory.c:221: header[1] = free_block;
	inc	de
	inc	de
	ld	a, (_free_block+0)
	ld	(de), a
	inc	de
	ld	a, (_free_block+1)
	ld	(de), a
;memory.c:222: free_block = offset;
	ld	l, -2 (ix)
	ld	h, -1 (ix)
	ld	(_free_block), hl
;memory.c:223: defrag();
	call	_defrag
00106$:
;memory.c:225: }
	ld	sp, ix
	pop	ix
	ret
;memory.c:227: byte verify_heap()
;	---------------------------------
; Function verify_heap
; ---------------------------------
_verify_heap::
	push	ix
	ld	ix,#0
	add	ix,sp
	push	af
;memory.c:229: word next_free_block=free_block;
	ld	hl, (_free_block)
;memory.c:230: word sum_free_blocks=0;
	ld	c, #0x00
	ld	e, c
;memory.c:231: while (next_free_block != 0xFFFF)
00103$:
	inc	sp
	inc	sp
	push	hl
	ld	a, -2 (ix)
	and	a, -1 (ix)
	inc	a
	jr	Z, 00105$
;memory.c:233: word* block=(word*)get_pointer(next_free_block);
	push	bc
	push	de
	call	_get_pointer
	ex	de, hl
	pop	de
	pop	bc
;memory.c:234: if (!block) break;
	ld	a, h
	or	a, l
	jr	Z, 00105$
;memory.c:235: sum_free_blocks+=*block;
	ld	a, (hl)
	inc	hl
	ld	b, (hl)
;memory.c:236: next_free_block=block[1];
	inc	hl
	add	a, c
	ld	c, a
	ld	a, b
	adc	a, e
	ld	e, a
	ld	a, (hl)
	inc	hl
	ld	h, (hl)
;	spillPairReg hl
	ld	l, a
;	spillPairReg hl
;	spillPairReg hl
	jr	00103$
00105$:
;memory.c:238: return (total_allocated + sum_free_blocks == heap) ? 1 : 0;
	ld	a, c
	ld	hl, #_total_allocated
	add	a, (hl)
	inc	hl
	ld	c, a
	ld	a, e
	adc	a, (hl)
	ld	b, a
	ld	hl, (_heap)
	cp	a, a
	sbc	hl, bc
	ld	a, #0x01
	jr	Z, 00109$
	xor	a, a
00109$:
;memory.c:239: }
	ld	sp, ix
	pop	ix
	ret
;memory.c:241: unsigned get_total_allocated()
;	---------------------------------
; Function get_total_allocated
; ---------------------------------
_get_total_allocated::
;memory.c:243: return total_allocated;
	ld	de, (_total_allocated)
;memory.c:244: }
	ret
;memory.c:246: unsigned get_max_allocated()
;	---------------------------------
; Function get_max_allocated
; ---------------------------------
_get_max_allocated::
;memory.c:248: return max_allocated;
	ld	de, (_max_allocated)
;memory.c:249: }
	ret
;memory.c:251: void print_leaked()
;	---------------------------------
; Function print_leaked
; ---------------------------------
_print_leaked::
;memory.c:257: }
	ret
	.area _CODE
	.area _INITIALIZER
__xinit__static_heap:
	.dw #0x8000
	.area _CABS (ABS)
