DrawApps:
	ld	a,(prgmCountDisp)
	or	a,a
	jr	z,+_
	ld	hl,(numapps)
	dec	hl
	call	ConvHL
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
	ld	(currappdraw),a
	ld	hl,pixelshadow2+5512
	res	isAtBox,(iy+asmFlag)
	ld	de,(currSelAbs)
	call	_ChkDEIs0
	jr	nz,+_
	set	isAtBox,(iy+asmFlag)
_:	ld	de,(scrollamt)
	call	_ChkDEIs0
	ld	bc,(numapps)
	jr	z,DrawAppsLoop
GetRealAppsOffset:
	inc	hl
	inc	hl
	inc	hl
	dec	de
	dec	bc
	ld	a,e
	or	a,d
	jr	nz,GetRealAppsOffset
DrawAppsLoop:
	xor	a,a
	ld	(iy+tmpPgrmStatus),a		; reset the tmpPgrmStatus flags
	res	drawingSelected,(iy+asmFlag)	; we aren't drawing the selected one yet.
	changeBGColor(255)
currappdraw: =$+1
	ld	e,0
	ld	a,(currSel)
	cp	a,e
	jr	nz,NotAppSelected
	set	drawingSelected,(iy+asmFlag)
	changeBGColor(HIGHLIGHT_COLOR)		; highlight the currently selected item
NotAppSelected:
	ld	a,e
	inc	a
	ld	(currappdraw),a
	ld	a,(posY)
	cp	a,220
	jp	nc,setOverflowFlag		; tells us we still have more to scroll, so draw an arrow or something later
	push	bc				; BC=number of programs left to draw
	push	hl				; HL->lookup table

	ld	hl,(hl)				; load name pointer
	ld	(appPtr),hl
	
	inc	hl
	inc	hl
	inc	hl
DrawAppName:
	push	hl
	ld	a,(hl)
	or	a,a
	jr	z,DrawAppNameDone
	call	DrawChar
	pop	hl
	inc	hl
	jr	DrawAppName
DrawAppNameDone:
	pop	hl

	call	DrawAppIcon
	
	pop	hl
	pop	bc
	inc	hl
	inc	hl
	inc	hl
	dec	bc
	ld	a,b
	or	a,c
	jp	nz,DrawAppsLoop
	ret

	ret

SpecialAppFolder:
	or	a,a
	sbc	hl,hl
	ld	(totalAppSize),hl
	ld	hl,directorySprite
	jr	+_
DrawAppIcon:
	ld	hl,(appPtr)
	ld	a,(hl)
	or	a,a
	jr	z,SpecialAppFolder
	ld	hl,AppFileSprite
	
_:	ld	a,(posY)
	add	a,20
	ld	(posY),a
	sub	a,8+17
	ld	c,a
	ld	a,24
	ld	(posX),a
	ld	b,2
	push	hl
	call	_Sprite8bpp
	pop	hl
	
	bit	drawingSelected,(iy+asmFlag)
	jp	z,NotCurrentlyDrawingApp
	
	ld	de,(posX)
	ld	a,(posY)
	push	de
	push	af
	
	ld	bc,(240/2*256)+57
	call	_Sprite8bpp_2x
	ld	hl,(appPtr)
	ld	(currAppPtr),hl
	push	hl				; push the pointer
	pop	de
	ld	bc,$24
	add	hl,bc
	ld	hl,(hl)				; load location of info string
	add	hl,de 
	or	a,a 
	sbc	hl,de				; check if HL is 0
	jr	z,DrawNormalInfo
	add	hl,de				; add extra bytes
	bit	isAtBox,(iy+asmFlag)
	jr	nz,DrawNormalInfo
	call	DrawLowerDescription
	jr	SaveDrawing
DrawNormalInfo:
	call	PrintRAMAndROMFree
	SetDefaultTextColor()
SaveDrawing:
	call	DrawStaticInfo
	
	print(LanguageStr,199,107)
	ld	hl,appStr
	bit	isAtBox,(iy+asmFlag)
	jr	z,+_
	ld	hl,DirStr
_:	call	DrawString
	print(SizeStr,199,162)
	ld	hl,(currAppPtr)
	ld	bc,0-256
	add	hl,bc
	push	hl
	bit	isAtBox,(iy+asmFlag)
	jr	z,+_
	or	a,a
	sbc	hl,hl
	jr	++_
_:	push	hl
	call	_NextFieldFromType		; move to start of signature
	call	_NextFieldFromType		; move to end of signature
	pop	de
	or	a,a
	sbc	hl,de
	inc	hl
	inc	hl
	inc	hl				; bypass app size bytes
_:	call	ConvHL
	inc	hl
	call	DrawString
	print(MinVersionStr,199,129)
	ld	hl,minVersion
	bit	isAtBox,(iy+asmFlag)
	call	z,_os_GetAppVersionString
	pop	de
	add	hl,de
	or	a,a
	sbc	hl,de
	jr	nz,DrawDefaultStr
	ld	hl,minVersion
DrawDefaultStr:
	ld	de,199
	ld	(posX),de
	ld	a,140
	ld	(posY),a
	call	DrawString
	pop	af
	pop	de
	ld	(posX),de
	ld	(posY),a
NotCurrentlyDrawingApp:
	ret

totalAppSize:
	.dl	0
appPtr:
	.dl	0
currAppPtr:
	.dl	0
minVersion:
	.db	"5.0.0.0.0",0
appStr:
	.db	"App",0
