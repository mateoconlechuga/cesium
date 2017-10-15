DeletePrgm:
	ld	a,(listApps)
	or	a,a
	jr	z,NoDeleteAppsFolder
	ld	hl,(currSelAbs)
	call	_ChkHLIs0
	jp	z,MAIN_START_LOOP_1
NoDeleteAppsFolder:
	call	ClearLowerBar
	SetInvertedTextColor()
	print(DeleteConfirmStr,4,228)
	SetDefaultTextColor()
	call	FullBufCpy
waitForInput:
	call	_GetCSC
	cp	a,skZoom
	jr	z,DeletePrgmYes
	cp	a,skGraph
	jp	z,MAIN_START_LOOP_SETTINGS
	jr	waitForInput
DeletePrgmYes:
	ld	a,(inAppScreen)
	or	a,a
	jr	nz,DeleteApp
	ld	hl,(prgmNamePtr)
	call	NamePtrToOP1				; move the selected name to OP1
	call	_ChkFindSym
	call	_DelVarArc
_:	call	GetListUp
	jp	MAIN_START_LOOP_1			; reload everything
DeleteApp:
	ld	hl,(currAppPtr)
	ld	bc,0-$100
	add	hl,bc
	call	_DeleteApp
	jr	-_					; reload everything