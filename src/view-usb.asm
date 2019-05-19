; routines for displaying the current directory contents present on the usb device

view_usb_partitions:
	xor	a,a
	ld	(partition_offet),a
	ld	(current_partition_selection),a
	call	gui_draw_core
	ld	hl,(number_of_items)
	call	gui_show_item_count.show
	set_normal_text
	print	string_select_partition_0, 10, 190
	print	string_select_partition_1, 10, 205
	set_cursor 24, 30
	ld	bc,(number_of_items)
.loop:
	ld	hl,lcd_text_bg
	ld	a,(color_senary)
	ld	(hl),a
	res	drawing_selected,(iy + item_flag)
	ld	e,0
current_partition_selection := $ - 1
	ld	a,(usb_selection)
	cp	a,e
	jr	nz,.not_selected
	set	drawing_selected,(iy + item_flag)
	ld	a,(color_tertiary)
	ld	(hl),a				; highlight the currently selected item
.not_selected:
	ld	a,e
	inc	a
	ld	(current_partition_selection),a
	push	bc				; bc = number of apps left to draw

	ld	hl,string_partition
	call	lcd_string
	ld	a,0
partition_offet := $ - 1
	inc	a
	ld	(partition_offet),a
	or	a,a
	sbc	hl,hl
	ld	l,a
	call	lcd_num_3

	ld	a,(lcd_y)
	add	a,20
	ld	(lcd_y),a
	sub	a,25
	ld	c,a
	ld	a,24
	ld	(lcd_x),a
	ld	b,2
	ld	hl,sprite_usb
	call	lcd_sprite

	pop	bc
	dec	bc
	ld	a,b
	or	a,c
	jp	nz,.loop
	jp	lcd_blit

; if in the root directory, the first entry is the name of the partition
view_usb_directory:
	call	usb_show_path
	ld	hl,(number_of_items)
	call	gui_show_item_count.show
	set_cursor 24, 30
	xor	a,a
	sbc	hl,hl
	ld	(iy + prgm_flag),a		; reset the item flag
	ld	(current_usb_file),a
	ld	hl,item_location_base
	ld	de,(scroll_amount)
	call	ti.ChkDEIs0
	ld	bc,(number_of_items)
	jr	z,.loop
.get_real_offset:
	push	bc
	ld	bc,16
	add	hl,bc
	pop	bc				; each entry is 16 bytes
	dec	de
	dec	bc
	ld	a,e
	or	a,d
	jr	nz,.get_real_offset
.loop:
	call	ti.ChkBCIs0
	jp	z,main_loop
	set_normal_text
	xor	a,a
	ld	(iy + temp_prgm_flag),a		; reset temp flags
	res	drawing_selected,(iy + item_flag)
	res	item_is_directory,(iy + item_flag)
	ld	e,0
current_usb_file := $-1
	ld	a,(current_selection)
	cp	a,e
	jr	nz,.not_selected
	set	drawing_selected,(iy + item_flag)
	ld	a,(color_tertiary)
	ld	(lcd_text_bg),a			; highlight the currently selected item
.not_selected:
	ld	a,e
	inc	a
	ld	(current_usb_file),a
	ld	a,(lcd_y)
	cp	a,220
	jp	nc,util_set_more_items_flag	; more to scroll, so draw an arrow or something later
	push	bc				; bc = number of usb files left to draw
	push	hl				; hl -> filename

	ld	(usb_filename_ptr),hl

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
	ld	bc,16
	add	hl,bc
	pop	bc
	dec	bc
	ld	a,b
	or	a,c
	jp	nz,.loop
	ret

draw_usb_icon:
	ld	hl,0
usb_filename_ptr := $-3
	call	usb_check_directory		; check directory bit
	call	usb_check_extensions
	push	de
	pop	hl
	jr	z,.draw
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

	ld	hl,(usb_filename_ptr)
	ld	(item_ptr),hl

	set_normal_text
	call	gui_draw_static_options

	print	string_language, 199, 107
	bit	item_is_directory,(iy + item_flag)
	ld	hl,string_directory
	jr	nz,.show_language
	call	usb_check_extensions
.show_language:
	call	lcd_string
	print	string_size, 199, 162

	call	usb_get_file_size		; get size of file
	call	lcd_num_6

	print string_attributes, 199, 173
	set_cursor_x 262
	inc	hl
	call	lcd_string
	print string_transfer, 199, 184
	set_cursor_x 270
	inc	hl
	call	lcd_string

	print string_hidden, 199, 118
	print string_read_only, 199, 129
	print string_system, 199, 140

	call	gui_draw_usb_item_options

	restore_cursor
	ret
