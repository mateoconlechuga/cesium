;Reloads the shell after a program has finished running
cesiumReloader_Start:
relocate(stubLocation)
cesiumReloader:

ErrCatchBASIC:
	call	_boot_ClearVRAM
	call	_DrawStatusBar
	call	_DispErrorScreen
	set	textInverse, (iy + textFlags)
	ld	hl,1
	ld	(curRow),hl
	ld	hl,QuitStr1
	call	_PutS
	ld	hl,QuitStr2
	res	textInverse, (iy + textFlags)
	call	_PutS
	call	_GetKey
	jr	ReturnHereIfError

ReturnHereBASIC:
ReturnHereNoError:                          ; handler for returning programs
	call	_PopErrorHandler
ReturnHereIfError:                          ; handler for returning programs
	ld	hl,CesiumAppVarNameReloader
	call	_Mov9ToOP1
	call	_ChkFindSym
	call	_ChkInRam
	ex	de,hl
	jr	z,ExistsInRAM
	ld	de,9
	add	hl,de
	ld	e,(hl)
	add	hl,de
	inc	hl
ExistsInRAM:					; HL->totalPrgmSize bytes
	inc	hl
	inc	hl				; HL->CESIUM PGRM DATA
	ld	de,CommonRoutines_Start-CesiumStart
	add	hl,de
	ld	de,SaveSScreen
	ld	bc,CommonRoutines_End-CommonRoutines_Start
	ldir
	jp	RELOAD_CESIUM
 
CesiumAppVarNameReloader:
	.db appVarObj,"CeOS",0
QuitStr1:
	.db "1:",0
QuitStr2:
	.db "Quit",0
endrelocate()
cesiumReLoader_End: