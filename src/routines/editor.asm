EditBasicPrgm:
	bit	pgrmLocked,(iy+pgrmStatus)
	jp	nz,MAIN_START_LOOP
	bit	isBasic,(iy+pgrmStatus)
	jp	z,MAIN_START_LOOP
	call	GetProgramName
	ld	a,(OP1)
	cp	a,5
	jp	nz,MAIN_START_LOOP
	call	_ChkFindSym
	xor	a,a
	jr	EditStart
EditGoto:
	call	SetErrOffset
	ld	a,$ff
EditStart:
	ld	(EditMode),a
	xor	a,a
	ld	(EditStatus),a
	call	_ChkInRam
	jr	z,EditNotArchived
	ld	a,$ff
	ld	(EditStatus),a
	call	_Arc_Unarc
EditNotArchived:
APP_CHANGE_HOOK:
	ld	hl,0
	call	_SetAppChangeHook
	xor	a,a
	ld	(menuCurrent),a
	call	_CursorOff
	call	_RunIndicOff
	call	_boot_ClearVRAM
	ld	a,$2D
	ld	(mpLcdCtrl),a
	call	_DrawStatusBar
	call	_PushOP1
	ld	hl,OP1
	ld	(hl),5
	inc	hl
	ld	de,progToEdit
	ld	bc,9
	ldir
	xor	a,a
	ld	(de),a
	ld	hl,OP1
	ld	de,BASIC_PROG
	ld	bc,9
	ldir
	xor	a,a
	ld	(de),a
	ld	a,kPrgmEd
	call	_NewContext
	xor	a,a
	ld	(winTop),a
	call	_ScrollUp
	call	_Homeup
	ld	a,':'
	call	_PutC
	ld	a,(EditMode)
	or	a
	jr	z,_edit_no_goto

	ld	hl,(editTop)
	ld	de,(editCursor)
	call	_CpHLDE
	jr	nz,_edit_goto_end

	ld	bc,(errOffset)
	call	_ChkBCIs0
	jr	z,_edit_goto_end
	ld	hl,(editTail)
	ldir
	ld	(editTail),hl
	ld	(editCursor),de
	call	_edit_goto_new_line
_edit_goto_end:
	call	_DispEOW
	ld	hl,0100h
	ld.sis	(curRow & $ffff),hl
	jr	_edit_skip

_edit_no_goto:
	call	_DispEOW
	ld	hl,0100h
	ld.sis	(curRow & $ffff),hl
	call	_BufToTop
_edit_skip:
	xor	a,a
	ld	(MenuCurrent),a
	set	7,(iy+28h)
	jp	_Mon

_edit_goto_new_line:
	ld	hl,(editCursor)
	ld	a,(hl)
	cp	a,$3F
	jr	z,_edit_goto_new_line_back
_edit_goto_new_line_loop:
	ld	a,(hl)
	ld	de,(editTop)
	or	a,a
	sbc	hl,de
	ret	z
	add	hl,de
	dec	hl
	push	af
	ld	a,(hl)
	call	_IsA2ByteTok
	pop	de
	jr	z,_edit_goto_new_line_back
	ld	a,d
	cp	a,$3F
	jr	z,_edit_goto_new_line_next
_edit_goto_new_line_back:
	call	_BufLeft
	ld	hl,(editCursor)
	jr	_edit_goto_new_line_loop
_edit_goto_new_line_next:
	jp	_BufRight

SetErrOffset:
	ld	hl,(curPC)
	ld	bc,(begPC)
	or	a,a
	sbc	hl,bc
	ld	(errOffset),hl
	ret
