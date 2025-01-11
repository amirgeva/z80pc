CFLAGS=-I../include -I../stdlib -I../datastr -I../utils -I../zos -I../edi

../build/datastr.a: ../build/strhash.rel ../build/vector.rel
	sdar -r ../build/datastr.a ../build/strhash.rel ../build/vector.rel

../build/strhash.rel: strhash.c
	sdcc -c $(CFLAGS) -o ../build/strhash.rel  -mz80 strhash.c

../build/vector.rel: vector.c
	sdcc -c $(CFLAGS) -o ../build/vector.rel  -mz80 vector.c

