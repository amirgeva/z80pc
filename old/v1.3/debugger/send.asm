ORG		0h
		jp main
text:
		ds 'Hello'
		
ORG		100h
main:
		ld A,0
		out (0),A
		ld A,0
		out (0),A
		ld A,0
		out (0),A
		ld A,1
		out (0),A
		ld HL,text
		ld B,5
		ld C,0
		ld A,30
		out (0),A
		ld A,B
		out (0),A
		OTIR
		
loop:
		jp main