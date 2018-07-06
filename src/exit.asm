; application exit handling routines

exit_full:
	call	flash_code_copy
	exit_cleanup.run

relocate exit_cleanup, mpLcdCrsrImage + 500
	bit	setting_ram_backup,(iy + settings_flag)
	call	nz,flash_clear_backup
	call	lcd_normal
	call	_ClrParserHook
	call	_ClrAppChangeHook
	call	util_setup_shortcuts
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
