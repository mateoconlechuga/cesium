;-------------------------------------------------------------------------------
FindPrograms:
	ld	hl,(progptr)
findloop:
	ld	de,(ptemp)			; check to see if we're at the end of the symbol table
	or	a,a
	sbc	hl,de
	ret	z
	ret	c
	add	hl,de				; restore HL
	ld	a,(hl)				; check the [t] of entry, take appropriate action
	and	a,$1F				; bitmask off bits 7-5 to get type only.
	cp	a,progobj			; check if progrm
	jr	z,isnormalprog
	cp	a,protprogobj			; check if protected progrm
	jp	nz,SkipEntry
isnormalprog:					; at this point, HL->[t], so we'll move back six bytes to [nl]
	dec	hl
	dec	hl
	dec	hl				; HL->[DAL]
	ld	e,(hl)
	dec	hl
	ld	d,(hl)
	dec	hl
	ld	a,(hl)
	call	_SetDEUToA			; silly system calls
	dec	hl
	push	hl
	call	GetDataPtr			; HL->totalPrgmSize bytes
	inc	hl
	inc	hl
	ld	a,(hl)
	cp	a,tExtTok			; ASM prgm?
	jr	z,CheckNextASMbyte
PrgmIsBASIC:
	ld	a,$BB				; $BB == BASIC prgm
	jr	GotPrgmType
CheckNextASMbyte:
	inc	hl
	ld	a,(hl)
	cp	a,tAsm84CECmp
	jr	nz,PrgmIsBASIC			; is it basic?
	xor	a,a
	ld	(AsmCBasic_SMC),a		; reset the default to an ASM prgm
	inc	hl
	ld	a,(hl)
	or	a,a				; NOP byte for C programs
	jr	nz,RegularAsmType
	ld	a,$CE
GotPrgmType:
	ld	(AsmCBasic_SMC),a		; $CE=CPrgm,$BB=BasicPrgm,$00=ASMPrgm
RegularAsmType:
	pop	hl
	dec	hl
	ld	a,(hl)
	cp	a,'A'
	jr	nz,NotprgmA			; we don't want to display prgmA because that is the loader
	inc	hl
	ld	a,(hl)
	dec	hl
	dec	a
	jr	nz,NotprgmA
	jp	NotValid
NotprgmA:
	cp	a,'!'				; system variable
	jp	z,NotValid
	cp	a,'#'				; system variable
	jr	z,NotValid
	cp	a,27				; hidden?
	jr	nc,NotHid
	add	a,64				; i honestly have no idea why this has to be here, but it does
NotHid:
numprograms: =$+1
	ld	bc,0
	inc	bc
	ld	(numprograms),bc		; increase the number of programs found
	inc	hl
	ex	de,hl
programNameLocationsPtr: =$+1			; this is the location to store the pointers to the prgm's VAT entry
	ld	hl,0
	ld	(hl),de
	inc	hl
	inc	hl
	inc	hl
AsmCBasic_SMC: =$+1
	ld	(hl),0
	inc	hl				; 4 bytes; pointer to name size byte+type of program
	ld	(programNameLocationsPtr),hl
	ex	de,hl
	ld	de,0
	jr	BypassName
NotValid:
	ld	de,0
	inc	hl
	jr	BypassName
SkipEntry:					; skip an entry
	ld	de,6
	or	a,a
	sbc	hl,de
BypassName:
	ld	e,(hl)				; put name length in e to skip
	inc	e				; add 1 to go to [t] of next entry
	sbc	hl,de
	jp	findloop

;-------------------------------------------------------------------------------
GetDataPtr:					; gets a pointer to the data of an archived program
	cp	a,$D0
	ex 	de,hl
	ret	nc
	ld	de,9
	add	hl,de				; skip VAT stuff
	ld	e,(hl)
	add	hl,de
	inc	hl					; size of name
	ret					; HL->totalPrgmSize bytes
