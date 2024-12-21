typedef unsigned char byte;
typedef unsigned short word;

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

void sendchar(byte b)
{
	b;
	__asm
	out (0),a
	__endasm;
}

byte strlen(const byte* s)
{
	byte res=0;
	for(;*s;++s,++res);
	return res;
}

void send_command(const byte* data, byte len)
{
	data;
	len;
	__asm
	ld b,a
	otir
	__endasm;
}

void printc(byte c)
{
	if (c==13)
	{
		sendchar(4);
	}
	else	{
		sendchar(30);		sendchar(1);		sendchar(c);
	}}

void print(const byte* s)
{
	byte header[2];
	header[0]=30;
	header[1]=strlen(s);
	send_command(header,2);
	send_command(s,header[1]);
}

void println(const byte* s)
{
	print(s);
	sendchar(4);
}


void cls()
{
	byte cmd[2];
	cmd[0]=0;
	cmd[1]=1;
	send_command(cmd,2);
}
