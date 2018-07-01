util_find_var:
	call	_Mov9ToOP1
	jp	_ChkFindSym

util_delete_program_from_usermem:
	or	a,a
	sbc	hl,hl
	ld	de,(asm_prgm_size)		; get program size
	ld	(asm_prgm_size),hl		; delete whatever was there
	ld	hl,userMem
	jp	_DelMem

util_show_time:
	bit	setting_clock,(iy + settings_flag)
	ret	z
	set	clockOn,(iy + clockFlags)
	set	useTokensInString,(iy + clockFlags)
	ld	de,OP6
	push	de
	call	_FormTime
	pop	hl
	save_cursor
	set_cursor clock_x, clock_y
	call	util_string_inverted
	restore_cursor
	ret

util_set_primary:
	ld	a,(color_primary)
	ld	(util_restore_primary.color),a
	ld	a,color_white
	ld	(color_primary),a
	ret

util_restore_primary:
	ld	a,0
.color := $-1
	ld	(color_primary),a
	ret

util_show_free_mem:
	call	gui_clear_status_bar
	set_inverted_text
	print	string_ram_free, 4, 228
	call	_MemChk
	call	lcd_num_6
	print	string_rom_free, 196, 228
	call	_ArcChk
	ld	hl,(tempFreeArc)
	call	lcd_num_7
	set_normal_text
	ret

util_string_inverted:
	set_inverted_text
	call	lcd_string
	set_normal_text
	ret

; bc = x
; a = y
util_string_xy:
	call	util_set_cursor
	jp	lcd_string

; bc = x
; a = y
util_set_cursor:
	ld	(lcd_x),bc
	ld	(lcd_y),a
	ret

util_save_cursor:
	pop	ix
	ld	bc,(lcd_x)
	push	bc
	ld	a,(lcd_y)
	push	af
	jp	(ix)

util_restore_cursor:
	pop	hl
	pop	af
	ld	(lcd_y),a
	pop	bc
	ld	(lcd_x),bc
	jp	(hl)

util_set_inverted_text_color:
	ld	a,(setting_color_primary)
	ld	(lcd_text_bg),a
	ld	a,color_white
	ld	(lcd_text_fg),a
	ret

util_set_normal_text_color:
	ld	a,color_white
	ld	(lcd_text_bg),a
	ld	a,(setting_color_secondary)
	ld	(lcd_text_fg),a
	ret

util_get_battery:
	call	_GetBatteryStatus
	ld	(battery_status),a
	ret

util_get_key:
	call	util_show_time
	call	lcd_blit
	call	_GetCSC
	or	a,a
	ret	nz
	call	util_handle_apd
	jr	util_get_key

util_setup_apd:
	ld	hl,$fffff
	ld	(apd_timer),hl
	ret

util_handle_apd:
	ld	hl,0
apd_timer := $-3
	dec	hl
	ld	(apd_timer),hl
	add	hl,de
	or	a,a
	sbc	hl,de
	ret	nz
	jp	exit_full

util_to_one_hot:
	ld	b,a
	xor	a,a
	scf
.loop:
	rla
	djnz	.loop
	ret

util_init_selection_screen:
	xor	a,a
	sbc	hl,hl
	ld	(current_selection),a
	ld	(current_selection_absolute),hl
	ld	(scroll_amount),hl
	ret

util_move_prgm_name_to_op1:
	ld	hl,(prgm_ptr)
util_prgm_ptr_to_op1:
	ld	hl,(hl)
	push	hl				; vat pointer
	ld	de,6
	add	hl,de
	ld	a,(hl)				; get the type byte
	pop	hl
	ld	de,OP1				; store to op1
	ld	(de),a
	inc	de
	ld	b,(hl)
	dec	hl
.copy:
	ld	a,(hl)
	ld	(de),a
	inc	de
	dec	hl
	djnz	.copy
	xor	a,a
	ld	(de),a				; terminate the string
	ret
