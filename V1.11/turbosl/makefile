CFLAGS=-I../include -I../stdlib -I../datastr -I../utils -I../zos -I../turbosl

../build/turbosl: ../build/turbosl.ihx
	python ../ihx2bin.py ../build/turbosl.ihx ../build/turbosl -b 4096
	cp ../build/turbosl ../../../z80sim/disk

../build/turbosl.ihx: ../build/z80hal.rel ../build/tslmain.rel
	make -C ../utils
	make -C ../stdlib
	make -C ../datastr
	sdldz80 -m -w -i  -b _CODE=0x1000 turbosl ../build/z80hal.rel ../build/tslmain.rel -l ../build/utils.a -l ../build/stdlib.a -l ../build/datastr.a
	mv turbosl.ihx ../build/
	mv turbosl.map ../build/

../build/tslmain.rel: tslmain.c
	sdcc -c $(CFLAGS) -o ../build/tslmain.rel  -mz80 tslmain.c

../build/z80hal.rel: z80hal.zasm
	python ../z80asm.py -r ../build/z80hal.rel z80hal.zasm

