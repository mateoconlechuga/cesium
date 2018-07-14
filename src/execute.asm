execute_item_alternate:
	set	cesium_execute_alt,(iy + cesium_flag)
	jr	execute_item.alt
execute_item:
	res	cesium_execute_alt,(iy + cesium_flag)
.alt:
	call	flash_code_copy
	ld	hl,(current_selection_absolute)
	ld	a,(current_screen)
	cp	a,screen_programs
	jr	z,execute_vat_check
	cp	a,screen_appvars
	jr	z,execute_vat_check
	cp	a,screen_apps
	jr	z,execute_app_check
	;cp	a,screen_usb
	;jr	z,execute_usb_check
	jp	exit_full

execute_vat_check:
	compare_hl_zero
	jp	nz,execute_program			; check if on directory
	bit	setting_special_directories,(iy + settings_flag)
	jp	z,main_find
	ld	a,screen_apps
	ld	(current_screen),a
	jp	main_find
execute_app_check:
	ld	a,screen_programs
	compare_hl_zero
	jr	z,.new					; check if on directory
	ld	a,screen_appvars
	dec	hl
	compare_hl_zero
	jr	nz,execute_app
.new:
	ld	(current_screen),a
	jp	main_find				; abort!

execute_app:
	bit	setting_ram_backup,(iy + settings_flag)
	call	nz,flash_clear_backup
	call	lcd_normal
	call	_ClrParserHook
	call	_ClrAppChangeHook
	call	util_setup_shortcuts
	res	useTokensInString,(iy + clockFlags)
	res	onInterrupt,(iy + onFlags)
	set	graphDraw,(iy + graphFlags)
	call	_ResetStacks
	call	_ReloadAppEntryVecs
	call	_AppSetup
	set	appRunning,(iy+APIFlg)			; turn on apps
	set	6,(iy+$28)
	res	0,(iy+$2C)				; set some app flags
	set	appAllowContext,(iy+APIFlg)		; turn on apps
	ld	hl,$d1787c				; copy to ram data location
	ld	bc,$fff
	call	_MemClear				; zero out the ram data section
	ld	hl,(item_ptr)				; hl -> start of app
	push	hl					; de -> start of code for app
	ex	de,hl
	ld	hl,$18					; find the start of the data to copy to ram
	add	hl,de
	ld	hl,(hl)
	compare_hl_zero					; initialize the bss if it exists
	jr	z,.no_bss
	push	hl
	pop	bc
	ld	hl,$15
	add	hl,de
	ld	hl,(hl)
	add	hl,de
	ld	de,$d1787c				; copy it in
	ldir
.no_bss:
	pop	hl
	push	hl
	pop	de
	ld	bc,$1b					; offset
	add	hl,bc
	ld	hl,(hl)
	add	hl,de
	jp	(hl)

execute_program:
	bit	cesium_execute_alt,(iy + cesium_flag)
	jr	nz,.skip_backup
	bit	setting_ram_backup,(iy + settings_flag)
	call	nz,gui_backup_ram_to_flash
.skip_backup:
	bit	setting_enable_shortcuts,(iy + settings_flag)
	call	nz,_ClrGetKeyHook
	call	lcd_normal
	call	util_move_prgm_name_to_op1
	call	util_backup_prgm_name
	bit	prgm_is_basic,(iy + prgm_flag)
	jp	nz,execute_basic_program		; execute basic program
	call	util_move_prgm_to_usermem		; execute assembly program
	call	util_install_error_handler
execute_assembly_program:
	ld	hl,return_asm
	push	hl
	set	appAutoScroll,(iy + appflags)		; allow scrolling
	jp	userMem

execute_basic_program:
	ld	hl,(prgm_data_ptr)
	ld	a,(hl)
	cp	a,tExtTok
	jr	nz,.not_unsquished			; check if actually an unsquished assembly program
	inc	hl
	ld	a,(hl)
	cp	a,tAsm84CePrgm
	jp	z,squish_program			; we've already installed an error handler
	jr	execute_assembly_program
.not_unsquished:
	call	_ClrTxtShd
	call	_HomeUp
	call	_RunIndicOn
	bit	setting_basic_indicator,(iy + settings_flag)
	call	nz,_RunIndicOff
	call	_APDSetup
	call	_EnableAPD
	call	hook_home.save
	call	hook_home.set
	bit	prgm_archived,(iy + prgm_flag)
	jr	z,.in_ram
	call	util_delete_temp_program_get_name
	ld	hl,(prgm_real_size)
	push	hl
	ld	a,tempProgObj
	call	_CreateVar				; create a temp program so we can execute
	inc	de
	inc	de
	pop	bc
	call	_ChkBCIs0
	jr	z,.in_rom				; there's nothing to copy
	ld	hl,(prgm_data_ptr)
	ldi
	jp	po,.in_rom
	ldir
.in_rom:
	call	_OP4ToOP1
.in_ram:
	ld	de,appErr1
	ld	hl,string_error_stop
	ld	bc,string_error_stop.length
	ldir
	set	graphdraw,(iy + graphFlags)
	ld	hl,return_basic_error
	call	_PushErrorHandler
	res	apptextsave,(iy + appflags)		; text goes to textshadow
	set	progExecuting,(iy + newdispf)
	set	allowProgTokens,(iy + newDispF)
	res	7,(iy + $45)
	set	appAutoScroll,(iy + appflags)		; allow scrolling
	set	cmdExec,(iy + cmdFlags) 		; set these flags to execute basic program
	res	onInterrupt,(iy + onflags)
	ld	hl,return_basic
	push	hl
	sub	a,a
	ld	(kbdGetKy),a
	ei
	jp	_ParseInp				; run program
