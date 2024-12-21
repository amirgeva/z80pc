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

zos.ihx: zos.rel bootloader.rel isrs.rel globals.rel
	sdldz80 -m -w -i -b _BOOT=1 -b _ISRS=0x38 -b _CODE=0x200 -b _GLOBALS=0xF0 zos zos.rel bootloader.rel isrs.rel globals.rel

bootloader.rel: bootloader.zasm
	sdasz80 -l -o bootloader.rel bootloader.zasm

isrs.rel: isrs.zasm
	sdasz80 -l -o isrs.rel isrs.zasm

globals.rel: globals.zasm
	sdasz80 -l -o globals.rel globals.zasm

zos.rel: zos.c zos.h
	sdcc -c -mz80 zos.c

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
