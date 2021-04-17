
zos.bin: zos.ihx
	rm -f zos.bin
	rm -f intermediate/*
	echo intermediate > intermediate/README.md
	python3 ihx2bin.py zos.ihx zos.bin
	mv *.asm intermediate
	mv *.lst intermediate
	mv *.ihx intermediate
	mv *.rel intermediate
	mv *.sym intermediate
	

zos.ihx:	ll.rel zos.rel bootloader.rel isrs.rel xmodem.rel
	sdldz80 -i -b _CODE=0x100 -b _BOOT=1 -b _ISRS=0x38 zos bootloader.rel isrs.rel zos.rel ll.rel xmodem.rel
	
ll.rel: ll.c
	sdcc -c -mz80 ll.c

zos.rel: zos.c
	sdcc -c -mz80 zos.c

xmodem.rel: xmodem.c
	sdcc -c -mz80 xmodem.c

bootloader.rel: bootloader.zasm
	sdasz80 -o bootloader.rel bootloader.zasm
	
isrs.rel: isrs.c
	sdcc -c -mz80 --codeseg ISRS isrs.c

clean:
	rm -f *.asm
	rm -f *.map
	rm -f *.rel
	rm -f *.lst
	rm -f *.sym
	rm -f *.cdb
	rm -f *.rst
	rm -f *.ihx
	