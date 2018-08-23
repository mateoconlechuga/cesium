; common routines for working with things involving settings

settings_load:
	ld	hl,settings_appvar
	call	util_find_var			; lookup the settings appvar
	jr	c,settings_create_default	; create it if it doesn't exist
	call	_ChkInRam
	push	af
	call	z,_Arc_Unarc			; archive it
	pop	af
	jq	z,settings_load			; find it again
settings_get_data:
	ex	de,hl
	ld	de,9
	add	hl,de
	ld	e,(hl)
	add	hl,de
	inc	hl
	inc	hl
	inc	hl
	ld	de,settings_data
	ld	bc,settings_size
	ldir
	ld	a,(setting_config)
	ld	(iy + settings_flag),a
	call	gui_fixup_sprites
	jp	util_setup_shortcuts

settings_create_default:
	ld	hl,setting_color_primary	; initialize default settings
	ld	(hl),color_primary_default
	inc	hl
	ld	(hl),color_secondary_default
	inc	hl
	ld	(hl),color_tertiary_default
	inc	hl
	ld	(hl),color_quaternary_default
	inc	hl
	ld	(hl),color_quinary_default
	inc	hl
	ld	(hl),color_senary_default
	ld	hl,setting_config
	ld	(hl),setting_config_default
	ld	hl,setting_password
	ld	(hl),0				; zero length
	ld	hl,settings_editor_default_prgm_name
	ld	de,setting_editor_name
	ld	bc,settings_editor_default_prgm_name.length
	ldir
	ld	hl,settings_appvar_size + 2	; increment for safety
	push	hl
	call	_EnoughMem
	pop	hl
	jp	c,exit_full
	call	_CreateAppVar
	inc	de
	inc	de
	ld	hl,settings_data
	ld	bc,settings_size
	ldir
	jq	settings_load

settings_save:
	ld	hl,settings_appvar
	call	util_find_var
	call	_ChkInRam
	push	af
	call	nz,_Arc_Unarc
	pop	af
	jr	nz,settings_save
	ld	a,(iy + settings_flag)
	ld	(setting_config),a
	inc	de
	inc	de
	ld	hl,settings_data
	ld	bc,settings_size
	ldir
	ld	hl,settings_appvar
	call	util_find_var
	jp	_Arc_Unarc

settings_show:
	xor	a,a
	ld	(current_option_selection),a			; start on the first menu item
	ld	(setting_brightness_check.counter),a
.draw:
	call	setting_draw_options

settings_get:
	call	util_get_key
	ld	hl,settings_show.draw
	push	hl
	ld	ix,current_option_selection
	cp	a,skStore
	jp	z,password_modify
	cp	a,skLeft
	jp	z,setting_left
	cp	a,skRight
	jp	z,setting_right
	cp	a,skDown
	jp	z,setting_down
	cp	a,skUp
	jp	z,setting_up
	cp	a,sk2nd
	jp	z,setting_toggle
	cp	a,skEnter
	jp	z,setting_toggle
	pop	hl
	cp	a,skDel
	jr	z,setting_set_and_save
	cp	a,skClear
	jr	z,setting_set_and_save
	jr	settings_get
setting_set_and_save:
	call	settings_save			; check if on disabled apps screen
	ld	a,(current_screen)
	cp	a,screen_apps
	jr	z,settings_return
	bit	setting_special_directories,(iy + settings_flag)
	jr	nz,settings_return
	call	find_lists.reset_selection
	ld	a,screen_programs
	ld	(current_screen),a
settings_return:
	ld	a,return_settings
	ld	(return_info),a
	jp	main_settings

setting_down:
	ld	a,(ix)
	cp	a,8
	jr	z,.top
	inc	a
.done:
	ld	(ix),a
	ret
.top:
	xor	a,a
	jr	.done

setting_up:
	ld	a,(ix)
	or	a,a
	jr	z,.bottom
	dec	a
.done:
	ld	(ix),a
	ret
.bottom:
	ld	a,8
	jr	.done

setting_left:
	call	setting_brightness_check
	sub	a,b
.done:
	ld	(hl),a
	ret

setting_right:
	call	setting_brightness_check
	add	a,b
	jr	setting_left.done

setting_brightness_check:
	ld	c,a
	ld	a,(ix)
	cp	a,8
	jr	nz,.fail
	ld	a,c
	ld	b,0
.prev_key := $-1
	cp	a,b
	jr	z,.no_reset
	xor	a,a
	jr	.reset
.no_reset:
	ld	a,0
.counter := $-1
	cp	a,10
	ld	b,10
	jr	z,.fast
.reset:
	inc	a
	ld	(.counter),a
	ld	b,1
.fast:
	ld	a,c
	ld	(.prev_key),a
	ld	hl,mpBlLevel
	ld	a,(hl)
	ret
.fail:
	pop	hl
	ret

setting_toggle:
	ld	a,(ix)
	or	a,a
	jr	z,setting_change_colors	; convert the option to one-hot
	call	util_to_one_hot
	xor	a,(iy + settings_flag)
	ld	(iy + settings_flag),a
	ret

setting_change_colors:
	xor	a,a
	ld	hl,color_primary
	ld	(color_table_active),a
	ld	(color_ptr),hl
	call	setting_color_get_xy
	call	gui_draw_color_table		; temporarily draw tables to compute color
setting_open_colors:
	call	gui_color_box.compute
	call	setting_draw_options
	call	gui_draw_color_table
.loop:
	call	util_get_key
	ld	hl,setting_open_colors
	push	hl
	cp	a,skLeft
	jr	z,setting_color_left
	cp	a,skRight
	jr	z,setting_color_right
	cp	a,skDown
	jr	z,setting_color_down
	cp	a,skUp
	jr	z,setting_color_up
	cp	a,skMode
	jr	z,setting_color_swap
	pop	hl
	cp	a,sk2nd
	jr	.complete
	cp	a,skEnter
	jr	.complete
	cp	a,skClear
	jr	.complete
	cp	a,skDel
	jr	.complete
	pop	hl
	jr	.loop
.complete:
	call	gui_fixup_sprites
	jp	settings_show.draw

setting_color_left:
	ld	a,(color_selection_x)
	or	a,a
	ret	z
	dec	a
	ld	(color_selection_x),a
	ret

setting_color_right:
	ld	a,0
color_selection_x := $-1
	cp	a,15
	ret	z
	inc	a
	ld	(color_selection_x),a
	ret

setting_color_down:
	ld	a,(color_selection_y)
	cp	a,15
	ret	z
	inc	a
	ld	(color_selection_y),a
	ret

setting_color_up:
	ld	a,0
color_selection_y := $-1
	or	a,a
	ret	z
	dec	a
	ld	(color_selection_y),a
	ret

setting_color_swap:
	ld	hl,color_primary
	ld	a,0
color_table_active := $-1
	cp	a,5
	jr	nz,.incr
	ld	a,-1
.incr:
	inc	a
	ld	(color_table_active),a
	call	_AddHLAndA
	ld	(color_ptr),hl
	;jq	setting_color_get_xy

setting_color_get_xy:
	ld	hl,(color_ptr)
	ld	a,(hl)
setting_color_index_to_xy:
	ld	b,a
	srl	a
	srl	a
	srl	a
	srl	a		; index / 16
	and	a,$f		; got y
	ld	(color_selection_y),a
	ld	a,b
	and	a,$f
	ld	(color_selection_x),a
	ret

setting_draw_options:
	call	gui_draw_cesium_info

	print	string_general_settings, 10, 30
	print	string_setting_color, 25, 51
	print	string_setting_indicator, 25, 71
	print	string_setting_list_count, 25, 91
	print	string_setting_clock, 25, 111
	print	string_setting_ram_backup, 25, 131
	print	string_setting_special_directories, 25, 151
	print	string_setting_enable_shortcuts, 25, 171
	print	string_settings_delete_confirm, 25, 191
	print	string_settings_brightness, 25, 211
	call	util_print_brightness

	xor	a,a
	inc	a				; color is always set
	draw_highlightable_option 10, 50, 0
	bit	setting_basic_indicator,(iy + settings_flag)
	draw_highlightable_option 10, 70, 1
	bit	setting_list_count,(iy + settings_flag)
	draw_highlightable_option 10, 90, 2
	bit	setting_clock,(iy + settings_flag)
	draw_highlightable_option 10, 110, 3
	bit	setting_ram_backup,(iy + settings_flag)
	draw_highlightable_option 10, 130, 4
	bit	setting_special_directories,(iy + settings_flag)
	draw_highlightable_option 10, 150, 5
	bit	setting_enable_shortcuts,(iy + settings_flag)
	draw_highlightable_option 10, 170, 6
	bit	setting_delete_confirm,(iy + settings_flag)
	draw_highlightable_option 10, 190, 7
	xor	a,a
	inc	a
	draw_highlightable_option 10, 210, 8	; brightness is always set
	ret

settings_appvar:
	db	appvarObj, cesium_name, 0

settings_editor_default_prgm_name:
	db	protProgObj,"KEDIT",0
.length :=$-settings_editor_default_prgm_name

