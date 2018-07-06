squish_program:
	call	util_install_error_handler
	call	util_move_prgm_name_to_op1
	ld	de,basic_prog
	ld	hl,OP1
	call	_Mov9b
	ld	hl,OP1
	ld	de,backup_prgm_name
	call	_Mov9b
	ld	bc,(prgm_real_size)
	dec	bc
	dec	bc
	push	bc
	bit	0,c
	jp	nz,_ErrSyntax
	srl	b
	rr	c
	push	bc
	push	bc
	pop	hl
	call	_EnoughMem
	pop	hl
	pop	bc
	jp	c,_ErrMemory
	push	bc
	ld	de,userMem
	ld	(asm_prgm_size),hl
	call	_InsertMem
	ld	hl,(prgm_data_ptr)
	ld	a,(prgm_data_ptr + 2)
	cp	a,$d0
	jr	c,.not_in_ram
	call	util_move_prgm_name_to_op1
	call	_ChkFindSym
	ex	de,hl
	inc	hl
	inc	hl
.not_in_ram:
	inc	hl
	inc	hl
	ld	(begPC),hl
	ld	(curPC),hl
	ld	de,userMem
	pop	bc
.squish_me:
	ld	a,b
	or	a,c
	jp	z,execute_assembly_program
	push	hl
	ld	hl,(curPC)
	inc	hl
	ld	(curPC),hl
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
	call	_SHLAcc
	add	a,e
	pop	hl
	pop	bc
	ret
.squishy_check_byte:
	cp	a,$30
	jp	c,_ErrSyntax
	cp	a,$3A
	jr	nc,.skip
	sub	a,$30
	ret
.skip:
	cp	a,$41
	jp	c,_ErrSyntax
	cp	a,$47
	jp	nc,_ErrSyntax
	sub	a,$37
	ret
