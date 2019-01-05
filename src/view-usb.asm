; routines for displaying the current directory contents present on the usb device

view_usb:
	ret


	call	gui_show_item_count
	set_normal_text
	set_cursor 24, 30
	xor	a,a
	sbc	hl,hl
	ld	(iy + prgm_flag),a		; reset the item flag
	ld	(current_item_selection),a
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
current_item_selection := $-1
	ld	a,(current_selection)
	cp	a,e
	jr	nz,.not_selected
	set	drawing_selected,(iy + item_flag)
	ld	a,(color_tertiary)
	ld	(lcd_text_bg),a			; highlight the currently selected item
.not_selected:
	ld	a,e
	inc	a
	ld	(current_item_selection),a
	ld	a,(lcd_y)
	cp	a,220
	jp	nc,util_set_more_items_flag	; more to scroll, so draw an arrow or something later
	push	bc				; bc = number of apps left to draw
	push	hl				; hl -> lookup table

	ld	hl,(hl)				; load name pointer
	ld	(usb_item_ptr),hl

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

	call	draw_usb_icon

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

draw_usb_icon:
	ld	hl,0
usb_item_ptr := $-3
	ld	a,(hl)
	or	a,a
	ld	hl,sprite_file_appvar
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

	ld	hl,(usb_item_ptr)
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
	ret
