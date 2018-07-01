; features offered by cesium

feature_item_new:
	ld	a,(current_screen)
	cp	a,screen_programs
	jp	nz,main_loop
	bit	cesium_is_nl_disabled,(iy + cesium_flag)
	jp	nz,main_loop
	res	item_renaming,(iy + item_flag)
	jr	feature_item_rename.setup_name
feature_item_rename:
	set	item_renaming,(iy + item_flag)
	ld	a,(prgm_type)
	cp	a,file_dir
	jp	z,main_loop
.setup_name:
	ld	a,color_white
	call	util_set_primary
	draw_rectangle 199, 173, 313, 215
	call	util_restore_primary
	bit	item_renaming,(iy + item_flag)
	jr	z,.rename_string
	print	string_rename, 199, 173
	jr	.skip_string
.rename_string:
	print	string_new_prgm, 199, 173
.skip_string:
	set_cursor 199, 195
	ld	a,(current_input_mode)
	call	lcd_char
	ld	hl,199
	ld	(lcd_x),hl
	xor	a,a
	ld	(cursor_position),a
	dec	a
	ld	(current_input_mode),a
name_buffer := mpLcdCrsrImage + 1000
	ld	hl,name_buffer + 1
	ld	(name_buffer_ptr),hl
.get_name:
	call	util_get_key
	cp	a,skDel
	jp	z,.setup_name
	cp	a,skLeft
	jp	z,.setup_name
	cp	a,skAlpha
	jr	z,.change_input_mode
	cp	a,skClear
	jp	z,main_start
	cp	a,sk2nd
	jp	z,.confirm
	cp	a,skEnter
	jp	z,.confirm
	sub	a,skAdd
	jp	c,.get_name
	cp	a,skMath-skAdd+1
	jp	nc,.get_name
	ld	hl,lut_character_standard
.current_character_lut := $-1
	call	_AddHLAndA		; find the offset
	ld	a,(hl)
	or	a,a
	jr	z,.get_name
	ld	e,a
	ld	a,0
cursor_position := $-1
	cp	a,8
	jr	z,.get_name
	or	a,a
	jr	nz,.got_name
	push	de
	ld	hl,(.current_character_lut)
	ld	de,lut_character_numbers
	compare_hl_de
	pop	bc
	jr	z,.get_name
	ld	e,c
.got_name:
	ld	a,e
	ld	hl,0
name_buffer_ptr := $-3
	ld	(hl),a
	call	lcd_char
	ld	hl,cursor_position
	inc	(hl)
	ld	a,255
current_input_mode := $-1
	call	lcd_char
	ld	hl,(lcd_x)
	ld	de,-9
	add	hl,de
	ld	(lcd_x),hl
	ld	hl,(name_buffer_ptr)
	inc	hl
	ld	(name_buffer_ptr),hl
	jp	.get_name

.change_input_mode:
	ld	hl,lut_character_standard
	ld	e,255
	ld	a,(current_input_mode)
	cp	a,254
	jr	z,.swap
	dec	e
	ld	hl,lut_character_numbers
.swap:
	ld	(.current_character_lut),hl
	ld	a,e
	ld	(current_input_mode),a
	call	lcd_char
	ld	hl,(lcd_x)
	ld	de,-9
	add	hl,de
	ld	(lcd_x),hl
	jp	.get_name

.confirm:
	ld	a,(cursor_position)
	or	a,a
	jp	z,.get_name
	ld	hl,(name_buffer_ptr)
	ld	(hl),0
	bit	item_renaming,(iy + item_flag)
	jr	nz,.renaming
	ld	hl,name_buffer
	ld	(hl),progObj			; already in op1
	call	_Mov9ToOP1
	call	_ChkFindSym
	jp	nc,.get_name			; check if name already exists
	ld	hl,name_buffer
	call	_Mov9ToOP1
	ld	a,(name_buffer)
	or	a,a
	sbc	hl,hl
	call	_CreateVar
	jp	.goto_main
.renaming:
	call	util_move_prgm_name_to_op1	; move the current name to op1
	ld	hl,_Arc_Unarc
	ld	(.jump_smc),hl
	ld	de,OP1
	ld	a,(de)
	ld	hl,name_buffer
	ld	(hl),a
	inc	de
	inc	hl
	ld	a,(de)
	cp	a,65
	jr	nc,.not_hidden				; check if program is hidden
	ld	a,(hl)
	sub	a,64
	ld	(hl),a
.not_hidden:
	call	_PushOP1
	ld	hl,name_buffer
	call	_Mov9ToOP1
	call	_ChkFindSym
	push	af
	call	_PopOP1
	pop	af
	jp	nc,.get_name			; check if name already exists
.locate_program:
	call	_ChkFindSym
	call	_ChkInRam
	jr	nz,.in_archive
	ld	hl,$f8				; _ret
	ld	(.jump_smc),hl
	call	_PushOP1
	call	_Arc_Unarc
	call	_PopOP1
	jr	.locate_program
.in_archive:
	ex	de,hl
	ld	de,9
	add	hl,de				; skip VAT stuff
	ld	e,(hl)
	add	hl,de
	inc	hl				; size of name
	call	_LoadDEInd_s
	push	hl
	push	de
	call	_PushOP1
	ld	hl,name_buffer
	call	_Mov9ToOP1
	call	_PushOP1
	pop	hl
	push	hl
	ld	a,(OP1)
	call	_CreateVar
	inc	de
	inc	de
	pop	bc
	pop	hl
	call	_ChkBCIs0
	jr	z,.is_zero
	ldir
.is_zero:
	call	_PopOP1
	call	_Arc_Unarc
.jump_smc := $-3
	call	_PopOP1
	call	_ChkFindSym
	call	_DelVarArc
.goto_main:
	call	find_programs_or_apps
	ld	hl,name_buffer + 1
	call	search_name
	jp	main_start

feature_item_edit:
	bit	prgm_locked,(iy + prgm_flag)
	jp	nz,main_loop
	ld	a,(prgm_type)
	cp	a,file_ice_source
	jr	z,.good
	cp	a,file_basic
	jp	nz,main_loop
.good:
	call	util_move_prgm_name_to_op1
	call	_ChkFindSym
	xor	a,a
	jp	edit_basic_program

feature_item_delete:
	call	feature_check_valid
	call	gui_clear_status_bar
	set_inverted_text
	print	string_delete_confirmation, 4, 228
	set_normal_text
.loop:
	call	util_get_key
	cp	a,skZoom
	jr	z,.delete
	cp	a,skGraph
	jp	z,main_start
	jr	.loop
.delete:
	ld	a,(current_screen)
	cp	a,screen_apps
	jr	z,.delete_app
.delete_program:
	call	util_move_prgm_name_to_op1		; move the selected name to op1
	call	_ChkFindSym
	call	_DelVarArc
	jr	.refresh
.delete_app:
	ld	hl,(item_ptr)
	ld	bc,0 - $100
	add	hl,bc
	call	_DeleteApp
	set	3,(iy + $25)				; defrag on exit
.refresh:
	call	main_move_up
	jp	main_find				; reload everything

feature_item_attributes:
	call	feature_check_valid
	ld	a,(iy + prgm_flag)
	ld	(iy + temp_prgm_flag),a
	xor	a,a
	ld	(current_option_selection),a
.show_edit:
	set_text_bg_color color_highlight
	call	.get_option_metadata
	set_normal_text
.loop:
	call	util_show_time
	call	lcd_blit
	call	_GetCSC
	ld	hl,.show_edit
	push	hl
	cp	a,skDown
	jp	z,.move_option_down
	cp	a,skUp
	jp	z,.move_option_up
	pop	hl
	cp	a,skAlpha
	jp	z,.set_options
	cp	a,skMode
	jp	z,.set_options
	cp	a,skClear
	jp	z,.set_options
	cp	a,skDel
	jp	z,.set_options
	cp	a,sk2nd
	jp	z,.check_what_to_do
	cp	a,skEnter
	jr	nz,.loop
	jp	.check_what_to_do

.move_option_down:
	call	.clear_current_selection
	cp	a,2
	ret	z
	inc	a
	ld	(current_option_selection),a
	ret

.move_option_up:
	call	.clear_current_selection
	or	a,a
	ret	z
	dec	a
	ld	(current_option_selection),a
	ret

.clear_current_selection:
	call	.get_option_metadata
	ld	a,(current_option_selection)
	ret

.get_option_metadata:
	ld	a,(current_option_selection)
	ld	l,a
	ld	h,11
	mlt	hl
	ld	a,118
	add	a,l
	ld	bc,199
	ld	(lcd_x),bc
	ld	(lcd_y),a
	ld	a,(current_option_selection)
	ld	hl,string_archived
	or	a,a
	jr	z,.draw
	ld	hl,string_locked
	dec	a
	jr	z,.draw
	ld	hl,string_hidden
.draw:
	jp	lcd_string

.check_what_to_do:
	ld	hl,.show_edit
	push	hl
	ld	a,(current_option_selection)
	dec	a
	jr	nz,.checked_lockable
	ld	a,(prgm_type)
	cp	a,file_basic				; basic programs
	jr	z,.checked_lockable
	cp	a,file_ice_source			; ice source programs
	ret	nz
.checked_lockable:
	ld	a,(current_option_selection)
	inc	a
	call	util_to_one_hot
	xor	a,(iy + prgm_flag)
	ld	(iy + prgm_flag),a
	jp	gui_draw_item_options

.set_options:
	call	util_move_prgm_name_to_op1
	call	_ChkFindSym
	ld	a,progObj
	bit	prgm_locked,(iy + prgm_flag)
	jr	z,.unlock
	inc	a
.unlock:
	ld	(hl),a
	ld	hl,(prgm_ptr)
	ld	hl,(hl)
	dec	hl					; bypass name byte
	ld	a,(hl)
	bit	prgm_hidden,(iy + prgm_flag)
	jr	z,.unhide
	cp	a,64
	jr	c,.check_archived			; already hidden
	sub	a,64
	ld	(hl),a
	jr	.check_archived
.unhide:
	cp	a,64
	jr	nc,.check_archived			; not hidden
	add	a,64
	ld	(hl),a
	;jr	.check_archived
.check_archived:
	call	util_move_prgm_name_to_op1		; if needed, archive it
	call	_ChkFindSym
	call	_ChkInRam
	push	af
	bit	prgm_archived,(iy + prgm_flag)
	jr	z,.unarchive
	pop	af
	call	z,_Arc_Unarc
	jr	.return
.unarchive:
	pop	af
	call	nz,_Arc_Unarc
.return:
	jp	main_start

feature_check_valid:
	bit	setting_special_directories,(iy + settings_flag)
	ret	z
	ld	hl,(current_selection_absolute)
	compare_hl_zero
	ret	nz
	pop	hl
	jp	main_loop				; don't allow deletion of directories
