
tetris.bin: tetris.ihx
	rm -f tetris.bin
	rm -f intermediate/*
	echo intermediate > intermediate/README.md
	python ihx2bin.py --start-addr 4608 tetris.ihx tetris.bin 
	mv *.asm intermediate
	mv *.lst intermediate
	mv *.ihx intermediate
	mv *.rel intermediate
	mv *.sym intermediate
	
# xmodem.rel  both lines end
tetris.ihx:	tetris.rel
	sdldz80 -m -w -i -b _APP=0x1200 tetris tetris.rel
	
tetris.rel: tetris.c
	sdcc -c -mz80 --codeseg APP tetris.c

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
