gui_main:
	call	gui_draw_core
	ld	a,(color_secondary)
	ld	(color_current),a
	draw_rectangle_outline 193, 24, 316, 221
	draw_rectangle_outline 237, 54, 274, 91
	draw_horiz 199, 36, 112
	set_normal_text
	print	string_file_information, 199, 27
	ld	a,(current_screen)
	cp	a,screen_programs
	jp	z,view_programs
	cp	a,screen_apps
	jp	z,view_apps
	;cp	a,screen_usb
	;jr	z,show_usb
	jp	exit_full

gui_draw_core:
	call	lcd_fill
	call	util_show_free_mem
	set_color color_primary
	draw_rectangle 1, 1, 319, 21
	set_color color_secondary
	draw_rectangle_outline 1, 22, 318, 223
	set_inverted_text
	print string_cesium, 15, 7
	draw_sprite sprite_battery, 3, 7
	set_color color_primary
	ld	a,0
battery_status := $-1
	sub	a,5
	cpl
	or	a,a
	ret	z
	ld	bc,4
	ld	de,(lcdWidth * 8) + 7
	jp	lcd_rectangle.computed

gui_clear_status_bar:
	set_color color_primary
	draw_rectangle 1, 225, 319, 239
	ret
