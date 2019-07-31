util_find_var:
	call	ti.Mov9ToOP1
	jp	ti.ChkFindSym

util_delete_prgm_from_usermem:
	or	a,a
	sbc	hl,hl
	ld	de,(ti.asm_prgm_size)		; get program size
	ld	(ti.asm_prgm_size),hl		; delete whatever was there
	ld	hl,ti.userMem
	jp	ti.DelMem

util_move_prgm_to_usermem:
	ld	a,$9				; 'add hl,bc'
	ld	(.smc),a
	call	ti.ChkFindSym
	jr	c,.error_not_found			; hope this doesn't happen
	call	ti.ChkInRam
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
	call	ti.LoadDEInd_s
	inc	hl
	inc	hl				; bypass tExtTok, tAsm84CECmp
	push	hl
	push	de
	ex	de,hl
	call	util_check_free_ram		; check and see if we have enough memory
	pop	hl
	jr	c,.error_ram
	ld	(ti.asm_prgm_size),hl		; store the size of the program
	ld	de,ti.userMem
	call	ti.InsertMem			; insert memory into usermem
	pop	hl				; hl -> start of program
	ld	bc,(ti.asm_prgm_size)		; load size of current program
.smc := $
	add	hl,bc				; if not in ram smc it so it doesn't execute
	ldir					; copy the program to userMem
	xor	a,a
	ret					; return
.error_ram:
	pop	hl				; pop start of program
.error_not_found:
	xor	a,a
	inc	a
	ret

util_show_time:
	bit	setting_clock,(iy + settings_flag)
	ret	z
	set	ti.clockOn,(iy + ti.clockFlags)
	set	ti.useTokensInString,(iy + ti.clockFlags)
	ld	de,ti.OP6
	push	de
	call	ti.FormTime
	pop	hl
	save_cursor
	set_cursor clock_x, clock_y
	call	util_string_inverted
	restore_cursor
	res	ti.useTokensInString,(iy + ti.clockFlags)
	ret

util_check_free_ram:
	push	hl
	ld	de,128
	add	hl,de				; for safety
	call	ti.EnoughMem
	pop	hl
	ret	nc
	call	gui_ram_error
	;jr	util_delay_one_second

util_delay_one_second:
	ld	bc,100
.delay:
	push	bc
	call	ti.Delay10ms
	pop	bc
	dec	bc
	ld	a,c
	or	a,b
	jr	nz,.delay
	ret

util_set_primary:
	push	af
	ld	a,(color_primary)
	ld	(util_restore_primary.color),a
	pop	af
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
	call	ti.MemChk
	call	lcd_num_6
	print	string_rom_free, 196, 228
	call	ti.ArcChk
	ld	hl,(ti.tempFreeArc)
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
	call	ti.GetBatteryStatus
	ld	(battery_status),a
	ret

util_get_key:
	di
.run:
	call	util_handle_apd
	ld	iy,ti.flags
	call	ti.DisableAPD			; disable os apd and use our own
	call	util_show_time
	call	lcd_blit
	call	ti.GetCSC			; avoid using getcsc for usb
	or	a,a
	jr	z,.run
	ret

util_setup_apd:
	ld	hl,$b0ff
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

util_check_if_app_page_directory:
	ld	hl,(item_ptr)
	ld	hl,(hl)
	compare_hl_zero
	ret

util_check_if_vat_page_directory:
	ld	hl,(item_ptr)
	ld	de,6
	add	hl,de
	ld	a,(hl)
	inc	a
	ret

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
	ld	de,ti.OP1			; store to op1
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

util_setup_shortcuts:
	bit	setting_enable_shortcuts,(iy + settings_flag)
	ret	z
	ld	hl,hook_get_key
	jp	ti.SetGetCSCHook

util_backup_prgm_name:
	ld	hl,ti.OP1
.entry:
	ld	de,backup_prgm_name
	jp	ti.Mov9b

util_set_more_items_flag:
	set	scroll_down_available,(iy + item_flag)
	ret

util_delete_temp_program_get_name:
	ld	hl,util_temp_program_object
	call	ti.Mov9ToOP1
	call	ti.PushOP1
	call	ti.ChkFindSym
	call	nc,ti.DelVarArc			; delete the temp prgm if it exists
	jp	ti.PopOP1

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
	ld	hl,ti.basic_prog
	ret

util_op1_to_temp:
	ld	de,string_temp
	push	de
	call	ti.ZeroOP
	ld	hl,ti.OP1 + 1
	pop	de
.handle:
	push	de
	call	ti.Mov8b
	pop	hl
	ret

util_temp_to_op1:
	ld	hl,string_temp
	ld	de,ti.OP1
	jr	util_op1_to_temp.handle

util_num_convert:
	ld	de,string_other_temp
	push	de
	call	.entry
	xor	a,a
	ld	(de),a
	pop	de
	ret
.entry:
	ld	bc,-1000000
	call	.aqu
	ld	bc,-100000
	call	.aqu
	ld	bc,-10000
	call	.aqu
	ld	bc,-1000
	call	.aqu
	ld	bc,-100
	call	.aqu
	ld	c,-10
	call	.aqu
	ld	c,b
.aqu:
	ld	a,'0' - 1
.under:
	inc	a
	add	hl,bc
	jr	c,.under
	sbc	hl,bc
	ld	(de),a
	inc	de
	ret

util_temp_program_object:
	db	ti.TempProgObj, 'ZAGTQZTB', 0
