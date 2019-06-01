; unrelocated data

; safely unarchive a varible and restore screen mode
; in the case of a garbage collect
; returns nz if okay, z if garbage collect
; derived from https://github.com/calc84maniac/tiboyce/blob/350e414dfc345d5e754eb87c1b87bc4e06131e71/tiboyce.asm#L468
cesium.Arc_Unarc:
	call	ti.ChkFindSym
	ret	c
	ex	de,hl
	push	hl
	add	hl,hl
	pop	hl
	jr	nc,.no_garbage_collect
	ld	hl,(hl)
	ld	a,c
	add	a,12
	ld	c,a
	ld	b,0
	add.s	hl,bc
	jr	c,.garbage_collect
	push	hl
	pop	bc
	call	ti.FindFreeArcSpot
	jr	nz,.no_garbage_collect
.garbage_collect:
	xor	a,a
	push	af
	call	ti.boot.ClearVRAM
	ld	a,$2d
	ld	(ti.mpLcdCtrl),a
	call	ti.DrawStatusBar
	jr	.archive_or_unarchive
.no_garbage_collect:
	xor	a,a
	inc	a
	push	af
.archive_or_unarchive:
	ld	hl,data_lcd_init
	call	ti.PushErrorHandler
	call	ti.Arc_Unarc
	call	ti.PopErrorHandler
data_lcd_init:
	call	ti.boot.ClearVRAM
	ld	a,ti.lcdBpp8
	ld	(ti.mpLcdCtrl),a		; operate in 8bpp
	ld	hl,ti.mpLcdPalette
	ld	b,0
.loop:
	ld	d,b
	ld	a,b
	and	a,192
	srl	d
	rra
	ld	e,a
	ld	a,31
	and	a,b
	or	a,e
	ld	(hl),a
	inc	hl
	ld	(hl),d
	inc	hl
	inc	b
	jr	nz,.loop
	pop	af
	ret

data_cesium_appvar:
	db	ti.AppVarObj
data_string_cesium_name:
	db	cesium_name,0

data_string_password:
if config_english
	db	'Password:',0
else
	db	'Mot de passe:',0
end if

data_string_quit1:
	db	'1:',0,'Quit',0
data_string_quit2:
	db	'2:',0,'Goto',0

; data in this location is allowed to be modified at runtime
	app_data

