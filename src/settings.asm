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

; common routines for working with things involving settings

SETTINGS_ITEMS_PAGE_1 := 9
SETTINGS_ITEMS_PAGE_2 := 5

settings_load:
	ld	hl,settings_appvar
	call	util_find_var			; lookup the settings appvar
	jr	c,settings_create_default	; create it if it doesn't exist
	call	ti.ChkInRam
	push	af
	call	z,cesium.Arc_Unarc		; archive it
	pop	af
	jq	z,settings_load			; find it again
settings_get_data:
	ex	de,hl
	ld	de,9
	add	hl,de
	ld	e,(hl)
	add	hl,de
	inc	hl
	push	hl
	call	ti.LoadDEInd_s			; make sure the size matches
	ld	hl,settings_size
	compare_hl_de
	pop	hl
	jr	nz,settings_create_default
	inc	hl
	inc	hl
	ld	de,settings_data
	ld	bc,settings_size
	ldir
	ld	iy,ti.flags
	ld	a,(setting_config)
	ld	(iy + settings_flag),a
	ld	a,(setting_adv_config)
	ld	(iy + settings_adv_flag),a
	call	gui_fixup_sprites
	jp	util_setup_shortcuts

settings_create_default:
	ld	hl,setting_color_primary	; initialize default settings
	ld	(hl),color_primary_default
	inc	hl
	ld	(hl),color_secondary_default
	inc	hl
	ld	(hl),color_tertiary_default
	inc	hl
	ld	(hl),color_quaternary_default
	inc	hl
	ld	(hl),color_quinary_default
	inc	hl
	ld	(hl),color_senary_default
	ld	hl,setting_config
	ld	(hl),settings_default
	ld	hl,setting_adv_config
	ld	(hl),settings_adv_default
	ld	hl,setting_password
	ld	(hl),0
	ld	hl,settings_editor_default_prgm_name
	ld	de,setting_editor_name
	ld	bc,settings_editor_default_prgm_name.length
	ldir
	call	settings_appvar_create_if_not_exist.make
	inc	de
	inc	de
	ld	hl,settings_data
	ld	bc,settings_size
	ldir
	jq	settings_load

settings_appvar_create_if_not_exist:
	ld	hl,settings_appvar
	call	util_find_var			; lookup the settings appvar
	ret	nc
	jq	.nodelete
.make:
	ld	hl,settings_appvar
	call	util_delete_var			; delete if exists
.nodelete:
	ld	hl,settings_size + 128		; increment for safety
	call	ti.EnoughMem
	ld	hl,settings_size
	jq	c,exit_full
	jp	ti.CreateAppVar

settings_save:
	call	settings_appvar_create_if_not_exist
	ld	a,(iy + settings_flag)
	ld	(setting_config),a
	ld	a,(iy + settings_adv_flag)
	and	a,(1 shl setting_special_directories) or \
                  (1 shl setting_enable_usb) or \
                  (1 shl setting_list_count)
	ld	(setting_adv_config),a
	ld	hl,settings_appvar
	call	util_find_var
	call	ti.ChkInRam
	ex	de,hl
	jq	z,.inram
	ld	de,9
	add	hl,de
	ld	e,(hl)
	add	hl,de
	inc	hl
.inram:
	inc	hl
	inc	hl				; compare to prev settings
	ld	de,settings_data
	ld	b,settings_size
.check:
	ld	a,(de)
	cp	a,(hl)
	jr	nz,.needs_save
	inc	hl
	inc	de
	djnz	.check
	call	ti.ChkInRam
	jq	z,.needs_archive
	ret					; no save needed
.needs_save:
	ld	hl,settings_appvar
	call	util_find_var
	call	ti.ChkInRam
	push	af
	call	nz,cesium.Arc_Unarc
	pop	af
	jq	nz,.needs_save			; unarchive to save
	inc	de
	inc	de
	ld	hl,settings_data
	ld	bc,settings_size
	ldir
.needs_archive:
	ld	hl,settings_appvar
	call	util_find_var
	jp	cesium.Arc_Unarc

settings_show:
	ld	a,(current_screen)
	cp	a,screen_usb
	jp	z,main_loop
	xor	a,a
	ld	(current_option_selection),a			; start on the first menu item
	ld	(setting_brightness_get.counter),a
.draw:
	call	setting_draw_options

settings_get:
	call	util_get_key
	ld	hl,settings_show.draw
	push	hl
	ld	ix,current_option_selection
	cp	a,ti.skLeft
	jq	z,setting_left
	cp	a,ti.skRight
	jq	z,setting_right
	cp	a,ti.skDown
	jq	z,setting_down
	cp	a,ti.skUp
	jq	z,setting_up
	cp	a,ti.sk2nd
	jq	z,setting_toggle
	cp	a,ti.skEnter
	jq	z,setting_toggle
	pop	hl
	cp	a,ti.skDel
	jr	z,setting_set_and_save
	cp	a,ti.skMode
	jr	z,setting_set_and_save
	cp	a,ti.skClear
	jq	z,setting_set_and_save
	jq	settings_get
setting_set_and_save:
	call	settings_save			; check if on disabled apps screen
	ld	a,(current_screen)
	cp	a,screen_apps
	jq	z,settings_return
	bit	setting_special_directories,(iy + settings_adv_flag)
	jq	nz,settings_return
	call	find_lists.reset_selection
	ld	a,screen_programs
	ld	(current_screen),a
settings_return:
	ld	a,return_settings
	ld	(return_info),a
	jq	main_settings

setting_down:
	ld	a,(settings_page)
	or	a,a
	ld	a,(ix)
	jq	z,.page1
.page2:
	cp	a,SETTINGS_ITEMS_PAGE_2 - 1
	jq	z,.top
	jr	.inc
.page1:
	cp	a,SETTINGS_ITEMS_PAGE_1 - 1
	jq	z,.top
.inc:
	inc	a
.done:
	ld	(ix),a
	ret
.top:
	xor	a,a
	jq	.done

setting_up:
	ld	a,(ix)
	or	a,a
	jr	z,.bottom
	dec	a
	jq	setting_down.done
.bottom:
	ld	a,(settings_page)
	or	a,a
	jq	z,.page1
	ld	a,SETTINGS_ITEMS_PAGE_2 - 1
	jq	setting_down.done
.page1:
	ld	a,SETTINGS_ITEMS_PAGE_1 - 1
	jq	setting_down.done

setting_left:
	ld	a,(ix)
	cp	a,7
	jq	z,setting_brightness_down
	jq	settings_switch_page

setting_brightness_down:
	call	setting_brightness_get
	sub	a,b
	ld	(hl),a
	ret

setting_right:
	ld	a,(ix)
	cp	a,7
	jq	z,setting_brightness_up
	jq	settings_switch_page

settings_switch_page:
	ld	a,(settings_page)
	xor	a,1
	ld	(settings_page),a
	xor	a,a
	ld	(current_option_selection),a
	ret

setting_brightness_up:
	call	setting_brightness_get
	add	a,b
	ld	(hl),a
	ret

setting_brightness_get:
	ld	b,0
.prev_key := $-1
	cp	a,b
	jr	z,.no_reset
	xor	a,a
	jr	.reset
.no_reset:
	ld	a,0
.counter := $-1
	cp	a,10
	ld	b,10
	jr	z,.fast
.reset:
	inc	a
	ld	(.counter),a
	ld	b,1
.fast:
	ld	a,c
	ld	(.prev_key),a
	ld	hl,ti.mpBlLevel
	ld	a,(hl)
	ret

setting_toggle:
	ld	a,(settings_page)
	or	a,a
	jq	z,.page1
.page2:
	ld	a,(ix)
	cp	a,3
	jq	z,settings_set_prgm_editor
	cp	a,4
	jq	z,settings_set_poweron_password
	inc	a
	call	util_to_one_hot
	xor	a,(iy + settings_adv_flag)
	ld	(iy + settings_adv_flag),a
	ret
.page1:
	ld	a,(ix)
	or	a,a
	jq	z,setting_change_colors
	call	util_to_one_hot
	xor	a,(iy + settings_flag)
	ld	(iy + settings_flag),a
	ret

setting_change_colors:
	xor	a,a
	ld	hl,color_primary
	ld	(color_table_active),a
	ld	(color_ptr),hl
	call	setting_color_get_xy
	call	gui_draw_color_table		; temporarily draw tables to compute color
setting_open_colors:
	call	gui_color_box.compute
	call	setting_draw_options
	call	gui_draw_color_table
.loop:
	call	util_get_key
	ld	hl,setting_open_colors
	push	hl
	cp	a,ti.skLeft
	jr	z,setting_color_left
	cp	a,ti.skRight
	jr	z,setting_color_right
	cp	a,ti.skDown
	jr	z,setting_color_down
	cp	a,ti.skUp
	jr	z,setting_color_up
	cp	a,ti.skMode
	jr	z,setting_color_swap
	pop	hl
	cp	a,ti.sk2nd
	jr	.complete
	cp	a,ti.skEnter
	jr	.complete
	cp	a,ti.skClear
	jr	.complete
	cp	a,ti.skDel
	jr	.complete
	pop	hl
	jr	.loop
.complete:
	call	gui_fixup_sprites
	jp	settings_show.draw

setting_color_left:
	ld	a,(color_selection_x)
	or	a,a
	ret	z
	dec	a
	ld	(color_selection_x),a
	ret

setting_color_right:
	ld	a,0
color_selection_x := $-1
	cp	a,15
	ret	z
	inc	a
	ld	(color_selection_x),a
	ret

setting_color_down:
	ld	a,(color_selection_y)
	cp	a,15
	ret	z
	inc	a
	ld	(color_selection_y),a
	ret

setting_color_up:
	ld	a,0
color_selection_y := $-1
	or	a,a
	ret	z
	dec	a
	ld	(color_selection_y),a
	ret

setting_color_swap:
	ld	hl,color_primary
	ld	a,0
color_table_active := $-1
	cp	a,5
	jr	nz,.incr
	ld	a,-1
.incr:
	inc	a
	ld	(color_table_active),a
	call	ti.AddHLAndA
	ld	(color_ptr),hl
	jq	setting_color_get_xy

setting_color_get_xy:
	ld	hl,(color_ptr)
	ld	a,(hl)
setting_color_index_to_xy:
	ld	b,a
	srl	a
	srl	a
	srl	a
	srl	a		; index / 16
	and	a,$f		; got y
	ld	(color_selection_y),a
	ld	a,b
	and	a,$f
	ld	(color_selection_x),a
	ret

setting_draw_options:
	call	gui_draw_cesium_info
	ld	a,(settings_page)
	or	a,a
	jq	z,.page1

.page2:
	print	string_setting_page2, 10, 30

	print	string_setting_special_directories, 25, 49
	print	string_setting_list_count, 25, 69
	print	string_setting_usb_enable, 25, 89
	print	string_setting_editor_prgm, 25, 109
	print	string_setting_poweron_password, 25, 129

	bit	setting_special_directories,(iy + settings_adv_flag)
	draw_highlightable_option 10, 48, 0
	bit	setting_list_count,(iy + settings_adv_flag)
	draw_highlightable_option 10, 68, 1
	bit	setting_enable_usb,(iy + settings_adv_flag)
	draw_highlightable_option 10, 88, 2
	draw_highlighted_option 10, 108, 3
	draw_highlighted_option 10, 128, 4
	ret

.page1:
	print	string_setting_page1, 10, 30

	print	string_setting_color, 25, 49
	print	string_setting_indicator, 25, 69
	print	string_setting_clock, 25, 89
	print	string_setting_show_battery, 25, 109
	print	string_setting_ram_backup, 25, 129
	print	string_setting_show_hidden, 25, 149
	print	string_setting_enable_shortcuts, 25, 169
	print	string_setting_delete_confirm, 25, 189
	print	string_setting_screen_brightness, 25, 209

	draw_highlighted_option 10, 48, 0
	bit	setting_basic_indicator,(iy + settings_flag)
	draw_highlightable_option 10, 68, 1
	bit	setting_clock,(iy + settings_flag)
	draw_highlightable_option 10, 88, 2
	bit	setting_show_battery,(iy + settings_flag)
	draw_highlightable_option 10, 108, 3
	bit	setting_ram_backup,(iy + settings_flag)
	draw_highlightable_option 10, 128, 4
	bit	setting_hide_hidden,(iy + settings_flag)
	draw_highlightable_option 10, 148, 5
	bit	setting_enable_shortcuts,(iy + settings_flag)
	draw_highlightable_option 10, 168, 6
	bit	setting_delete_confirm,(iy + settings_flag)
	draw_highlightable_option 10, 188, 7
	draw_highlighted_option 10, 208, 8
	ret

settings_set_prgm_editor:
	pop	hl				; not returning to loop
	call	gui_draw_cesium_info
	print	string_prgm_editor_name, 10, 30
	ld	hl,setting_editor_name + 1
	call	util_get_var_name_input.prgm
	jq	settings_show.draw

settings_set_poweron_password:
	call	gui_draw_cesium_info

	print	string_new_password, 10, 30
	ld	hl,setting_password + 1
	ld	b,6
.loop:
	push	hl
	push	bc
	call	lcd_blit
.get_key:
	call	ti.GetCSC
	or	a,a
	jr	z,.get_key
	cp	a,ti.sk2nd
	jr	z,.done_fill
	cp	a,ti.skEnter
	jr	z,.done_fill
	push	af
	ld	a,'*'
	call	lcd_char
	pop	af
	pop	bc
	pop	hl
	ld	(hl),a
	inc	hl
	djnz	.loop
.done:
	ld	de,setting_password + 1
	or	a,a
	sbc	hl,de
	ld	a,l
	ld	(setting_password),a
	ret
.done_fill:
	pop	bc
	pop	hl
	jr	.done

settings_appvar:
	db	ti.AppVarObj, cesium_name, 0

settings_page:
	db	0

settings_editor_default_prgm_name:
	db	ti.ProtProgObj,"KRYPTIDE",0
.length :=$-settings_editor_default_prgm_name
