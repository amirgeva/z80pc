;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 4.1.0 #12072 (MINGW64)
;--------------------------------------------------------
	.module bootloader
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _start_bootloader
	.globl _service6
	.globl _service5
	.globl _service4
	.globl _service3
	.globl _service2
	.globl _service1
	.globl _main
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
	.area _BOOT
;bootloader.c:6: void start_bootloader()
;	---------------------------------
; Function start_bootloader
; ---------------------------------
_start_bootloader::
;bootloader.c:8: main();
;bootloader.c:14: __endasm;
	jp  _main
	nop
	nop
	nop
	nop
	call  _service1
	ret
	nop
	nop
	nop
	nop
	call  _service2
	ret
	nop
	nop
	nop
	nop
	call  _service3
	ret
	nop
	nop
	nop
	nop
	call  _service4
	ret
	nop
	nop
	nop
	nop
	call  _service5
	ret
	nop
	nop
	nop
	nop
	call  _service6
	ret
	nop
	nop
	nop
	nop

;bootloader.c:37: }
	.area _BOOT
	.area _INITIALIZER
	.area _CABS (ABS)
