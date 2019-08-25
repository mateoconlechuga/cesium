; features offered by cesium

NORMAL_CHARS    := 255
NUMBER_CHARS    := 254
LOWERCASE_CHARS := 253

feater_setup_editor:
	res	item_renaming,(iy + item_flag)
	set	item_set_editor,(iy + item_flag)
	jr	feature_item_rename.setup_name
feature_item_new:
	ld	a,(current_screen)
	cp	a,screen_programs
	jp	nz,main_loop
	bit	cesium_is_nl_disabled,(iy + cesium_flag)
	jp	nz,main_loop
	res	item_set_editor,(iy + item_flag)
	res	item_renaming,(iy + item_flag)
	jr	feature_item_rename.setup_name
feature_item_rename:
	ld	a,(current_screen)
	cp	a,screen_programs
	jr	z,.continue
	cp	a,screen_appvars
	jp	nz,main_loop
.continue:
	res	item_set_editor,(iy + item_flag)
	set	item_renaming,(iy + item_flag)
	ld	a,(prgm_type)
	cp	a,file_dir
	jp	z,main_loop
	cp	a,file_usb_dir
	jp	z,main_loop
.setup_name:
	ld	a,NORMAL_CHARS
	ld	(current_input_mode),a
	call	.clear
.cleared:
	ld	a,(current_input_mode)
	call	lcd_char
	ld	hl,199
	ld	(lcd_x),hl
	xor	a,a
	ld	(cursor_position),a
	ld	a,NORMAL_CHARS
	ld	(current_input_mode),a
	ld	hl,lut_character_standard
	ld	(.current_character_lut),hl
name_buffer := ti.mpLcdCrsrImage + 1000
	ld	hl,name_buffer + 1
	ld	(name_buffer_ptr),hl
.get_name:
	call	util_get_key
	cp	a,ti.skDel
	jq	z,.backspace
	cp	a,ti.skLeft
	jq	z,.backspace
	cp	a,ti.skAlpha
	jp	z,.change_input_mode
	cp	a,ti.skClear
	jp	z,main_start
	cp	a,ti.sk2nd
	jp	z,.confirm
	cp	a,ti.skEnter
	jp	z,.confirm
	sub	a,ti.skAdd
	jp	c,.get_name
	cp	a,ti.skMath - ti.skAdd + 1
	jp	nc,.get_name
	ld	hl,.get_name
	push	hl
	ld	hl,lut_character_standard
.current_character_lut := $-3
	call	ti.AddHLAndA			; find the offset
	ld	a,(hl)
	or	a,a
	ret	z
	ld	e,a
	ld	a,0
cursor_position := $-1
	cp	a,8
	ret	z
	ld	a,(current_input_mode)
	cp	a,NUMBER_CHARS
	jr	nz,.got_name
	ld	a,(current_screen)
	cp	a,screen_programs
	jr	nz,.got_name
	ld	a,(current_input_mode)
	cp	a,LOWERCASE_CHARS
	ret	z
	ld	a,(cursor_position)
	or	a,a
	ret	z
.got_name:
	ld	a,e
.insert_char:
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
	ret
.backspace:
	ld	hl,cursor_position
	ld	a,(hl)
	ld	(hl),0
	or	a,a
	jp	z,.get_name
	push	af
	call	.clear
	pop	af
	dec	a
	or	a,a
	jp	z,.cleared
	ld	b,a
	ld	hl,name_buffer + 1
	ld	(name_buffer_ptr),hl
.redraw:
	push	bc
	push	hl
	ld	a,(hl)
	call	.insert_char
	pop	hl
	pop	bc
	inc	hl
	djnz	.redraw
	jp	.get_name

.clear:
	ld	a,(color_senary)
	draw_rectangle_color 199, 173, 313, 215
	ld	hl,string_editor_name
	bit	item_set_editor,(iy + item_flag)
	jr	nz,.rename
	bit	item_renaming,(iy + item_flag)
	ld	hl,string_rename
	jr	nz,.rename
	ld	hl,string_new_prgm
.rename:
	print_xy 199, 173
	set_cursor 199, 195
	ret

.change_input_mode:
	ld	a,(current_input_mode)
	cp	a,NORMAL_CHARS
	jr	z,.setnumbers
	cp	a,NUMBER_CHARS
	jr	z,.setlowercase
.setnormal:
	ld	a,NORMAL_CHARS
	ld	hl,lut_character_standard
	jr	.set_input_mode
.setlowercase:
	ld	a,(current_screen)
	cp	a,screen_programs
	jr	z,.setnormal
	ld	a,LOWERCASE_CHARS
	ld	hl,lut_character_lowercase
	jr	.set_input_mode
.setnumbers:
	ld	a,NUMBER_CHARS
	ld	hl,lut_character_numbers
.set_input_mode:
	ld	(.current_character_lut),hl
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
	bit	item_set_editor,(iy + item_flag)
	jq	nz,.setting_editor_name
	ld	hl,name_buffer
	ld	(hl),ti.ProgObj			; already in op1
	call	ti.Mov9ToOP1
	call	ti.ChkFindSym
	jp	nc,.get_name			; check if name already exists
	ld	hl,name_buffer
	call	ti.Mov9ToOP1
	ld	a,(ti.OP1 + 1)			; check if hidden name already exists
	sub	a,64
	ld	(ti.OP1 + 1),a
	call	ti.ChkFindSym
	jp	nc,.get_name			; check if name already exists
	ld	hl,name_buffer
	call	ti.Mov9ToOP1
	ld	a,ti.ProgObj
	or	a,a
	sbc	hl,hl
	call	ti.CreateVar
	jp	.goto_main
.renaming:
	call	util_move_prgm_name_to_op1	; move the current name to op1
	ld	hl,cesium.Arc_Unarc
	ld	(.jump_smc),hl
	ld	hl,name_buffer
	ld	de,ti.OP1
	ldi
	call	ti.PushOP1
	ld	hl,name_buffer
	call	ti.Mov9ToOP1
	call	ti.ChkFindSym
	push	af
	call	ti.PopOP1
	pop	af
	jp	nc,.get_name			; check if name already exists
	call	ti.PushOP1
	ld	hl,name_buffer
	call	ti.Mov9ToOP1
	ld	a,(ti.OP1 + 1)			; check if hidden name already exists
	sub	a,64
	ld	(ti.OP1 + 1),a
	call	ti.ChkFindSym
	push	af
	call	ti.PopOP1
	pop	af
	jp	nc,.get_name			; check if name already exists
.locate_program:
	call	ti.ChkFindSym
	call	ti.ChkInRam
	jr	nz,.in_archive
	ld	hl,$f8				; _ret
	ld	(.jump_smc),hl
	call	ti.PushOP1
	call	cesium.Arc_Unarc
	call	ti.PopOP1
	jr	.locate_program
.in_archive:
	ex	de,hl
	ld	de,9
	add	hl,de				; skip VAT stuff
	ld	e,(hl)
	add	hl,de
	inc	hl				; size of name
	call	ti.LoadDEInd_s
	push	hl
	push	de
	call	ti.PushOP1
	ld	hl,name_buffer
	call	ti.Mov9ToOP1
	call	ti.PushOP1
	pop	hl
	push	hl
	ld	a,(ti.OP1)
	call	ti.CreateVar
	inc	de
	inc	de
	pop	bc
	pop	hl
	call	ti.ChkBCIs0
	jr	z,.is_zero
	ldir
.is_zero:
	call	ti.PopOP1
	call	cesium.Arc_Unarc
.jump_smc := $-3
	call	ti.PopOP1
	call	ti.ChkFindSym
	call	ti.DelVarArc
.goto_main:
	call	find_files
	ld	hl,name_buffer + 1
	call	search_name
	jp	main_start
.setting_editor_name:
	ld	hl,name_buffer
	ld	(hl),ti.ProtProgObj
	ld	de,setting_editor_name
	call	ti.Mov9b
	call	settings_save
	jp	main_start

feature_item_edit:
	ld	a,(current_screen)
	cp	a,screen_programs
	jp	nz,main_loop
	call	feature_check_valid
	bit	prgm_locked,(iy + prgm_flag)
	jp	nz,main_loop
	ld	a,(prgm_type)
	cp	a,file_ice_source
	jr	z,.good
	cp	a,file_basic
	jp	nz,main_loop
.good:
	call	util_move_prgm_name_to_op1
	jp	edit_basic_program

feature_item_delete:
	ld	a,(current_screen)
	cp	a,screen_usb
	call	nz,feature_check_valid
	bit	setting_delete_confirm,(iy + settings_flag)
	jr	z,.delete
	call	gui_clear_status_bar
	set_inverted_text
	print	string_delete_confirmation, 4, 228
	set_normal_text
.delete:
	ld	a,(current_screen)
	cp	a,screen_apps
	jr	z,.delete_app
	cp	a,screen_usb
	jp	z,usb_delete_file
.delete_program:
	call	util_check_if_vat_page_directory
	jp	z,main_start
	call	.getinput
	call	util_move_prgm_name_to_op1	; move the selected name to op1
	call	ti.ChkFindSym
	call	ti.DelVarArc
	jr	.refresh
.delete_app:
	call	util_check_if_app_page_directory
	jp	z,main_start
	call	.getinput
	ld	hl,(item_ptr)
	ld	bc,0 - $100
	add	hl,bc
	call	ti.DeleteApp
	set	3,(iy + $25)			; defrag on exit
.refresh:
	ld	hl,(current_selection_absolute)
	ld	de,(number_of_items)
	inc	hl
	compare_hl_de
	call	z,main_move_up
	ld	a,return_settings
	ld	(return_info),a
	jp	main_find			; reload everything

.getinput:
	call	util_get_key
	cp	a,ti.skZoom
	ret	z
	cp	a,ti.skGraph
	jr	nz,.getinput
	pop	hl
	jp	main_start

feature_item_attributes:
	call	feature_check_valid
	ld	hl,.max_options
	ld	(hl),2
	ld	a,(current_screen)
	cp	a,screen_usb
	jr	z,.usb
	cp	a,screen_apps
	jp	z,main_loop
	cp	a,screen_programs
	jr	z,.programs
	ld	(hl),0
.programs:
	ld	a,(iy + prgm_flag)
	ld	(iy + temp_prgm_flag),a
	ld	a,$c9
	ld	hl,.check_hide_smc
	ld	(hl),a
	xor	a,a
	ld	(current_option_selection),a
	bit	prgm_archived,(iy + prgm_flag)
	jr	nz,.show_edit
	ld	(hl),a
.show_edit:
	ld	a,(color_tertiary)
	ld	(lcd_text_bg),a			; highlight the currently selected item
	call	.get_option_metadata
	set_normal_text
.loop:
	call	util_show_time
	call	lcd_blit
	call	ti.GetCSC
	ld	hl,.show_edit
	push	hl
	cp	a,ti.skDown
	jp	z,.move_option_down
	cp	a,ti.skUp
	jp	z,.move_option_up
	pop	hl
	cp	a,ti.skAlpha
	jp	z,.set_options
	cp	a,ti.skMode
	jp	z,.set_options
	cp	a,ti.skClear
	jp	z,.set_options
	cp	a,ti.skDel
	jp	z,.set_options
	cp	a,ti.sk2nd
	jp	z,.check_what_to_do
	cp	a,ti.skEnter
	jr	nz,.loop
	jp	.check_what_to_do
.usb:
	jp	main_start

.move_option_down:
	call	.clear_current_selection
	cp	a,2
.max_options := $-1
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
	jr	z,.check_lock
	dec	a
	jr	z,.check_hide
	jr	.toggle_option
.check_hide:
	ret
.check_hide_smc := $ - 1
	jr	.toggle_option
.check_lock:
	ld	a,(prgm_type)
	cp	a,file_basic			; basic programs
	jr	z,.toggle_option
	cp	a,file_ice_source		; ice source programs
	ret	nz
.toggle_option:
	ld	a,(current_option_selection)
	inc	a
	call	util_to_one_hot
	xor	a,(iy + prgm_flag)
	ld	(iy + prgm_flag),a
	jp	gui_draw_item_options

.set_options:
	call	util_move_prgm_name_to_op1
	ld	a,(current_screen)
	cp	a,screen_appvars
	jr	z,.check_archived		; appvars can only be (un)archived
	call	ti.ChkFindSym
	ld	a,ti.ProgObj
	bit	prgm_locked,(iy + prgm_flag)
	jr	z,.unlock
	inc	a
.unlock:
	ld	(hl),a
	ld	hl,(prgm_ptr)
	ld	hl,(hl)
	dec	hl				; bypass name byte
	ld	a,(hl)
	bit	prgm_hidden,(iy + prgm_flag)
	jr	z,.unhide
	cp	a,64
	jr	c,.check_archived		; already hidden
	sub	a,64
	ld	(hl),a
	jr	.check_archived
.unhide:
	cp	a,64
	jr	nc,.check_archived		; not hidden
	add	a,64
	ld	(hl),a
	;jr	.check_archived
.check_archived:
	call	util_move_prgm_name_to_op1	; if needed, archive it
	call	ti.ChkFindSym
	call	ti.ChkInRam
	push	af
	bit	prgm_archived,(iy + prgm_flag)
	jr	z,.unarchive
.archive:
	pop	af
	call	z,cesium.Arc_Unarc
	jr	nz,.return
	ld	a,return_settings
	ld	(return_info),a
	jp	main_find
.unarchive:
	pop	af
	call	nz,cesium.Arc_Unarc
.return:
	jp	main_start

feature_check_valid:
	bit	setting_special_directories,(iy + settings_flag)
	jr	z,.empty_check
	ld	hl,(current_selection_absolute)
	compare_hl_zero
	ret	nz
	pop	hl
	jp	main_loop			; don't allow deletion of directories
.empty_check:
	ld	hl,(number_of_items)
	compare_hl_zero
	ret	nz
	pop	hl
	jp	main_loop



