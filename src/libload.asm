; routines for loading libload for using fat (and potentially other) libraries

; returns z if loaded, nz if not loaded
libload_load:
	call	libload_unload
	ld	de,lib_fat_Init + 1	; initialize default jump locations
	or	a,a
	sbc	hl,hl
	ex	de,hl
	ld	a,$c0
	ld	(libload_libload),a
	ld	(libload_fatdrvce),a	; reset loaded libraries that libload destroyed
	ld	b,25			; number of routines in library
.loop:
	ld	(hl),de
	inc	hl
	inc	hl
	inc	hl
	inc	hl
	inc	de
	inc	de
	inc	de
	djnz	.loop
	jr	.try
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
	db	$c0, "LibLoad", $00, $1F

; fat library functions
libload_fatdrvce:
	db	$c0, "FATDRVCE", $00, $00

lib_fat_Init:
	jp	$00
lib_fat_Deinit:
	jp	$03
lib_fat_Find:
	jp	$06
lib_fat_Select:
	jp	$09
lib_fat_Open:
	jp	$0c
lib_fat_Close:
	jp	$0f
lib_fat_GetFileSize:
	jp	$12
lib_fat_SetFileSize:
	jp	$15
lib_fat_ReadSector:
	jp	$18
lib_fat_WriteSector:
	jp	$1b
lib_fat_Tell:
	jp	$1e
lib_fat_SetBuffer:
	jp	$21
lib_fat_Delete:
	jp	$24
lib_fat_Create:
	jp	$27
lib_fat_GetAttrib:
	jp	$2a
lib_fat_SetAttrib:
	jp	$2d
lib_fat_DirList:
	jp	$30
lib_msd_Init:
	jp	$33
lib_msd_Find:
	jp	$36
lib_msd_Select:
	jp	$39
lib_msd_KeepAlive:
	jp	$3c
lib_msd_ReadSector:
	jp	$3f
lib_msd_WriteSector:
	jp	$42
lib_msd_SetJmpBuf:
	jp	$45
lib_msd_Deinit:
	jp	$48

	xor	a,a		; return z (loaded)
	pop	hl		; pop error return
	ret

; remove loaded libraries from usermem
libload_unload:
	jp	util_delete_prgm_from_usermem

libload_name:
	db	ti.AppVarObj, "LibLoad", 0
.len := $ - .
