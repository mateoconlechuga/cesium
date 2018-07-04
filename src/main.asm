; main cesium process routines

main_cesium:
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
	cp	a,skClear
	jp	z,exit_full
	cp	a,skMode
	jp	z,settings_show
	cp	a,skUp
	jp	z,main_move_up_return
	cp	a,skDown
	jp	z,main_move_down_return
	cp	a,sk2nd
	jp	z,execute_item
	cp	a,skEnter
	jp	z,execute_item_alternate
	cp	a,skGraph
	jp	z,feature_item_rename
	cp	a,skYequ
	jp	z,feature_item_new
	cp	a,skAlpha
	jp	z,feature_item_attributes
	cp	a,skZoom
	jp	z,feature_item_edit
	cp	a,skDel
	jp	z,feature_item_delete
	sub	a,skAdd
	jp	c,main_loop
	cp	a,skMath - skAdd + 1
	jp	nc,main_loop
	call	search_alpha_item
	jp	z,main_loop
	jp	main_start

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
	call	_ClrGetKeyHook				; clear key hooks

	ld	a,screen_programs
	ld	(current_screen),a			; start on the programs screen

	ld	hl,util_get_battery
	push	hl					; return here

	ld	a,(return_info)				; let's check if returned from execution
	cp	a,return_goto
	ret	nz
	ld	hl,basic_prog
	ld	a,(hl)					; check if correct program
	cp	a,protProgObj
	ret	z
	pop	bc					; pop return location
	inc	hl
	call	util_get_archived_name
	call	_Mov9ToOP1
	call	_ChkFindSym
	jp	nc,edit_basic_program_goto
	jp	util_get_battery
