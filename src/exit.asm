; application exit handling routines

exit_full:
	bit	settings_ram_backup,(iy + settings_flag)
	jr	z,.dont_clear_backup
	ld	b,$00
	ld	de,$3c0000
	flash_unlock_m
	call	_WriteFlashByte				; clear old backup
	flash_lock_m
.dont_clear_backup:
	ld	a,lcdBpp16
	ld	(mpLcdCtrl),a
	call	_DrawStatusBar
	call	_ClrParserHook
	call	_ClrAppChangeHook
	call	_ClrScrn
	call	_HomeUp
	res	useTokensInString,(iy + clockFlags)
	res	onInterrupt,(iy + onFlags)
	set	graphDraw,(iy + graphFlags)
	res	apdWarmStart,(iy + apdFlags)
	call	_APDSetup
	call	_EnableAPD				; restore apd
	im	1
	ei

	wipe_safe_ram.run				; we are going to clear this

relocate wipe_safe_ram, mpLcdCrsrImage
	ld	hl,pixelShadow
	ld	bc,69090
	call	_MemClear
	call	_ClrTxtShd				; clear text shadow
	bit	3,(iy+$25)
	jr	z,.no_defrag
	ld	a,cxErase
	call	_NewContext0				; trigger a defrag as needed
.no_defrag:
	ld	a,kClear
	jp	_JForceCmd				; exit the application for good
end relocate
