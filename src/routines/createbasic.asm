_CreateBASICPrgm:				; Create a BASIC prgm called 'A'
	ld	hl,Aname
	call	_Mov9ToOP1			; move to name to OP1
	call	_ChkFindSym			; try to find it
	ret	nc				; return if it exists
	ld	hl,Aend-Astart
	push	hl
	call	_CreateProtProg
	pop	bc
	inc	de
	inc	de				; bypass size bytes
	ld	hl,Astart
	ldir					; copy in the data
	ret					; return

Aname:	.db 6,"A",0
Astart:
	.db $BB,$6A,"_CESIUM"		; Asm(prgmCESIUM
Aend: