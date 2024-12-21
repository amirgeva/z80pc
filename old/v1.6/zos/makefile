CFLAGS=-I../stdlib

zos.bin: zos.ihx
	rm -f zos.bin
	rm -f intermediate/*
	echo intermediate > intermediate/README.md
	python ihx2bin.py zos.ihx zos.bin
	python bin2list.py zos.bin ../z80io/os.inl
	mv *.asm intermediate
	mv *.lst intermediate
	mv *.ihx intermediate
	mv *.rel intermediate
	mv *.sym intermediate

zos.ihx: zos.rel stdlibimpl.rel bootloader.rel globals.rel isrs.rel llfuncs.rel stdlib.rel
	sdldz80 -m -w -i -b _BOOT=1 -b _ISRS=0x38 -b _CODE=0x120 -b _GLOBALS=0x64 zos zos.rel stdlibimpl.rel bootloader.rel globals.rel isrs.rel llfuncs.rel stdlib.rel

bootloader.rel: bootloader.zasm
	sdasz80 -l -o bootloader.rel bootloader.zasm

globals.rel: globals.zasm
	sdasz80 -l -o globals.rel globals.zasm

isrs.rel: isrs.zasm
	sdasz80 -l -o isrs.rel isrs.zasm

llfuncs.rel: llfuncs.zasm
	sdasz80 -l -o llfuncs.rel llfuncs.zasm

stdlib.rel: ../stdlib/stdlib.zasm
	sdasz80 -l -o stdlib.rel ../stdlib/stdlib.zasm

zos.rel: zos.c
	sdcc -c $(CFLAGS) -mz80 zos.c

stdlibimpl.rel: ../stdlib/stdlibimpl.c
	sdcc -c $(CFLAGS) -mz80 ../stdlib/stdlibimpl.c

clean:
	rm -f *.asm
	rm -f *.map
	rm -f *.rel
	rm -f *.lst
	rm -f *.sym
	rm -f *.cdb
	rm -f *.rst
	rm -f *.ihx
	rm -f intermediate/*
