		TIMER_FLAG		EQU 3
		LAST_KEY		EQU 6

		GPU_NOP          EQU 0
		GPU_CLS          EQU 1
		GPU_FLIP         EQU 2
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

	ORG		400h
start:
	jp		main

xrnd:
	ld		hl,1       ; seed must not be 0
	ld		a,h
	rra
	ld		a,l
	rra
	xor		h
	ld		h,a
	ld		a,l
	rra
	ld		a,h
	rra
	xor		l
	ld		l,a
	xor		h
	ld		h,a
	ld		(xrnd+1),hl
	ret	

;	Sets the pixel cursor
;	Inputs:
;	HL - X
;	DE - Y
;
set_cursor:
	ld		A,GPU_PIXEL_CURSOR
	out		(2),A
	ld		A,L
	out		(2),A
	ld		A,H
	out		(2),A
	ld		A,E
	out		(2),A
	ld		A,D
	out		(2),A
	ret

;	Clear screen
;
;
clear_screen:
	ld		A,GPU_CLS
	out		(2),A
	ret

; Set block color
;
;	DE - Color
;
;	Modifies:  BC,IX
set_block_color:
	ld		B,0eh
	ld		IX,sprite_color_start
sbc_loop_y:
	ld		C,0eh
	inc		IX
	inc		IX
sbc_loop_x:
	ld		(IX+0),E
	ld		(IX+1),D
	inc		IX
	inc		IX
	dec		C
	jr		NZ,sbc_loop_x
	inc		IX
	inc		IX
	dec		B
	jr		NZ,sbc_loop_y
	ret
	
;
;
;
send_sprite_pixel:
	ld		A,GPU_SET_SPRITE
	out		(2),A
	ld		A,C
	out		(2),A
	ld		A,16
	out		(2),A
	ld		A,16
	out		(2),A
	push	BC
	push	HL
	ld		BC,2
	ld		HL,base_sprite
	OTIR
	OTIR
	pop		HL
	pop		BC
	ret

; Set color from DE
set_bg_color:
	ld		A,GPU_BG_COLOR
	out		(2),A
	ld		A,E
	out		(2),A
	ld		A,D
	out		(2),A
	ret

; Fill rect WxH  in   DE x HL
fill_rect:
	ld		A,GPU_FILL_RECT
	out		(2),A
	ld		A,E
	out		(2),A
	ld		A,D
	out		(2),A
	ld		A,L 
	out		(2),A
	ld		A,H
	out		(2),A
	ret

;	Draw game board
;
draw_board:
	call	clear_screen
	ld		DE,1EF7h
	call	set_bg_color
	
	ld		DE,0
	ld		HL,32
	call	set_cursor

	ld		DE,256
	ld		HL,202
	call	fill_rect
	
	ld		IX,board
	ld		DE,10				; Y position on screen
	LD		B,12				; Rows left
db_loop_y:
	ld		HL,32				; X position on screen
	ld		C,16				; Columns left
db_loop_x:
	ld		A,0
	cp		(IX+0)				; If cell value is 0, nothing to draw
	jr		Z,db_skip_blit
	call	set_cursor			; Position cursor at HL,DE
	ld		A,GPU_DRAW_SPRITE
	out		(2),A
	ld		A,(IX+0)
	out		(2),A
db_skip_blit:
	inc		IX					; Move to next cell
	push	BC
	ld		BC,16				; Add 16 to X position
	add		HL,BC				;
	pop		BC
	dec		C
	jr		NZ,db_loop_x
	ld		HL,16
	add		HL,DE
	ex		DE,HL
	dec		B
	jr		NZ,db_loop_y
	ld		A,GPU_FLIP
	out		(2),A
	ret

init_board:
	ld		HL,board
	ld		B,192
clear_loop:
	ld		(HL),0
	inc		HL
	dec		B
	jr		NZ,clear_loop
	ret

set_sprites:
	ld		BC,9
	ld		HL,1ffh
	ld		DE,1fh
set_sprite_loop:
	push	BC
	call	set_block_color
	pop		BC
	push	HL
	add		HL,DE
	ex		DE,HL
	pop		HL
	call	send_sprite_pixel
	dec		C
	jr		NZ,set_sprite_loop
	ret
	
part_templates:
	db		6,7,8,9
	db		8,9,23,24
	db		7,8,24,25
	db		8,23,24,25
	db		8,9,24,25
	db		7,23,24,25
	db		7,8,9,23

; Place active part with index from A on board
; used to actually place, and to remove the part (A=0)
place_part_on_board:
	ld		IX,active_part
	ld		C,4
place_loop:
	ld		HL,board
	ld		E,(IX+0)
	ld		D,0
	add		HL,DE
	ld		(HL),A
	inc		IX
	dec		C
	jr		NZ,place_loop
	ret


generate_part:
	call	xrnd
	ld		A,L
	and		7
	cp		0
	jr		Z,generate_part
	push	AF
	dec		A
	sla		A
	sla		A
	ld		E,A
	ld		D,0
	ld		HL,part_templates
	add		HL,DE
	ld		DE,active_part
	ld		BC,4
	LDIR
	push	DE
	pop		IX
	pop		AF
	ld		(IX+0),8
	ld		(IX+1),A
	call	place_part_on_board
	ret




main:
	call	init_board
	call	set_sprites
	;call    generate_part
	jp		main_loop


; Line index in A
; Returns A=1 if full, A=0 if not
check_full_line:
	sla		A
	sla		A
	sla		A
	sla		A
	ld		HL,board
	ld		C,A
	ld		B,0
	add		HL,BC
	ld		A,0
	ld		BC,16
cfl_loop:
	cpi
	jr		Z,cfl_done
	jp		PE,cfl_loop
	ld		A,1
cfl_done:
	ret

; Remove line, index in A
;
remove_line:
	cp		0
	jr		Z,remove_done
	push	AF
	sla		A
	sla		A
	sla		A
	sla		A
	ld		E,A
	ld		D,0
	ld		HL,board
	add		HL,DE
	push	HL
	pop		DE
	ld		BC,16
	scf
	ccf
	sbc		HL,BC
	ldir
	pop		AF
	dec		A
	jp		remove_line
remove_done:
	ld		HL,board
	ld		B,16
	ld		A,0
remove_loop:
	ld		(HL),A
	inc		HL
	DJNZ	remove_loop
	ret
	
	
check_all_lines:
	ld		A,11
cal_loop:
	push	AF
	call	check_full_line
	cp		0
	jr		Z,no_remove
	pop		AF
	push	AF
	call	remove_line
	pop		AF
	inc		A
	push	AF
no_remove:
	pop		AF
	dec		A
	jr		Z,cal_done
	jr		cal_loop
cal_done:
	ret

; Check whether the space below the active part is free
; if not, deactivate part
check_lower:
	ld		A,0
	call	place_part_on_board
	ld		BC,4
	ld		IX,active_part
check_loop:
	ld		A,(IX+0)
	cp		176			;	Index of start of last row
	jr		NC,stop_active_part
	ld		E,A
	ld		D,0
	ld		HL,board
	add		HL,DE
	ld		DE,16
	add		HL,DE
	ld		A,(HL)
	cp		0
	jr		NZ,stop_active_part
	inc		IX
	dec		C
	jr		NZ,check_loop
	ld		A,(active_index)
	call	place_part_on_board
	ret
	
stop_active_part:
	ld		A,(active_index)
	call	place_part_on_board
	ld		IX,active_part
	ld		(IX+0),0
	ld		(IX+1),0
	ld		(IX+2),0
	ld		(IX+3),0
	ld		(IX+4),0		; center
	ld		(IX+5),0		; index
	call	check_all_lines
	ret
	
	
check_timer:
	ld		A,(TIMER_FLAG)
	cp		255
	jr		C,no_timer
	ld		A,0
	ld		(TIMER_FLAG),A
move_down:
	ld		A,1
	ld		(redraw),A
	ld		A,(active_index)
	cp		0
	jr		Z,no_timer
	call	check_lower
	ld		A,0
	call	place_part_on_board
	ld		IX,active_part
	ld		C,5
lower_loop:
	ld		A,(IX+0)
	add		A,16
	ld		(IX+0),A
	inc		IX
	dec		C
	jr		NZ,lower_loop
	ld		A,(IX+0)
	call	place_part_on_board
no_timer:
	ret
	
move_part:
	ld		B,A
	ld		A,0
	call	place_part_on_board
	ld		IX,active_part
	ld		C,4
move_loop:
	ld		A,(IX+0)
	and		15			; Get the X coord of the piece
	add		A,B
	jp		M,move_end
	cp		16
	jp		Z,move_end
	jp		P,move_end
	ld		A,(IX+0)
	add		A,B
	ld		E,A
	ld		D,0
	ld		HL,board
	add		HL,DE
	ld		A,(HL)
	cp		0
	jr		NZ,move_end
	inc		IX
	dec		C
	jr		NZ,move_loop
	; No objections found.  Actually move
	ld		A,1
	ld		(redraw),A
	ld		IX,active_part
	ld		C,5  ; 4 pieces + center
move_loop2:
	ld		A,(IX+0)
	add		A,B
	ld		(IX+0),A
	inc		IX
	dec		C
	jr		NZ,move_loop2
	
move_end:	
	ld		A,(active_index)
	call	place_part_on_board
	ret
	
; Relative to position in A
; Returns dx in H, and dy in L
calculate_dx_dy:
	ld		L,A
	ld		BC,(active_center)
	ld		A,C
	and		15
	ld		B,A
	ld		A,L
	and		15
	sub		B
	ld		H,A
	srl		C
	srl		C
	srl		C
	srl		C
	ld		B,C
	srl		L
	srl		L
	srl		L
	srl		L
	ld		A,L
	sub		B
	ld		L,A
	ret
	
; Calculte cell position, taking HL=dx,dy
; and adding the center position
; Return valid result in A, or FF if fail
add_center:
	ld		B,0
	ld		A,(active_center)
	and		15
	add		A,H
	cp		16
	jr		NC,ac_fail
	cp		0
	jp		M,ac_fail
	ld		H,A
	ld		A,(active_center)
	srl		A
	srl		A
	srl		A
	srl		A
	add		A,L
	cp		12
	jr		NC,ac_fail
	cp		0
	jp		M,ac_fail
	sla		A
	sla		A
	sla		A
	sla		A
	add		A,H
	ld		HL,board
	ld		C,A
	add		HL,BC
	ld		A,(HL)
	cp		0
	jr		NZ,ac_fail
	ld		A,C
	ret
ac_fail:
	ld		A,255
	ret
	
	
	
rotate_part:
	ld		A,0
	call	place_part_on_board
	ld		IX,active_part
	ld		IY,temp_part
	ld		C,4
rotate_loop:
	ld		A,(IX+0)
	push	BC
	call	calculate_dx_dy
	pop		BC
	ld		A,L
	neg
	ld		L,H
	ld		H,A
	push	BC
	call	add_center
	pop		BC
	cp		255
	jr		Z,rotate_fail
	ld		(IY+0),A
	inc		IX
	inc		IY
	dec		C
	jr		NZ,rotate_loop
	ld		DE,active_part
	ld		HL,temp_part
	ld		BC,4
	LDIR
	ld		A,1
	ld		(redraw),A
rotate_fail:
	ld		A,(active_index)
	call	place_part_on_board
	ret


	
check_keyboard:
	ld		A,(LAST_KEY)
	cp		0
	jr		Z,no_key
	push	AF
	ld		A,0
	ld		(LAST_KEY),A
	pop		AF
	cp		52			; left
	jr		NZ,check_right_key
	ld		A,255
	call	move_part
	ret
check_right_key:
	cp		54			; right
	jr		NZ,check_rotate_key
	ld		A,1
	call	move_part
	ret
check_rotate_key:	
	cp		53			; center
	jr		NZ,check_down_key
	call	rotate_part
check_down_key:
	cp		50			; down
	jr		NZ,no_key
	call	move_down
no_key:
	ret
	
	
main_loop:
	ld		A,(redraw)
	cp		0
	jr		Z,no_redraw
	ld		A,0
	ld		(redraw),A
	call	draw_board
no_redraw:
	call	check_timer
	call	check_keyboard
	ld		IX,active_part
	ld		A,(IX+5)
	cp		0
	jr		Z,gen_new_part
	nop
	nop
	nop
	nop
	nop
	nop
	jp		main_loop
	
gen_new_part:
	call	generate_part
	ld		A,1
	ld		(redraw),A
	jp		main_loop
	
redraw:
	db		1
active_part:
	db		0,0,0,0
active_center:
	db		0
active_index:
	db		0
temp_part:
	db		0,0,0,0
	
base_sprite:
	dw		3fffh,3fffh,3fffh,3fffh,3fffh,3fffh,3fffh,3fffh
	dw		3fffh,3fffh,3fffh,3fffh,3fffh,3fffh,3fffh,3fffh
sprite_color_start:
	dw		3fffh,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
	dw		3fffh,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
	dw		3fffh,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
	dw		3fffh,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
	dw		3fffh,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
	dw		3fffh,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
	dw		3fffh,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
	dw		3fffh,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
	dw		3fffh,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
	dw		3fffh,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
	dw		3fffh,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
	dw		3fffh,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
	dw		3fffh,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
	dw		3fffh,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
	dw		    1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
	
board:
