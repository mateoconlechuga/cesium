; routines for accessing flash drive data on usb

usb_init:
	xor	a,a
	sbc	hl,hl
	ld	(usb_selection),a
	ld	(current_selection),a
	ld	(current_selection_absolute),hl
	ld	(usb_fat_path),a			; root path = "/"

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

; organizes directories first then files
usb_get_directory_listing:
	ld	bc,0					; get directories first
	push	bc
	ld	b,2					; allow for maximum of 512 directories
	push	bc
	ld	bc,1					; FAT_DIR
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
	pop	bc
	push	hl
	pop	de
	compare_hl_zero
	jr	z,.no_directories
	ld	hl,item_location_base
	ld	bc,16
.get_offset:						; move past directory entries
	add	hl,bc					; sure, this could be better but I'm lazy
	dec	de
	ld	a,e
	cp	a,d
	jr	nz,.get_offset
.no_directories:
	ld	bc,0					; now get files in directory
	push	bc
	ld	b,3					; allow for maximum of 512 directories
	push	bc
	ld	b,0
	push	bc
	push	hl					; offset past directories
	ld	bc,usb_fat_path				; path
	push	bc
	call	lib_fat_DirList
	ld	iy,ti.flags
	ld	bc,(number_of_items)
	add	hl,bc
	ld	(number_of_items),hl			; number of items in directory
	pop	bc
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

; returns the corresponding string
usb_check_extensions:
	push	af
	ld	de,sprite_file_unknown
	ld	bc,string_unknown
	ld	hl,(usb_filename_ptr)		; move to the extension
.get_extension:
	ld	a,(hl)
	or	a,a
	jr	z,.unknown
	cp	a,'.'
	jr	z,.found_extension
	inc	hl
	jr	.get_extension
.found_extension:
	inc	hl
	ld	a,(hl)
	cp	a,'8'
	jr	nz,.unknown
	inc	hl
	ld	a,(hl)
	cp	a,'x'
	jr	z,.tios
	cp	a,'X'
	jr	z,.tios
.unknown:
	push	bc
	pop	hl
	pop	af
	ret
.tios:
	ld	de,sprite_file_ti
	ld	hl,string_ti
	pop	af
	ret

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

; unfortunately the file must be opened...
usb_get_file_size:
	ld	hl,(item_ptr)
	call	usb_check_directory
	jr	nz,.directory
	call	usb_append_fat_path
	ld	bc,1
	push	bc
	ld	bc,usb_fat_path
	push	bc
	call	lib_fat_Open
	pop	bc
	pop	bc				; just assume this succeeds
	or	a,a
	sbc	hl,hl
	ld	l,a
	push	hl
	push	hl
	call	lib_fat_GetFileSize
	pop	bc
	pop	bc
	push	hl
	push	bc
	call	lib_fat_Close
	pop	bc
	call	usb_directory_previous
	pop	hl
	ret
.directory:
	or	a,a
	sbc	hl,hl
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
	ld	(hl),a				; prevent root from being overwritten
	ret

usb_append_fat_path:
	ld	de,usb_fat_path			; append directory to path
.append_loop:
	ld	a,(de)
	or	a,a
	jr	z,.current_end
	inc	de
	jr	.append_loop
.current_end:
	ld	a,'/'
	ld	(de),a
	inc	de
.append_dir_loop:
	ld	a,(hl)
	ld	(de),a
	or	a,a
	ret	z
	inc	de
	inc	hl
	jr	.append_dir_loop

usb_fat_transfer:
	ld	a,(current_screen)
	cp	a,screen_usb
	jp	nz,main_loop
	call	gui_fat_transfer
	ld	bc,150
.delay:
	push	bc
	call	ti.Delay10ms
	pop	bc
	dec	bc
	ld	a,c
	or	a,b
	jr	nz,.delay
	jp	main_start

usb_sector:
	rb	512

usb_msdenv:
	rb	14

usb_fat_partitions:
	rb	80

usb_fat_path:
	rb	260		; current path in fat filesystem
