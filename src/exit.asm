; application exit handling routines

exit_full:
	call	flash_code_copy
	exit_cleanup.run

relocate exit_cleanup, ti.mpLcdCrsrImage + 500
	bit	setting_ram_backup,(iy + settings_flag)
	call	nz,flash_clear_backup
	call	lcd_normal
	call	ti.ClrParserHook
	call	ti.ClrAppChangeHook
	call	util_setup_shortcuts
	call	ti.ClrScrn
	call	ti.HomeUp
	res	ti.useTokensInString,(iy + ti.clockFlags)
	res	ti.onInterrupt,(iy + ti.onFlags)
	set	ti.graphDraw,(iy + ti.graphFlags)
	ld	hl,ti.pixelShadow
	ld	bc,69090
	call	ti.MemClear
	call	ti.ClrTxtShd				; clear text shadow
	bit	3,(iy + $25)
	jr	z,.no_defrag
	ld	a,ti.cxErase
	call	ti.NewContext0				; trigger a defrag as needed
.no_defrag:
	res	ti.apdWarmStart,(iy + ti.apdFlags)
	call	ti.ApdSetup
	call	ti.EnableAPD				; restore apd
	im	1
	ei
	ld	a,ti.kQuit
	call	ti.NewContext0
	xor	a,a
	ld	(ti.menuCurrent),a
	ld	a,ti.kClear
	jp	ti.JForceCmd				; exit the application for good
end relocate
