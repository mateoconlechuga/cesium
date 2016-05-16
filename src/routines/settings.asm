CreateDefaultSettings:
	ld	hl,10
	call	_EnoughMem
	jp	c,FullExit
	ld	hl,10
	call	_CreateAppVar
	inc	de
	inc	de
	ex	de,hl
	push	hl
	ld	bc,10
	call	_MemClear
	pop	hl
	ld	(hl),107					; Default Color
	call	_OP4ToOP1
	ret

SaveSettings:
	ld	hl,settingsAppVar
	call	_Mov9ToOP1
	call	_ChkFindSym
	call	_ChkInRam
	push	af
	call	nz,_Arc_Unarc
	pop	af
	jr	nz,SaveSettings
	inc	de
	inc	de
	ld	hl,TmpSettings
	ld	bc,9
	ldir
NotArchivedSet:
	ld	hl,settingsAppVar				; locate the appvar
	call	_Mov9ToOP1
	call	_ChkFindSym
	call	_ChkInRam
	push	af
	call	z,_Arc_Unarc
	pop	af
	jr	z,NotArchivedSet
	ret

DrawSettingsMenu:
	xor	a
	ld	(currMenuSel),a					; start on the first menu item
RedrawSettings:
	res	drawPrgmCnt,(iy+asmFlag)
	set	clockIsOff,(iy+clockFlag)
	res	shiftLwrAlph,(iy+shiftFlags)
	call	DrawMainOSThings
	SetDefaultTextColor()
	print(GenSettingsStr,10,30)
	print(ColorStr,25,53)
	print(RunIndicStr,25,76)
	print(ProgramCountStr,25,99)				; draw the setting's option text
	print(ClockStr,25,122)
	ld	a,107
	ld	(cIndex),a
	drawRectOutline(10,52,18,60)
	drawRectOutline(10,75,18,83)
	drawRectOutline(10,98,18,106)
	drawRectOutline(10,121,18,129)				; draw the empty rectangles
	drawRectFilled(12,54,17,59)
	ld	a,(RunIndic)
	or	a,a
	jr	z,BreakNotSet
	drawRectFilled(12,77,17,82)
BreakNotSet:							; option for RunIndic
	ld	a,(PrgmCountDisp)
	or	a,a
	jr	z,ProgCountNotSet
	drawRectFilled(12,100,17,105)
ProgCountNotSet:						; option for program count
	ld	a,(ClockDisp)
	or	a,a
	jr	z,ClockDispNotSet
	drawRectFilled(12,123,17,128)
ClockDispNotSet:						; option for clock on
	call	HighlightBox
GetOptions:	
	call	DrawTime
	call	FullBufCpy
	call	_GetCSC
	ld	hl,RedrawSettings
	push	hl
	cp	a,skLeft
	jp	z,decrementColor
	cp	a,skRight
	jp	z,incrementColor
	cp	a,skDown
	jp	z,incrementSettingsOption
	cp	a,skUp
	jp	z,decrementSettingsOption
	cp	a,sk2nd
	jp	z,SwapOption
	cp	a,skEnter
	jp	z,SwapOption
	pop	hl
	cp	a,skDel
	jr	z,SetAndSaveOptions
	cp	a,skClear
	jr	z,SetAndSaveOptions
	jr	GetOptions
SetAndSaveOptions:
	call	SaveSettings
	jp	MAIN_START_LOOP
	
HighlightBox:
	ld	a,HIGHLIGHT_COLOR
	ld	(cIndex),a
	ld	a,(currMenuSel)
	or	a,a
	jr	nz,+_
	drawRectOutline(10,52,18,60)
	ret

_:	dec	a
	jr	nz,+_
	drawRectOutline(10,75,18,83)
	ret
_:	dec	a
	jr	nz,+_
	drawRectOutline(10,98,18,106)
	ret
_:	drawRectOutline(10,121,18,129)
	ret

incrementSettingsOption:
	ld	a,(currMenuSel)
	cp	3
	ret	z
	inc	a
	ld	(currMenuSel),a
	ret
decrementSettingsOption:
	ld	a,(currMenuSel)
	or	a,a
	ret	z
	dec	a
	ld	(currMenuSel),a
	ret
decrementColor:
	ld	a,(currMenuSel)
	or	a,a
	ret	nz
	ld	a,(skinColor)
	dec	a
	jr	LoadColor
incrementColor:
	ld	a,(currMenuSel)
	or	a,a
	ret	nz
	ld	a,(skinColor)
	inc	a
LoadColor:
	ld	(skinColor),a
	ret
SwapOption:
	ld	a,(currMenuSel)
	or	a,a
	ret	z
	ld	hl,TmpSettings
	ld	a,(currMenuSel)
	call	_AddHLAndA
	ld	a,(hl)
	cpl
	ld	(hl),a
	ret
