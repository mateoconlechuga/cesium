gui_main:
	call	gui_draw_core
	draw_rectangle_outline 193, 24, 316, 221
	draw_rectangle_outline 237, 54, 274, 91
	draw_horiz 199, 36, 112
	set_normal_text
	print	string_file_information, 199, 27
	ld	a,(current_screen)
	cp	a,screen_programs
	jp	z,view_vat_items
	cp	a,screen_appvars
	jp	z,view_vat_items
	cp	a,screen_apps
	jp	z,view_apps
	;cp	a,screen_usb
	;jr	z,show_usb
	jp	exit_full

gui_draw_core:
	call	lcd_fill
	call	util_show_free_mem
	draw_rectangle 1, 1, 319, 21
	draw_rectangle_outline 1, 22, 318, 223
	set_inverted_text
	print string_cesium, 15, 7
	draw_sprite sprite_battery, 3, 7
	ld	a,0
battery_status := $-1
	sub	a,5
	cpl
	or	a,a
	ret	z
	ld	bc,4
	ld	de,(lcdWidth * 8) + 7
	jp	lcd_rectangle.computed

gui_draw_cesium_info:
	call	gui_draw_core
	call	gui_clear_status_bar
	set_inverted_text
	print	string_cesium_version, 4, 228
	set_normal_text
	ret

gui_show_description:
	push	bc
	push	hl
	call	gui_clear_status_bar
	pop	hl
	save_cursor
	set_inverted_text
	ld	bc,4
	ld	a,228
	call	util_string_xy
	set_normal_text
	restore_cursor
	pop	bc
	ret

gui_draw_static_options:
	print	string_settings, 199, 206
	ld	de,270
	ld	(lcd_x),de
	inc	hl
	call	lcd_string
	ld	a,(current_screen)
	cp	a,screen_programs
	ret	z
	print	string_delete, 199, 195
	ld	de,278
	ld	(lcd_x),de
	inc	hl
	jp	lcd_string

; z flag set = option is on
; a = index
gui_draw_highlightable_option:
	push	af
	ld	ix,current_option_selection
	cp	a,(ix)
	ld	ix,color_secondary
	ld	a,(ix)
	ld	(.color_save),a
	jr	nz,.no_highlight
	ld	a,(color_tertiary)
	ld	(ix),a
.no_highlight:
	pop	af
	call	gui_draw_option
	ld	a,0
.color_save := $-1
	ld	(color_secondary),a
	ret

; z flag not set = fill
gui_draw_option:
	push	af
	ld	a,(color_primary)
	ld	(util_restore_primary.color),a
	jr	nz,.no_fix
	ld	a,color_white
	call	util_set_primary
.no_fix:
	pop	af
	push	af
	push	hl
	push	bc
	push	de
	call	lcd_rectangle_outline.computed
	pop	hl
	pop	bc
	dec	bc
	dec	bc
	dec	bc
	dec	bc				; bc - 4
	ld	a,h
	sub	a,4
	ld	(.recompute),a
	inc	l				; Ty + 3
	inc	l
	ld	h,lcdWidth / 2
	mlt	hl
	add	hl,hl
	pop	de
	add	hl,de
	ex	de,hl				; recompute offset
	inc	e
	inc	e
	pop	af
	ld	a,0
.recompute := $-1
	call	lcd_rectangle.computed
	jp	util_restore_primary

gui_draw_color_table:
	call	gui_clear_status_bar
	ld	a,(color_table_active)
	ld	hl,string_primary_color
	or	a,a
	jr	z,.string
	ld	hl,string_secondary_color
	dec	a
	jr	z,.string
	ld	hl,string_tertiary_color
.string:
	set_inverted_text
	set_cursor 4, 228
	call	lcd_string
	ld	hl,string_mode_select
	call	lcd_string
	set_normal_text
	draw_rectangle_outline 111, 71, 208, 168
	ld	de,(72 shl 8) or 112
	xor	a,a
	ld	b,16
.loop:
	push	bc
	ld	b,6
.vert:
	push	bc
	ld	l,lcdWidth / 2
	ld	h,d
	mlt	hl
	add	hl,hl
	push	de
	ld	d,0
	add	hl,de
	ld	de,vRamBuffer
	add	hl,de
	pop	de
	ld	b,16
.horiz:
	ld	(hl),a
	inc	hl
	ld	(hl),a
	inc	hl
	ld	(hl),a
	inc	hl
	ld	(hl),a
	inc	hl
	ld	(hl),a
	inc	hl
	ld	(hl),a
	inc	hl
	inc	a
	djnz	.horiz
	sub	a,16
	ld	e,112
	inc	d
	pop	bc
	djnz	.vert
	pop	bc
	add	a,16
	djnz	.loop
	call	gui_color_box.compute
	jq	gui_color_box.draw

gui_color_box:
.compute:
	ld	bc,6					; width
	ld	a,(color_selection_y)
	ld	e,a
	ld	d,c
	mlt	de
	ld	a,e
	add	a,72
	ld	e,a					; y
	ld	a,(color_selection_x)
	ld	l,a
	ld	h,c
	mlt	hl
	ld	bc,112
	add	hl,bc					; x
	ld	c,6
	ld	d,c
	push	hl
	push	de
	push	bc
	call	lcd_compute
	ld	de,lcdWidth * 2 + 3
	add	hl,de
	ld	a,(hl)					; get the new color
	ld	hl,(color_ptr)
	ld	(hl),a
	pop	bc
	pop	de
	pop	hl
	ret
.draw:
	ld	a,(color_secondary)
	push	af
	ld	a,0
	ld	(color_secondary),a
	call	lcd_rectangle_outline.computed
	pop	af
	ld	(color_secondary),a
	ret

color_ptr := $
	dl	0

gui_clear_status_bar:
	draw_rectangle 1, 225, 319, 239
	ret

gui_draw_item_options:
	bit	prgm_archived,(iy + prgm_flag)
	draw_option 300, 118, 308, 126
	ld	a,(current_screen)
	cp	a,screen_appvars
	ret	z
	bit	prgm_locked,(iy + prgm_flag)
	draw_option 300, 129, 308, 137
	bit	prgm_hidden,(iy + prgm_flag)
	draw_option 300, 140, 308, 148
	ret

gui_show_item_count:
	ld	hl,(number_of_items)
	bit	setting_list_count,(iy + settings_flag)
	ret	z
	bit	setting_special_directories,(iy + settings_flag)
	jr	z,.no_extra_directories
	dec	hl
	ld	a,(current_screen)
	cp	a,screen_apps
	jr	nz,.no_extra_directories
	dec	hl
.no_extra_directories:
	push	hl
	set_cursor 195, 7
	set_inverted_text
	call	lcd_num_4
	pop	hl
	ret

gui_backup_ram_to_flash:
	ld	a,color_white
	call	util_set_primary
if config_english
	draw_rectangle 114, 105, 206, 121
	draw_rectangle_outline 113, 104, 207, 121
	set_cursor 119, 109
else
	draw_rectangle 89, 105, 256, 121
	draw_rectangle_outline 88, 104, 257, 121
	set_cursor 95, 109
end if
	call	util_restore_primary
	set_normal_text
	ld	hl,string_ram_backup
	call	lcd_string
	call	lcd_blit
	jp	flash_backup_ram
