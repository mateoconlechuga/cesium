; Copyright 2015-2020 Matt "MateoConLechuga" Waltz
; 
; Redistribution and use in source and binary forms, with or without
; modification, are permitted provided that the following conditions are met:
; 
; 1. Redistributions of source code must retain the above copyright notice,
;    this list of conditions and the following disclaimer.
; 
; 2. Redistributions in binary form must reproduce the above copyright notice,
;    this list of conditions and the following disclaimer in the documentation
;    and/or other materials provided with the distribution.
; 
; 3. Neither the name of the copyright holder nor the names of its contributors
;    may be used to endorse or promote products derived from this software
;    without specific prior written permission.
; 
; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
; AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
; IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
; ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
; LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
; CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
; SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
; INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
; CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
; ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
; POSSIBILITY OF SUCH DAMAGE.

; routines for accessing flash drive data on usb

usb_device_ptr:
	dl	0
usb_device_valid:
	db	0
msd_sector_buffer:
	rb	512
msd_struct:
	rb	30
fat_struct:
	rb	80
fat_partitions:
	rb	80
fat_file:
	dl	0
fat_path:
	rb	260		; current path in fat filesystem
fat_sector:
	rb	512

usb_handle_event:
	ld	iy,0
	add	iy,sp
	ld	a,(iy + 3)
	cp	a,4
	jq	nz,.notenabled
	ld	hl,(iy + 6)
	ld	(usb_device_ptr),hl
	ld	a,$ff
	ld	(usb_device_valid),a
.notenabled:
	cp	a,1
	jq	z,.invalidate
	cp	a,3
	jq	z,.invalidate
	xor	a,a
	sbc	hl,hl
	ld	iy,ti.flags
	ret
.invalidate:
	xor	a,a
	sbc	hl,hl
	ld	(usb_device_valid),a			; if a disconnect event, go home
	ld	iy,ti.flags
	ret

usb_init:
	xor	a,a
	sbc	hl,hl
	ld	(usb_device_valid),a
	ld	(usb_selection),a
	ld	(current_selection),a
	ld	(current_selection_absolute),hl
	ld	hl,fat_path
	ld	(hl),'/'			; root path = "/"
	inc	hl
	ld	(hl),a

	call	gui_draw_core
	ld	iy,ti.flags
	call	libload_load
	ld	iy,ti.flags
	jq	nz,usb_not_available.libload

	ld	bc,4
	push	bc
	ld	c,0
	push	bc
	push	bc
	ld	bc,usb_handle_event
	push	bc
	call	lib_usb_Init
	ld	iy,ti.flags
	pop	bc,bc,bc,bc
	ld	a,l
	or	a,a
	jq	nz,usb_not_available			; probably not the right thing to go to

	call	usb_wait_gui
	call	util_setup_apd

.notyetvalid:
	call	lib_usb_WaitForInterrupt
	ld	a,l
	or	a,a
	jq	nz,usb_detach				; if error, detach

	call	util_get_key_nonblocking
	cp	a,ti.skClear
	jq	z,usb_detach

	ld	a,(usb_device_valid)
	or	a,a
	jq	z,.notyetvalid

	ld	bc,msd_sector_buffer
	push	bc
	ld	bc,(usb_device_ptr)
	push	bc
	ld	bc,msd_struct
	push	bc
	call	lib_msd_Init
	ld	iy,ti.flags
	pop	bc,bc,bc
	ld	a,l
	or	a,a
	jq	nz,usb_invaliddevice

.initedmsd:
	ld	bc,8			; gets up to 8 available partitions on the device
	push	bc
	ld	bc,fat_partition_num
	push	bc
	ld	bc,fat_partitions
	push	bc
	ld	bc,msd_struct
	push	bc
	call	lib_fat_Find
	ld	iy,ti.flags
	pop	bc,bc,bc,bc
	ld	a,0
fat_partition_num := $-1
	or	a,a
	jq	z,usb_invaliddevice
	sbc	hl,hl
	ld	l,a
	ld	(number_of_items),hl
	dec	a
	jr	nz,select_valid_partition		; if there's only one partion, select it
	jr	select_valid_partition.selected_partition

select_valid_partition:
	call	view_usb_partitions
.get_partition:
	call	util_get_key
	cp	a,ti.skClear
	jp	z,usb_detach
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
	xor	a,a
	sbc	hl,hl
	ld	l,0
usb_selection := $ - 1
	ld	h,7					; partition structure is 7 bytes
	mlt	hl
	ld	bc,fat_partitions
	add	hl,bc
	push	hl
	ld	bc,fat_struct
	push	bc
	call	lib_fat_Init
	pop	bc,bc
	compare_hl_zero
	jr	z,.fat_init_completed

	push	af					; check for an error during initialization
	set_normal_text
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
	call	fat_get_directory_listing		; start with root directory
	jp	main_start

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
fat_get_directory_listing:
	xor	a,a
	sbc	hl,hl
        ld      (number_of_items),hl

	ld	a,(fat_path + 1)
	or	a,a
	jr	nz,.notroot				; if at root show exit directory

.notroot:
	ld	bc,0					; don't skip any
	push	bc
	ld	b,2					; allow for maximum of 512 directories
	push	bc
	ld	bc,item_location_base			; place to store
	push	bc
	ld	bc,1					; get directories first
	push	bc
	ld	bc,fat_path				; path
	push	bc
	ld	bc,fat_struct				; global fat state
	push	bc
	call	lib_fat_DirList
	ld	iy,ti.flags
	pop	bc,bc,bc,bc,bc,bc
	inc	hl
	compare_hl_zero
	dec	hl
	jq	z,.error
	ld	(number_of_items),hl
	ld	bc,18					; each entry is 18 bytes
	call	ti._imulu
	ld	de,item_location_base
	add	hl,de
.find_files:
	ld	bc,0					; don't skip any
	push	bc
	ld	b,3					; allow for maximum of 768 files
	push	bc
	push	hl
	ld	c,0					; get files
	push	bc
	ld	bc,fat_path				; path
	push	bc
	ld	bc,fat_struct				; global fat state
	push	bc
	call	lib_fat_DirList
	ld	iy,ti.flags
	pop	bc,bc,bc,bc,bc,bc
	inc	hl
	compare_hl_zero
	dec	hl
	jq	z,.error
	ld	bc,(number_of_items)
	add	hl,bc
	ld	(number_of_items),hl			; number of items in directory
	ret
.error:
	xor	a,a
	sbc	hl,hl
	ld	(number_of_items),hl			; just do this...
	ret

usb_show_path:
	ld	hl,fat_path
	jp	gui_show_description

usb_settings_show:
	xor	a,a
	ld	(usb_selection),a
	call	lib_usb_Cleanup
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
        ld	de,sprite_file_ti
	ld	hl,string_ti
	pop	af
	ret
.tiappvar:
	ld	de,sprite_file_appvar
	ld	hl,string_appvar
	pop	af
	ret

usb_detach_only:
	call	lib_usb_Cleanup
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
	bit	setting_special_directories,(iy + settings_adv_flag)
	jr	z,.no_apps_dir
	inc	hl
.no_apps_dir:
	ld	(current_selection_absolute),hl
	ld	a,l
	ld	(current_selection),a
	jp	main_find

usb_wait_gui:
	set_normal_text
	print	string_usb_waiting, 10, 30
	print	string_insert_fat32, 10, 50
	print	string_usb_info_6, 10, 90
	ret

usb_invaliddevice:
	call	gui_draw_core
	call	usb_detach_only
	set_normal_text
	print	string_usb_no_partitions, 10, 30
	print	string_insert_fat32, 10, 50
	print	string_usb_info_5, 10, 90
	jq	usb_not_available.wait

usb_not_available:
	call	usb_detach_only
.libload:
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
	call	util_get_key
	cp	a,ti.skEnter
	jp	z,usb_init
	cp	a,ti.sk2nd
	jp	z,usb_init
	jp	usb_detach.home

usb_check_directory:
	push	bc,hl
	ld	bc,13
	add	hl,bc
	bit	4,(hl)
	pop	hl,bc
	ret

; get the size from the entry
usb_get_file_size:
	ld	iy,(item_ptr)
	ld	hl,(iy + 14)		; only gets the low bytes...
	ld	iy,ti.flags
	ret

; move to the previous directory in the path
usb_directory_previous:
	ld	b,'/'
	ld	hl,fat_path
.find_end:
	ld	a,(hl)
	or	a,a
	jr	z,.find_prev
	inc	hl
	jr	.find_end
.find_prev:
	ld	a,(hl)
	cp	a,b
	jr	z,.found_prev
	dec	hl
	jr	.find_prev
.found_prev:
	xor	a,a
	ld	(hl),a
	ld	hl,fat_path
	ld	a,(hl)
	cp	a,b
	ret	z
	ld	(hl),b
	inc	hl
	ld	(hl),0
	ret

usb_append_fat_path:
	ld	de,fat_path
	ld	a,(fat_path + 1)
	or	a,a
	jr	z,.current_end			; append directory to path
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

fat_file_transfer_from_device:
	ld	a,(current_screen)
	cp	a,screen_usb
	jq	nz,main_loop
	bit	item_is_ti,(iy + item_flag)
	jq	z,main_loop

	call	gui_fat_transfer

	call	usb_open_tivar
	jq	nz,main_loop

	call	ti.PushOP1
	call	ti.ChkFindSym
	call	nc,ti.DelVarArc
	call	ti.PopOP1
	ld	hl,0
fat_file_size := $-3
	call	util_check_free_ram
	jp	c,main_start

	call	usb_validate_tivar
	jp	nz,main_start

	ld	a,(ti.OP1)
	call	ti.CreateVar			; create the variable in ram

	; now we need to do the fun part of copying the data into the variable
	; the first and last sectors are annoying so be lazy

	ld	a,(fat_sector + 69)
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

; performs check on first sector of tivar to make sure
; that is actually looks somewhat okay before transfer
usb_validate_tivar:
	ld	a,(fat_sector)			; yeah that's good enough
	cp	a,$2a
	ret

usb_open_tivar:
	ld	hl,(item_ptr)
.entry:
	call	usb_append_fat_path
	ld	bc,1
	push	bc
	ld	bc,fat_path			; open the file for reading
	push	bc
	ld	bc,fat_struct
	push	bc
	call	lib_fat_Open
	ld	iy,ti.flags
	pop	bc,bc,bc
	ld	(fat_file),hl
	compare_hl_zero
	jq	z,.error
	call	usb_directory_previous
	call	fat_file_read_sector		; read the first sector to get the size information
	jq	nz,.error
	ld	hl,fat_sector + 70		; size of variable to create
	ld	de,0
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ld	(fat_file_size),de
	ld	hl,fat_sector + 59		; name / type of variable
	call	ti.Mov9ToOP1
	xor	a,a
	ret
.error:
	xor	a,a
	inc	a
	ret

fat_file_read_sector:
	push	de
	ld	bc,fat_sector
	push	bc
	ld	bc,(fat_file)
	push	bc
	call	lib_fat_ReadSector
	ld	iy,ti.flags
	pop	bc,bc
	pop	de
	ld	a,l
	or	a,a
	ret

; de -> destination
; fat_file_size = size
; fat_file = file descriptor
; must have read first sector of variable by this point
usb_copy_tivar_to_ram:
	ld	ix,76 - 1
	ld	hl,fat_sector + 76
	jr	usb_copy_tivar.entry
usb_copy_tivar:
	ld	ix,72 - 1
	ld	hl,fat_sector + 72
.entry:
	ld	bc,(fat_file_size)
.not_done:
	push	bc
	inc	ix
	ld	a,ixh
	cp	a,2				; every 512 bytes read a sector
	jr	nz,.no_read
	call	fat_file_read_sector
	jq	nz,.error
	ld	ix,0
	ld	hl,fat_sector
.no_read:
	pop	bc
	ldi
	jq	pe,.not_done
	jq	fat_file_close
.error:
	call	ti.PushOP1
	call	ti.OP4ToOP1
	call	ti.ChkFindSym
	call	nc,ti.DelVarArc
	call	ti.PopOP1
	call	ti.OP1ToOP4
	ret

fat_file_close:
	ld	bc,(fat_file)
	push	bc
	call	lib_fat_Close
	ld	iy,ti.flags
	pop	bc
	ret

fat_file_delete:
	ld	hl,(item_ptr)
	call	usb_append_fat_path
	ld	bc,fat_path
	push	bc
	ld	bc,fat_struct
	push	bc
	call	lib_fat_Delete
	ld	iy,ti.flags
	pop	bc,bc
	call	usb_directory_previous
	ld	hl,(current_selection_absolute)
	ld	de,(number_of_items)
	inc	hl
	compare_hl_de
	call	nc,main_move_up
	ld	a,return_settings
	ld	(return_info),a
	call	fat_get_directory_listing
	jq	main_start
