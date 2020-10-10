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

; main cesium process routines

main_cesium:
	call	port_setup
	or	a,a
	jq	z,.okay
.invalid_os:
	call	ti.ClrScrn
	jp	ti.HomeUp
	ld	hl,str_invalid_os
	call	ti.PutS
	call	ti.GetKey
	call	ti.ClrScrn
	jp	ti.HomeUp
.okay:
	call	lcd_init
	call	main_init
main_settings:
	call	settings_load
main_find:
	call	find_files
main_start:
	call	gui_main
	call	util_setup_apd
main_loop:
	call	util_get_key
	cp	a,ti.skClear
	jp	z,.check_exit
	cp	a,ti.skMode
	jp	z,settings_show
	cp	a,ti.skUp
	jp	z,main_move_up_return
	cp	a,ti.skDown
	jp	z,main_move_down_return
	;cp	a,ti.skPrgm
	;jp	z,fat_file_transfer_from_device
	cp	a,ti.sk2nd
	jp	z,execute_item
	cp	a,ti.skEnter
	jp	z,execute_item_alternate
	cp	a,ti.skGraph
	jp	z,feature_item_rename
	cp	a,ti.skYequ
	jp	z,feature_item_new
	cp	a,ti.skAlpha
	jp	z,feature_item_attributes
	cp	a,ti.skZoom
	jp	z,feature_item_edit
	cp	a,ti.skDel
	jp	z,feature_item_delete
	sub	a,ti.skAdd
	jp	c,main_loop
	cp	a,ti.skMath - ti.skAdd + 1
	jp	nc,main_loop
	call	search_alpha_item
	jp	z,main_loop
	jp	main_start
.check_exit:
	ld	a,(current_screen)
	cp	a,screen_usb
	jp	z,usb_detach
	jp	exit_full

main_move_up_return:
	ld	hl,main_start
	push	hl
main_move_up:
	ld	hl,(current_selection_absolute)
	compare_hl_zero
	ret	z					; check if we are at the top
	dec	hl
	ld	(current_selection_absolute),hl
	ld	a,(current_selection)
	or	a,a
	jr	nz,.dont_scroll
	ld	hl,(scroll_amount)
	dec	hl
	ld	(scroll_amount),hl
	ret
.dont_scroll:
	dec	a
	ld	(current_selection),a
	ret

main_move_down_return:
	ld	hl,main_start
	push	hl
main_move_down:
	ld	hl,(current_selection_absolute)
	ld	de,(number_of_items)
	dec	de
	compare_hl_de
	ret	z
	inc	hl
	ld	(current_selection_absolute),hl
	ld	a,(current_selection)
	cp	a,9					; limit items per screen
	jr	nz,dont_scroll
	ld	hl,(scroll_amount)
	inc	hl
	ld	(scroll_amount),hl
	ret
dont_scroll:
	inc	a
	ld	(current_selection),a
	ret

main_init:
	call	ti.ClrGetKeyHook			; clear key hooks

	ld	a,screen_programs
	ld	(current_screen),a			; start on the programs screen

	ld	hl,util_get_battery
	push	hl					; return here

	ld	a,(return_info)				; let's check if returned from execution
	cp	a,return_goto
	ret	nz
	ld	hl,ti.basic_prog
	ld	a,(hl)					; check if correct program
	cp	a,ti.ProtProgObj
	ret	z
	pop	bc					; pop return location
	inc	hl
	call	util_get_archived_name
	call	ti.Mov9ToOP1
	call	ti.ChkFindSym
	jp	nc,edit_basic_program_goto
	jp	util_get_battery
