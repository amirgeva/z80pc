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

		IO_NOP           EQU 00h
		IO_OUTBYTE       EQU 01h
		IO_OUTBLOCK      EQU 02h
		IO_OPEN_FILE_W   EQU 10h
		IO_OPEN_FILE_R   EQU 11h
		IO_OPEN_FILE_A   EQU 12h
		IO_CLOSE_FILE    EQU 13h
		IO_GET_FILE_SIZE EQU 20h
		IO_GET_FILE_NUM  EQU 21h
		IO_ERASE_FILE    EQU 22h
		IO_GET_FILE_NAME EQU 23h
		IO_WRITE_FILE    EQU 30h
		IO_READ_FILE     EQU 31h

		SYSCALL			 EQU RST 0x38
		KBD_BUF_SIZE	 EQU 80h

		ORG		0
		jp		main
timer_count:			; Address 3
		db		0
lastkey:				; Address 4
		db		0
		
		ORG		8h		; Input interrupt handler
keyboard_isr:
		CALL    keyboard_handler
		EI
		RETI
		
		ORG		10h
disk_isr:
		CALL    disk_read_handler
		EI
		RETI

		ORG		18h
serial_isr:
		; CALL serial_handler
		EI
		RETI

		ORG		20h
timer_isr:
		PUSH	AF
		ld		A,(timer_count)
		inc		A
		ld		(timer_count),A
		POP		AF
		EI
		RETI

		ORG		38h
; Make a system call		(call via    RST 7)
; Parameters:
;	A  - Call number
;   BC - Context dependent parameter and return value
system_call:
		PUSH	HL
		PUSH	BC
		SLA		A
		SBC		HL,HL
		ADD		A,system_calls
		LD		L,A
		LD		C,(HL)
		INC		HL
		LD		B,(HL)
		PUSH	BC
		POP		HL			; Restore system call parameter
		POP		BC
		JP		(HL)

		ORG		50h
system_calls:
		dw		sys0
		dw		sys1
		dw		sys2
		dw		sys3
		dw		sys4
		dw		sys5
		dw		sys6
		dw		sys7
		dw		sys8
		dw		sys9
		dw		sys10
		dw		sys11
		dw		sys12
		dw		sys13
		dw		sys14
		dw		sys15
		
kbd_wptr:
		db		0
kbd_rptr:
		db		0
disk_wptr:
		dw		0
disk_wcount:
		db		0

keyboard_handler:
		PUSH	AF
		IN		A,(0)    ; Read IO
		PUSH	HL
		LD		HL,(kbd_wptr)
		LD		H,1
		LD		(HL),A
		LD		(lastkey),A
		LD		A,L
		INC		A
		AND		KBD_BUF_SIZE-1
		LD		(kbd_wptr),A
		POP		HL
		POP		AF
		RET

disk_read_handler:
		PUSH	AF
		LD		A,(disk_wcount)
		OR		A,A
		JR		Z,done_reading
		DEC		A
		LD		(disk_wcount),A
		IN		A,(0)    ; Read IO
		PUSH	HL
		LD		HL,(disk_wptr)
		LD		(HL),A
		INC		HL
		LD		(disk_wptr),HL
		POP		HL
done_reading:
		POP		AF
		RET

wait_io:
		LD		A,(disk_wcount)
		OR		A
		JR		NZ,wait_io
		RET

sys0:	; System call 0
		; Get Number of files on disk
		LD		A,3						; Call returns 3 bytes (2,L,H)
		LD		(disk_wcount),A
		LD		HL,osbuf
		LD		(disk_wptr),HL			; Init write pointer to OS buffer
		LD		A,IO_GET_FILE_NUM
		OUT		(0),A
		CALL	wait_io					; Wait for all bytes to be received
		INC		HL
		INC		HL
		LD		C,(HL)
		INC		HL
		LD		B,(HL)
		POP		HL
		RET
sys1:	; System call 1
		; Get file name for index in BC
		LD		A,16					; 15 & file name chars
		LD		(disk_wcount),A
		LD		HL,osbuf
		LD		(disk_wptr),HL			; Init write pointer to OS buffer
		LD		A,IO_GET_FILE_NAME
		OUT		(0),A
		LD		A,C
		OUT		(0),A
		CALL	wait_io					; Wait for all bytes to be received
		LD		B,0
		LD		C,0
		LD		A,(osbuf)
		OR		A,A
		JR		Z,sys1_done
		LD		BC,osbuf
sys1_done:
		POP		HL
		RET
sys2: ; System call 2
		RET
sys3: ; System call 3
		RET
sys4: ; System call 4
		RET
sys5: ; System call 5
		RET
sys6: ; System call 6
		RET
sys7: ; System call 7
		RET
sys8: ; System call 8
		RET
sys9: ; System call 9
		RET
sys10: ; System call 10
		RET
sys11: ; System call 11
		RET
sys12: ; System call 12
		RET
sys13: ; System call 13
		RET
sys14: ; System call 14
		RET
sys15: ; System call 15
		RET

		ORG		100h
kbdbuf: BUF 	KBD_BUF_SIZE
osbuf:  BUF		80h
	
main:
		EI
		;jp		400h
		
		CALL	cls
		LD		HL,os_prompt
		CALL	print
		CALL	cursor_on

		LD		A,0
		SYSCALL
		
		LD		A,0
list_loop:
		PUSH	BC
		PUSH	AF
		LD		C,A
		LD		B,0
		LD		A,1
		SYSCALL
		PUSH	BC
		POP		HL
		CALL	print
		LD		A,10
		CALL	print_char
		POP		AF
		POP		BC
		INC		A
		CP		A,C
		JR		NZ,list_loop
stub:	jp		stub
		
		


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