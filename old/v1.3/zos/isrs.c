void input_isr() 
{
	__asm
	PUSH	AF
	PUSH	HL
	PUSH	IX
	PUSH	BC
	IN		A,(0)
	OR		A
	JR		NZ,no_timer
	LD		HL,#0x1124			; timer
	INC		(HL)
	JR		NZ,isr_done
	INC		L
	INC		(HL)	
	JP		isr_done
no_timer:	
	LD		B,A					; Save input data for later
	LD		IX,#0x1120
	LD		A,(IX+0)			; Write
	LD		C,(IX+1)			; Read
	DEC		C
	CP		C
	JR		Z,isr_done			; If buffer full
	LD		H,#0x10				; Beginning of input buffer
	LD		L,A
	LD		(HL),B				; Store input byte
	INC		A
	LD		(IX+0),A
isr_done:
	POP		BC
	POP		IX
	POP		HL
	POP		AF
	EI
	RETI
	__endasm;
}
