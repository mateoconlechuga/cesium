CESIUM_OS_BEGIN:
	push	af
	call	FindAppStart
	ld	bc,0-CesiumStart
	add	hl,bc
	push	hl
	ld	bc,ParserHook
	add	hl,bc
	call	_SetParserHook
	pop	hl
	ld	bc,ReturnHereNoError
	add	hl,bc
	ld	(ASMSTART_HANDLER+1),hl
	ld	(BASICSTART_HANDLER+1),hl
	or	a,a
	sbc	hl,bc
	ld	bc,ReturnHereIfError
	add	hl,bc
	ld	(ASMERROR_HANDLER+1),hl
	or	a,a
	sbc	hl,bc
	ld	bc,ErrCatchBASIC
	add	hl,bc
	ld	(BASICERROR_HANDLER+1),hl
	pop	af
	cp	a,$AA
	jr	z,RELOADED_FROM_PRGM
RunShell:
	ld	hl,settingsAppVar
	call	_Mov9ToOP1
	call	_ChkFindSym			; now lookup the settings program
	call	c,CreateDefaultSettings		; create it if it doesn't exist
	call	_ChkInRam
	push	af
	call	z,_Arc_Unarc			; archive it
	pop	af
	jr	z,RunShell			; now lookup the settings program
	ex	de,hl
	ld	de,9
	push	de
	pop	bc
	add	hl,de
	ld	e,(hl)
	add	hl,de
	inc	hl				; HL->totalPrgmSize bytes
	inc	hl
	inc	hl
	ld	de,TmpSettings
	ldir					; copy the temporary settings to the lower stack
	xor	a,a 
	sbc	hl,hl
	ld	(currSelAbs),hl
	ld	(scrollamt),hl
	ld	(currSel),a			; op1 holds the name of this program
RELOADED_FROM_PRGM:		
	res	onInterrupt,(iy+OnFlags)	; this bit of stuff just enables the [on] key
	call	ClearScreens
	call	_GetBatteryStatus		;> 75%=4 ;50%-75%=3 ;25%-50%=2 ;5%-25%=1 ;< 5%=0
	sub	a,5
	cpl
	ld	(CesiumBatteryStatus),a
MAIN_START_LOOP_1:
	call	DeleteTempProgramGetName
	ld	hl,pixelshadow2
	ld	(programNameLocationsPtr),hl
	xor	a,a
	sbc	hl,hl
	ld	(numprograms),hl
	call	sort				; sort the VAT alphabetically
	call	FindPrograms			; find available assembly programs in the VAT
	ld	a,$27
	ld	(mpLcdCtrl),a			; set LCD to 8bpp
	call	CopyHL1555Palette		; HIGH=LOW
MAIN_START_LOOP:
	call	DrawMainOSThings
	ld	a,107
	ld	(cIndex),a
	drawRectOutline(3+2+185+3,22+2,318-2,238-2-15)
	drawRectOutline(193+44,54,316-42,91)
	drawHLine(3+2+185+9,22+2+3+9,112)
	SetDefaultTextColor()
	ld	hl,(numprograms)
	add	hl,de
	or	a,a
	sbc	hl,de
	jr	z,NoInfoString
	print(FileInforamtionStr,3+2+185+9,22+2+3)
NoInfoString:
	ld	hl,$FFF
	ld	(APDtmmr),hl
	or	a,a
	sbc	hl,hl
	ld	(posX),hl
	call	DrawProgramNames
	ld	hl,(numprograms)
	add	hl,de
	or	a,a
	sbc	hl,de
	jr	z,GetKeysNoPrgms
GetKeys:
	call	DrawTime
	call	FullBufCpy
	call	_GetCSC
	or	a,a
	call	z,DecrementAPD
	cp	a,skGraph
	jp	z,RenameProgram
	cp	a,skAlpha
	jp	z,LoadProgramOptions
	cp	a,skClear
	jp	z,FullExit
	cp	a,skDel
	jp	z,DeletePrgm
	cp	a,skMode
	jp	z,DrawSettingsMenu
	cp	a,skUp
	jp	z,MoveSelectionUp
	cp	a,skDown
	jp	z,MoveSelectionDown
	cp	a,sk2nd
	jr	z,BootPrgm
	cp	a,skEnter
	jr	z,BootPrgm
	sub	a,skAdd
	jp	c,GetKeys
	cp	a,skMath-skAdd+1
	jp	nc,GetKeys
	jp	SearchAlpha
BootPrgm:
	jp	CesiumLoader

GetKeysNoPrgms:
	call	DrawTime
	call	FullBufCpy
	call	_GetCSC
	or	a,a
	call	z,DecrementAPD
	cp	a,skClear
	jp	z,FullExit
	cp	a,skMode
	jp	z,DrawSettingsMenu
	jr	GetKeysNoPrgms

DecrementAPD:
APDtmmr: =$+1
	ld	hl,0
	dec	hl
	ld	(APDtmmr),hl
	add	hl,de
	or	a,a
	sbc	hl,de
	ret	nz
	pop	hl
	jp	FullExit

MoveSelectionUp:
	ld	hl,MAIN_START_LOOP
	push	hl
GetNextPrgmUp:
	ld	hl,(currSelAbs)
	add	hl,de
	or	a,a
	sbc	hl,de
	ret	z					; check if we are at the top
	dec	hl
	ld	(currSelAbs),hl
	ld	a,(currSel)
	or	a					; 5 programs for now
	jp	z,ScrollListUp
	dec	a
	ld	(currSel),a
	ret

MoveSelectionDown:
	ld	hl,MAIN_START_LOOP
	push	hl
GetNextPrgmDown:
	ld	hl,(currSelAbs)
	ld	de,(numprograms)
	dec	de
	call	_CpHLDE
	ret	z
	inc	hl
	ld	(currSelAbs),hl
	ld	a,(currSel)
	cp	a,9					; 10 programs per screen
	jr	z,ScrollListDown
	inc	a
	ld	(currSel),a
	ret

ScrollListUp:
	ld	hl,(scrollamt)
	dec	hl
	ld	(scrollamt),hl
	ret

ScrollListDown:
	ld	hl,(scrollamt)
	inc	hl
	ld	(scrollamt),hl
	ret
