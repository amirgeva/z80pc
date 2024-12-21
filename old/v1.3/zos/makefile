
zos.bin: zos.ihx
	rm -f zos.bin
	rm -f intermediate/*
	echo intermediate > intermediate/README.md
	python ihx2bin.py zos.ihx zos.bin
	mv *.asm intermediate
	mv *.lst intermediate
	mv *.ihx intermediate
	mv *.rel intermediate
	mv *.sym intermediate
	
# xmodem.rel  both lines end
zos.ihx:	ll.rel lla.rel zos.rel bootloader.rel isrs.rel dflt.rel
	sdldz80 -m -w -i -b _CODE=0x100 -b _BOOT=1 -b _ISRS=0x38 -b _INITIALIZER=0x04 -b _DFLT=0x1200 zos bootloader.rel isrs.rel zos.rel ll.rel lla.rel dflt.rel
	
ll.rel: ll.c
	sdcc -c -mz80 ll.c

lla.rel: lla.zasm
	sdasz80 -l -o lla.rel lla.zasm

zos.rel: zos.c
	sdcc -c -mz80 zos.c

#xmodem.rel: xmodem.c
#	sdcc -c -mz80 xmodem.c

bootloader.rel: bootloader.zasm
	sdasz80 -l -o bootloader.rel bootloader.zasm
	
isrs.rel: isrs.zasm
	sdasz80 -l -o isrs.rel isrs.zasm

dflt.rel: dflt.c
	sdcc -c -mz80 --codeseg DFLT dflt.c
	
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
