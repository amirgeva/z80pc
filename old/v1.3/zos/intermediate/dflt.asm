;--------------------------------------------------------
; File Created by SDCC : free open source ISO C Compiler 
; Version 4.2.2 #13407 (MINGW64)
;--------------------------------------------------------
	.module dflt
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _entry_point
	.globl _println
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
	.area _DFLT
;dflt.c:3: void entry_point()
;	---------------------------------
; Function entry_point
; ---------------------------------
_entry_point::
;dflt.c:5: println("Hello World");
	ld	hl, #___str_0
;dflt.c:6: }
	jp	_println
___str_0:
	.ascii "Hello World"
	.db 0x00
	.area _DFLT
	.area _INITIALIZER
	.area _CABS (ABS)