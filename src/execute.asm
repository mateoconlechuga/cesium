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

execute_app:
	jp	exit_full

execute_program:
	bit	cesium_execute_alt,(iy + cesium_flag)
	jr	nz,.skip_backup
	bit	setting_ram_backup,(iy + settings_flag)
	call	nz,gui_backup_ram_to_flash
.skip_backup:
	;call	hook_home.save
	;ld	hl,hook_home
	;call	_SetHomescreenHook
	;call	hook_home.establish
	bit	setting_enable_shortcuts,(iy + settings_flag)
	call	nz,_ClrGetKeyHook
	call	lcd_normal
	call	util_move_prgm_name_to_op1
	call	util_backup_prgm_name
	bit	prgm_is_basic,(iy + prgm_flag)
	jp	nz,execute_basic_program	; execute basic program
	call	util_move_prgm_to_usermem	; execute assembly program
	call	util_install_error_handler
execute_assembly_program:
	ld	hl,0
reloc_asm_return_location := $-3
	push	hl
	jp	userMem

execute_basic_program:
	ld	hl,(prgm_data_ptr)
	ld	a,(hl)
	cp	a,tExtTok
	jr	nz,.not_unsquished		; check if actually an unsquished assembly program
	inc	hl
	ld	a,(hl)
	cp	a,tAsm84CePrgm
	jr	nz,.not_unsquished
	call	squish_program			; we've already installed an error handler
	jr	execute_assembly_program
.not_unsquished:
	call	_RunIndicOn
	call	_ApdSetup
	call	_DisableAPD
	bit	setting_basic_indicator,(iy + settings_flag)
	call	nz,_RunIndicOff
	bit	prgm_archived,(iy + prgm_flag)
	jr	z,.in_ram
	call	util_delete_temp_program_get_name
	ld	hl,(prgm_real_size)
	push	hl
	call	_CreateProg			; create a temp program so we can execute
	inc	de
	inc	de
	pop	bc
	call	_ChkBCIs0
	jr	z,.in_rom			; there's nothing to copy
	ld	hl,(prgm_data_ptr)
	ldi
	jp	po,.in_rom
	ldir
.in_rom:
	call	_OP4ToOP1
.in_ram:
	ld	de,apperr1
	ld	hl,string_error_stop
	ld	bc,string_error_stop_end - string_error_stop
	ldir
	set	graphdraw,(iy+graphFlags)
	ld	hl,0
reloc_basic_error_handler := $-3
	call	_PushErrorHandler
	res	apptextsave,(iy+appflags)	;text goes to textshadow
	set	progExecuting,(iy+newdispf)
	set	allowProgTokens,(iy+newDispF)
	res	7,(iy + $45)
	set	cmdExec,(iy+cmdFlags) 		; set these flags to execute BASIC prgm
	res	onInterrupt,(iy+onflags)
	ld	hl,0
reloc_basic_return_handler := $-3
	push	hl
	sub	a,a
	ld	(kbdGetKy),a
	ei
	jp	_ParseInp			; run program
