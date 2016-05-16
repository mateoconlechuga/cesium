;-------------------------------------------------------------------------------
FullExit:
	call	_boot_ClearVRAM
	ld	a,$2D
	ld	(mpLcdCtrl),a				; Set LCD to 16bpp
	set	graphdraw,(iy+graphFlags)
	res	useTokensInString,(iy+clockFlags)
	res	onInterrupt,(iy+onFlags)		; [ON] break error destroyed
	ld	hl,CesiumPrgmName
	call	_Mov9ToOP1
	call	_ChkFindSym
	call	_ChkInRam
	call	nz,_Arc_Unarc
	call	_ClrTxtShd				; clear text shadow
	call	_DrawStatusBar
	ld	hl,pixelshadow
	ld	bc,SaveSScreen-pixelShadow
	call	_MemClear
	call	_ClrParserHook
	xor	a,a
	im	1
	ei
	ld	hl,stub
	ld	de,cursorImage
	ld	bc,stubEnd-stub
	ldir
	jp	cursorImage
stub:	ld	hl,userMem
	ld	de,(asm_prgm_size)
	call	_DelMem
	ld	a,kClear
	jp	_JForceCmd				; clear the screen like a boss
stubEnd: