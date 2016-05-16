	di				; disable interrupts
; loader for this appvar
LoaderOfLoader_Start:
	push	hl
	ld	de,CommonRoutines_Start-CesiumStart-2
	add	hl,de			; now we are looking at the common routines
	ld	de,SaveSScreen
	ld	bc,CommonRoutines_End-CommonRoutines_Start
	ldir				; copy the common routines to safeRAM
	pop	hl
	push	hl
	ld	de,ParserHook-CesiumStart-2
	add	hl,de
	call	_SetParserHook
	call	_RunIndicOff 		; turn off the indicator
	call	DeletePgrmFromUserMem	; delete the loader from UserMem
	pop	hl
	ld	de,CesiumAppVarName_Installer_Relocated-CesiumStart-2
	add	hl,de
	call	_Mov9ToOP1
	call	MovePgrmToUserMem	; copy the AppVar to UserMem
	jp	UserMem+LoaderOfLoader_End-LoaderOfLoader_Start+1
CesiumAppVarName_Installer_Relocated:
	.db	appVarObj,"CeOS",0
LoaderOfLoader_End: