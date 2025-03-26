; Copyright 2015-2024 Matt "MateoConLechuga" Waltz
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
	ld	hl,(ti.appChangeHookPtr)
	ld	(backup_app_change_hook_location),hl
	ld	hl,hook_app_change
	call	ti.SetAppChangeHook
	call	util_setup_shortcuts
	xor	a,a
	ld	(ti.menuCurrent),a
	call	ti.CursorOff
	call	ti.RunIndicOff
	call	lcd_normal
	call	ti.DrawStatusBar
	ld	hl,string_temp			; contains OP1
	push	hl
	ld	de,ti.progToEdit
	call	ti.Mov9b
	pop	hl
	dec	hl
	ld	de,ti.basic_prog
	call	ti.Mov9b
	edit_helper.run

relocate edit_helper, ti.cursorImage + 256
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

	ld	bc,(error_offset)
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
end relocate

compute_error_offset:
	ld	hl,(ti.curPC)
	ld	bc,(ti.begPC)
	or	a,a
	sbc	hl,bc
	ld	(error_offset),hl
	ret

; Password input handling
password_input:
	ld	hl,setting_password + 1
	ld	b,password_max_length
	ld	c,0
	ld	de,password_input_buffer
.loop:
	call	ti.GetCSC
	cp	a,ti.skDel
	jr	z,.del_key
	cp	a,ti.skClear
	jr	z,.clear_key
	cp	a,ti.skOn
	jr	z,.on_key
	cp	a,ti.sk2nd
	jr	z,.submit_key
	cp	a,ti.skEnter
	jr	z,.submit_key
	cp	a,ti.skClear
	jr	z,.clear_key
	cp	a,ti.skDel
	jr	z,.del_key
	cp	a,ti.skOn
	jr	z,.on_key
	cp	a,ti.sk2nd
	jr	z,.submit_key
	cp	a,ti.skEnter
	jr	z,.submit_key
	cp	a,ti.skClear
	jr	z,.clear_key
	cp	a,ti.skDel
	jr	z,.del_key
	cp	a,ti.skOn
	jr	z,.on_key
	cp	a,ti.sk2nd
	jr	z,.submit_key
	cp	a,ti.skEnter
	jr	z,.submit_key
	cp	a,ti.skClear
	jr	z,.clear_key
	cp	a,ti.skDel
	jr	z,.del_key
	cp	a,ti.skOn
	jr	z,.on_key
	cp	a,ti.sk2nd
	jr	z,.submit_key
	cp	a,ti.skEnter
	jr	z,.submit_key
	cp	a,ti.skClear
	jr	z,.clear_key
	cp	a,ti.skDel
	jr	z,.del_key
	cp	a,ti.skOn
	jr	z,.on_key
	cp	a,ti.sk2nd
	jr	z,.submit_key
	cp	a,ti.skEnter
	jr	z,.submit_key
	cp	a,ti.skClear
	jr	z,.clear_key
	cp	a,ti.skDel
	jr	z,.del_key
	cp	a,ti.skOn
	jr	z,.on_key
	cp	a,ti.sk2nd
	jr	z,.submit_key
	cp	a,ti.skEnter
	jr	z,.submit_key
	cp	a,ti.skClear
	jr	z,.clear_key
	cp	a,ti.skDel
	jr	z,.del_key
	cp	a,ti.skOn
	jr	z,.on_key
	cp	a,ti.sk2nd
	jr	z,.submit_key
	cp	a,ti.skEnter
	jr	z,.submit_key
	cp	a,ti.skClear
	jr	z,.clear_key
	cp	a,ti.skDel
	jr	z,.del_key
	cp	a,ti.skOn
	jr	z,.on_key
	cp	a,ti.sk2nd
	jr	z,.submit_key
	cp	a,ti.skEnter
	jr	z,.submit_key
	cp	a,ti.skClear
	jr	z,.clear_key
	cp	a,ti.skDel
	jr	z,.del_key
	cp	a,ti.skOn
	jr	z,.on_key
	cp	a,ti.sk2nd
	jr	z,.submit_key
	cp	a,ti.skEnter
	jr	z,.submit_key
	cp	a,ti.skClear
	jr	z,.clear_key
	cp	a,ti.skDel
	jr	z,.del_key
	cp	a,ti.skOn
	jr	z,.on_key
	cp	a,ti.sk2nd
	jr	z,.submit_key
	cp	a,ti.skEnter
	jr	z,.submit_key
	cp	a,ti.skClear
	jr	z,.clear_key
	cp	a,ti.skDel
	jr	z,.del_key
	cp	a,ti.skOn
	jr	z,.on_key
	cp	a,ti.sk2nd
	jr	z,.submit_key
	cp	a,ti.skEnter
	jr	z,.submit_key
	cp	a,ti.skClear
	jr	z,.clear_key
	cp	a,ti.skDel
	jr	z,.del_key
	cp	a,ti.skOn
	jr	z,.on_key
	cp	a,ti.sk2nd
	jr	z,.submit_key
	cp	a,ti.skEnter
	jr	z,.submit_key
	cp	a,ti.skClear
	jr	z,.clear_key
	cp	a,ti.skDel
	jr	z,.del_key
	cp	a,ti.skOn
	jr	z,.on_key
	cp	a,ti.sk2nd
	jr	z,.submit_key
	cp	a,ti.skEnter
	jr	z,.submit_key
	cp	a,ti.skClear
	jr	z,.clear_key
	cp	a,ti.skDel
	jr	z,.del_key
	cp	a,ti.skOn
	jr	z,.on_key
	cp	a,ti.sk2nd
	jr	z,.submit_key
	cp	a,ti.skEnter
	jr	z,.submit_key
	cp	a,ti.skClear
	jr	z,.clear_key
	cp	a,ti.skDel
	jr	z,.del_key
	cp	a,ti.skOn
	jr	z,.on_key
	cp	a,ti.sk2nd
	jr	z,.submit_key
	cp	a,ti.skEnter
	jr	z,.submit_key
	cp	a,ti.skClear
	jr	z,.clear_key
	cp	a,ti.skDel
	jr	z,.del_key
	cp	a,ti.skOn
	jr	z,.on_key
	cp	a,ti.sk2nd
	jr	z,.submit_key
	cp	a,ti.skEnter
	jr	z,.submit_key
	cp	a,ti.skClear
	jr	z,.clear_key
	cp	a,ti.skDel
	jr	z,.del_key
	cp	a,ti.skOn
	jr	z,.on_key
	cp	a,ti.sk2nd
	jr	z,.submit_key
	cp	a,ti.skEnter
	jr	z,.submit_key
	cp	a,ti.skClear
	jr	z,.clear_key
	cp	a,ti.skDel
	jr	z,.del_key
	cp	a,ti.skOn
	jr	z,.on_key
	cp	a,ti.sk2nd
	jr	z,.submit_key
	cp	a,ti.skEnter
	jr	z,.submit_key
	cp	a,ti.skClear
	jr	z,.clear_key
	cp	a,ti.skDel
	jr	z,.del_key
	cp	a,ti.skOn
	jr	z,.on_key
	cp	a,ti.sk2nd
	jr	z,.submit_key
	cp	a,ti.skEnter
	jr	z,.submit_key
	cp	a,ti.skClear
	jr	z,.clear_key
	cp	a,ti.skDel
	jr	z,.del_key
	cp	a,ti.skOn
	jr	z,.on_key
	cp	a,ti.sk2nd
	jr	z,.submit_key
	cp	a,ti.skEnter
	jr	z,.submit_key
	cp	a,ti.skClear
	jr	z,.clear_key
	cp	a,ti.skDel
	jr	z,.del_key
	cp	a,ti.skOn
	jr	z,.on_key
	cp	a,ti.sk2nd
	jr	z,.submit_key
	cp	a,ti.skEnter
	jr	z,.submit_key
	cp	a,ti.skClear
	jr	z,.clear_key
	cp	a,ti.skDel
	jr	z,.del_key
	cp	a,ti.skOn
	jr	z,.on_key
	cp	a,ti.sk2nd
	jr	z,.submit_key
	cp	a,ti.skEnter
	jr	z,.submit_key
	cp	a,ti.skClear
	jr	z,.clear_key
	cp	a,ti.skDel
	jr	z,.del_key
	cp	a,ti.skOn
	jr	z,.on_key
	cp	a,ti.sk2nd
	jr	z,.submit_key
	cp	a,ti.skEnter
	jr	z,.submit_key
	cp	a,ti.skClear
	jr	z,.clear_key
	cp	a,ti.skDel
	jr	z,.del_key
	cp	a,ti.skOn
	jr	z,.on_key
	cp	a,ti.sk2nd
	jr	z,.submit_key
	cp	a,ti.skEnter
	jr	z,.submit_key
	cp	a,ti.skClear
	jr	z,.clear_key
.cp_del:
	ld	a,(hl)
	or	a,a
	jr	z,.loop
	dec	hl
	ld	(hl),0
	dec	c
	jr	.loop
.clear_key:
	ld	hl,setting_password + 1
	ld	b,password_max_length
	ld	c,0
	ld	de,password_input_buffer
	jr	.loop
.on_key:
	call	ti.PowerOff
	jr	.loop
.submit_key:
	ld	hl,password_input_buffer
	ld	de,setting_password + 1
	ld	b,password_max_length
	ld	c,0
.compare:
	ld	a,(hl)
	cp	a,(de)
	jr	nz,.wrong
	inc	hl
	inc	de
	dec	b
	jr	nz,.compare
.correct:
	ld	a,ti.kClear
	jp	ti.SendKPress
.wrong:
	call	ti.CursorOff
	ld	a,ti.cxCmd
	call	ti.NewContext0
	call	ti.CursorOff
	call	ti.ClrScrn
	call	ti.HomeUp
	ld	hl,data_string_password
	call	ti.PutS
	di
	call	ti.EnableAPD
	ld	a,1
	ld	hl,ti.apdSubTimer
	ld	(hl),a
	inc	hl
	ld	(hl),a
	set	ti.apdRunning,(iy + ti.apdFlags)
	ei
	ld	hl,setting_password
	ld	a,(hl)				; password length
	or	a,a
	jr	z,.correct
	ld	b,a
	ld	c,0
	inc	hl
.get_user_password:
	call	.get_key
	cp	a,(hl)
	inc	hl
	jr	z,.draw_character
	inc	c
.draw_character:
	ld	a,'*'
	call	ti.PutC
	djnz	.get_user_password
	dec	c
	inc	c
	jr 	nz,.wrong
	jr	.correct
