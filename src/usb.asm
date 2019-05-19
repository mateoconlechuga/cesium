; routines for accessing flash drive data on usb

usb_init:
	xor	a,a
	sbc	hl,hl
	ld	(usb_selection),a
	ld	(current_selection),a
	ld	(current_selection_absolute),hl
	ld	(usb_fat_path),a			; root path = "/"

	call	gui_draw_core
	ld	iy,ti.flags
	call	libload_load
	ld	iy,ti.flags
	jq	nz,usb_not_available

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
	ld	bc,5000					; 500 milliseconds for timeout
	push	bc
	call	lib_msd_Init
	ld	iy,ti.flags
	pop	bc
	or	a,a
	jq	nz,usb_not_detected			; if failed to init, retry a few times...

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

usb_detach_only:
	call	lib_fat_Deinit
	ld	iy,ti.flags
	call	lib_msd_Deinit
	ld	iy,ti.flags
	call	libload_unload
	ld	iy,ti.flags
	ret

usb_detach:						; detach the fat library hooks
	call	usb_detach_only
.home:
	ld	a,screen_programs
	ld	(current_screen),a
	ld	a,return_settings
	ld	(return_info),a
	or	a,a
	sbc	hl,hl
	ld	(scroll_amount),hl
	bit	setting_special_directories,(iy + settings_flag)
	jr	z,.no_apps_dir
	inc	hl
.no_apps_dir:
	ld	(current_selection_absolute),hl
	ld	a,l
	ld	(current_selection),a
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
	ld	a,(usb_fat_path)
	or	a,a
	jr	nz,.not_root				; if at root show exit directory

.not_root:
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
	ld	hl,item_location_base
	jr	z,.no_directories
	ld	bc,16
.get_offset:						; move past directory entries
	add	hl,bc					; sure, this could be better but I'm lazy
	dec	de
	ld	a,e
	cp	a,d
	jr	nz,.get_offset
	jr	.find_files
.no_directories:
	ld	a,(usb_fat_path)
	or	a,a
	jp	nz,usb_detach				; if there are no directories but our path isn't root, the filesystem must be broken
.find_files:
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

usb_get_tiprgm_info:
	ld	hl,(usb_filename_ptr)
	call	usb_open_tivar.entry
	call	usb_close_file

	; attempt to read language from 8xp
	; also read sprite if possible

	ld	hl,usb_sector + 74
	ld	a,(hl)
	cp	a,ti.tExtTok			; is it an assembly program
	jr	z,.check_if_is_asm
.program_is_basic:
	cp	a,byte_ice_source		; actually it is ice source
	ld	a,file_ice_source
	jr	z,.store_program_type
	ld	a,file_basic
	jr	.store_program_type
.check_if_is_asm:
	inc	hl
	ld	a,(hl)
	cp	a,ti.tAsm84CeCmp
	jr	nz,.program_is_basic		; is it a basic program
	inc	hl
	ld	a,(hl)
	cp	a,byte_ice
	ld	a,file_ice
	jr	z,.store_program_type		; is it an ice program
	ld	a,(hl)
	cp	a,byte_c
	ld	a,file_c
	jr	z,.store_program_type
	ld	a,file_asm			; default to assembly program
.store_program_type:
	ld	hl,string_asm
	ld	de,sprite_file_asm
	cp	a,file_asm
	jr	z,.file_uneditable
	ld	hl,string_c
	ld	de,sprite_file_c
	cp	a,file_c
	jr	z,.file_uneditable
	ld	hl,string_ice
	ld	de,sprite_file_ice
	cp	a,file_ice
	jr	z,.file_uneditable
	ld	hl,string_ice_source
	cp	a,file_ice_source
	jp	z,.file_editable
	ld	hl,string_basic
	ld	de,sprite_file_basic

.file_editable:
	push	hl
	push	de
	ld	de,lut_basic_icon
	ld	b,6
	ld	hl,usb_sector + 74
.verify_icon:
	ld	a,(de)
	cp	a,(hl)
	inc	hl
	inc	de
	jr	nz,.no_custom_icon
	djnz	.verify_icon
	pop	de					; remove default icon
	ld	de,sprite_temp
	ld	a,16
	ld	(de),a
	inc	de
	ld	(de),a
	inc	de					; save the size of the sprite
	ld	b,0
.get_icon:						; okay, now loop 256 times to do the squish
	ld	a,(hl)
	sub	a,$30
	cp	a,$11
	jr	c,.no_overflow
	sub	a,$07
.no_overflow:						; rather than doing an actual routine, just do this
	push	hl
	ld	hl,lut_color_basic
	call	ti.AddHLAndA
	ld	a,(hl)
	pop	hl
	ld	(de),a
	inc	de
	inc	hl
	djnz	.get_icon				; collect all the values
	ld	hl,sprite_temp				; yay, a custom icon
	push	hl
.no_custom_icon:
	pop	de
	pop	hl
	ret

.file_uneditable:
	push	hl
	push	de
	ld	hl,usb_sector + 76
	ld	a,(hl)
	cp	a,byte_jp
	jr	z,.custom_icon
	inc	hl
	ld	a,(hl)
	cp	a,byte_jp
	jr	nz,.icon
.custom_icon:
	inc	hl
	inc	hl
	inc	hl
	inc	hl					; hl -> icon indicator byte, hopefully
	ld	a,(hl)
	cp	a,byte_icon				; cesium indicator byte
	jr	z,.valid_icon
.icon:
	pop	de					; de -> icon
	pop	hl					; hl -> language string
	ret
.valid_icon:
	pop	de					; pop the old icon
	inc	hl
	push	hl
	jr	.icon

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
	bit	drawing_selected,(iy + item_flag)
	jr	z,.not_current
	res	item_is_ti,(iy + item_flag)
	res	item_is_prgm,(iy + item_flag)
.not_current:
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
	bit	drawing_selected,(iy + item_flag)
	jr	z,.not_current_ti
	set	item_is_ti,(iy + item_flag)
.not_current_ti:
	inc	hl
	ld	a,(hl)
	cp	a,'P'
	jr	z,.tiprgm
	cp	a,'V'
	jr	z,.tiappvar
	cp	a,'p'
	jr	z,.tiprgm
	cp	a,'v'
	jr	z,.tiappvar
	ld	de,sprite_file_ti
	ld	hl,string_ti
	pop	af
	ret
.tiprgm:
	bit	drawing_selected,(iy + item_flag)
	jr	z,.not_current_prgm
	set	item_is_prgm,(iy + item_flag)
.not_current_prgm:
	call	usb_get_tiprgm_info
	pop	af
	ret
.tiappvar:
	ld	de,sprite_file_appvar
	ld	hl,string_appvar
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
	cp	a,ti.skEnter
	jp	z,usb_init
	cp	a,ti.sk2nd
	jp	z,usb_init
	jp	usb_detach.home

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
	ld	iy,ti.flags
	pop	bc
	pop	bc				; just assume this succeeds
	or	a,a
	sbc	hl,hl
	ld	l,a
	push	hl
	push	hl
	call	lib_fat_GetFileSize
	ld	iy,ti.flags
	pop	bc
	pop	bc
	push	hl
	push	bc
	call	lib_fat_Close
	ld	iy,ti.flags
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
	bit	item_is_ti,(iy + item_flag)
	jp	z,main_loop

	call	gui_fat_transfer

	call	usb_open_tivar
	call	ti.PushOP1
	call	ti.ChkFindSym
	call	nc,ti.DelVarArc
	call	ti.PopOP1
	ld	hl,0
usb_var_size := $-3
	call	util_check_free_ram
	jp	c,main_start

	call	usb_validate_tivar
	jp	nz,main_start

	ld	a,(ti.OP1)
	call	ti.CreateVar			; create the variable in ram

	; now we need to do the fun part of copying the data into the variable
	; the first and last sectors are annoying so be lazy

	ld	a,(usb_sector + 69)
	cp	a,$80				; check if archived
	push	af
	call	usb_copy_tivar
	call	ti.OP4ToOP1
	pop	af
	jr	nz,.notarchived
	call	ti.ChkFindSym
	call	cesium.Arc_Unarc
.notarchived:

	call	util_delay_one_second
	jp	main_start

usb_read_sector:
	push	de
	or	a,a
	sbc	hl,hl
	ld	l,0
usb_fat_fd := $-1
	push	hl
	call	lib_fat_ReadSector
	ld	iy,ti.flags
	pop	hl
	pop	de
	ret

; performs check on first sector of tivar to make sure
; that is actually looks somewhat okay before transfer
usb_validate_tivar:
	ld	a,(usb_sector)			; yeah that's good enough
	cp	a,$2a
	ret

usb_open_tivar:
	ld	hl,(item_ptr)
.entry:
	call	usb_append_fat_path
	ld	bc,1
	push	bc
	ld	bc,usb_fat_path			; open the file for reading
	push	bc
	call	lib_fat_Open
	ld	iy,ti.flags
	pop	bc
	pop	bc
	ld	(usb_fat_fd),a
	call	usb_directory_previous
	call	usb_read_sector			; read the first sector to get the size information
	ld	hl,usb_sector + 70		; size of variable to create
	ld	de,0
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ld	(usb_var_size),de
	ld	hl,usb_sector + 59		; name / type of variable
	jp	ti.Mov9ToOP1

; de -> destination
; usb_var_size = size
; usb_fat_fd = file descriptor
; must have read first sector of variable by this point
usb_copy_tivar_to_ram:
	ld	ix,76 - 1
	ld	hl,usb_sector + 76
	jr	usb_copy_tivar.entry
usb_copy_tivar:
	ld	ix,72 - 1
	ld	hl,usb_sector + 72
.entry:
	ld	bc,(usb_var_size)
.not_done:
	push	bc
	inc	ix
	ld	a,ixh
	cp	a,2				; every 512 bytes read a sector
	jr	nz,.no_read
	call	usb_read_sector
	ld	ix,0
	ld	hl,usb_sector
.no_read:
	pop	bc
	ldi
	jp	pe,.not_done

usb_close_file:
	ld	a,(usb_fat_fd)
	or	a,a
	sbc	hl,hl
	ld	l,a
	push	hl
	call	lib_fat_Close
	ld	iy,ti.flags
	pop	hl
	ret

usb_delete_file:
	ld	hl,(item_ptr)
	call	usb_append_fat_path
	ld	bc,usb_fat_path
	push	bc
	call	lib_fat_Delete
	ld	iy,ti.flags
	pop	bc
	call	usb_directory_previous
	ld	hl,(current_selection_absolute)
	ld	de,(number_of_items)
	inc	hl
	compare_hl_de
	jr	z,.move_up
	call	c,main_move_up
.return:
	ld	a,return_settings
	ld	(return_info),a
	call	usb_get_directory_listing
	jp	main_start
.move_up:
	call	main_move_up
	jr	.return

usb_sector:
	rb	512

usb_msdenv:
	rb	14

usb_fat_partitions:
	rb	80

usb_fat_path:
	rb	260		; current path in fat filesystem
