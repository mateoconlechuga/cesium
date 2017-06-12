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
	ld	hl,ThisAppName
	push	hl
	call	$021100
	pop	bc
	ld	bc,$100
	add	hl,bc
	push	hl
	ld	bc,$12
	add	hl,bc
	ld	hl,(hl)
	pop	bc
	add	hl,bc
	ld	de,CommonRoutines_Start-CesiumStart+_app_init_size
	add	hl,de
	ld	de,SaveSScreen
	ld	bc,CommonRoutines_End-CommonRoutines_Start
	ldir
	ld	a,$AA
	ld	(HasReloaded),a
	jp	RELOAD_CESIUM

HasReloaded:
	.db	0
	
	; reload here
	
ThisAppName:
	.db "Cesium",0
QuitStr1:
	.db "1:",0
QuitStr2:
	.db "Quit",0
endrelocate()
cesiumReLoader_End: