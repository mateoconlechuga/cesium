DeletePrgm:
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
	jp	z,MAIN_START_LOOP
	jr	waitForInput
DeletePrgmYes:
	ld	hl,(prgmNamePtr)
	call	NamePtrToOP1				; move the selected name to OP1
	call	_ChkFindSym
	call	_DelVarArc
	call	GetNextPrgmUp
	jp	MAIN_START_LOOP_1			; reload everything
