;-------------------------------------------------------------------------------
DrawTime:
	ld	a,(ClockDisp)
	or	a,a
	ret	z
	set	clockOn,(iy+clockFlags)
	set	useTokensInString,(iy+clockFlags)
	ld	de,OP6
	push	de
	call	_FormTime
	pop	hl
	ld	bc,(posX)
	push	bc
	ld	a,(posY)
	push	af
	ld	bc,255
	ld	(posX),bc
	ld	a,7
	ld	(posY),a
	SetInvertedTextColor()
	call	DrawString
	SetDefaultTextColor()
	pop	af
	ld	(posY),a
	pop	bc
	ld	(posX),bc
	di
	ret
 
;-------------------------------------------------------------------------------
DrawMainOSThings:
	call	ClearVBuf2
	SetInvertedTextColor()
	drawRectFilled(1,1,319,21)
	call	ClearLowerBar
	ld	a,107
	ld	(cIndex),a
	drawRectOutline(1,22,318,223)
	print(CesiumTitle,15,7)
	print(RAMFreeStr,4,228)
	call	_MemChk
	call	ConvHL
	inc	hl
	call	DrawString
	print(ROMFreeStr,196,228)
	call	_ArcChk
	ld	hl,(tempFreeArc)
	call	ConvHL
	call	DrawString
	drawSpr255(batterySprite, 3,7)
	ld	a,255
	ld	(cIndex),a
CesiumBatteryStatus: =$+1
	ld	a,0
	or	a,a
	ret	z
	ld	bc,4
	ld	de,(lcdWidth*8)+7
	jp	FillRectangle_Computed
 
ClearLowerBar:
	push	bc
	drawRectFilled(1,225,319,239)
	pop	bc
	ret
