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

; features offered by cesium

NORMAL_CHARS    := 255
NUMBER_CHARS    := 254
LOWERCASE_CHARS := 253

name_buffer := ti.mpLcdCrsrImage + 1000

feature_item_new:
	ld	a,(current_screen)
	cp	a,screen_programs
	jq	nz,main_loop
	bit	cesium_is_nl_disabled,(iy + cesium_flag)
	jp	nz,main_loop
	res	item_renaming,(iy + item_flag)
	res	item_is_hidden,(iy + item_flag)
	xor	a,a
	ld	(name_buffer + 1),a		; no name set yet
	jq	feature_item_rename.get_input
feature_item_rename:
	ld	a,(current_screen)
	cp	a,screen_programs
	jq	z,.continue
	cp	a,screen_appvars
	jq	nz,main_loop
.continue:
	call	feature_check_valid
	call	util_move_prgm_name_to_op1
	ld	hl,ti.OP1
	ld	de,name_buffer
	ld	bc,9
	ldir
	res	item_is_hidden,(iy + item_flag)
	ld	hl,name_buffer + 1
	ld	a,(hl)
	cp	a,64
	jr	nc,.not_hidden
	set	item_is_hidden,(iy + item_flag)
	add	a,64
	ld	(hl),a
.not_hidden:
	set	item_renaming,(iy + item_flag)
.get_input:
	ld	a,(color_senary)
	draw_rectangle_color 199, 173, 313, 215
	ld	hl,string_rename
	bit	item_renaming,(iy + item_flag)
	jr	nz,.rename
	ld	hl,string_new_prgm
.rename:
	print_xy 199, 173
	set_cursor 199, 195
	ld	hl,name_buffer + 1
	ld	a,(current_screen)
	cp	a,screen_programs
	jq	nz,.appvar
	call	util_get_var_name_input.prgm
	jq	.confirm
.appvar:
	call	util_get_var_name_input.appvar
.confirm:
	jq	z,.goto_main			; canceled input
	bit	item_renaming,(iy + item_flag)
	jq	nz,.renaming
	ld	hl,name_buffer
	ld	(hl),ti.ProgObj			; already in op1
	call	ti.Mov9ToOP1
	call	ti.ChkFindSym
	jq	nc,.get_input			; check if var exists
	ld	hl,name_buffer
	call	ti.Mov9ToOP1
	ld	a,(ti.OP1 + 1)
	sub	a,64
	ld	(ti.OP1 + 1),a
	call	ti.ChkFindSym
	jq	nc,.get_input			; check if hidden var exists
	ld	hl,name_buffer
	call	ti.Mov9ToOP1
	ld	a,ti.ProgObj
	or	a,a
	sbc	hl,hl
	call	ti.CreateVar
	jq	.goto_main
.renaming:
	bit	item_is_hidden,(iy + item_flag)
	jr	z,.dont_hide
	ld	a,(name_buffer + 1)
	sub	a,64
	ld	(name_buffer + 1),a
.dont_hide:
	call	util_move_prgm_name_to_op1	; move the current name to op1
	ld	hl,cesium.Arc_Unarc
	ld	(.jump_smc),hl
	ld	de,name_buffer
	ld	hl,ti.OP1
	ldi
	call	ti.PushOP1
	ld	hl,name_buffer
	call	ti.Mov9ToOP1
	call	ti.ChkFindSym
	push	af
	call	ti.PopOP1
	pop	af
	jq	c,.locate_program		; check if var exists
	bit	item_is_hidden,(iy + item_flag)
	jq	z,.get_input
	ld	a,(name_buffer + 1)
	add	a,64
	ld	(name_buffer + 1),a
	jq	.get_input
.locate_program:
	call	ti.PushOP1
	call	ti.ChkFindSym
	call	ti.ChkInRam
	push	af,hl,de
	call	ti.PopOP1
	pop	de,hl,af
	jr	nz,.in_archive
	ld	hl,$f8				; _ret
	ld	(.jump_smc),hl
	call	ti.PushOP1
	call	cesium.Arc_Unarc
	call	ti.PopOP1
	jr	.locate_program
.in_archive:
	ex	de,hl
	ld	de,9
	add	hl,de				; skip VAT stuff
	ld	e,(hl)
	add	hl,de
	inc	hl				; size of name
	call	ti.LoadDEInd_s
	push	hl
	push	de
	call	ti.PushOP1
	ld	hl,name_buffer
	call	ti.Mov9ToOP1
	call	ti.PushOP1
	pop	hl
	push	hl
	ld	a,(ti.OP1)
	call	ti.CreateVar
	inc	de
	inc	de
	pop	bc
	pop	hl
	call	ti.ChkBCIs0
	jr	z,.is_zero
	ldir
.is_zero:
	call	ti.PopOP1
	call	cesium.Arc_Unarc
.jump_smc := $-3
	call	ti.PopOP1
	call	ti.ChkFindSym
	call	ti.DelVarArc
.goto_main:
	call	find_files
	ld	hl,name_buffer + 1
	call	search_name
	jp	main_start
.setting_editor_name:
	ld	hl,name_buffer
	ld	(hl),ti.ProtProgObj
	ld	de,setting_editor_name
	call	ti.Mov9b
	call	settings_save
	jp	main_start

feature_item_edit:
	ld	a,(current_screen)
	cp	a,screen_programs
	jp	nz,main_loop
	call	feature_check_valid
	bit	prgm_locked,(iy + prgm_flag)
	jp	nz,main_loop
	ld	a,(prgm_type)
	cp	a,file_ice_source
	jr	z,.good
	cp	a,file_basic
	jp	nz,main_loop
.good:
	call	util_move_prgm_name_to_op1
	jp	edit_basic_program

feature_item_delete:
	ld	a,(current_screen)
	cp	a,screen_usb
	jq	nz,.notfatfile
	bit	setting_delete_confirm,(iy + settings_flag)
	jq	z,fat_file_delete
	call	.showconfirm
	call	.getinput
	jq	fat_file_delete
.notfatfile:
	call	feature_check_valid
	ld	a,(current_screen)
	cp	a,screen_apps
	jr	z,.delete_app
.delete_program:
	call	util_check_if_vat_page_directory
	jp	z,main_start
	bit	setting_delete_confirm,(iy + settings_flag)
	call	nz,.showconfirm
	bit	setting_delete_confirm,(iy + settings_flag)
	call	nz,.getinput
	call	util_move_prgm_name_to_op1	; move the selected name to op1
	call	util_delete_var.op1
	jr	.refresh
.delete_app:
	call	util_check_if_app_page_directory
	jp	z,main_start
	bit	setting_delete_confirm,(iy + settings_flag)
	call	nz,.showconfirm
	bit	setting_delete_confirm,(iy + settings_flag)
	call	nz,.getinput
	ld	hl,(item_ptr)
	ld	bc,0 - $100
	add	hl,bc
	call	ti.DeleteApp
	set	3,(iy + $25)			; defrag on exit
.refresh:
	ld	hl,(current_selection_absolute)
	ld	de,(number_of_items)
	inc	hl
	compare_hl_de
	call	z,main_move_up
	ld	a,return_settings
	ld	(return_info),a
	jp	main_find			; reload everything

.showconfirm:
	call	gui_clear_status_bar
	set_inverted_text
	print	string_delete_confirmation, 4, 228
	set_normal_text
	ret
.getinput:
	call	util_get_key
	cp	a,ti.skZoom
	ret	z
	cp	a,ti.skGraph
	jr	nz,.getinput
	pop	hl
	jp	main_start

feature_item_attributes:
	call	feature_check_valid
	ld	hl,.max_options
	ld	(hl),2
	ld	a,(current_screen)
	cp	a,screen_usb
	jr	z,.usb
	cp	a,screen_apps
	jp	z,main_loop
	cp	a,screen_programs
	jr	z,.programs
	ld	(hl),0
.programs:
	ld	a,(iy + prgm_flag)
	ld	(iy + temp_prgm_flag),a
	ld	hl,.check_hide_smc
	xor	a,a
	ld	(hl),a
	ld	(current_option_selection),a
	bit	prgm_archived,(iy + prgm_flag)
	jr	nz,.show_edit
	ld	(hl),$c9
.show_edit:
	ld	a,(color_tertiary)
	ld	(lcd_text_bg),a			; highlight the currently selected item
	call	.get_option_metadata
	set_normal_text
.loop:
	call	util_show_time
	call	lcd_blit
	call	ti.GetCSC
	ld	hl,.show_edit
	push	hl
	cp	a,ti.skDown
	jp	z,.move_option_down
	cp	a,ti.skUp
	jp	z,.move_option_up
	pop	hl
	cp	a,ti.skAlpha
	jp	z,.set_options
	cp	a,ti.skMode
	jp	z,.set_options
	cp	a,ti.skClear
	jp	z,.set_options
	cp	a,ti.skDel
	jp	z,.set_options
	cp	a,ti.sk2nd
	jp	z,.check_what_to_do
	cp	a,ti.skEnter
	jr	nz,.loop
	jp	.check_what_to_do
.usb:
	jp	main_start

.move_option_down:
	call	.clear_current_selection
	cp	a,2
.max_options := $-1
	ret	z
	inc	a
	ld	(current_option_selection),a
	ret

.move_option_up:
	call	.clear_current_selection
	or	a,a
	ret	z
	dec	a
	ld	(current_option_selection),a
	ret

.clear_current_selection:
	call	.get_option_metadata
	ld	a,(current_option_selection)
	ret

.get_option_metadata:
	ld	a,(current_option_selection)
	ld	l,a
	ld	h,11
	mlt	hl
	ld	a,118
	add	a,l
	ld	bc,199
	ld	(lcd_x),bc
	ld	(lcd_y),a
	ld	a,(current_option_selection)
	ld	hl,string_archived
	or	a,a
	jr	z,.draw
	ld	hl,string_locked
	dec	a
	jr	z,.draw
	ld	hl,string_hidden
.draw:
	jp	lcd_string

.check_hide_toggle:
	ret
.check_hide_smc := $ - 1
	pop	de
	jq	gui_show_cannot_hide

.check_what_to_do:
	ld	hl,.show_edit
	push	hl
	ld	a,(current_option_selection)
	dec	a
	jr	z,.check_lock
	dec	a
	call	z,.check_hide_toggle
	jr	.toggle_option
.check_lock:
	ld	a,(prgm_type)
	cp	a,file_basic			; basic programs
	jr	z,.toggle_option
	cp	a,file_ice_source		; ice source programs
	ret	nz
.toggle_option:
	ld	a,(current_option_selection)
	inc	a
	call	util_to_one_hot
	xor	a,(iy + prgm_flag)
	ld	(iy + prgm_flag),a
	jp	gui_draw_item_options

.set_options:
	call	util_move_prgm_name_to_op1
	ld	a,(current_screen)
	cp	a,screen_appvars
	jr	z,.check_archived		; appvars can only be (un)archived
	call	ti.ChkFindSym
	ld	a,ti.ProgObj
	bit	prgm_locked,(iy + prgm_flag)
	jr	z,.unlock
	inc	a
.unlock:
	ld	(hl),a
	ld	hl,(prgm_ptr)
	ld	hl,(hl)
	dec	hl				; bypass name byte
	ld	a,(hl)
	bit	prgm_hidden,(iy + prgm_flag)
	jr	z,.unhide
	cp	a,64
	jr	c,.check_archived		; already hidden
	sub	a,64
	ld	(hl),a
	jr	.check_archived
.unhide:
	cp	a,64
	jr	nc,.check_archived		; not hidden
	add	a,64
	ld	(hl),a
	;jr	.check_archived
.check_archived:
	call	util_move_prgm_name_to_op1	; if needed, archive it
	call	ti.ChkFindSym
	call	ti.ChkInRam
	push	af
	bit	prgm_archived,(iy + prgm_flag)
	jr	z,.unarchive
.archive:
	pop	af
	call	z,cesium.Arc_Unarc
	jr	nz,.return
	ld	a,return_settings
	ld	(return_info),a
	jp	main_find
.unarchive:
	pop	af
	call	nz,cesium.Arc_Unarc
.return:
	jp	main_start

feature_check_valid:
	ld	a,(prgm_type)
	cp	a,file_dir
	jq	z,.invalid
	cp	a,file_usb_dir
	jq	z,.invalid
	ret
.invalid:
	pop	hl
	jq	main_loop
