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
	call	ti.PushOP1
	ld	hl,setting_editor_name
	call	ti.Mov9ToOP1
	call	ti.ChkFindSym
	push	af
	call	ti.PopOP1
	pop	af
	jp	c,.no_external_editor
	call	ti.AnsName			; need to write new ans variable
	call 	ti.FindSym
	call	nc,ti.DelVar
	call	ti.AnsName			; write to ans
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
	ld	(hl),ti.tColon
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
	call	ti.CreateStrng
	pop	bc
	inc	de
	inc	de
	ld	hl,string_temp
	ldir					; copied name to ans
	ld	hl,setting_editor_name
	call	ti.Mov9ToOP1
	res	prgm_is_basic,(iy + prgm_flag)	; not a basic program
	jp	execute_program.entry		; launch the editor

.no_external_editor:
	call	ti.PushOP1			; for restoring in hook
	call	ti.ChkFindSym
	call	ti.ChkInRam
	jr	z,.not_archived
	ld	a,edit_archived
	ld	(edit_status),a
	call	cesium.Arc_Unarc
.not_archived:
	ld	hl,hook_app_change
	call	ti.SetAppChangeHook
	call	util_setup_shortcuts
	xor	a,a
	ld	(ti.menuCurrent),a
	call	ti.CursorOff
	call	ti.RunIndicOff
	call	lcd_normal
	ld	hl,string_temp			; contains OP1
	push	hl
	ld	de,ti.progToEdit
	call	ti.Mov9b
	pop	hl
	dec	hl
	ld	de,ti.basic_prog
	call	ti.Mov9b
	ld	a,ti.cxPrgmEdit
	call	ti.NewContext
	xor	a,a
	ld	(ti.winTop),a
	call	ti.ScrollUp
	call	ti.HomeUp
	ld	a,':'
	call	ti.PutC
	ld	a,(edit_mode)
	or	a
	jr	z,.goto_none

	ld	hl,(ti.editTop)
	ld	de,(ti.editCursor)
	compare_hl_de
	jr	nz,.goto_end

	ld	bc,0
error_offset := $-3
	call	ti.ChkBCIs0
	jr	z,.goto_end
	ld	hl,(ti.editTail)
	ldir
	ld	(ti.editTail),hl
	ld	(ti.editCursor),de
	call	.goto_new_line
.goto_end:
	call	ti.DispEOW
	ld	hl,$100
	ld.sis	(ti.curRow and $ffff),hl
	jr	.skip

.goto_none:
	call	ti.DispEOW
	ld	hl,$100
	ld.sis	(ti.curRow and $ffff),hl
	call	ti.BufToTop
.skip:
	xor	a,a
	ld	(ti.menuCurrent),a
	set	7,(iy + $28)
	jp	ti.Mon

.goto_new_line:
	ld	hl,(ti.editCursor)
	ld	a,(hl)
	cp	a,ti.tEnter
	jr	z,.goto_new_line_back
.loop:
	ld	a,(hl)
	ld	de,(ti.editTop)
	or	a,a
	sbc	hl,de
	ret	z
	add	hl,de
	dec	hl
	push	af
	ld	a,(hl)
	call	ti.Isa2ByteTok
	pop	de
	jr	z,.goto_new_line_back
	ld	a,d
	cp	a,ti.tEnter
	jr	z,.goto_new_line_next
.goto_new_line_back:
	call	ti.BufLeft
	ld	hl,(ti.editCursor)
	jr	.loop
.goto_new_line_next:
	jp	ti.BufRight

compute_error_offset:
	ld	hl,(ti.curPC)
	ld	bc,(ti.begPC)
	or	a,a
	sbc	hl,bc
	ld	(error_offset),hl
	ret

