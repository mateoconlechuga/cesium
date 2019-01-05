; routines for accessing flash drive data on usb

usb_init:
	call	libload_load
	jr	nz,usb_not_available

	; start doing usb things here

	call	libload_unload
	jp	main_find

usb_not_available:
	call	libload_unload
	call	gui_draw_core
	set_normal_text
	print	string_usb_info_0, 10, 30
	print	string_usb_info_1, 10, 50
	print	string_usb_info_2, 10, 70
	print	string_usb_info_3, 10, 90
	print	string_usb_info_4, 10, 110
	print	string_usb_info_5, 10, 150
	call	lcd_blit
	call	ti.GetCSC
.getkey:
	call	ti.GetCSC
	or	a,a
	jr	z,.getkey
	jp	main_start

