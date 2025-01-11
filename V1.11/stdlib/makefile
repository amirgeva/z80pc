CFLAGS=-I../include -I../stdlib -I../datastr -I../utils -I../zos -I../edi

../build/stdlib.a: ../build/stdlib.rel ../build/stdlibimpl.rel
	sdar -r ../build/stdlib.a ../build/stdlib.rel ../build/stdlibimpl.rel

../build/stdlibimpl.rel: stdlibimpl.c
	sdcc -c $(CFLAGS) -o ../build/stdlibimpl.rel  -mz80 stdlibimpl.c

../build/stdlib.rel: stdlib.zasm
	python ../z80asm.py -r ../build/stdlib.rel stdlib.zasm

