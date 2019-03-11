; common routines for working with things involving settings

settings_load:
	ld	hl,settings_appvar
	call	util_find_var			; lookup the settings appvar
	jr	c,settings_create_default	; create it if it doesn't exist
	call	ti.ChkInRam
	push	af
	call	z,ti.Arc_Unarc			; archive it
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
	call	ti.EnoughMem
	pop	hl
	jp	c,exit_full
	call	ti.CreateAppVar
	inc	de
	inc	de
	ld	hl,settings_data
	ld	bc,settings_size
	ldir
	jq	settings_load

settings_save:
	ld	hl,settings_appvar
	call	util_find_var
	call	ti.ChkInRam
	push	af
	call	nz,ti.Arc_Unarc
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
	jp	ti.Arc_Unarc

settings_show:
	ld	a,(current_screen)
	cp	a,screen_usb
	jp	z,main_loop
	xor	a,a
	ld	(current_option_selection),a			; start on the first menu item
	ld	(setting_brightness_get.counter),a
.draw:
	call	setting_draw_options

settings_get:
	call	util_get_key
	ld	hl,settings_show.draw
	push	hl
	ld	ix,current_option_selection
	cp	a,ti.skStore
	jp	z,password_modify
	cp	a,ti.skLeft
	jp	z,setting_left
	cp	a,ti.skRight
	jp	z,setting_right
	cp	a,ti.skDown
	jp	z,setting_down
	cp	a,ti.skUp
	jp	z,setting_up
	cp	a,ti.sk2nd
	jp	z,setting_toggle
	cp	a,ti.skEnter
	jp	z,setting_toggle
	pop	hl
	cp	a,ti.skDel
	jr	z,setting_set_and_save
	cp	a,ti.skClear
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
	jr	setting_brightness_down

setting_right:
	;jr	setting_brightness_up

setting_brightness_up:
	call	setting_brightness_get
	add	a,b
	ld	(hl),a
	ret

setting_brightness_down:
	call	setting_brightness_get
	sub	a,b
	ld	(hl),a
	ret

setting_brightness_get:
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
	ld	hl,ti.mpBlLevel
	ld	a,(hl)
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
	cp	a,ti.skLeft
	jr	z,setting_color_left
	cp	a,ti.skRight
	jr	z,setting_color_right
	cp	a,ti.skDown
	jr	z,setting_color_down
	cp	a,ti.skUp
	jr	z,setting_color_up
	cp	a,ti.skMode
	jr	z,setting_color_swap
	pop	hl
	cp	a,ti.sk2nd
	jr	.complete
	cp	a,ti.skEnter
	jr	.complete
	cp	a,ti.skClear
	jr	.complete
	cp	a,ti.skDel
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
	call	ti.AddHLAndA
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
	print	string_setting_color, 25, 49
	print	string_setting_indicator, 25, 69
	print	string_setting_list_count, 25, 89
	print	string_setting_clock, 25, 109
	print	string_setting_ram_backup, 25, 129
	print	string_setting_special_directories, 25, 149
	print	string_setting_enable_shortcuts, 25, 169
	print	string_settings_delete_confirm, 25, 189
	print	string_settings_usb_edit, 25, 209

	xor	a,a
	inc	a				; color is always set
	draw_highlightable_option 10, 48, 0
	bit	setting_basic_indicator,(iy + settings_flag)
	draw_highlightable_option 10, 68, 1
	bit	setting_list_count,(iy + settings_flag)
	draw_highlightable_option 10, 88, 2
	bit	setting_clock,(iy + settings_flag)
	draw_highlightable_option 10, 108, 3
	bit	setting_ram_backup,(iy + settings_flag)
	draw_highlightable_option 10, 128, 4
	bit	setting_special_directories,(iy + settings_flag)
	draw_highlightable_option 10, 148, 5
	bit	setting_enable_shortcuts,(iy + settings_flag)
	draw_highlightable_option 10, 168, 6
	bit	setting_delete_confirm,(iy + settings_flag)
	draw_highlightable_option 10, 188, 7
	bit	setting_enable_usb,(iy + settings_flag)
	draw_highlightable_option 10, 208, 8
	ret

settings_appvar:
	db	ti.AppVarObj, cesium_name, 0

settings_editor_default_prgm_name:
	db	ti.ProtProgObj,"KEDIT",0
.length :=$-settings_editor_default_prgm_name
