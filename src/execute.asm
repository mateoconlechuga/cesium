execute_item_alternate:
	set	cesium_execute_alt,(iy + cesium_flag)
execute_item:
	ld	hl,(current_selection_absolute)
	ld	a,(current_screen)
	cp	a,screen_programs
	jr	z,execute_program_check
	cp	a,screen_apps
	jr	z,execute_app_check
	;cp	a,screen_usb
	;jr	z,execute_usb_check
	jp	exit_full

execute_program_check:
	compare_hl_zero
	jr	nz,execute_program			; check if on directory
	ld	a,screen_apps
	ld	(current_screen),a
	jp	main_start
execute_app_check:
	compare_hl_zero
	jr	nz,execute_app				; check if on directory
	ld	a,screen_programs
	ld	(current_screen),a
	jp	main_start				; abort!

execute_program:
	jp	exit_full

execute_app:
	jp	exit_full
