; process for displaying the list of programs

view_programs:
	bit	setting_list_count,(iy + settings_flag)
	jr	z,.no_count_display
	ld	hl,(number_of_items)
	bit	setting_special_directories,(iy + settings_flag)
	jr	z,.no_extra_directories
	dec	hl
.no_extra_directories:
	set_cursor 195, 7
	set_inverted_text
	call	lcd_num_4
.no_count_display:
	set_normal_text
	set_cursor 24, 30
	xor	a,a
	sbc	hl,hl
	ld	(iy + prgm_flag),a			; reset the program status flags
	ld	(current_prgm_drawing),a
	ld	bc,(number_of_items)
	sbc	hl,hl
	adc	hl,bc
	ret     z					; return if no programs are found
	ld	hl,(scroll_amount)
	compare_hl_zero
	ld	de,item_location_base
	ex	de,hl
	jr	z,.loop
.get_physical_offset:
	inc	hl
	inc	hl
	inc	hl
	inc	hl
	dec	de
	dec	bc
	ld	a,e
	or	a,d
	jr	nz,.get_physical_offset
.loop:
	xor	a,a
	ld	(iy + temp_prgm_flag),a			; reset the temporary flags
	res	drawing_selected,(iy + item_flag)	; not drawing the selected one yet
	ld	e,0
current_prgm_drawing := $-1
	ld	a,(current_selection)
	cp	a,e
	jr	nz,.not_selected
	set	drawing_selected,(iy + item_flag)
	ld	(prgm_ptr),hl
	set_text_bg_color color_highlight		; highlight the currently selected item
.not_selected:
	ld	a,e
	inc	a
	ld	(current_prgm_drawing),a
	ld	a,(lcd_y)
	cp	a,220
	jp	nc,.set_more_flag			; more to scroll, so draw an arrow or something later
	push	bc					; bc = number of programs left to draw
	push	hl					; hl -> lookup table
	ld	hl,(hl)					; load name pointer
	push	hl					; push the name pointer
	inc	hl					; the next byte is the status
	ld	a,(hl)
	call	_SetDEUToA
	inc	hl
	ld	d,(hl)
	inc	hl
	ld	e,(hl)
	push	hl
	ex	de,hl
	cp	a,$d0
	jr	nc,.in_ram
	set	temp_prgm_archived,(iy + temp_prgm_flag)
	ld	de,9
	add	hl,de
	ld	e,(hl)
	add	hl,de
	inc	hl
.in_ram:
	call	_LoadDEInd_s
	ld	(temp_prgm_data_ptr),hl
	bit	drawing_selected,(iy + item_flag)
	jr	z,.not_drawing_selected
	ld	(prgm_data_ptr),hl
	ld	(prgm_real_size),de
.not_drawing_selected:
	ex	de,hl
	ld	de,9
	add	hl,de
	pop	de
	pop	bc
	ld	a,(bc)
	push	bc
	push	de
	call	_AddHLAndA
	ld	(prgm_size),hl
	pop	hl
	inc	hl
	inc	hl
	inc	hl
	ld	a,(hl)					; previously stored type of program
	cp	a,progObj
	jr	z,.not_locked
	set	temp_prgm_locked,(iy + temp_prgm_flag)
.not_locked:
	pop	hl
	ld	b,(hl)
	dec	hl
	ld	a,(hl)
	cp	a,64
	jr	nc,.draw_prgm
	add	a,64
	ld	(hl),a
	set	temp_prgm_hidden,(iy + temp_prgm_flag)
	ld	a,(lcd_text_fg)
	ld	(color_save),a
	set_text_fg_color color_hidden
.draw_prgm:
	push hl
.draw_prgm_name:
	ld	a,(hl)
	dec	hl
	push	bc
	call	lcd_char
	pop	bc
	djnz	.draw_prgm_name
	pop	hl
	bit	temp_prgm_hidden,(iy + temp_prgm_flag)
	jr	z,.not_hidden
	ld	a,0
color_save := $-1
	ld	(lcd_text_fg),a
	ld	a,(hl)
	sub	a,64
	ld	(hl),a
.not_hidden:
	ld	a,(lcd_y)
	add	a,20
	ld	(lcd_y),a
	sub	a,25
	ld	c,a
	ld	a,24
	ld	(lcd_x),a
	ld	b,2
	pop	hl
	inc	hl
	inc	hl
	inc	hl
	ld	a,(hl)
	bit	drawing_selected,(iy + item_flag)
	jr	z,.dont_set_type
	ld	(prgm_type),a
.dont_set_type:
	inc	hl
	push	hl
	ld	de,string_directory
	ld	hl,sprite_directory
	cp	a,file_dir
	jp	z,file_directory
	ld	de,string_asm
	ld	hl,sprite_file_asm
	cp	a,file_asm
	jr	z,file_uneditable
	ld	de,string_c
	ld	hl,sprite_file_c
	cp	a,file_c
	jr	z,file_uneditable
	ld	de,string_ice
	ld	hl,sprite_file_ice
	cp	a,file_ice
	jr	z,file_uneditable
	ld	de,string_ice_source
	cp	a,file_ice_source
	jp	z,file_editable
	ld	de,string_basic
	ld	hl,sprite_file_basic
	cp	a,file_basic
	jr	z,file_editable
.no_programs:
	ret
.set_more_flag:
	set	scroll_down_available,(iy + item_flag)
	ret

file_directory:
	push	hl
	or	a,a
	sbc	hl,hl
	ld	(prgm_size),hl
	pop	hl
	jp	draw_listed_program

file_uneditable:
	push	de
	push	hl
	ld	hl,0					; hl -> program data
temp_prgm_data_ptr := $-3
	inc	hl
	inc	hl
	ld	a,(hl)
	cp	a,byte_jp
	jr	z,.custom_icon
	inc	hl
	ld	a,(hl)
	cp	a,byte_jp
	jr	nz,.no_custom_icon
.custom_icon:
	inc	hl
	inc	hl
	inc	hl
	inc	hl					; hl -> icon indicator byte, hopefully
	ld	a,(hl)
	cp	a,byte_cesium				; cesium indicator byte
	jr	nz,.no_custom_icon
	pop	hl					; pop the old icon
	inc	hl
	bit	drawing_selected,(iy + item_flag)	; check if the description should be drawn
	jr	z,.icon
	push	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	mlt	de
	inc	de
	add	hl,de					; hl -> description string (null terminated)
	call	gui_show_description			; actually draw the description string
.no_custom_icon:
	pop	hl					; hl -> icon
.icon:
	pop	de					; de -> language string
	jp	draw_listed_program

file_editable:
	push	bc
	push	de
	push	hl
	ld	hl,(temp_prgm_data_ptr)
	ld	de,lut_basic_icon
	ld	b,6
.verify_icon:
	ld	a,(de)
	cp	a,(hl)
	inc	hl
	inc	de
	jr	nz,.no_custom_icon
	djnz	.verify_icon
	pop	hl					; remove default icon
	ld	de,sprite_temp
	ld	a,16
	ld	(de),a
	inc	de
	ld	(de),a
	inc	de					; save the size of the sprite
	ld	b,0
.get_icon:						; okay, now loop 256 times to do the squish
	ld	a,(hl)
	sub	a,$30
	cp	a,$11
	jr	c,.no_overflow
	sub	a,$07
.no_overflow:						; rather than doing an actual routine, just do this
	push	hl
	ld	hl,lut_color_basic
	call	_AddHLAndA
	ld	a,(hl)
	pop	hl
	ld	(de),a
	inc	de
	inc	hl
	djnz	.get_icon				; collect all the values
	ld	hl,sprite_temp				; yay, a custom icon
	push	hl
.no_custom_icon:
	pop	hl
	pop	de
	pop	bc
	;jp	draw_listed_program

draw_listed_program:
	ld	a,(lcd_y)
	push	af
	ld	ix,(lcd_x)
	push	ix					; save_cursor
	ld	(tmp_y),a
	push	de
	push	hl
	call	lcd_sprite
	ld	a,0
tmp_y := $-1
	sub	a,20
	ld	c,a
	ld	hl,sprite_locked
	ld	b,250
	bit	temp_prgm_locked,(iy + temp_prgm_flag)
	jr	z,.not_protected
	push	bc
	call	lcd_sprite
	pop	bc
.not_protected:
	ld	a,b
	sub	a,4
	ld	b,a
	ld	hl,sprite_archived
	bit	temp_prgm_archived,(iy + temp_prgm_flag)
	call	z,lcd_sprite
	bit	drawing_selected,(iy + item_flag)
	pop	hl					; hl -> program icon
	jp	z,.not_selected

	ld	a,(iy + temp_prgm_flag)
	ld	(iy + prgm_flag),a			; load the program info

	draw_sprite_2x 120, 57
	set_text_bg_color color_white

	print string_archived, 199, 118
	print string_locked, 199, 129
	print string_hidden, 199, 140

	bit	prgm_archived,(iy + prgm_flag)
	draw_option 300, 118, 308, 126
	bit	prgm_locked,(iy + prgm_flag)
	draw_option 300, 129, 308, 137
	bit	prgm_hidden,(iy + prgm_flag)
	draw_option 300, 140, 308, 148

	print string_size, 199, 151
	ld	hl,(prgm_size)
	call	lcd_num_5

	print string_language, 199, 107
	pop	hl
	call	lcd_string				; language string

	print string_attributes, 199, 173
	ld	de,262
	ld	(lcd_x),de
	inc	hl
	call	lcd_string

	print string_rename, 199, 194
if config_english
	ld	de,262
else
	ld	de,254
end if
	ld	(lcd_x),de
	inc	hl
	call	lcd_string

	bit	prgm_locked,(iy + prgm_flag)
	jr	nz,.is_locked
	print	string_edit_prgm, 199, 195
	ld	de,269
	jr	.no_new
.is_locked:
	print	string_new_prgm, 199, 195
	ld	de,287
.no_new:
	ld	(lcd_x),de
	inc	hl
	call	lcd_string
	print	string_settings, 199, 206
	ld	de,270
	ld	(lcd_x),de
	inc	hl
	call	lcd_string

.not_selected:
	pop	bc
	ld	(lcd_x),bc
	pop	af
	ld	(lcd_y),a				; restore_cursor
	pop	hl
	pop	bc
	dec	bc
	ld	a,b
	or	a,c
	jp	nz,view_programs.loop
	ret

.file_directory:
	push	hl
	or	a,a
	sbc	hl,hl
	ld	(prgm_size),hl
	pop	hl
	jp	draw_listed_program
