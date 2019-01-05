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
	;cp	a,screen_apps
	;jr	z,execute_app_check
	jr	execute_app_check			; optimize!

execute_vat_check:
	bit	prgm_is_usb_directory,(iy + prgm_flag)
	jp	nz,usb_init
	bit	setting_special_directories,(iy + settings_flag)
	jp	z,execute_program
	compare_hl_zero
	jp	nz,execute_program			; check if on directory
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
	call	ti.ClrParserHook
	call	ti.ClrAppChangeHook
	call	util_setup_shortcuts
	res	ti.useTokensInString,(iy + ti.clockFlags)
	res	ti.onInterrupt,(iy + ti.onFlags)
	set	ti.graphDraw,(iy + ti.graphFlags)
	call	ti.ResetStacks
	call	ti.ReloadAppEntryVecs
	call	ti.AppSetup
	set	ti.appRunning,(iy + ti.APIFlg)		; turn on apps
	set	6,(iy + $28)
	res	0,(iy + $2C)				; set some app flags
	set	ti.appAllowContext,(iy + ti.APIFlg)	; turn on apps
	ld	hl,$d1787c				; copy to ram data location
	ld	bc,$fff
	call	ti.MemClear				; zero out the ram data section
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
	ld	a,(current_screen)
	cp	a,screen_appvars
	jp	z,main_loop
	bit	cesium_execute_alt,(iy + cesium_flag)
	jr	nz,.skip_backup
	bit	setting_ram_backup,(iy + settings_flag)
	call	nz,gui_backup_ram_to_flash
.skip_backup:
	call	lcd_normal
	call	util_move_prgm_name_to_op1
	call	util_backup_prgm_name
.entry:							; entry point, OP1 = name
	bit	setting_enable_shortcuts,(iy + settings_flag)
	call	nz,ti.ClrGetKeyHook
	bit	prgm_is_basic,(iy + prgm_flag)
	jr	nz,execute_ti.basic_program		; execute basic program
	call	util_move_prgm_to_usermem		; execute assembly program
	call	util_install_error_handler
execute_assembly_program:
	ld	hl,return_asm
	push	hl
	call	ti.DisableAPD
	set	ti.appAutoScroll,(iy + ti.appFlags)	; allow scrolling
	jp	ti.userMem

execute_ti.basic_program:
	ld	hl,(prgm_data_ptr)
	ld	a,(hl)
	cp	a,ti.tExtTok
	jr	nz,.not_unsquished			; check if actually an unsquished assembly program
	inc	hl
	ld	a,(hl)
	cp	a,ti.tAsm84CePrgm
	jp	z,squish_program			; we've already installed an error handler
.not_unsquished:
	call	ti.ClrTxtShd
	call	ti.HomeUp
	call	ti.RunIndicOn
	bit	setting_basic_indicator,(iy + settings_flag)
	call	nz,ti.RunIndicOff
	call	ti.DisableAPD
	call	hook_home.save
	call	hook_home.set
	bit	prgm_archived,(iy + prgm_flag)
	jr	z,.in_ram
	call	util_delete_temp_program_get_name
	ld	hl,(prgm_real_size)
	push	hl
	ld	a,ti.TempProgObj
	call	ti.CreateVar				; create a temp program so we can execute
	inc	de
	inc	de
	pop	bc
	call	ti.ChkBCIs0
	jr	z,.in_rom				; there's nothing to copy
	ld	hl,(prgm_data_ptr)
	ldi
	jp	po,.in_rom
	ldir
.in_rom:
	call	ti.OP4ToOP1
.in_ram:
	ld	de,ti.appErr1
	ld	hl,string_error_stop
	ld	bc,string_error_stop.length
	ldir
	set	ti.graphDraw,(iy + ti.graphFlags)
	ld	hl,return_basic_error
	call	ti.PushErrorHandler
	res	ti.appTextSave,(iy + ti.appFlags)	; text goes to textshadow
	set	ti.progExecuting,(iy + ti.newDispF)
	set	ti.allowProgTokens,(iy + ti.newDispF)
	res	7,(iy + $45)
	set	ti.appAutoScroll,(iy + ti.appFlags)	; allow scrolling
	set	ti.cmdExec,(iy + ti.cmdFlags) 		; set these flags to execute basic program
	res	ti.onInterrupt,(iy + ti.onFlags)
	ld	hl,return_basic
	push	hl
	sub	a,a
	ld	(ti.kbdGetKy),a
	call	ti.EnableAPD
	ei
	jp	ti.ParseInp				; run program
