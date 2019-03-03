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
