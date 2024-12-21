CFLAGS=-I../stdlib

tetris.bin: tetris.ihx
	rm -f tetris.bin
	rm -f intermediate/*
	echo intermediate > intermediate/README.md
	python ihx2bin.py --start-addr 4096 tetris.ihx tetris.bin 
	mv *.asm intermediate
	mv *.lst intermediate
	mv *.ihx intermediate
	mv *.rel intermediate
	mv *.sym intermediate
	
# xmodem.rel  both lines end
tetris.ihx:	loader.rel tetris.rel stdlibimpl.rel stdlib.rel
	sdldz80 -m -w -i -b _CODE=0x1000 tetris loader.rel tetris.rel stdlibimpl.rel stdlib.rel
	
loader.rel: loader.zasm
	sdasz80 -l -o loader.rel loader.zasm
	
tetris.rel: tetris.c
	sdcc -c $(CFLAGS) -mz80 --codeseg CODE tetris.c

stdlibimpl.rel: ../stdlib/stdlibimpl.c
	sdcc -c $(CFLAGS) -mz80 ../stdlib/stdlibimpl.c

stdlib.rel: ../stdlib/stdlib.zasm
	sdasz80 -l -o stdlib.rel ../stdlib/stdlib.zasm

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
