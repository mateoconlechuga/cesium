; routines for building lists of available programs and applications

find_files:
	call	ti.DeleteTempPrograms
	call	ti.CleanAll
	call	find_lists
	ld	hl,(item_locations_ptr)
	ld	de,item_location_base
	or	a,a
	sbc	hl,de
	srl	h
	rr	l
	srl	h
	rr	l
	ld	(number_of_items),hl		; divide by 4 to compute number of stored items
	ld	hl,return_info
	ld	a,(hl)
	ld	(hl),0
	cp	a,return_prgm
	jr	z,.restore_selection
	cp	a,return_edit
	jr	z,.restore_selection
	cp	a,return_goto
	ret	nz
.restore_selection:
	ld	hl,backup_prgm_name + 1
	jp	search_name

find_lists:
	call	.reset
	call	find_check_apps
	ld	a,(current_screen)
	cp	a,screen_apps
	jp	z,find_apps
	call	sort_vat			; sort the vat before trying anything
	ld	a,(current_screen)
	cp	a,screen_programs
	jp	z,find_programs
	cp	a,screen_appvars
	jp	z,find_appvars
	jp	exit_full			; abort
.reset:
	ld	hl,item_location_base
	ld	(item_locations_ptr),hl
	xor	a,a
	sbc	hl,hl
	ld	(number_of_items),hl
.reset_selection:
	ld	a,(return_info)
	cp	a,return_settings
	jr	z,.reset_offset
	xor	a,a
	sbc	hl,hl
	ld	(current_selection),a
	ld	(scroll_amount),hl
	ld	(current_selection_absolute),hl
	ret
.reset_offset:
	xor	a,a
	ld	(return_info),a
	ret

find_appvars:
	call	find_app_directory
	ld	hl,(ti.progPtr)
.loop:
	ld	de,(ti.pTemp)			; check to see if at end of symbol table
	or	a,a
	sbc	hl,de
	ret	z
	ret	c
	add	hl,de				; restore hl
	ld	a,(hl)				; check the [t] of entry, take appropriate action
	ld	de,6
	or	a,a
	sbc	hl,de
	and	a,$1f				; bitmask off bits 7-5 to get type only.
	cp	a,ti.AppVarObj			; check if appvar
	jr	nz,.skip
	ex	de,hl
	ld	hl,(item_locations_ptr)
	ld	(hl),de
	inc	hl
	inc	hl
	inc	hl
	ld	(hl),file_appvar
	inc	hl				; 4 bytes per entry - pointer to name + dummy
	ld	(item_locations_ptr),hl
	ex	de,hl
	ld	de,0
.skip:
	ld	e,(hl)				; e = name length
	inc	e				; add 1 to go to [t] of next entry
	or	a,a
	sbc	hl,de
	jr	.loop

find_programs:
	call	find_app_directory
	call	find_usb_directory
	ld	hl,(ti.progPtr)
.loop:
	ld	de,(ti.pTemp)			; check to see if at end of symbol table
	or	a,a
	sbc	hl,de
	ret	z
	ret	c
	add	hl,de				; restore hl
	ld	a,(hl)				; check the [t] of entry, take appropriate action
	and	a,$1f				; bitmask off bits 7-5 to get type only.
	cp	a,ti.ProgObj			; check if program
	jr	z,.normal_program
	cp	a,ti.ProtProgObj			; check if protected progrm
	jp	nz,.skip_program
.normal_program:				; at this point, hl -> [t], so we'll move back six bytes to [nl]
	dec	hl
	bit	cesium_is_disabled,(iy + cesium_flag)
	jr	z,.no_disable_check
	ld	a,(hl)
	inc	hl
	or	a,a
	jr	nz,.skip_program
	dec	hl
.no_disable_check:
	dec	hl
	dec	hl				; hl -> [dal]
	ld	e,(hl)
	dec	hl
	ld	d,(hl)
	dec	hl
	ld	a,(hl)
	call	ti.SetDEUToA
	dec	hl
	push	hl
	call	find_data_ptr
	inc	hl
	inc	hl
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
	ld	(.file_type),a
	pop	hl
	dec	hl
	ld	a,(hl)
	cp	a,'!'				; system variable
	jp	z,.not_valid
	cp	a,'#'				; system variable
	jr	z,.not_valid
	cp	a,27				; hidden?
	jr	nc,.not_hidden
	add	a,64				; i honestly have no idea why this has to be here, but it does
.not_hidden:
	inc	hl
	ex	de,hl
	ld	hl,0
item_locations_ptr := $-3			; this is the location to store the pointers to vat entry
	ld	(hl),de
	inc	hl
	inc	hl
	inc	hl
.file_type := $+1
	ld	(hl),0
	inc	hl				; 4 bytes per entry - pointer to name + type of program
	ld	(item_locations_ptr),hl
	ex	de,hl
	ld	de,0
	jr	.skip_name
.not_valid:
	ld	de,0
	inc	hl
	jr	.skip_name
.skip_program:					; skip an entry
	ld	de,6
	or	a,a
	sbc	hl,de
.skip_name:
	ld	e,(hl)				; put name length in e to skip
	inc	e				; add 1 to go to [t] of next entry
	sbc	hl,de
	jp	.loop

find_app_directory:
	bit	setting_special_directories,(iy + settings_flag)
	ret	z
	ld	hl,(item_locations_ptr)
	ld	de,find_application_directory_name
	ld	(hl),de
	inc	hl
	inc	hl
	inc	hl
	ld	(hl),byte_dir
	inc	hl
	ld	(item_locations_ptr),hl
	ret

find_usb_directory:
	bit	setting_enable_usb,(iy + settings_flag)
	ret	z
	ld	hl,(item_locations_ptr)
	ld	de,find_usb_directory_name
	ld	(hl),de
	inc	hl
	inc	hl
	inc	hl
	ld	(hl),byte_usb_dir
	inc	hl
	ld	(item_locations_ptr),hl
	ret

find_apps:
	ld	hl,(item_locations_ptr)
	ld	de,find_program_directory_name
	ld	(hl),de
	inc	hl
	inc	hl
	inc	hl
	inc	hl
	ld	de,find_appvars_directory_name
	ld	(hl),de
	inc	hl
	inc	hl
	inc	hl
	inc	hl
	ld	(item_locations_ptr),hl
	call	ti.ZeroOP3
	ld	a,ti.AppObj
	ld	(ti.OP3),a
.loop:
	call	ti.OP3ToOP1
	call	ti.FindAppUp
	push	hl
	push	de
	call	ti.OP1ToOP3
	pop	hl
	pop	de
	ret	c
	ld	bc,$100				; bypass some header info
	add	hl,bc
	ex	de,hl
	ld	hl,(item_locations_ptr)
	ld	(hl),de
	inc	hl
	inc	hl
	inc	hl
	inc	hl
	ld	(item_locations_ptr),hl
	jr	.loop

find_data_ptr:				; gets a pointer to the data of an archived program
	cp	a,$d0
	ex 	de,hl
	ret	nc
	ld	de,9
	add	hl,de				; skip vat entry
	ld	e,(hl)
	add	hl,de
	inc	hl				; size of name
	ret

find_check_apps:
	res	cesium_is_disabled,(iy + cesium_flag)
	res	cesium_is_nl_disabled,(iy + cesium_flag)
	ld	de,$c00
	call	$310
	ret	nz
	call	$30c
	ld	a,(hl)
	or	a,a
	ret	z
	set	cesium_is_disabled,(iy + cesium_flag)
	inc	hl
	ld	a,(hl)
	tst	a,4
	jr	nz,.skip
	res	setting_special_directories,(iy + settings_flag)
	ret
.skip:
	set	cesium_is_nl_disabled,(iy + cesium_flag)
	pop	hl
	ret

; program metadata directories
	db	"evirD hsalF BSU"
find_usb_directory_name:
	db	15
.ptr:
	dl	.ptr bswap 3
	db	0,0,$ff

	db	"sppA"
find_application_directory_name:
	db	4
.ptr:
	dl	.ptr bswap 3
	db	0,0,$ff
find_program_directory_name:
	db	0,0,0,"All Programs",0
.ptr:
	dl	.ptr bswap 3
	db	0,0,4
; application metadata directories
find_appvars_directory_name:
	db	0,0,0,"AppVars",0
.ptr:
	dl	.ptr bswap 3
	db	0,0,4

