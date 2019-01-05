; routines for accessing flash drive data on usb

usb_init:
	call	libload_load
	jr	nz,usb_not_available

	ld	bc,usb_msdenv
	push	bc
	call	ti._setjmp
	pop	bc
	compare_hl_zero
	jr	z,usb_no_error
usb_xfer_error:				; if we are here, usb broke somehow

	jp	main_find
usb_no_error:
	ld	bc,usb_msdenv
	push	bc
	call	lib_msd_SetJmpBuf	; set the error handler callback
	pop	bc
	ld	bc,200			; 200 milliseconds for timeout
	push	bc
	call	lib_msd_Init
	pop	bc
	or	a,a
	jr	nz,usb_not_detected	; if failed to init, exit
					; woo we initialized the usb. now let's see what partitions it has for the user to select


	call	libload_unload
	jp	main_find

usb_not_detected:
	call	libload_unload
	call	gui_draw_core
	set_normal_text
	print	string_usb_not_detected_0, 10, 30
	print	string_usb_not_detected_1, 10, 50
	jr	usb_not_available.wait

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
.wait:
	call	lcd_blit
	call	ti.GetCSC
.getkey:
	call	ti.GetCSC
	or	a,a
	jr	z,.getkey
	jp	main_start

usb_sector:
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

usb_msdenv:
	db	0,0,0,0,0,0,0,0,0,0,0,0

