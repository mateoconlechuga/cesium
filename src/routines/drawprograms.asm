DrawPrograms:
	ld	a,(PrgmCountDisp)
	or	a,a
	jr	z,++_
	ld	hl,(numprograms)
	ld	a,(listApps)
	or	a,a
	jr	z,+_
	dec	hl
_:	call	ConvHL
	inc	hl
	inc	hl
	inc	hl
	ld	bc,195
	ld	a,7
	ld	(posX),bc
	ld	(posY),a
	SetInvertedTextColor()
	call	DrawString
	SetDefaultTextColor()
_:	ld	a,24
	ld	(posX),a
	ld	a,24+6
	ld	(posY),a
	xor	a,a
	sbc	hl,hl
	ld	(iy+pgrmStatus),a				; reset the prgrmStatus flags
	ld	(currpgrmdraw),a
	ld	bc,(numprograms)
	sbc	hl,hl
	adc	hl,bc
	jp	z,DrawNoPrograms                                ; return if no programs are found
	res	isAtBox,(iy+asmFlag)
	ld	a,(listApps)
	or	a,a
	jr	z,+_
	ld	de,(currSelAbs)
	call	_ChkDEIs0
	jr	nz,+_
	set	isAtBox,(iy+asmFlag)
_:	ld	hl,pixelshadow2
	ld	de,(scrollamt)
	call	_ChkDEIs0
	jr	z,DrawProgramsLoop
GetRealOffset:
	inc	hl
	inc	hl
	inc	hl
	inc	hl
	dec	de
	dec	bc
	ld	a,e
	or	a,d
	jr	nz,GetRealOffset
DrawProgramsLoop:
	xor	a,a
	ld	(iy+tmpPgrmStatus),a				; reset the tmpPrgrmStatus flags
	res	drawingSelected,(iy+asmFlag)			; we aren't drawing the selected one yet.
currpgrmdraw: =$+1
	ld	e,0
	ld	a,(currSel)
	cp	a,e
	ld	(tmpPrgmNamePtr),hl
	jr	nz,NotSelected
	set	drawingSelected,(iy+asmFlag)
	ld	(prgmNamePtr),hl
	changeBGColor(HIGHLIGHT_COLOR)				; highlight the currently selected item
NotSelected:
	ld	a,e
	inc	a
	ld	(currpgrmdraw),a
	ld	a,(posY)
	cp	a,220
	jp	nc,setOverflowFlag				; tells us we still have more to scroll, so draw an arrow or something later
	push	bc						; BC=number of programs left to draw
	push	hl						; HL->lookup table
	ld	hl,(hl)						; load name pointer
	push	hl						; push the name pointer
	inc	hl						; the next byte is the status
	ld	a,(hl)
	ld	(archivestatus),a
	call	_SetDEUToA
	inc	hl
	ld	d,(hl)
	inc	hl
	ld	e,(hl)
	push	hl
	ex	de,hl
	cp	a,$D0
	jr	nc,IsInRAM
	set	tmpPgrmArchived,(iy+tmpPgrmStatus)	; tells us later that we are in the archive
	ld	de,9
	add	hl,de
	ld	e,(hl)
	add	hl,de
	inc	hl
IsInRAM:					; HL->totalPrgmSize bytes
	call	_LoadDEInd_s
	ld	(tmpPrgmDataPtr),hl
	bit	drawingSelected,(iy+asmFlag)
	jr	z,+_
	ld	(prgmDataPtr),hl
	ld	(actualSizePrgm),de
_:	ex	de,hl
	ld	de,9
	add	hl,de
	pop	de
	pop	bc
	ld	a,(bc)
	push	bc
	push	de
	call	_AddHLAndA
	ld	(totalPrgmSize),hl
	pop	hl
	inc	hl
	inc	hl
	inc	hl
	ld	a,(hl)
	ld	(typebyte),a
	pop	hl
	ld	b,(hl)
	dec	hl
	ld	a,(hl)
	cp	a,64
	jr	nc,DrawPrgm
	add	a,64
	ld	(hl),a
	set	tmpPgrmHidden,(iy+tmpPgrmStatus)
	ld	a,(foreColor)
	ld	(color_save),a
	ld	a,181						; lighten the color
	ld	(foreColor),a
DrawPrgm:
	push hl
DrawPrgmName:
	ld	a,(hl)
	dec	hl
	push	bc
	call	DrawChar
	pop	bc
	djnz	DrawPrgmName
	pop	hl
	bit	tmpPgrmHidden,(iy+tmpPgrmStatus)
	jr	z,NotHiddenHere
color_save: =$+1
	ld	a,0
	ld	(foreColor),a
	ld	a,(hl)
	sub	a,64
	ld	(hl),a
NotHiddenHere:
	ld	a,(posY)
	add	a,20
	ld	(posY),a
	sub	a,8+17
	ld	c,a
	ld	a,24
	ld	(posX),a
	ld	b,2
	pop	hl
	inc	hl
	inc	hl
	inc	hl
	res	isspecialprog,(iy+asmFlag)
	ld	a,(hl)
	bit	drawingSelected,(iy+asmFlag)
	jr	z,NotHighlighted
	ld	(prgmbyte),a
NotHighlighted:
	inc	hl
	push	hl
	ld	de,DirStr
	ld	hl,directorySprite
	cp	a,$aa
	jp	z,SpecialFolder
	ld	de,ez80Str
	ld	hl,asmFileSprite
	or	a,a
	jp	z,AsmOrICEOrCFile
	; move somewhere else to check for custom icon and things :P. we will return to DrawIcon
	set	isspecialprog,(iy+asmFlag)
	ld	de,CStr
	ld	hl,cFileSprite
	cp	a,$CE
	jp	z,AsmOrICEOrCFile					; Well... technically an ASM file could be a C file? :)
	ld	de,ICEStr
	ld	hl,iceFileSprite
	cp	a,$7F
	jp	z,AsmOrICEOrCFile
	set	tmpIsBasic,(iy+tmpPgrmStatus)
	ld	de,ICESourceStr
	cp	a,$2C
	jp	z,AsmOrICEOrCFile
	call	CheckIfIconBASIC

DrawIcon:
	ld	a,(posY)
	ld	(tmpY),a
	push	af
	ld	ix,(posX)
	push	ix
	push	de
	push	hl
	call	_Sprite8bpp
tmpY: =$+1
	ld	a,0
	sub	a,20
	ld	c,a
	ld	hl,lockedSprite
	ld	b,250
typebyte: =$+1
	ld	a,0
	cp	a,5
	jr	z,NotProtected
	push	bc
	call	_Sprite8bpp
	pop	bc
	set	tmpPgrmLocked,(iy+tmpPgrmStatus)
NotProtected:
	ld	a,b
	sub	a,4
	ld	b,a
	ld	hl,archivedSprite
archivestatus: =$+1
	ld	a,0
	cp	a,$D0
	call	c,_Sprite8bpp
	pop	hl

	bit	drawingSelected,(iy+asmFlag)
	jp	z,NotCurrentlySelected

	ld	a,(iy+tmpPgrmStatus)
	ld	(iy+pgrmStatus),a

	ld	bc,(240/2*256)+57
	call	_Sprite8bpp_2x
	changeBGColor(255)
	print(ArchiveStatusStr,185+9+3+2,22+2+3+91)
	ld	a,BG_COlOR_INDEX
	ld	(cIndex),a
	drawRectOutline(300,118,308,126)
	xor	a,a
	bit	pgrmArchived,(iy+pgrmStatus)
	jr	z,NotArchived
	drawRectFilled(302,120,307,125)
	ld	a,255
NotArchived:
	ld	(arcStatus),a
	print(EditStatusStr,199,22+2+3+91+11)
	drawRectOutline(300,118+11,308,126+11)
	bit	pgrmLocked,(iy+pgrmStatus)
	jr	z,Unlocked
	drawRectFilled(302,120+11,307,125+11)
Unlocked:
	print(HiddenStr,199,140)
	drawRectOutline(300,118+22,308,126+22)
	bit	pgrmHidden,(iy+pgrmStatus)
	jr	z,NotHidden
	drawRectFilled(302,142,307,147)
NotHidden:
	print(SizeStr,199,151)
	ld	hl,(totalPrgmSize)
	call	ConvHL
	inc	hl
	inc	hl
	call	DrawString
	print(LanguageStr,199,107)
	pop	hl
	call	DrawString
	print(AttributesStr,199,173)
	ld	de,262
	ld	(posX),de
	inc	hl
	call	DrawString
	print(RenameStr,199,184)
#ifdef ENGLISH
	ld	de,262
#else
	ld	de,254
#endif
	ld	(posX),de
	inc	hl
	call	DrawString
	call	DrawStaticInfo
	push	hl
NotCurrentlySelected:
	pop	hl
	pop	bc
	ld	(posX),bc
	pop	af
	ld	(posY),a
	pop	hl
	pop	bc
	dec	bc
	ld	a,b
	or	a,c
	jp	nz,DrawProgramsLoop
	ret
setOverflowFlag:
	set	scrollDown,(iy+asmFlag)
	ret

SpecialFolder:
	push	hl
	or	a,a
	sbc	hl,hl
	ld	(totalPrgmSize),hl
	pop	hl
	jp	DrawIcon

AsmOrICEOrCFile:
	push	hl					; save the default icon
	push	de
tmpPrgmDataPtr: =$+1
	ld	hl,0					; HL->pointer to data for program
	inc	hl					; $EF
	inc	hl					; $7B
	bit	isspecialprog,(iy+asmFlag)
	jr	z,notc
	inc	hl					; SMC byte to 'inc hl' if C program -- remember the nop magic byte?
notc:
	ld	a,(hl)					; is it a $C3 byte? (JP)
	cp	a,$C3
	jr	nz,NoIcon
	inc	hl
	inc	hl
	inc	hl
	inc	hl					; HL->Icon indicator byte, hopefully
	ld	a,(hl)
	cp	a,$01					; is it the Cesium indicator?
	jr	nz,NoIcon
	inc	hl					; now we have to load in the icon -- which is just an 'inc hl'
	bit	drawingSelected,(iy+asmFlag)		; make sure we actually want to draw the description
	jr	z,Icon
	push	hl
	ld	d,(hl)					; okay, now we have to draw the description string
	inc	hl
	ld	e,(hl)
	mlt	de
	inc	de
	add	hl,de					; hl->description string (NULL terminated)
	call	DrawLowerDescription
	pop	hl
	pop	de
	pop	ix
	jp	DrawIcon

NoIcon:
	pop	de
	pop	hl                                      ; hl -> icon, de -> language string
	jp	DrawIcon				; now draw the right icon :)

Icon:
	pop	de
	pop	ix
	jp	DrawIcon

CheckIfIconBASIC:
	ld	hl,basicFileSprite
	push	hl
	push	bc
	ld	hl,(tmpPrgmDataPtr)
	ld	de,CheckIconBASICStr
	ld	b,6
CheckLoop:
	ld	a,(de)
	cp	a,(hl)
	inc	hl
	inc	de
	jp	nz,NoIconBASIC
	djnz	CheckLoop
	ld	de,tmpSpriteLoc
	ld	a,16
	ld	(de),a
	inc	de
	ld	(de),a
	inc	de				; save the size of the sprite
	ld	b,0
GetIconBASIC:					; okay, now we want to loop 256 times in order to place in the right things
	ld	a,(hl)
	sub	a,$30
	cp	a,$11
	jr	c,NotAbove9
	sub	a,$07
NotAbove9:					; rather than doing an actual routine, we'll just do this. 'tis faster
	push	hl
	ld	hl,colorTable
	call	_AddHLAndA
	ld	a,(hl)
	pop	hl
	ld	(de),a
	inc	de
	inc	hl
	djnz	GetIconBASIC			; check all the values
	pop	bc
	pop	hl
	ld	hl,tmpSpriteLoc			; yay, we have a custom icon! :)
	jr	+_
NoIconBASIC:
	pop	bc
	pop	hl
	ret	z
	ld	hl,basicFileSprite
_:	ld	de,BasicStr
	ret

DrawNoPrograms:
	print(NoProgramsStr,24,30)
	ld	hl,CesiumIcon
	ld	bc,(240/2*256)+57
	call	_Sprite8bpp_2x
PrintModeSettings:
	print(SettingsStr,3+2+185+9,22+2+3)
	ld	de,270
	ld	(posX),de
	inc	hl
	call	DrawString
	ret

DrawLowerDescription:
	push	bc
	push	hl
	call	ClearLowerBar				; clear out the bottom bar
	pop	hl
	ld	bc,(posX)
	push	bc
	ld	a,(posY)
	push	af
	ld	bc,4
	ld	a,228
	ld	(posX),bc
	ld	(posY),a
	SetInvertedTextColor()
	call	DrawString
	SetDefaultTextColor()
	pop	af
	pop	bc
	ld	(posX),bc
	ld	(posY),a
	pop	bc
	ret

DrawStaticInfo:
	print(DeleteStr,199,195)
#ifdef ENGLISH
	ld	de,278
#else
	ld	de,262
#endif
	ld	(posX),de
	inc	hl
	call	DrawString
	print(SettingsStr,199,206)
	ld	de,270
	ld	(posX),de
	inc	hl
	jp	DrawString

colorTable:
	.db	255,24,224,0,248,36,227,97,09,19,230,255,181,107,106,74
