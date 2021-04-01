typedef unsigned char byte;

char strcmp(const byte* s1, const byte* s2)
{
	while (1)
	{
		byte b1=*s1;
		byte b2=*s2;
		byte e1=(b1==0);
		byte e2=(b2==0);
		if (e1 && e2) return 0;
		if (e1) return -1;
		if (e2) return 1;
		if (b1>b2) return 1;
		if (b2>b1) return -1;
		++s1;
		++s2;
	}
}

byte strlen(const byte* s)
{
	byte res=0;
	for(;*s;++s,++res);
	return res;
}

void sendstr(const byte* s)
{
	s;
	__asm
	pop		bc
	pop		hl
	push	hl
	push	bc
	push	hl
	call	_strlen
	LD		B,L
	pop		HL
	OTIR
	__endasm;
}

