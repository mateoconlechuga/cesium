; application exit handling routines

exit_full:
	exit_cleanup.run

relocate exit_cleanup, mpLcdCrsrImage
	bit	setting_ram_backup,(iy + settings_flag)
	jr	z,.dont_clear_backup
	ld	b,$00
	ld	de,$3c0000
	flash_unlock_m
	call	_WriteFlashByte				; clear old backup
	flash_lock_m
.dont_clear_backup:
	call	lcd_fill
	call	lcd_blit
	ld	a,$2d
	ld	(mpLcdCtrl),a
	call	_DrawStatusBar
	call	_ClrParserHook
	call	_ClrAppChangeHook
	call	_ClrScrn
	call	_HomeUp
	res	useTokensInString,(iy + clockFlags)
	res	onInterrupt,(iy + onFlags)
	set	graphDraw,(iy + graphFlags)
	ld	hl,pixelShadow
	ld	bc,69090
	call	_MemClear
	call	_ClrTxtShd				; clear text shadow
	bit	3,(iy+$25)
	jr	z,.no_defrag
	ld	a,cxErase
	call	_NewContext0				; trigger a defrag as needed
.no_defrag:
	res	apdWarmStart,(iy + apdFlags)
	call	_APDSetup
	call	_EnableAPD				; restore apd
	im	1
	ei
	ld	a,kClear
	jp	_JForceCmd				; exit the application for good
end relocate
