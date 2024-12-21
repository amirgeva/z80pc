void main();
void service1();
void service2();
void service3();

void start_bootloader()
{
	main();
	__asm
		ret
		nop
		nop
		nop
	__endasm;
	service1();
	__asm
		ret
		nop
		nop
		nop
	__endasm;
	service2();
	__asm
		ret
		nop
		nop
		nop
	__endasm;
	service3();
	__asm
		ret
		nop
		nop
		nop
	__endasm;
		
}

