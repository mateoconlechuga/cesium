edit_basic_program_goto:
	call	compute_error_offset
	ld	a,edit_goto
edit_basic_program:
	ld	(edit_mode),a
	xor	a,a
	ld	(edit_status),a
	call	_ChkInRam
	jr	z,.not_archived
	ld	a,edit_archived
	ld	(edit_status),a
	call	_Arc_Unarc
.not_archived:
	ld	hl,hook_app_change
	call	_SetAppChangeHook
	xor	a,a
	ld	(menuCurrent),a
	call	_CursorOff
	call	_RunIndicOff
	call	lcd_normal
	ld	hl,OP1
	ld	(hl),progObj
	push	hl
	call	_PushOP1			; save return
	ld	hl,edit_prgm_name
	call	_Mov9ToOP1
	call	_ChkFindSym
	jr	c,.no_external_edit
.no_external_edit:
	call	_PopOP1
	pop	hl
	inc	hl
	ld	de,progToEdit
	call	_Mov9b
	ld	hl,OP1
	ld	de,basic_prog
	call	_Mov9b
	call	util_backup_prgm_name
	ld	a,cxPrgmEdit
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

edit_prgm_name:
	db	protProgObj,"KEDIT",0
