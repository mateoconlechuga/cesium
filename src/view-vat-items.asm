; Copyright 2015-2022 Matt "MateoConLechuga" Waltz
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

; process for displaying the list of programs / appvars

view_vat_items:
	call	gui_show_item_count
	set_normal_text
	set_cursor 24, 30
	xor	a,a
	sbc	hl,hl
	ld	(iy + prgm_flag),a			; reset the program status flags
	ld	(current_prgm_drawing),a
	ld	bc,(number_of_items)
	sbc	hl,hl
	adc	hl,bc
	ret     z					; return if no programs are found
	ld	hl,(scroll_amount)
	compare_hl_zero
	ld	de,item_location_base
	ex	de,hl
	jr	z,.loop
.get_physical_offset:
	inc	hl
	inc	hl
	inc	hl
	inc	hl
	dec	de
	dec	bc
	ld	a,e
	or	a,d
	jr	nz,.get_physical_offset
.loop:
	xor	a,a
	ld	(iy + temp_prgm_flag),a			; reset the temporary flags
	res	drawing_selected,(iy + item_flag)	; not drawing the selected one yet
	ld	e,0
current_prgm_drawing := $-1
	ld	a,(current_selection)
	cp	a,e
	jr	nz,.not_selected
	set	drawing_selected,(iy + item_flag)
	ld	(prgm_ptr),hl
	ld	a,(color_tertiary)
	ld	(lcd_text_bg),a				; highlight the currently selected item
.not_selected:
	ld	a,e
	inc	a
	ld	(current_prgm_drawing),a
	ld	a,(lcd_y)
	cp	a,220
	jp	nc,util_set_more_items_flag		; more to scroll, so draw an arrow or something later
	push	bc					; bc = number of programs left to draw
	push	hl					; hl -> lookup table
	ld	hl,(hl)					; load name pointer
	push	hl					; push the name pointer
	inc	hl					; the next byte is the status
	ld	a,(hl)
	call	ti.SetDEUToA
	inc	hl
	ld	d,(hl)
	inc	hl
	ld	e,(hl)
	push	hl
	ex	de,hl
	cp	a,$d0
	jr	nc,.in_ram
	set	temp_prgm_archived,(iy + temp_prgm_flag)
	ld	de,9
	add	hl,de
	ld	e,(hl)
	add	hl,de
	inc	hl
.in_ram:
	call	ti.LoadDEInd_s
	ld	(temp_prgm_data_ptr),hl
	ld	(tmp_prgm_real_size),de
	bit	drawing_selected,(iy + item_flag)
	jr	z,.not_drawing_selected
	ld	(prgm_data_ptr),hl
	ld	(prgm_real_size),de
.not_drawing_selected:
	ex	de,hl
	ld	de,9
	add	hl,de
	pop	de					; lookup table
	pop	bc					; name pointer
	ld	a,(bc)
	push	bc
	push	de
	call	ti.AddHLAndA
	ld	(prgm_size),hl
	pop	hl
	inc	hl
	inc	hl
	inc	hl
	ld	a,(hl)					; previously stored type of program
	cp	a,ti.ProtProgObj
	jr	nz,.not_locked
	set	temp_prgm_locked,(iy + temp_prgm_flag)
.not_locked:
	ld	a,(lcd_text_fg)
	ld	(color_save),a
	pop	hl
	ld	b,(hl)
	dec	hl
	ld	a,(hl)
	cp	a,64
	jr	nc,.draw_item
	add	a,64
	ld	(hl),a
	set	temp_prgm_hidden,(iy + temp_prgm_flag)
	ld	a,(color_quinary)
	ld	(lcd_text_fg),a
.draw_item:
	push hl
.draw_item_name:
	ld	a,(hl)
	dec	hl
	push	bc
	call	lcd_char
	pop	bc
	djnz	.draw_item_name
	pop	hl
	bit	temp_prgm_hidden,(iy + temp_prgm_flag)
	jr	z,.not_hidden
	ld	a,0
color_save := $-1
	ld	(lcd_text_fg),a
	ld	a,(hl)
	sub	a,64
	ld	(hl),a
.not_hidden:
	ld	a,(lcd_y)
	add	a,20
	ld	(lcd_y),a
	sub	a,25
	ld	c,a
	ld	a,24
	ld	(lcd_x),a
	ld	b,2
	pop	hl
	inc	hl
	inc	hl
	inc	hl
	ld	a,(hl)
	bit	drawing_selected,(iy + item_flag)
	jr	z,.dont_set_type
	ld	(prgm_type),a
.dont_set_type:
	inc	hl
	push	hl					; save location in list
	ld	de,string_directory
	ld	hl,sprite_directory
	cp	a,file_dir
	jp	z,file_directory
	cp	a,file_usb_dir
	ld	de,string_usb
	ld	hl,sprite_usb
	jp	z,file_usb_directory			; it's a directory right?
	ld	de,string_appvar
	ld	hl,sprite_file_appvar
	cp	a,file_appvar
	jr	z,file_uneditable
	ld	de,string_asm
	ld	hl,sprite_file_asm
	cp	a,file_asm
	jr	z,file_uneditable
	ld	de,string_c
	ld	hl,sprite_file_c
	cp	a,file_c
	jr	z,file_uneditable
	ld	de,string_ice
	ld	hl,sprite_file_ice
	cp	a,file_ice
	jr	z,file_uneditable
	set	temp_prgm_is_basic,(iy + temp_prgm_flag)
	ld	de,string_ice_source
	cp	a,file_ice_source
	jq	z,file_editable
	ld	de,string_basic
	ld	hl,sprite_file_basic
	cp	a,file_basic
	jq	z,file_editable
	jp	exit_full		; abort

file_usb_directory:
	set	temp_prgm_is_usb_directory,(iy + temp_prgm_flag)
file_directory:
	push	hl
	or	a,a
	sbc	hl,hl
	ld	(prgm_size),hl
	pop	hl
	jp	draw_listed_entry

file_uneditable:
	push	de
	push	hl
	ld	hl,0					; hl -> program data
temp_prgm_data_ptr := $-3
	inc	hl
	inc	hl
	ld	a,(hl)
	cp	a,byte_jp
	jr	z,.custom_icon
	inc	hl
	ld	a,(hl)
	cp	a,byte_jp
	jr	nz,.no_custom_icon
.custom_icon:
	inc	hl
	inc	hl
	inc	hl
	inc	hl					; hl -> icon indicator byte, hopefully
	ld	a,(hl)
	cp	a,byte_icon				; cesium indicator byte
	jr	z,.valid_icon
	cp	a,byte_description
	jr	nz,.no_custom_icon
	bit	drawing_selected,(iy + item_flag)	; check if the description should be drawn
	jr	z,.no_custom_icon
	inc	hl
	call	gui_show_description
	jr	.no_custom_icon
.valid_icon:
	pop	de					; pop the old icon
	inc	hl
	bit	drawing_selected,(iy + item_flag)	; check if the description should be drawn
	jr	z,.icon
	push	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	mlt	de
	inc	de
	add	hl,de					; hl -> description string (null terminated)
	call	gui_show_description			; actually draw the description string
.no_custom_icon:
	pop	hl					; hl -> icon
.icon:
	pop	de					; de -> language string
	jp	draw_listed_entry

check_dcs_icon:
	ld	hl,(temp_prgm_data_ptr)
	ld	de,lut_dcs_icon
	ld	b,6
.verify:
	ld	a,(de)
	cp	a,(hl)
	inc	hl
	inc	de
	ret	nz
	djnz	.verify
	ret
check_dcs6_icon:
	ld	hl,(temp_prgm_data_ptr)
	ld	de,lut_dcs6_icon
	ld	b,7
	jr	check_dcs_icon.verify
check_mos_dcs_icon:
	ld	hl,(temp_prgm_data_ptr)
	ld	de,lut_dcs6_icon
	ld	b,7
	jr	check_dcs_icon.verify
check_description_icon:
	ld	hl,(temp_prgm_data_ptr)
.enter:
	ld	de,lut_description_icon
	ld	b,2
	jr	check_dcs_icon.verify

file_editable:
	push	bc,de,hl
	call	check_description_icon
	jq	z,description_icon
	call	check_dcs_icon
	jr	z,.dcs_icon
	call	check_dcs6_icon
	jr	z,.dcs_icon
	jr	.return
.dcs_icon:
	ld	de,sprite_temp				; setup new icon
	ld	a,16
	ld	(de),a
	inc	de
	ld	(de),a

	ld	bc,16
	add	hl,bc
	ld	a,(hl)
	sbc	hl,bc
	cp	a,ti.tString
	jp	z,monochrome_8x8
	cp	a,ti.tEnter
	jp	z,monochrome_8x8

	ld	bc,64
	add	hl,bc
	ld	a,(hl)
	sbc	hl,bc
	cp	a,ti.tString
	jp	z,monochrome_16x16
	cp	a,ti.tEnter
	jp	z,monochrome_16x16

	ld	bc,256
	add	hl,bc
	ld	a,(hl)
	sbc	hl,bc
	cp	a,ti.tString
	jr	z,color_16x16
	cp	a,ti.tEnter
	jr	z,color_16x16

.return:
	pop	hl,de,bc
	jq	draw_listed_entry

color_16x16:
	pop	bc
	ld	de,sprite_temp				; push new icon
	push	de
	inc	de
	inc	de
	ld	b,0
.loop:							; okay, now loop 256 times to do the squish
	ld	a,(hl)
	sub	a,$30
	cp	a,$11
	jr	c,.no_overflow
	sub	a,$07
.no_overflow:						; rather than doing an actual routine, just do this
	push	hl
	ld	hl,lut_color_basic
	call	ti.AddHLAndA
	ld	a,(hl)
	pop	hl
	ld	(de),a
	inc	de
	inc	hl
	djnz	.loop					; collect all the values
	jq	file_editable.return

monochrome_8x8:
	pop	bc
	ld	de,sprite_temp				; push new icon
	push	de
	inc	de
	inc	de
	ex	de,hl
	ld	b,8
.loop:
	ld	a,(de)					; high nibble
	inc	de
	call	util_ascii_nibble_to_byte
	add	a,a
	add	a,a
	add	a,a
	add	a,a
	ld	c,a
	ld	a,(de)					; high nibble
	inc	de
	call	util_ascii_nibble_to_byte
	add	a,c					; byte :)
	ld	c,a
	push	bc
	push	hl
	ld	b,8
.inner_byte:
	rl	c
	ld	a,107
	jr	c,.set
.not_set:
	ld	a,(color_senary)
.set:
	ld	(hl),a
	inc	hl
	ld	(hl),a
	inc	hl
	djnz	.inner_byte
	push	hl
	pop	bc
	pop	hl
	push	de
	push	bc
	pop	de
	ld	bc,16
	ldir
	ex	de,hl
	pop	de
	pop	bc
	djnz	.loop
	jq	file_editable.return

monochrome_16x16:
	pop	bc
	ld	de,sprite_temp				; push new icon
	push	de
	inc	de
	inc	de
	ex	de,hl
	ld	b,64
.loop:
	ld	a,(de)					; high nibble
	inc	de
	call	util_ascii_nibble_to_byte
	add	a,a
	add	a,a
	add	a,a
	add	a,a
	ld	c,a
	ld	a,(de)					; high nibble
	inc	de
	call	util_ascii_nibble_to_byte
	add	a,c					; byte :)
	ld	c,a
	push	bc
	ld	b,8
.inner_byte:
	rl	c
	ld	a,107
	jr	c,.set
.not_set:
	ld	a,(color_senary)
.set:
	ld	(hl),a
	inc	hl
	djnz	.inner_byte
	pop	bc
	djnz	.loop
	jq	file_editable.return

description_icon:
	push	hl
	ld	hl,0
tmp_prgm_real_size := $-3
	dec	hl
	ld	(.smc_prgm_real_size),hl
	compare_hl_zero
	pop	hl
	ld	de,sprite_temp
	jr	z,.done_get_icon
	xor	a,a
.next_token:
	push	hl
	push	de
	push	af
	ld	a,(hl)
	cp	a,ti.tEnter
	jr	z,.done_get_icon
	inc	hl
	cp	a,ti.tString
	jr	z,.done_get_icon
	dec	hl
	push	hl
	ld	hl,0
.smc_prgm_real_size := $-3
	dec	hl
	ld	(.smc_prgm_real_size),hl
	compare_hl_zero
	pop	hl
	jr	z,.no_icon
	call	ti.Get_Tok_Strng
	ld	c,a
	pop	af
	add	a,c
	cp	a,25
	jr	nc,.no_icon
	pop	de
	pop	hl
	push	af
	ld	a,(hl)
	call	ti.Isa2ByteTok
	jr	nz,.not2byte
	inc	hl
.not2byte:
	inc	hl
	push	hl
	ld	hl,ti.OP3
	ldir
	pop	hl
	pop	af
	jr	.next_token
.done_get_icon:
	pop	bc,bc,bc
	xor	a,a
	ld	(de),a
	inc	hl
	push	hl
	ld	hl,sprite_temp
	bit	drawing_selected,(iy + item_flag)
	call	nz,gui_show_description
	pop	hl
	call	check_description_icon.enter
	jq	nz,file_editable.return
	jq	file_editable.dcs_icon
.no_icon:
	pop	bc,bc,bc
	xor	a,a
	ld	(de),a
	ld	hl,sprite_temp
	bit	drawing_selected,(iy + item_flag)
	call	nz,gui_show_description
	jq	file_editable.return

draw_listed_entry:
	ld	a,(lcd_y)
	push	af
	ld	ix,(lcd_x)
	push	ix					; save_cursor
	ld	(tmp_y),a
	push	de					; save language string
	push	hl					; save icon pointer
	call	lcd_sprite
	ld	a,0
tmp_y := $-1
	sub	a,20
	ld	c,a
	ld	hl,sprite_locked
	ld	b,250
	bit	temp_prgm_locked,(iy + temp_prgm_flag)
	jr	z,.not_protected
	push	bc
	call	lcd_sprite
	pop	bc
.not_protected:
	ld	a,b
	sub	a,4
	ld	b,a
	ld	hl,sprite_archived
	bit	temp_prgm_archived,(iy + temp_prgm_flag)
	call	nz,lcd_sprite
	bit	drawing_selected,(iy + item_flag)
	pop	hl					; hl -> program icon
	jp	z,.not_selected

	ld	a,(iy + temp_prgm_flag)
	ld	(iy + prgm_flag),a			; load the program info

	draw_sprite_2x 120, 57
	ld	a,(color_senary)
	ld	(lcd_text_bg),a

	print	string_language, 199, 107
	pop	hl
	call	lcd_string				; hl -> language string

	bit	temp_prgm_is_usb_directory,(iy + temp_prgm_flag)
	jq	nz,.nosize
	print string_size, 199, 151
	ld	hl,(prgm_size)
	call	lcd_num_5
.nosize:

	print string_attributes, 199, 173
	set_cursor_x 262
	inc	hl
	call	lcd_string

	print string_archived, 199, 118

	ld	a,(current_screen)
	cp	a,screen_appvars			; don't draw things that appvars can't handle
	jr	z,.dont_draw_extras

	print string_locked, 199, 129
	print string_hidden, 199, 140

	print string_rename, 199, 195
	ld	de,262
	ld	(lcd_x),de
	inc	hl
	call	lcd_string

	bit	prgm_locked,(iy + prgm_flag)
	jr	nz,.is_locked
	print	string_edit_prgm, 199, 184
	ld	de,269
	jr	.no_new
.is_locked:
	print	string_new_prgm, 199, 184
	ld	de,287
.no_new:
	ld	(lcd_x),de
	inc	hl
	call	lcd_string

.dont_draw_extras:

	call	gui_draw_item_options
	call	gui_draw_static_options

	push	de
.not_selected:
	pop	de					; description may not have been popped
	pop	bc
	ld	(lcd_x),bc
	pop	af
	ld	(lcd_y),a				; restore_cursor

	pop	hl					; restore list location
	pop	bc
	dec	bc
	ld	a,b
	or	a,c
	jp	nz,view_vat_items.loop
	ret

.file_directory:
	push	hl
	or	a,a
	sbc	hl,hl
	ld	(prgm_size),hl
	pop	hl
	jp	draw_listed_entry
