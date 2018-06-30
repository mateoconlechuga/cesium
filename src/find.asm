; routines for building lists of available programs and applications

find_programs_or_apps:
	call	.reset_lists
	call	.check_apps
	ld	a,(current_screen)
	cp	a,screen_apps
	jp	z,.find_apps
	call	sort_vat			; sort the vat before trying anything
	;jp	.find_programs

.find_programs:
	bit	setting_special_directories,(iy + settings_flag)
	jr	z,.no_apps_directory
	ld	hl,(item_locations_ptr)
	ld	de,find_application_directory_name
	ld	(hl),de
	inc	hl
	inc	hl
	inc	hl
	inc	hl
	ld	(item_locations_ptr),hl
	ld	bc,1
	ld	(number_of_items),bc
.no_apps_directory:
	ld	hl,(progptr)
.find_programs_loop:
	ld	de,(ptemp)			; check to see if at end of symbol table
	or	a,a
	sbc	hl,de
	ret	z
	ret	c
	add	hl,de				; restore hl
	ld	a,(hl)				; check the [t] of entry, take appropriate action
	and	a,$1f				; bitmask off bits 7-5 to get type only.
	cp	a,progObj			; check if program
	jr	z,.normal_program
	cp	a,protProgObj			; check if protected progrm
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
	call	_SetDEUToA
	dec	hl
	push	hl
	call	.get_program_data_ptr
	inc	hl
	inc	hl
	ld	a,(hl)
	cp	a,tExtTok			; is it an assembly program
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
	cp	a,tAsm84CECmp
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
	ld	bc,0
number_of_items := $-3
	inc	bc
	ld	(number_of_items),bc		; increase the number of programs found
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
	jp	.find_programs_loop

.find_apps:
	ld	hl,(item_locations_ptr)
	ld	de,find_program_directory_name
	ld	(hl),de
	inc	hl
	inc	hl
	inc	hl
	ld	(item_locations_ptr),hl
	ld	hl,number_of_items
	ld	de,(hl)
	inc	de
	ld	(hl),de
	call	_ZeroOP3
	ld	a,appObj
	ld	(OP3),a
.find_appsLoop:
	call	_OP3ToOP1
	call	_FindAppUp
	push	hl
	push	de
	call	_OP1ToOP3
	pop	hl
	pop	de
	ret	c
	ld	bc,(number_of_items)
	inc	bc
	ld	(number_of_items),bc
	ld	bc,$100				; bypass some header info
	add	hl,bc
	ex	de,hl
	ld	hl,(item_locations_ptr)
	ld	(hl),de
	inc	hl
	inc	hl
	inc	hl
	ld	(item_locations_ptr),hl
	jr	.find_appsLoop

.get_program_data_ptr:				; gets a pointer to the data of an archived program
	cp	a,$d0
	ex 	de,hl
	ret	nc
	ld	de,9
	add	hl,de				; skip vat entry
	ld	e,(hl)
	add	hl,de
	inc	hl				; size of name
	ret

.check_apps:
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

.reset_lists:
	ld	hl,item_location_base
	ld	(item_locations_ptr),hl
	xor	a,a
	sbc	hl,hl
	ld	(number_of_items),hl
	ret

	db	"SPPA"
find_application_directory_name:
	db	4
find_directory_ptr:
	dl	0
	db	0,0,5
find_program_directory_name:
	db	0,0,0,"Programs",0
