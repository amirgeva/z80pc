CFLAGS=-I../include -I../stdlib -I../datastr -I../utils -I../zos -I../edi

../build/utils.a: ../build/memory.rel ../build/utils.rel
	sdar -r ../build/utils.a ../build/memory.rel ../build/utils.rel

../build/memory.rel: memory.c
	sdcc -c $(CFLAGS) -o ../build/memory.rel  -mz80 memory.c

../build/utils.rel: utils.c
	sdcc -c $(CFLAGS) -o ../build/utils.rel  -mz80 utils.c

