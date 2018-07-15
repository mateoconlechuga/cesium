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
	ld	a,(color_senary)
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
	ld	a,(color_primary)
	ld	(lcd_text_bg),a
	ld	a,(color_quaternary)
	ld	(lcd_text_fg),a
	ret

util_set_normal_text_color:
	ld	a,(color_senary)
	ld	(lcd_text_bg),a
	ld	a,(color_secondary)
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
	ld	hl,$4ff
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

util_move_prgm_to_usermem:
	ld	a,$9				; 'add hl,bc'
	ld	(.smc),a
	call	_ChkFindSym
	call	_ChkInRam
	ex	de,hl
	jr	z,.in_ram
	xor	a,a
	ld	(.smc),a
	ld	de,9
	add	hl,de
	ld	e,(hl)
	add	hl,de
	inc	hl
.in_ram:					; hl -> size bytes
	call	_LoadDEInd_s
	inc	hl
	inc	hl				; bypass tExtTok, tAsm84CECmp
	push	hl
	push	de
	ex	de,hl
	call	_ErrNotEnoughMem		; check and see if we have enough memory
	pop	hl
	ld	(asm_prgm_size),hl		; store the size of the program
	ld	de,userMem
	push	de
	call	_InsertMem			; insert memory into usermem
	pop	de
	pop	hl				; hl -> start of program
	ld	bc,(asm_prgm_size)		; load size of current program
.smc := $
	add	hl,bc				; if not in ram smc it so it doesn't execute
	ldir					; copy the program to userMem
	ret					; return

util_setup_shortcuts:
	ld	hl,hook_get_key
	bit	setting_enable_shortcuts,(iy + settings_flag)
	call	nz,_SetGetCSCHook
	ret

util_install_error_handler:
	ld	hl,return_asm_error
	jp	_PushErrorHandler

util_backup_prgm_name:
	ld	hl,OP1
	ld	de,backup_prgm_name
	jp	_Mov9b

util_set_more_items_flag:
	set	scroll_down_available,(iy + item_flag)
	ret

util_delete_temp_program_get_name:
	ld	hl,util_temp_program_object
	call	_Mov9ToOP1
	call	_PushOP1
	call	_ChkFindSym
	call	nc,_DelVarArc			; delete the temp prgm if it exists
	jp	_PopOP1

util_get_archived_name:
	ld	de,util_temp_program_object + 1
	ld	b,8
.compare:
	ld	a,(de)
	cp	a,(hl)
	jr	nz,.no_match
	inc	hl
	inc	de
	djnz	.compare
	ld	hl,backup_prgm_name
	ret
.no_match:
	ld	hl,basic_prog
	ret

util_print_brightness:
	push	hl
	xor	a,a
	sbc	hl,hl
	ld	a,(mpBlLevel)
	ld	l,a
	call	lcd_num_3
	pop	hl
	inc	hl
	jp	lcd_string

util_temp_program_object:
	db	tempProgObj, 'ZAGTQZTB', 0
