		GPU_NOP          EQU 0
		GPU_CLS          EQU 1
		GPU_PIXEL_CURSOR EQU 5
		GPU_TEXT_CURSOR  EQU 6
		GPU_FG_COLOR     EQU 7
		GPU_BG_COLOR     EQU 8
		GPU_PUSH_CURSOR  EQU 9
		GPU_POP_CURSOR   EQU 10
		GPU_BLINK_CURSOR EQU 11
		GPU_FILL_RECT    EQU 20
		GPU_HORZ_LINE    EQU 21
		GPU_VERT_LINE    EQU 22
		GPU_HORZ_PIXELS  EQU 23
		GPU_TEXT         EQU 30
		GPU_SET_SPRITE   EQU 40
		GPU_DRAW_SPRITE  EQU 41

		KBD_BUF_SIZE	 EQU 80h

		ORG		0
		jp		main
timer_count:			; Address 3
		db		0
ioptr:  dw		kbdbuf
lastkey:				; Address 6
		db		0
		
		ORG		8h		; Input interrupt handler
		PUSH	AF
		IN		A,(0)    ; Read IO
		PUSH	BC
		LD		BC,(ioptr)
		LD		(BC),A
		LD		(lastkey),A
		LD		A,C
		INC		A
		AND		KBD_BUF_SIZE-1
		LD		C,A
		LD		(ioptr),BC
		POP		BC
		POP		AF
		EI
		RETI

		ORG		38h
timer_isr:
		PUSH	AF
		ld		A,(timer_count)
		inc		A
		ld		(timer_count),A
		POP		AF
		EI
		RETI

		ORG		80h
main:
		EI
		jp		400h
		
		CALL	cls
		LD		HL,os_prompt
		CALL	print
		CALL	cursor_on

		ORG		100h
kbdbuf: BUF 	KBD_BUF_SIZE

main_loop:
		LD		A,(lastkey)
		OR		A
		JR		Z,main_loop
		CALL	print_char
		LD		A,0
		LD		(lastkey),A
		jp       main_loop
		nop
		nop



cursor_on:
		LD		A,GPU_BLINK_CURSOR
		OUT		(2),A
		LD		A,1
		OUT		(2),A
		RET
		
cls:
		LD		A,GPU_CLS
		OUT		(2),A
		RET

print_char:
		PUSH	AF
		LD		A,GPU_TEXT
		OUT		(2),A
		LD		A,1
		OUT		(2),A
		POP		AF
		OUT		(2),A
		RET
print:
		PUSH	BC
		LD		B,(HL)
		INC		B
		LD		C,2
		LD		A,GPU_TEXT
		OUT		(2),A
		OTIR
		POP		BC
		RET



data:
os_prompt:
		db		4
		ds		'ZOS>'
		nop
userspace: