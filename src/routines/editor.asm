EditBasicPrgm:
	bit	isBasic,(iy+pgrmStatus)
	jp	z,MAIN_START_LOOP
	xor	a,a
	ld	hl,(prgmNamePtr)
	call	NamePtrToOP1
	call	_ChkFindSym
_edit_jump:
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
	; hm
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
