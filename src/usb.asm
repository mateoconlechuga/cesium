; routines for accessing flash drive data on usb

usb_init:
	xor	a,a
	ld	(current_selection),a

	call	gui_draw_core
	call	libload_load
	jq	nz,usb_not_available

	ld	bc,usb_msdenv
	push	bc
	call	ti._setjmp
	pop	bc
	compare_hl_zero
	jr	z,usb_no_error
usb_xfer_error:				; if we are here, usb broke somehow
	call	lib_msd_Deinit
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
	jq	nz,usb_not_detected	; if failed to init, exit
	ld	bc,usb_sector
	push	bc
	call	lib_fat_SetBuffer	; set the buffer used for reading sectors
	pop	bc
	
	ld	bc,8
	push	bc
	ld	bc,usb_fat_partitions
	push	bc
	call	lib_fat_Find		; get up to 8 available partitions on the device
	ld	iy,ti.flags
	pop	bc
	pop	bc
	or	a,a
	sbc	hl,hl
	ld	l,a
	ld	(number_of_items),hl
	or	a,a
	jr	nz,select_valid_partitions

	call	lib_msd_Deinit		; end usb handling
	ld	iy,ti.flags
	call	usb_invalid_gui
	print	string_usb_no_partitions, 10, 30
	print	string_insert_fat32, 10, 50
	print	string_usb_info_5, 10, 90
	jq	usb_not_available.wait

select_valid_partitions:
	call	view_usb_partitions
.get_partition:
	call	util_get_key
	cp	a,ti.skClear
	jp	z,usb_exit_full
	cp	a,ti.skMode
	jp	z,usb_settings_show
	cp	a,ti.skUp
	jr	z,partition_move_up
	cp	a,ti.skDown
	jr	z,partition_move_down
	cp	a,ti.sk2nd
	jr	z,.selected_partition
	cp	a,ti.skEnter
	jr	z,.selected_partition
	jr	.get_partition
.selected_partition:
	ld	a,(current_selection)
	ld	(current_partition_selection),a
.got_partition:
	ld	a,(current_partition_selection)

	call	lib_msd_Deinit
	ld	iy,ti.flags
	call	libload_unload
	jp	main_find

partition_move_up:
	ld	hl,select_valid_partitions
	push	hl
	ld	a,(current_selection)
	or	a,a					; limit items per screen
	ret	z
	dec	a
	ld	(current_selection),a
	ret

partition_move_down:
	ld	hl,select_valid_partitions
	push	hl
	ld	a,(number_of_items)
	ld	b,a
	dec	b
	ld	a,(current_selection)
	cp	a,b					; limit items per screen
	ret	z
	inc	a
	ld	(current_selection),a
	ret

usb_exit_full:
	call	lib_msd_Deinit
	call	libload_unload
	jp	exit_full

usb_settings_show:
	xor	a,a
	ld	(current_selection),a
	call	lib_msd_Deinit
	call	libload_unload
	jp	settings_show

usb_invalid_gui:
	set_normal_text
	jp	libload_unload

usb_not_detected:
	call	usb_invalid_gui
	print	string_usb_not_detected, 10, 30
	print	string_insert_fat32, 10, 50
	print	string_usb_info_5, 10, 90
	jr	usb_not_available.wait

usb_not_available:
	call	usb_invalid_gui
	print	string_usb_info_0, 10, 30
	print	string_usb_info_1, 10, 50
	print	string_usb_info_2, 10, 70
	print	string_usb_info_3, 10, 90
	print	string_usb_info_4, 10, 110
	print	string_usb_info_5, 10, 150
.wait:
	call	lcd_blit
	call	util_get_key
	jp	main_start

usb_sector:
	rb	512

usb_msdenv:
	rb	12

usb_fat_partitions:
	rb	80

