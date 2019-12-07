		GPU_NOP          EQU 0
		GPU_CLS          EQU 1
		GPU_TEXT_NEWLINE EQU 4
		GPU_PIXEL_CURSOR EQU 5
		GPU_TEXT_CURSOR  EQU 6
		GPU_FG_COLOR     EQU 7
		GPU_BG_COLOR     EQU 8
		GPU_PUSH_CURSOR  EQU 9
		GPU_POP_CURSOR   EQU 10
		GPU_BLINK_CURSOR EQU 11
		GPU_FILL_RECT    EQU 20
		GPU_HORZ_LINE    EQU 21
		GPU_VERT_LINE    EQU 22
		GPU_HORZ_PIXELS  EQU 23
		GPU_TEXT         EQU 30
		GPU_SET_SPRITE   EQU 40
		GPU_DRAW_SPRITE  EQU 41

		IO_NOP           EQU 00h
		IO_OUTBYTE       EQU 01h
		IO_OUTBLOCK      EQU 02h
		IO_OPEN_FILE_W   EQU 10h
		IO_OPEN_FILE_R   EQU 11h
		IO_OPEN_FILE_A   EQU 12h
		IO_CLOSE_FILE    EQU 13h
		IO_GET_FILE_SIZE EQU 20h
		IO_GET_FILE_NUM  EQU 21h
		IO_ERASE_FILE    EQU 22h
		IO_GET_FILE_NAME EQU 23h
		IO_WRITE_FILE    EQU 30h
		IO_READ_FILE     EQU 31h

		SYSCALL			 EQU RST 0x38
		KBD_BUF_SIZE	 EQU 80h

		ORG		0
main:
        LD      BC,65000
        jp      delay_loop
print:
        LD      A,GPU_TEXT
        OUT     (4),A
        LD      A,1
        OUT     (4),A
        LD      A,65
        OUT     (4),A
        LD      BC,8192
delay_loop:
        NOP
        LD      A,B
        CP      0
        JR      NZ,dec_count
        LD      A,C
        CP      0
        JR      Z,print
dec_count:
        DEC     BC
        jp      delay_loop

        
