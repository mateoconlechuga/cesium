; Copyright 2015-2020 Matt "MateoConLechuga" Waltz
; 
; Redistribution and use in source and binary forms, with or without
; modification, are permitted provided that the following conditions are met:
; 
; 1. Redistributions of source code must retain the above copyright notice,
;    this list of conditions and the following disclaimer.
; 
; 2. Redistributions in binary form must reproduce the above copyright notice,
;    this list of conditions and the following disclaimer in the documentation
;    and/or other materials provided with the distribution.
; 
; 3. Neither the name of the copyright holder nor the names of its contributors
;    may be used to endorse or promote products derived from this software
;    without specific prior written permission.
; 
; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
; AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
; IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
; ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
; LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
; CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
; SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
; INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
; CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
; ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
; POSSIBILITY OF SUCH DAMAGE.

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
