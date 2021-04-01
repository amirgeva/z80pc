
zos.bin: zos.ihx
	python3 ihx2bin.py zos.ihx zos.bin
	mv *.asm intermediate
	mv *.lst intermediate
	mv *.ihx intermediate
	mv *.rel intermediate
	mv *.sym intermediate
	

zos.ihx:	ll.rel zos.rel bootloader.rel isrs.rel
	sdldz80 -i -b _CODE=0x100 -b _BOOT=0x00 -b _ISRS=0x38 zos bootloader.rel isrs.rel zos.rel ll.rel
	
ll.rel: ll.c
	sdcc -c -mz80 ll.c

zos.rel: zos.c
	sdcc -c -mz80 zos.c

bootloader.rel: bootloader.c
	sdcc -c -mz80 --codeseg BOOT bootloader.c
	
isrs.rel: isrs.c
	sdcc -c -mz80 --codeseg ISRS isrs.c

clean:
	rm -f *.map
	rm -f *.rel
	rm -f *.lst
	rm -f *.sym
	rm -f *.cdb
	rm -f *.rst
	rm -f *.ihx
	