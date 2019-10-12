; routines for loading libload for using usbdrvce and fatdrvce libraries

; returns z if loaded, nz if not loaded
libload_load:
	call	libload_unload
	ld	de,lib_usb_Init		; initialize default usbdrvce jump locations
	ld	hl,lib_usbdrvce
	ld	bc,lib_usbdrvce.size
	ldir
	ld	de,lib_msd_Init		; initialize default fatdrvce jump locations
	ld	hl,lib_fatdrvce
	ld	bc,lib_fatdrvce.size
	ldir
	ld	a,$c0
	ld	(libload_libload),a
	ld	(libload_usbdrvce),a
	ld	(libload_fatdrvce),a	; reset loaded libraries that libload destroyed
	jq	.try
.inram:
	call	cesium.Arc_Unarc
.try:
	ld	hl,libload_name
	call	ti.Mov9ToOP1
	call	ti.ChkFindSym
	jr	c,.notfound
	call	ti.ChkInRam
	jr	z,.inram		; if in ram, archive LibLoad and search again
	ld	hl,9 + 3 + libload_name.len
	add	hl,de			; start of loader (required to be in hl)
	ld	a,(hl)
	cp	a,$1F			; ensure a valid libload version
	jr	c,.notfound
	dec	hl			; move to start of libload
	dec	hl
	ld	de,.relocations 	; start of relocation data
	ld	bc,.notfound
	push	bc
	ld	bc,$aa55aa		; tell libload to not show an error screen
	jp	(hl)			; jump to the loader -- it should take care of everything else
.notfound:
	call	lcd_init.setup
	xor	a,a
	inc	a
	ret

.relocations:

; default libload library
libload_libload:
	db	$c0,"LibLoad",0,31

; usbdrvce library functions
libload_usbdrvce:
	db	$c0,"USBDRVCE",0,0

lib_usb_Init:
	jp	0
lib_usb_Cleanup:
	jp	3
lib_usb_WaitForInterrupt:
	jp	12

; fatdrvce library functions
libload_fatdrvce:
	db	$c0,"FATDRVCE",0,0

lib_msd_Init:
	jp	0
lib_fat_Find:
	jp	15
lib_fat_Init:
	jp	18
lib_fat_DirList:
	jp	24
lib_fat_Open:
	jp	30
lib_fat_Close:
	jp	33
lib_fat_ReadSector:
	jp	54
lib_fat_WriteSector:
	jp	57
lib_fat_Delete:
	jp	63

	xor	a,a		; return z (loaded)
	pop	hl		; pop error return
	ret

lib_usbdrvce:
	jp	0
	jp	3
	jp	12
.size := $-lib_usbdrvce

lib_fatdrvce:
	jp	0
	jp	15
	jp	18
	jp	24
	jp	30
	jp	33
	jp	54
	jp	57
	jp	63
.size := $-lib_fatdrvce

; remove loaded libraries from usermem
libload_unload:
	jp	util_delete_prgm_from_usermem

libload_name:
	db	ti.AppVarObj, "LibLoad", 0
.len := $ - .
