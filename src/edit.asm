edit_basic_program_goto:
	call	compute_error_offset
	ld	a,$ff
edit_basic_program:
	ld	(edit_mode),a
	xor	a,a
	ld	(edit_status),a
	call	_ChkInRam
	jr	z,.not_archived
	ld	a,$ff
	ld	(edit_status),a
	call	_Arc_Unarc
.not_archived:
	ld	hl,0
app_change_hook_ptr =$-3
	call	_SetAppChangeHook
	xor	a,a
	ld	(menuCurrent),a
	call	_CursorOff
	call	_RunIndicOff
	call	lcd_normal
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
	ld	de,basic_prog
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
	ld	a,(edit_mode)
	or	a
	jr	z,.goto_none

	ld	hl,(editTop)
	ld	de,(editCursor)
	compare_hl_de
	jr	nz,.goto_end

	ld	bc,0
error_offset := $-3
	call	_ChkBCIs0
	jr	z,.goto_end
	ld	hl,(editTail)
	ldir
	ld	(editTail),hl
	ld	(editCursor),de
	call	.goto_new_line
.goto_end:
	call	_DispEOW
	ld	hl,$100
	ld.sis	(curRow and $ffff),hl
	jr	.skip

.goto_none:
	call	_DispEOW
	ld	hl,$100
	ld.sis	(curRow and $ffff),hl
	call	_BufToTop
.skip:
	xor	a,a
	ld	(menuCurrent),a
	set	7,(iy + $28)
	jp	_Mon

.goto_new_line:
	ld	hl,(editCursor)
	ld	a,(hl)
	cp	a,$3f
	jr	z,.goto_new_line_back
.loop:
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
	jr	z,.goto_new_line_back
	ld	a,d
	cp	a,$3f
	jr	z,.goto_new_line_next
.goto_new_line_back:
	call	_BufLeft
	ld	hl,(editCursor)
	jr	.loop
.goto_new_line_next:
	jp	_BufRight

compute_error_offset:
	ld	hl,(curPC)
	ld	bc,(begPC)
	or	a,a
	sbc	hl,bc
	ld	(error_offset),hl
	ret
