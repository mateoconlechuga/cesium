view_apps:
	call	gui_show_item_count
	set_normal_text
	set_cursor 24, 30
	xor	a,a
	sbc	hl,hl
	ld	(iy + prgm_flag),a		; reset the item flag
	ld	(current_app),a
	ld	hl,item_location_base
	ld	de,(scroll_amount)
	call	ti.ChkDEIs0
	ld	bc,(number_of_items)
	jr	z,.loop
.get_real_offset:
	inc	hl
	inc	hl
	inc	hl
	inc	hl
	dec	de
	dec	bc
	ld	a,e
	or	a,d
	jr	nz,.get_real_offset
.loop:
	xor	a,a
	ld	(iy + temp_prgm_flag),a		; reset temp flags
	res	drawing_selected,(iy + item_flag)
	res	item_is_directory,(iy + item_flag)
	ld	e,0
current_app := $-1
	ld	a,(current_selection)
	cp	a,e
	jr	nz,.not_selected
	set	drawing_selected,(iy + item_flag)
	ld	a,(color_tertiary)
	ld	(lcd_text_bg),a			; highlight the currently selected item
.not_selected:
	ld	a,e
	inc	a
	ld	(current_app),a
	ld	a,(lcd_y)
	cp	a,220
	jp	nc,util_set_more_items_flag	; more to scroll, so draw an arrow or something later
	push	bc				; bc = number of apps left to draw
	push	hl				; hl -> lookup table

	ld	hl,(hl)				; load name pointer
	ld	(application_ptr),hl

	inc	hl
	inc	hl
	inc	hl
.name:
	push	hl
	ld	a,(hl)
	or	a,a
	jr	z,.name_done
	call	lcd_char
	pop	hl
	inc	hl
	jr	.name
.name_done:
	pop	hl

	call	draw_app_icon

	pop	hl
	pop	bc
	inc	hl
	inc	hl
	inc	hl
	inc	hl
	dec	bc
	ld	a,b
	or	a,c
	jp	nz,.loop
	ret

draw_app_icon:
	ld	hl,0
application_ptr := $-3
	ld	a,(hl)
	or	a,a
	ld	hl,sprite_file_app
	jr	nz,.draw
	set	item_is_directory,(iy + item_flag)
	ld	hl,sprite_directory
.draw:
	ld	a,(lcd_y)
	add	a,20
	ld	(lcd_y),a
	sub	a,25
	ld	c,a
	ld	a,24
	ld	(lcd_x),a
	ld	b,2
	push	hl
	call	lcd_sprite
	pop	hl

	bit	drawing_selected,(iy + item_flag)
	ret	z

	save_cursor
	draw_sprite_2x 120, 57

	ld	hl,(application_ptr)
	ld	(item_ptr),hl

	push	hl				; push the pointer
	pop	de
	ld	bc,$24
	add	hl,bc
	ld	hl,(hl)				; load location of info string
	compare_hl_zero
	jr	z,.normal_description
	add	hl,de				; add extra bytes
	bit	item_is_directory,(iy + item_flag)
	jr	nz,.normal_description
	call	gui_show_description
	jr	.static_information
.normal_description:
	call	util_show_free_mem
.static_information:
	call	gui_draw_static_options

	print	string_language, 199, 107
	ld	hl,string_application
	bit	item_is_directory,(iy + item_flag)
	jr	z,.is_directory
	ld	hl,string_directory
.is_directory:
	call	lcd_string
	print	string_size, 199, 162
	ld	hl,(item_ptr)
	ld	bc,0 - $100
	add	hl,bc
	push	hl
	bit	item_is_directory,(iy + item_flag)
	jr	z,.draw_real_size
	or	a,a
	sbc	hl,hl
	jr	.draw_size
.draw_real_size:
	push	hl
	call	ti.NextFieldFromType		; move to start of signature
	call	ti.NextFieldFromType		; move to end of signature
	pop	de
	or	a,a
	sbc	hl,de
	inc	hl
	inc	hl
	inc	hl				; bypass app size bytes
.draw_size:
	call	lcd_num_6
	print	string_min_version, 199, 129
	bit	item_is_directory,(iy + item_flag)
	call	z,ti.os.GetAppVersionString
	pop	de
	compare_hl_zero
	jr	nz,.custom_version
	ld	hl,string_min_os_version
.custom_version:
	set_cursor 199, 140
	call	lcd_string
	restore_cursor
	ret
