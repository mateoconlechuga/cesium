; routines for accessing flash drive data on usb

usb_init:
	xor	a,a
	sbc	hl,hl
	ld	(usb_selection),a
	ld	(current_selection),a
	ld	(current_selection_absolute),hl
	ld	hl,usb_fat_path + 1
	ld	(hl),a
	dec	hl
	ld	a,'/'
	ld	(hl),a					; root path = "/"

	call	gui_draw_core
	call	libload_load
	jq	nz,usb_not_available
	ld	iy,ti.flags

	ld	bc,usb_msdenv
	push	bc
	call	ti._setjmp
	pop	bc
	compare_hl_zero
	jr	z,usb_no_error
usb_xfer_error:						; if we are here, usb broke somehow
	ld	iy,ti.flags
	jp	main_find
usb_no_error:
	ld	bc,usb_msdenv
	push	bc
	call	lib_msd_SetJmpBuf			; set the error handler callback
	ld	iy,ti.flags
	pop	bc
	ld	bc,300					; 200 milliseconds for timeout
	push	bc
	call	lib_msd_Init
	ld	iy,ti.flags
	pop	bc
	or	a,a
	jq	nz,usb_not_detected			; if failed to init, exit
	ld	bc,usb_sector
	push	bc
	call	lib_fat_SetBuffer			; set the buffer used for reading sectors
	ld	iy,ti.flags
	pop	bc

	ld	bc,8
	push	bc
	ld	bc,usb_fat_partitions
	push	bc
	call	lib_fat_Find				; get up to 8 available partitions on the device
	ld	iy,ti.flags
	pop	bc
	pop	bc
	or	a,a
	sbc	hl,hl
	ld	l,a
	ld	(number_of_items),hl
	or	a,a
	jr	z,.no_partitions_found
	dec	a
	jr	nz,select_valid_partition		; if there's only one partion, select it
	jr	select_valid_partition.selected_partition

.no_partitions_found:
	call	lib_msd_Deinit				; end usb handling
	ld	iy,ti.flags
	call	usb_invalid_gui
	print	string_usb_no_partitions, 10, 30
	print	string_insert_fat32, 10, 50
	print	string_usb_info_5, 10, 90
	jq	usb_not_available.wait

select_valid_partition:
	call	view_usb_partitions
.get_partition:
	call	util_get_key
	cp	a,ti.skClear
	jp	z,usb_exit_full
	cp	a,ti.skMode
	jp	z,usb_settings_show
	cp	a,ti.skUp
	jq	z,usb_partition_move_up
	cp	a,ti.skDown
	jq	z,usb_partition_move_down
	cp	a,ti.sk2nd
	jr	z,.selected_partition
	cp	a,ti.skEnter
	jr	z,.selected_partition
	jr	.get_partition
.selected_partition:
	ld	a,0
usb_selection := $ - 1
.got_partition:
	or	a,a
	sbc	hl,hl
	ld	l,a
	push	hl
	ld	bc,usb_fat_partitions
	push	bc
	call	lib_fat_Select				; select the desired partition
	ld	iy,ti.flags
	pop	bc
	pop	bc
	call	lib_fat_Init				; attempt to initialize the filesystem
	ld	iy,ti.flags
	or	a,a
	jr	z,.fat_init_completed

	push	af					; check for an error during initialization
	call	usb_invalid_gui
	print	string_fat_init_error_0, 10, 30
	print	string_fat_init_error_1, 10, 50
	pop	af
	or	a,a
	sbc	hl,hl
	ld	l,a
	call	lcd_num_3
	jq	usb_not_available.wait

.fat_init_completed:
	ld	a,screen_usb
	ld	(current_screen),a
	call	usb_get_directory_listing		; start with root directory
	jp	main_start

usb_detach:						; detach the fat library hooks
	call	lib_fat_Deinit
	ld	iy,ti.flags
	call	lib_msd_Deinit
	ld	iy,ti.flags
	call	libload_unload
	jp	main_find

usb_partition_move_up:
	ld	hl,select_valid_partition
	push	hl
	ld	a,(usb_selection)
	or	a,a					; limit items per screen
	ret	z
	dec	a
	ld	(usb_selection),a
	ret

usb_partition_move_down:
	ld	hl,select_valid_partition
	push	hl
	ld	a,(number_of_items)
	ld	b,a
	dec	b
	ld	a,(usb_selection)
	cp	a,b					; limit items per screen
	ret	z
	inc	a
	ld	(usb_selection),a
	ret

usb_get_directory_listing:
	ld	bc,0
	push	bc
	ld	b,$04					; allow for maximum of 1024 entries per directory
	push	bc
	ld	bc,item_location_base
	push	bc
	ld	bc,usb_fat_path				; path
	push	bc
	call	lib_fat_DirList
	ld	iy,ti.flags
	ld	(number_of_items),hl			; number of items in directory
	pop	bc
	pop	bc
	pop	bc
	pop	bc
	ret

usb_show_path:
	ld	hl,usb_fat_path
	jp	gui_show_description

usb_exit_full:
	call	lib_msd_Deinit
	ld	iy,ti.flags
	call	libload_unload
	jp	exit_full

usb_settings_show:
	xor	a,a
	ld	(usb_selection),a
	call	lib_msd_Deinit
	ld	iy,ti.flags
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
	jq	usb_not_available.wait

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

usb_check_directory:
	push	bc
	push	hl
	ld	bc,13
	add	hl,bc
	ld	a,(hl)
	tst	a,16
	pop	hl
	pop	bc
	ret

; move to the previous directory in the path
usb_directory_previous:
	ld	hl,usb_fat_path
.find_end:
	ld	a,(hl)
	or	a,a
	jr	z,.find_prev
	inc	hl
	jr	.find_end
.find_prev:
	ld	a,(hl)
	cp	a,'/'
	jr	z,.found_prev
	dec	hl
	jr	.find_prev
.found_prev:
	xor	a,a
	ld	(hl),a
	ld	de,usb_fat_path
	compare_hl_de
	ret	nz
	inc	hl
	ld	(hl),a
	dec	hl
	ld	a,'/'
	ld	(hl),a			; prevent root from being overwritten
	ret

usb_sector:
	rb	512

usb_msdenv:
	rb	14

usb_fat_partitions:
	rb	80

usb_fat_path:
	rb	312		; current path in fat filesystem
