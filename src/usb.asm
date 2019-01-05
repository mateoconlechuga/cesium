; routines for accessing flash drive data on usb

usb_init:
	xor	a,a
	ld	(current_selection),a
	ld	(usb_path),a

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
	pop	bc
	ld	bc,300					; 200 milliseconds for timeout
	push	bc
	call	lib_msd_Init
	pop	bc
	or	a,a
	jq	nz,usb_not_detected			; if failed to init, exit
	ld	bc,usb_sector
	push	bc
	call	lib_fat_SetBuffer			; set the buffer used for reading sectors
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
	jq	z,partition_move_up
	cp	a,ti.skDown
	jq	z,partition_move_down
	cp	a,ti.sk2nd
	jr	z,.selected_partition
	cp	a,ti.skEnter
	jr	z,.selected_partition
	jr	.get_partition
.selected_partition:
	ld	a,(current_selection)
.got_partition:
	or	a,a
	sbc	hl,hl
	ld	l,a
	push	hl
	ld	bc,usb_fat_partitions
	push	bc
	call	lib_fat_Select				; select the desired partition
	pop	bc
	pop	bc
	call	lib_fat_Init				; attempt to initialize the filesystem
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
	call	usb_get_directory_listing		; start with root directory

	call	view_usb_directory

	call	util_get_key				; now we can parse the files \o/

	call	lib_fat_Deinit
	call	lib_msd_Deinit
	ld	iy,ti.flags
	call	libload_unload
	jp	main_find

view_usb_directory:
	call	gui_draw_core
	ld	hl,(number_of_items)
	call	gui_show_item_count.show
	set_normal_text
	jp	lcd_blit

partition_move_up:
	ld	hl,select_valid_partition
	push	hl
	ld	a,(current_selection)
	or	a,a					; limit items per screen
	ret	z
	dec	a
	ld	(current_selection),a
	ret

partition_move_down:
	ld	hl,select_valid_partition
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

usb_get_directory_listing:
	ld	bc,0
	push	bc
	ld	b,$04					; allow for maximum of 1024 entries per directory
	push	bc
	ld	bc,usb_fat_entrys
	push	bc
	ld	bc,0
	push	bc
	call	lib_fat_DirList
	ld	iy,ti.flags
	ld	(number_of_items),hl			; number of items in directory
	pop	bc
	pop	bc
	pop	bc
	pop	bc
	ret

usb_exit_full:
	call	lib_msd_Deinit
	ld	iy,ti.flags
	call	libload_unload
	jp	exit_full

usb_settings_show:
	xor	a,a
	ld	(current_selection),a
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

usb_sector:
	rb	512

usb_msdenv:
	rb	14

usb_fat_partitions:
	rb	80

usb_fat_entrys:
	rb	1024		; location for storing directory information

usb_path:
	rb	256

