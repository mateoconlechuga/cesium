CESIUM_OS_BEGIN:
	cp	a,$aa
	jr	z,LoadSettings
	
	xor	a,a
	sbc	hl,hl
	ld	(currSelAbs),hl
	ld	(scrollamt),hl
	ld	(currSel),a			; op1 holds the name of this program
	ld	(inAppScreen),a

LoadSettings:
	ld	hl,settingsAppVar
	call	_Mov9ToOP1
	call	_ChkFindSym			; now lookup the settings appvar
	call	c,CreateDefaultSettings		; create it if it doesn't exist
	call	_ChkInRam
	push	af
	call	z,_Arc_Unarc			; archive it
	pop	af
	jr	z,LoadSettings			; now lookup the settings appvar
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
	
	call	SetKeyHookPtr
	push	hl
	ld	bc,ParserHook
	add	hl,bc
	call	_SetParserHook
	pop	hl
	push	hl
	ld	bc,GetKeyHook
	add	hl,bc
	ld	(getKeyHookPtr),hl
	ld	a,(shortcutKeys)
	or	a,a
	call	nz,$0213E0
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
	res	onInterrupt,(iy+OnFlags)	; this bit of stuff just enables the [on] key
	call	ClearScreens
	call	_GetBatteryStatus		;> 75%=4 ;50%-75%=3 ;25%-50%=2 ;5%-25%=1 ;< 5%=0
	sub	a,5
	cpl
	ld	(CesiumBatteryStatus),a
MAIN_START_LOOP_1:
	call	DeleteTempProgramGetName
	call	sort				; sort the VAT alphabetically
	ld	a,$27
	ld	(mpLcdCtrl),a			; set LCD to 8bpp
	call	CopyHL1555Palette		; HIGH=LOW
MAIN_START_LOOP_SETTINGS:
	call	AppCheck
	call	FindAppsPrograms		; find available programs and apps
	ld	hl,(numprograms)
	ld	a,(inAppScreen)
	or	a,a
	jr	z,+_
	ld	hl,(numapps)
_:	ld	(MaxListAmt),hl
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
	ld	a,(inAppScreen)
	or	a,a
	push	af
	call	z,DrawPrograms
	pop	af
	call	nz,DrawApps
	ld	hl,(numprograms)
	add	hl,de
	or	a,a
	sbc	hl,de
	jp	z,GetKeysNoPrgms
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
	ld	a,(listApps)
	or	a,a
	jp	z,CesiumLoader
	ld	hl,(currSelAbs)
	call	_ChkHLIs0
	jr	nz,CheckForRun
	ld	hl,inAppScreen
	ld	a,(hl)
	cpl
	ld	(hl),a
	jp	MAIN_START_LOOP_SETTINGS
CheckForRun:
	ld	a,(inAppScreen)
	or	a,a
	jp	z,CesiumLoader
	call	CleanUp
	call	_ResetStacks
	call	_ReloadAppEntryVecs
	call	_AppSetup
	set	appRunning,(iy+APIFlg)	; turn on apps
	set	6,(iy+$28)
	res	0,(iy+$2C)		; set some app flags
	set	appAllowContext,(iy+APIFlg)	; turn on apps
	ld	hl,$D1787C		; copy to ram data location
	ld	bc,$FFF
	call	_MemClear		; zero out the ram data section
	ld	hl,(currAppPtr)		; hl -> start of app
	push	hl			; de -> start of code for app
	ex	de,hl
	ld	hl,$18			; find the start of the data to copy to ram
	add	hl,de
	ld	hl,(hl)
	call	__icmpzero		; initialize the bss if it exists
	jr	z,+_
	push	hl
	pop	bc
	ld	hl,$15
	add	hl,de
	ld	hl,(hl)
	add	hl,de
	ld	de,$D1787C		; copy it in
	ldir
_:	pop	hl
	push	hl
	pop	de
	ld	bc,$1B			; offset
	add	hl,bc
	ld	hl,(hl)
	add	hl,de
	jp	(hl)

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
GetListUp:
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
MaxListAmt =$+1
	ld	de,0
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
