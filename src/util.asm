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

util_find_var:
	call	ti.Mov9ToOP1
	jp	ti.ChkFindSym

util_delete_prgm_from_usermem:
	ld	hl,(ti.asm_prgm_size)		; get program size
	compare_hl_zero
	ret	z
	ex	de,hl
	or	a,a
	sbc	hl,hl
	ld	(ti.asm_prgm_size),hl		; delete whatever was there
	ld	hl,ti.userMem
	jp	ti.DelMem

util_move_prgm_to_usermem:
	ld	a,$9				; 'add hl,bc'
	ld	(.smc),a
	call	ti.ChkFindSym
	jr	c,.error_not_found		; hope this doesn't happen
	call	ti.ChkInRam
	ex	de,hl
	jr	z,.in_ram
	xor	a,a
	ld	(.smc),a
	ld	de,9
	add	hl,de
	ld	e,(hl)
	add	hl,de
	inc	hl
.in_ram:					; hl -> size bytes
	call	ti.LoadDEInd_s
	inc	hl
	inc	hl				; bypass tExtTok, tAsm84CECmp
	push	hl
	push	de
	ex	de,hl
	call	util_check_free_ram		; check and see if we have enough memory
	pop	hl
	jr	c,.error_ram
	ld	(ti.asm_prgm_size),hl		; store the size of the program
	ld	de,ti.userMem
	call	ti.InsertMem			; insert memory into usermem
	pop	hl				; hl -> start of program
	ld	bc,(ti.asm_prgm_size)		; load size of current program
.smc := $
	add	hl,bc				; if not in ram smc it so it doesn't execute
	ldir					; copy the program to userMem
	xor	a,a
	ret					; return
.error_ram:
	pop	hl				; pop start of program
.error_not_found:
	xor	a,a
	inc	a
	ret

util_show_time:
	bit	setting_clock,(iy + settings_flag)
	ret	z
	set	ti.clockOn,(iy + ti.clockFlags)
	set	ti.useTokensInString,(iy + ti.clockFlags)
	ld	de,ti.OP6
	push	de
	call	ti.FormTime
	pop	hl
	save_cursor
	set_cursor clock_x, clock_y
	call	util_string_inverted
	restore_cursor
	res	ti.useTokensInString,(iy + ti.clockFlags)
	ret

util_check_free_ram:
	push	hl
	ld	de,128
	add	hl,de				; for safety
	call	ti.EnoughMem
	pop	hl
	ret	nc
	call	gui_ram_error
	call    util_delay_one_second
	scf
	ret

util_delay_one_second:
	ld	bc,100
.delay:
	push	bc
	call	ti.Delay10ms
	pop	bc
	dec	bc
	ld	a,c
	or	a,b
	jr	nz,.delay
	ret

util_set_primary:
	push	af
	ld	a,(color_primary)
	ld	(util_restore_primary.color),a
	pop	af
	ld	(color_primary),a
	ret

util_restore_primary:
	ld	a,0
.color := $-1
	ld	(color_primary),a
	ret

util_show_free_mem:
	call	gui_clear_status_bar
	set_inverted_text
	print	string_ram_free, 4, 228
	call	ti.MemChk
	call	lcd_num_6
	print	string_rom_free, 196, 228
	call	ti.ArcChk
	ld	hl,(ti.tempFreeArc)
	call	lcd_num_7
	set_normal_text
	ret

util_string_inverted:
	set_inverted_text
	call	lcd_string
	set_normal_text
	ret

; bc = x
; a = y
util_string_xy:
	call	util_set_cursor
	jp	lcd_string

; bc = x
; a = y
util_set_cursor:
	ld	(lcd_x),bc
	ld	(lcd_y),a
	ret

util_save_cursor:
	pop	ix
	ld	bc,(lcd_x)
	push	bc
	ld	a,(lcd_y)
	push	af
	jp	(ix)

util_restore_cursor:
	pop	hl
	pop	af
	ld	(lcd_y),a
	pop	bc
	ld	(lcd_x),bc
	jp	(hl)

util_set_inverted_text_color:
	ld	a,(color_primary)
	ld	(lcd_text_bg),a
	ld	a,(color_quaternary)
	ld	(lcd_text_fg),a
	ret

util_set_normal_text_color:
	ld	a,(color_senary)
	ld	(lcd_text_bg),a
	ld	a,(color_secondary)
	ld	(lcd_text_fg),a
	ret

util_get_battery:
	call	ti.GetBatteryStatus
	ld	(battery_status),a
	ret

util_get_key:
	di
.run:
	call	util_handle_apd
	ld	iy,ti.flags
	call	ti.DisableAPD			; disable os apd and use our own
	call	util_show_time
	call	lcd_blit
	call	ti.GetCSC
	or	a,a
	jr	z,.run
	ret

util_get_key_nonblocking:
	di
	call	util_handle_apd
	ld	iy,ti.flags
	call	ti.DisableAPD			; disable os apd and use our own
	call	util_show_time
	call	lcd_blit
	jq	ti.GetCSC

util_setup_apd:
	ld	hl,$b0ff
	ld	(apd_timer),hl
	ret

util_handle_apd:
	ld	hl,0
apd_timer := $-3
	dec	hl
	ld	(apd_timer),hl
	add	hl,de
	or	a,a
	sbc	hl,de
	ret	nz
	jp	exit_full

util_check_if_app_page_directory:
	ld	hl,(item_ptr)
	ld	hl,(hl)
	compare_hl_zero
	ret

util_check_if_vat_page_directory:
	ld	hl,(item_ptr)
	ld	de,6
	add	hl,de
	ld	a,(hl)
	inc	a
	ret

util_to_one_hot:
	ld	b,a
	xor	a,a
	scf
.loop:
	rla
	djnz	.loop
	ret

util_move_prgm_name_to_op1:
	ld	hl,(prgm_ptr)
util_prgm_ptr_to_op1:
	ld	hl,(hl)
	push	hl				; vat pointer
	ld	de,6
	add	hl,de
	ld	a,(hl)				; get the type byte
	pop	hl
	ld	de,ti.OP1			; store to op1
	ld	(de),a
	inc	de
	ld	b,(hl)
	dec	hl
.copy:
	ld	a,(hl)
	ld	(de),a
	inc	de
	dec	hl
	djnz	.copy
	xor	a,a
	ld	(de),a				; terminate the string
	ret

util_setup_shortcuts:
	bit	setting_enable_shortcuts,(iy + settings_flag)
	ret	z
	ld	hl,hook_get_key
	jp	ti.SetGetCSCHook

util_backup_prgm_name:
	ld	hl,ti.OP1
.entry:
	ld	de,backup_prgm_name
	jp	ti.Mov9b

util_clear_backup_prgm_name:
	ld	hl,backup_prgm_name
	jp	ti.ZeroOP

util_set_more_items_flag:
	set	scroll_down_available,(iy + item_flag)
	ret

util_delete_var:
	call	ti.Mov9ToOP1
.op1:
	call	ti.PushOP1
	call	ti.ChkFindSym
	call	nc,ti.DelVarArc
	jp	ti.PopOP1

util_get_archived_name:
	ld	de,util_temp_program_object + 1
	ld	b,8
.compare:
	ld	a,(de)
	cp	a,(hl)
	jr	nz,.no_match
	inc	hl
	inc	de
	djnz	.compare
	ld	hl,backup_prgm_name
	ret
.no_match:
	ld	hl,ti.basic_prog
	ret

util_op1_to_temp:
	ld	de,string_temp
	push	de
	call	ti.ZeroOP
	ld	hl,ti.OP1 + 1
	pop	de
.handle:
	push	de
	call	ti.Mov8b
	pop	hl
	ret

util_temp_to_op1:
	ld	hl,string_temp
	ld	de,ti.OP1
	jr	util_op1_to_temp.handle

util_num_convert:
	ld	de,string_other_temp
	push	de
	call	.entry
	xor	a,a
	ld	(de),a
	pop	de
	ret
.entry:
	ld	bc,-1000000
	call	.aqu
	ld	bc,-100000
	call	.aqu
	ld	bc,-10000
	call	.aqu
	ld	bc,-1000
	call	.aqu
	ld	bc,-100
	call	.aqu
	ld	c,-10
	call	.aqu
	ld	c,b
.aqu:
	ld	a,'0' - 1
.under:
	inc	a
	add	hl,bc
	jr	c,.under
	sbc	hl,bc
	ld	(de),a
	inc	de
	ret

util_squishy_convert_byte:
	push	bc
	push	hl
	ld	a,d
	call	ti.ShlACC
	add	a,e
	pop	hl
	pop	bc
	ret

util_squishy_check_byte:
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

util_ascii_nibble_to_byte:
	sub	a,48
	cp	a,16
	ret	c
	sub	a,55-48
	ret

util_get_var_name_input:
.prgm:
	ld	a,0
	jq	.start
.appvar:
	ld	a,1
.start:
	ld	(.mode),a
	ld	(.buffer_ptr),hl
	ld	hl,(lcd_x)
	ld	(.starting_x),hl
	ld	hl,lut_character_standard
	ld	(.current_character_lut),hl
	ld	a,NORMAL_CHARS
	ld	(.current_input_mode),a
	jq	.redraw
.get_name:
	call	util_get_key
	cp	a,ti.skDel
	jq	z,.backspace
	cp	a,ti.skLeft
	jq	z,.backspace
	cp	a,ti.skAlpha
	jq	z,.change_input_mode
	cp	a,ti.skClear
	ret	z
	cp	a,ti.skMode
	ret	z
	cp	a,ti.sk2nd
	jq	z,.confirm
	cp	a,ti.skEnter
	jq	z,.confirm
	sub	a,ti.skAdd
	jq	c,.get_name
	cp	a,ti.skMath - ti.skAdd + 1
	jq	nc,.get_name
	ld	hl,lut_character_standard
.current_character_lut := $-3
	call	ti.AddHLAndA			; find the offset
	ld	a,0
.cursor_position := $-1
	cp	a,8				; maximum name length
	jq	z,.get_name
	ld	a,(hl)
	or	a,a
	jq	z,.get_name
	ld	e,a
	ld	a,(.current_input_mode)
	cp	a,NUMBER_CHARS			; don't allow number on first
	jr	nz,.okay
	ld	a,(.mode)
	or	a,a
	jr	nz,.okay
	ld	a,(.cursor_position)
	or	a,a
	jq	z,.get_name
.okay:
	ld	a,(.mode)
	or	a,a
	jr	nz,.nospace
	ld	a,e
	cp	a,32				; don't allow space in prgm
	jq	z,.get_name
.nospace:
	call	.get_offset
	inc	a
	ld	(.cursor_position),a
	ld	a,e
	ld	(hl),a
	call	lcd_char
.draw_mode:
	ld	a,255
.current_input_mode := $-1
	call	lcd_char
.backup:
	ld	hl,(lcd_x)
	ld	de,-9
	add	hl,de
	ld	(lcd_x),hl
	jq	.get_name
.backspace:
	call	.get_offset
	or	a,a
	jq	z,.get_name
	dec	a
	ld	(.cursor_position),a
	dec	hl
	ld	(hl),0
.redraw:
	ld	de,0
.starting_x := $-3
	ld	(lcd_x),de
	ld	hl,(lcd_y)
	ld	h,160
	mlt	hl
	add	hl,hl
	add	hl,de
	ex	de,hl
	ld	bc,86
	ld	a,8
	ld	hl,color_senary
	ld	(lcd_rectangle.color_ptr),hl
	call	lcd_rectangle.computed
	ld	hl,color_primary
	ld	(lcd_rectangle.color_ptr),hl
	ld	hl,(.buffer_ptr)
	xor	a,a
	ld	(.cursor_position),a
.redraw_loop:
	ld	a,(hl)
	or	a,a
	jq	z,.draw_mode
	push	bc
	push	hl
	call	lcd_char
	ld	hl,.cursor_position
	inc	(hl)
	pop	hl
	pop	bc
	inc	hl
	jq	.redraw_loop
.change_input_mode:
	ld	a,(.current_input_mode)
	cp	a,NORMAL_CHARS
	jr	z,.setnumbers
	cp	a,NUMBER_CHARS
	jr	z,.setlowercase
.setnormal:
	ld	a,NORMAL_CHARS
	ld	hl,lut_character_standard
	jr	.set_input_mode
.setlowercase:
	ld	a,0
.mode := $-1
	or	a,a
	jr	z,.setnormal
	ld	a,LOWERCASE_CHARS
	ld	hl,lut_character_lowercase
	jr	.set_input_mode
.setnumbers:
	ld	a,NUMBER_CHARS
	ld	hl,lut_character_numbers
.set_input_mode:
	ld	(.current_character_lut),hl
	ld	(.current_input_mode),a
	call	lcd_char
	jq	.backup
.confirm:
	ld	a,(.cursor_position)
	or	a,a
	jq	z,.get_name
	call	.get_offset
	xor	a,a
	ld	(hl),a
	inc	a
	ret
.get_offset:
	ld	a,(.cursor_position)
	ld	hl,0
.buffer_ptr := $-3
	jp	ti.AddHLAndA

util_temp_program_object:
	db	ti.TempProgObj, 'MATEOTMP', 0
