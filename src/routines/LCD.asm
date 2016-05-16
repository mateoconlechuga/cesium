;-------------------------------------------------------------------------------
ClearScreens:
	call	ClearVBuf1
ClearVBuf2:
	ld	hl,vBuf2
	jr	+_
ClearVBuf1:
	ld	hl,vBuf1
_:	ld	a,$FF
	ld	bc,lcdWidth*lcdHeight
	jp	_MemSet

;-------------------------------------------------------------------------------
CopyHL1555Palette:
	ld	hl,$E30200    ; palette mem
	ld	b,0
_:	ld	d,b
	ld	a,b
	and	a,%11000000
	srl	d
	rra
	ld	e,a
	ld	a,%00011111
	and	a,b
	or	a,e
	ld	(hl),a
	inc	hl
	ld	(hl),d
	inc	hl
	inc	b
	jr	nz,-_
	ret

;-------------------------------------------------------------------------------
FullBufCpy:
	ld	bc,lcdWidth*lcdHeight
	ld	hl,vBuf2
	ld	de,vBuf1
	ldir
	ret

;-------------------------------------------------------------------------------
_Sprite8bpp:
; hl -> sprite
; bc = xy
	push	hl
	or	a,a
	sbc	hl,hl
	ld	l,b
	add	hl,hl
	ld	de,vBuf2
	add	hl,de
	ld	b,lcdWidth/2
	mlt	bc
	add	hl,bc
	add	hl,bc				; hl -> start draw location
	ld	b,0
	ex	de,hl
	pop	hl
	ld	a,(hl)
	ld	(NoClipSprLineNext),a		; a = width
	inc	hl
	ld	a,(hl)				; a = height
	inc	hl
	ld	ix,0
NoClipSprLineNext =$+1
_:	ld	c,0
	add	ix,de
	lea	de,ix
	ldir
	ld	de,lcdWidth
	dec	a
	jr	nz,-_
	ret

;-------------------------------------------------------------------------------
_Sprite8bpp_2x:
; hl -> sprite
; bc = xy
	ld	a,(hl) 				; width
	ld	(SpriteWidth_2x_SMC),a
	push	hl
	ld	de,0
	add	a,a
	ld	e,a
	ld	hl,lcdWidth
	sbc	hl,de
	ld	(SpriteWidth255_2x_SMC),hl
	pop	hl
	inc	hl
	push	hl
	ld	l,c
	ld	h,lcdWidth/2
	mlt	hl
	add	hl,hl
	ld	de,vBuf2
	add	hl,de
	push	hl
	sbc	hl,hl
	ld	l,b
	add	hl,hl
	pop	de
	add	hl,de  				; Add X ; Returns hl -> sprite data, a = sprite height
	ex	de,hl
	pop	hl
	ld	b,(hl)
	inc	hl
InLoop8bpp_2x:
	push	bc
SpriteWidth_2x_SMC: =$+1
	ld	bc,0
	push	de				; save pointer to current line
_:	ld	a,(hl)
	ld	(de),a
	inc	de
	ld	(de),a
	inc	de
	inc	hl
	dec	bc
	ld 	a,b
	or	a,c
	jr	nz,-_
	ex	de,hl
SpriteWidth255_2x_SMC: =$+1
	ld	bc,0				; Increment amount per line
	add	hl,bc				; HL->next place to draw, DE->location to get from
	push	de
	pop	ix				; ix->location to get from
	ex	de,hl				; hl
	ld	hl,(SpriteWidth_2x_SMC)
	add	hl,hl
	ld	b,h
	ld	c,l				; BC=real size to copy
	pop	hl				; HL->pervious line
	ldir
	ex	de,hl
	ld	bc,(SpriteWidth255_2x_SMC)
	add	hl,bc
	lea	de,ix
	ex	de,hl
	pop	bc
	djnz	InLoop8bpp_2x
	ret

;-------------------------------------------------------------------------------
FillRectangle:
; bc = width
; ixh = height
; hl = x coordinate
; e = y coordinate
; a = color
	ld	d,lcdWidth/2
	mlt	de
	add	hl,de
	add	hl,de
	ex	de,hl
FillRectangle_Computed:
	ld	ix,vBuf2			; de -> place to begin drawing
	ld	(_RectangleWidth_SMC),bc
_Rectangle_Loop_NoClip:
	add	ix,de
	lea	de,ix
_RectangleWidth_SMC =$+1
	ld	bc,0
	ld	hl,skinColor
	ldi					; check if we only need to draw 1 pixel
	jp	po,_Rectangle_NoClip_Skip
	scf
	sbc	hl,hl
	add	hl,de
	ldir					; draw the current line
_Rectangle_NoClip_Skip:
	ld	de,lcdWidth			; move to next line
	dec	a
	jr	nz,_Rectangle_Loop_NoClip
	ret

;-------------------------------------------------------------------------------
RectangleOutline:
; Draws an unclipped rectangle outline with the global color index
; Arguments:
; hl : top x left
; e  : top y left
; bc : bot x right
; d  : bot y right
; Returns:
;  None
	ld	a,(cIndex)			; color index to use
	push	bc
	push	hl
	push	de
	call	_RectHoriz_ASM			; top horizontal line
	pop	bc
	push	bc
	call	_RectVert_ASM			; left vertical line
	pop	bc
	pop	hl
	ld	e,c
	call	_VertLine_ASM			; right vertical line
	pop	bc
	jp	_MemSet				; bottom horizontal line

_RectHoriz_ASM:
	ld	d,lcdWidth/2
	mlt	de
	add	hl,de
	add	hl,de
	ld	de,vBuf2
	add	hl,de				; hl -> place to draw
	jp	_MemSet

_VertLine_ASM:
	dec	b
	ld	d,lcdWidth/2
	mlt	de
	add	hl,de
	add	hl,de
	ld	de,vBuf2
	add	hl,de				; hl -> drawing location
_RectVert_ASM:
	ld	de,lcdWidth
_:	ld	(hl),a				; loop for height
	add	hl,de
	djnz	-_
	ret

;-------------------------------------------------------------------------------
DrawVLine8:
cIndex =$+1
	ld	a,0
_:	ld	(hl),a
	ld	de,lcdWidth
	add	hl,de
	djnz	-_
	ret

;-------------------------------------------------------------------------------
; Common Sprites
;-------------------------------------------------------------------------------
asmFileSprite:
 .db 16,16
 .db 255,255,255,093,125,125,125,125,125,125,019,019,255,255,255,255
 .db 255,255,255,125,255,255,223,223,223,223,125,019,019,255,255,255
 .db 255,255,255,125,255,255,255,223,223,223,223,125,125,019,255,255
 .db 255,255,255,125,255,255,255,223,223,223,223,125,255,125,019,255
 .db 255,255,255,125,255,255,255,255,223,223,223,125,191,191,125,019
 .db 255,255,255,125,255,255,255,255,255,223,223,223,223,223,125,019
 .db 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,019
 .db 000,255,255,255,255,255,255,255,255,255,255,255,255,255,000,019
 .db 000,255,160,160,160,255,160,160,160,255,160,255,160,255,000,019
 .db 000,255,160,255,160,255,160,255,255,255,160,160,160,255,000,019
 .db 000,255,160,160,160,255,255,255,160,255,160,255,160,255,000,019
 .db 000,255,160,255,160,255,160,160,160,255,160,255,160,255,000,019
 .db 000,255,255,255,255,255,255,255,255,255,255,255,255,255,000,019
 .db 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,019
 .db 255,255,255,019,255,255,255,255,255,255,255,255,255,255,255,019
 .db 255,255,255,018,019,019,019,019,019,019,019,019,019,019,019,018
cFileSprite:
 .db 16,16
 .db 255,255,255,093,125,125,125,125,125,125,019,019,255,255,255,255
 .db 255,255,255,125,255,255,223,223,223,223,125,019,019,255,255,255
 .db 255,255,255,125,255,255,255,223,223,223,223,125,125,019,255,255
 .db 255,255,255,125,255,255,255,223,223,223,223,125,255,125,019,255
 .db 255,255,255,125,255,255,255,255,223,223,223,125,191,191,125,019
 .db 255,255,255,125,255,255,255,255,255,223,223,223,223,223,125,019
 .db 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,019
 .db 000,255,255,255,255,255,255,255,255,255,255,255,255,255,000,019
 .db 000,255,255,255,255,255,019,019,019,255,255,255,255,255,000,019
 .db 000,255,255,255,255,255,019,255,255,255,255,255,255,255,000,019
 .db 000,255,255,255,255,255,019,255,255,255,255,255,255,255,000,019
 .db 000,255,255,255,255,255,019,019,019,255,255,255,255,255,000,019
 .db 000,255,255,255,255,255,255,255,255,255,255,255,255,255,000,019
 .db 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,019
 .db 255,255,255,019,255,255,255,255,255,255,255,255,255,255,255,019
 .db 255,255,255,018,019,019,019,019,019,019,019,019,019,019,019,018
basicFileSprite:
 .db 16,16
 .db 255,255,255,093,125,125,125,125,125,125,019,019,255,255,255,255
 .db 255,255,255,125,255,255,223,223,223,223,125,019,019,255,255,255
 .db 255,255,255,125,255,255,255,223,223,223,223,125,125,019,255,255
 .db 255,255,255,125,255,255,255,223,223,223,223,125,255,125,019,255
 .db 255,255,255,125,255,255,255,255,223,223,223,125,191,191,125,019
 .db 255,255,255,125,255,255,255,255,255,223,223,223,223,223,125,019
 .db 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,019
 .db 000,255,255,255,255,255,255,255,255,255,255,255,255,255,000,019
 .db 000,255,255,255,227,227,227,255,227,227,227,255,255,255,000,019
 .db 000,255,255,255,255,227,255,255,255,227,255,255,255,255,000,019
 .db 000,255,255,255,255,227,255,255,255,227,255,255,255,255,000,019
 .db 000,255,255,255,255,227,255,255,227,227,227,255,255,255,000,019
 .db 000,255,255,255,255,255,255,255,255,255,255,255,255,255,000,019
 .db 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,019
 .db 255,255,255,019,255,255,255,255,255,255,255,255,255,255,255,019
 .db 255,255,255,018,019,019,019,019,019,019,019,019,019,019,019,018
lockedSprite:
 .db 6,8
 .db 255,75,75,75,75,255
 .db 255,75,255,255,75,255
 .db 255,75,255,255,75,255
 .db 75,75,75,75,75,75
 .db 75,228,228,228,228,75
 .db 75,228,228,228,228,75
 .db 75,228,228,228,228,75
 .db 75,75,75,75,75,75
archivedSprite:
 .db 6,8
 .db 75,75,75,75,75,75
 .db 75,255,75,255,255,75
 .db 75,255,255,75,255,75
 .db 75,255,75,255,255,75
 .db 75,228,228,75,228,75
 .db 75,228,75,228,228,75
 .db 75,228,228,75,228,75
 .db 75,75,75,75,75,75
batterySprite:
 .db 6,8
 .db 000,000,000,000,000,000
 .db 000,037,037,037,037,000
 .db 000,037,037,037,037,000
 .db 000,037,037,037,037,000
 .db 000,037,037,037,037,000
 .db 000,037,037,037,037,000
 .db 000,037,037,037,037,000
 .db 000,000,000,000,000,000
