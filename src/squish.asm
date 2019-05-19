squish_program:
	ld	hl,return_asm_error
	call	ti.PushErrorHandler
	ld	(persistent_sp),sp
	call	util_move_prgm_name_to_op1
	ld	de,ti.basic_prog
	ld	hl,ti.OP1
	call	ti.Mov9b
	ld	hl,ti.OP1
	ld	de,backup_prgm_name
	call	ti.Mov9b
	ld	bc,(prgm_real_size)
	dec	bc
	dec	bc
	push	bc
	bit	0,c
	jp	nz,ti.ErrSyntax
	srl	b
	rr	c
	push	bc
	push	bc
	pop	hl
	call	ti.EnoughMem
	pop	hl
	pop	bc
	jp	c,ti.ErrMemory
	push	bc
	ld	de,ti.userMem
	ld	(ti.asm_prgm_size),hl
	call	ti.InsertMem
	ld	hl,(prgm_data_ptr)
	ld	a,(prgm_data_ptr + 2)
	cp	a,$d0
	jr	c,.not_in_ram
	call	util_move_prgm_name_to_op1
	call	ti.ChkFindSym
	ex	de,hl
	inc	hl
	inc	hl
.not_in_ram:
	inc	hl
	inc	hl
	ld	(ti.begPC),hl
	ld	(ti.curPC),hl
	ld	de,ti.userMem
	pop	bc
.squish_me:
	ld	a,b
	or	a,c
	jp	z,execute_assembly_program
	push	hl
	ld	hl,(ti.curPC)
	inc	hl
	ld	(ti.curPC),hl
	pop	hl
	dec	bc
	ld	a,(hl)
	inc	hl
	cp	a,$3f
	jr	z,.squish_me
	push	de
	call	.squishy_check_byte
	ld	d,a
	ld	a,(hl)
	inc	hl
	call	.squishy_check_byte
	ld	e,a
	call	.squishy_convert_byte
	pop	de
	ld	(de),a
	inc	de
	dec	bc
	jr	.squish_me

.squishy_convert_byte:
	push	bc
	push	hl
	ld	a,d
	call	ti.ShlACC
	add	a,e
	pop	hl
	pop	bc
	ret
.squishy_check_byte:
	cp	a,$30
	jp	c,ti.ErrSyntax
	cp	a,$3A
	jr	nc,.skip
	sub	a,$30
	ret
.skip:
	cp	a,$41
	jp	c,ti.ErrSyntax
	cp	a,$47
	jp	nc,ti.ErrSyntax
	sub	a,$37
	ret
