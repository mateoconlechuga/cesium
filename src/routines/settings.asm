CreateDefaultSettings:
	ld	hl,30
	call	_EnoughMem
	jp	c,FullExit
	ld	hl,15
	call	_CreateAppVar
	inc	de
	inc	de
	ex	de,hl
	push	hl
	ld	bc,15
	call	_MemClear
	pop	hl
	ld	(hl),107			; Default Color
	inc	hl
	inc	hl
	inc	hl
	inc	hl
	inc	hl
	ld	(hl),255			; List applications
	inc	hl
	ld	(hl),255			; Enable homescreen hooks
	inc	hl
	ld	(hl),4				; Length of password
	inc	hl
	ld	(hl),sk5
	inc	hl
	ld	(hl),sk5
	inc	hl
	ld	(hl),sk5
	inc	hl
	ld	(hl),sk5
	jp	_OP4ToOP1

SaveSettings:
	call	$0213E4
	ld	a,(shortcutKeys)
	or	a,a
	ld	hl,(getKeyHookPtr)
	call	nz,$0213E0
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
	ld	hl,tmpSettings
	ld	bc,14
	ldir
NotArchivedSet:
	ld	hl,settingsAppVar		; locate the appvar
	call	_Mov9ToOP1
	call	_ChkFindSym
	call	_ChkInRam
	push	af
	call	z,_Arc_Unarc
	pop	af
	jr	z,NotArchivedSet
	ret

DrawSettingsMenu:
	xor	a,a
	ld	(currMenuSel),a			; start on the first menu item
RedrawSettings:
	res	drawPrgmCnt,(iy+asmFlag)
	set	clockIsOff,(iy+clockFlag)
	res	shiftLwrAlph,(iy+shiftFlags)
	call	DrawMainOSThings
	call	ClearLowerBar
	ld	a,107
	ld	(cIndex),a
	print(CesiumVersionStr,4,228)
	ld	a,255
	ld	(cIndex),a
	SetDefaultTextColor()
	print(GenSettingsStr,10,30)
	print(ColorStr,25,53)
	ld	bc,4
	ld	hl,(posX)
	add	hl,bc
	ld	(posX),hl
	ld	a,(skinColor)
	call	ConvA
	add	hl,bc
	call	DrawString
	print(RunIndicStr,25,76)
	print(ProgramCountStr,25,99)		; draw the setting's option text
	print(ClockStr,25,122)
	print(AutoBackupStr,25,145)
	print(ListAppsStr,25,168)
	print(ShortcutsStr,25,191)
	ld	a,107
	ld	(cIndex),a
	drawRectOutline(10,52,18,60)
	drawRectOutline(10,75,18,83)
	drawRectOutline(10,98,18,106)
	drawRectOutline(10,121,18,129)
	drawRectOutline(10,144,18,152)
	drawRectOutline(10,167,18,175)				
	drawRectOutline(10,190,18,198)		; draw the empty rectangles
	drawRectFilled(12,54,17,59)
	ld	a,(runIndic)
	or	a,a
	jr	z,BreakNotSet
	drawRectFilled(12,77,17,82)
BreakNotSet:					; option for RunIndic
	ld	a,(prgmCountDisp)
	or	a,a
	jr	z,ProgCountNotSet
	drawRectFilled(12,100,17,105)
ProgCountNotSet:				; option for program count
	ld	a,(clockDisp)
	or	a,a
	jr	z,ClockDispNotSet
	drawRectFilled(12,123,17,128)
ClockDispNotSet:				; option for clock on
	ld	a,(autoBackup)
	or	a,a
	jr	z,AutoBackupNotSet
	drawRectFilled(12,146,17,151)
AutoBackupNotSet:
	ld	a,(listApps)
	or	a,a
	jr	z,ListAppsNotSet
	drawRectFilled(12,169,17,174)
ListAppsNotSet:
	ld	a,(shortcutKeys)
	or	a,a
	jr	z,ShortcutsNotSet
	drawRectFilled(12,192,17,197)
ShortcutsNotSet:
	call	HighlightBox
GetOptions:	
	call	DrawTime
	call	FullBufCpy
	call	_GetCSC
	ld	hl,RedrawSettings
	push	hl
	cp	a,skStore
	jp	z,ChangePassword
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
	ld	a,(inAppScreen)
	or	a,a
	jr	nz,++_
_:	jp	MAIN_START_LOOP_SETTINGS
_:	ld	a,(listApps)
	or	a,a
	jr	nz,--_
	xor	a,a
	sbc	hl,hl
	ld	(currSelAbs),hl
	ld	(scrollamt),hl
	ld	(currSel),a			; op1 holds the name of this program
	ld	(inAppScreen),a
	jr	--_

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
_:	dec	a
	jr	nz,+_
	drawRectOutline(10,121,18,129)
	ret
_:	dec	a
	jr	nz,+_
	drawRectOutline(10,144,18,152)
	ret
_:	dec	a
	jr	nz,+_
	drawRectOutline(10,167,18,175)
	ret
_:	drawRectOutline(10,190,18,198)
	ret

incrementSettingsOption:
	ld	a,(currMenuSel)
	cp	a,6
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
	ld	hl,tmpSettings
	ld	a,(currMenuSel)
	call	_AddHLAndA
	ld	a,(hl)
	cpl
	ld	(hl),a
	ret

ChangePassword:
	call	_boot_ClearVRAM
	call	DrawMainOSThings
	call	ClearLowerBar
	ld	a,107
	ld	(cIndex),a
	print(CesiumVersionStr,4,228)
	ld	a,255
	ld	(cIndex),a
	SetDefaultTextColor()
	print(NewPasswordPrompt,10,30)
	ld	bc,$600
	ld	hl,passPtr
GetPassLoop:
	push	hl
	push	bc
	call	FullBufCpy
_:	call	_GetCSC
	or	a,a
	jr	z,-_
	cp	a,sk2nd
	jr	z,DonePassword2
	cp	a,skEnter
	jr	z,DonePassword2
	push	af
	ld	a,'*'
	call	DrawChar
	pop	af
	pop	bc
	pop	hl
	ld	(hl),a
	inc	hl
	djnz	GetPassLoop
DonePassword:
	ld	de,passPtr
	or	a,a
	sbc	hl,de
	ld	a,l
	ld	(passLength),a
	ret
DonePassword2:
	pop	bc
	pop	hl
	jr	DonePassword

	
settingsAppVar:
	.db	appVarObj,"Cesium",0
settingsOldAppVar:
	.db	appVarObj,"CesiumS",0
