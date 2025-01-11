CFLAGS=-I../include -I../stdlib -I../datastr -I../utils -I../zos -I../edi

../build/zos: ../build/zos.ihx
	python ../ihx2bin.py ../build/zos.ihx ../build/zos

../build/zos.ihx: ../build/bootloader.rel ../build/globals.rel ../build/isrs.rel ../build/llfuncs.rel ../build/services.rel ../build/zos.rel
	make -C ../stdlib
	sdldz80 -m -w -i  -b _BOOT=0x0001 -b _ISRS=0x0020 -b _SERVICES=0x0064 -b _GLOBALS=0x00E0 -b _CODE=0x0200 zos ../build/bootloader.rel ../build/globals.rel ../build/isrs.rel ../build/llfuncs.rel ../build/services.rel ../build/zos.rel -l ../build/stdlib.a
	mv zos.ihx ../build/

	mv zos.map ../build/

../build/zos.rel: zos.c
	sdcc -c $(CFLAGS) -o ../build/zos.rel  -mz80 zos.c

../build/bootloader.rel: bootloader.zasm
	python ../z80asm.py -r ../build/bootloader.rel bootloader.zasm

../build/globals.rel: globals.zasm
	python ../z80asm.py -r ../build/globals.rel globals.zasm

../build/isrs.rel: isrs.zasm
	python ../z80asm.py -r ../build/isrs.rel isrs.zasm

../build/llfuncs.rel: llfuncs.zasm
	python ../z80asm.py -r ../build/llfuncs.rel llfuncs.zasm

../build/services.rel: services.zasm
	python ../z80asm.py -r ../build/services.rel services.zasm

