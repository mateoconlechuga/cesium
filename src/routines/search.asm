;-------------------------------------------------------------------------------
SearchAlpha:
; Search for first program with the first char in A
	ld	hl,CharTableNormal
	call	_AddHLAndA		; find the offset
	ld	a,(hl)
	or	a,a
	jp	z,GetKeys
	ld	(SearchChar),a
	xor	a,a
	sbc	hl,hl
	ld	(currSel),a
	ld	(currSelAbs),hl
	ld	(scrollamt),hl
	ld	hl,pixelshadow2
	ld	bc,(PrgmCountDisp)	; loop through the prgms
FindAlpha:
	ld	de,(hl)			; pointer to program name size
	dec	de
	ld	a,(de)
	cp	a,64
	jr	nc,+_
	add	a,64
_:
SearchChar: =$+1
	cp	a,0
	jr	nc,FoundIt
	push	hl
	call	GetNextPrgmDown
	pop	hl
	inc	hl
	inc	hl
	inc	hl
	inc	hl
	dec	bc
	ld	a,b
	or	a,c
	jr	nz,FindAlpha
FoundIt:
	jp	MAIN_START_LOOP

;-------------------------------------------------------------------------------
SearchAlphaName:
	call	_StrLength
	ld	a,c
	ld	(length_SMC),a
	push	hl
	xor	a,a
	sbc	hl,hl
	ld	(currSel),a
	ld	(currSelAbs),hl
	ld	(scrollamt),hl
	ld	hl,pixelshadow2
	ld	bc,(PrgmCountDisp)	; loop through the prgms
	pop	ix
	dec	ix
FindAlphaName:
	ld	de,(hl)			; pointer to program name size
	
	push	bc
	push	ix
length_SMC =$+1
	ld	b,0
_:	dec	de
	inc	ix
	ld	a,(de)
	cp	a,(ix)
	jr	nz,+_
	djnz	-_
	pop	ix
	pop	bc
	jr	FoundIt

_:	pop	ix
	pop	bc
	push	hl
	call	GetNextPrgmDown
	pop	hl
	inc	hl
	inc	hl
	inc	hl
	inc	hl
	dec	bc
	ld	a,b
	or	a,c
	jr	nz,FindAlphaName
	jr	FoundIt