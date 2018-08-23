; entry points
; required: OP1 = name of program to edit
edit_basic_program_goto:
	call	compute_error_offset
	ld	a,edit_goto
	ld	(edit_mode),a
	jr	edit_basic_program.entry
edit_basic_program:
	xor	a,a
	sbc	hl,hl
	ld	(error_offset),hl		; perhaps in future restore location?
	ld	(edit_mode),a
.entry:
	xor	a,a
	ld	(edit_status),a
	call	util_backup_prgm_name
	call	util_op1_to_temp
	call	_PushOP1
	ld	hl,setting_editor_name
	call	_Mov9ToOP1
	call	_ChkFindSym
	push	af
	call	_PopOP1
	pop	af
	jp	c,.no_external_editor
	call	_AnsName			; need to write new ans variable
	call 	_FindSym
	call	nc,_DelVar
	call	_AnsName			; write to ans
	ld	bc,0
	ld	hl,string_temp
.namelen:
	ld	a,(hl)
	or	a,a
	jr	z,.namedone
	inc	bc
	inc	hl
	jr	.namelen
.namedone:					; hl -> end of string
	push	bc
	push	hl
	ld	hl,(error_offset)		; check if append offset
	compare_hl_zero
	pop	hl
	jr	nz,.addoffset
	xor	a,a
	sbc	hl,hl				; no length to add
	jr	.noaddoffset
.addoffset:
	ld	(hl),tColon
	inc	hl
	push	hl
	ld	hl,(error_offset)
	call	util_num_convert		; de -> number string
	pop	hl				; hl -> output string
	ld	bc,1
.numlen:
	ld	a,(de)
	or	a,a
	jr	z,.numdone
	cp	a,'0'
	jr	z,.numskip
	ld	(hl),a
	inc	hl
	inc	bc
.numskip:
	inc	de
	jr	.numlen
.numdone:					; hl -> end of string
	push	bc
	pop	hl				; hl = appended length
.noaddoffset:
	pop	bc
	add	hl,bc
	push	hl
	call	_CreateStrng
	pop	bc
	inc	de
	inc	de
	ld	hl,string_temp
	ldir					; copied name to ans
	ld	hl,setting_editor_name
	call	_Mov9ToOP1
	res	prgm_is_basic,(iy + prgm_flag)	; not a basic program
	jp	execute_program.entry		; launch the editor

.no_external_editor:
	call	_PushOP1			; for restoring in hook
	call	_ChkFindSym
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
	ld	hl,string_temp			; contains OP1
	push	hl
	ld	de,progToEdit
	call	_Mov9b
	pop	hl
	dec	hl
	ld	de,basic_prog
	call	_Mov9b
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

