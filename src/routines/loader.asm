cesiumLoader_Start:
relocate(cmdPixelShadow)
cesiumLoader:

	call	DeletePgrmFromUserMem		; now we deleted ourselves. cool.
	call	ArchiveCesium			; archive ourselves to perserve space when running other things

	call	_boot_ClearVRAM
	call	_HomeUp
	ld	a,$2D
	ld	(mpLcdCtrl),a			; Set LCD to 16bpp
	call	_DrawStatusBar
	ld	hl,(prgmNamePtr)
	call	NamePtrToOP1
	bit	isBasic,(iy+pgrmStatus)
	jp	nz,RunBasicProgram
	call	MovePgrmToUserMem		; the program is now stored at userMem -- Now we need to check and see what kind of file it is - C or assembly
	push	hl
	ld	hl,ReturnHere
	call	_PushErrorHandler
	ld	de,ReturnHere
	push	de
	jp	UserMem				; simply call userMem to execute the program

RunBasicProgram:
	call	_RunIndicOn
	ld	a,(RunIndic)
	or	a,a
	call	nz,_RunIndicOff
	ld	a,(arcStatus)
	or	a,a
	jr	z,GoodInRAM
	call	DeleteTempProgramGetName
	ld	hl,(actualSizePrgm)
	push	hl
	call	_CreateProg			; create a temp program so we can execute
	inc	de
	inc	de
	pop	bc
	call	_ChkBCIs0
	jr	z,InROM				; there's nothing to copy
	ld	hl,(prgmDataPtr)
	ldi
	jp	po,InROM
	ldir
InROM:	call	_OP4ToOP1
GoodInRAM:
	set	graphdraw,(iy+graphFlags)
	ld	hl,ErrCatchBASIC
	call	_PushErrorHandler
	set	ProgExecuting,(iy+newdispf)
	set	allowProgTokens,(iy+newDispF)
	set	cmdExec,(iy+cmdFlags) 		; set these flags to execute BASIC prgm
	res	onInterrupt,(iy+onflags)
	ld	hl,ReturnHereBASIC
	push	hl
	xor	a,a
	ld	(kbdGetKy),a
	ei
	jp	_ParseInp			; run program

endrelocate()
CesiumLoader_End:
