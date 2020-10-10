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

execute_item_alternate:
	set	cesium_execute_alt,(iy + cesium_flag)
	jr	execute_item.alt
execute_item:
	res	cesium_execute_alt,(iy + cesium_flag)
.alt:
	ld	hl,(current_selection_absolute)
	ld	a,(current_screen)
	cp	a,screen_programs
	jq	z,execute_vat_check
	cp	a,screen_appvars
	jq	z,execute_vat_check
	cp	a,screen_usb
	jq	z,execute_usb_check
	cp	a,screen_apps
	jq	z,execute_app_check

execute_usb_check:
	ld	hl,(item_ptr)
	call	usb_check_directory
	jq	z,.not_directory			; if not a directory, check extension
	ld	a,(hl)
	cp	a,'.'					; check if special directory
	jr	nz,.not_special
	inc	hl
	ld	a,(hl)
	or	a,a
	jq	z,main_loop				; current directory skip
	cp	a,'.'
	jr	nz,.not_special
	inc	hl
	ld	a,(hl)
	or	a,a
	jr	nz,.not_special				; previous directory
	call	usb_directory_previous
	jr	.special_directory
.not_special:
	call	usb_append_fat_path			; append directory to path
.special_directory:
	xor	a,a
	sbc	hl,hl
	ld	(current_selection),a
	ld	(current_selection_absolute),hl
	call	fat_get_directory_listing		; update the path
	jq	main_start
.not_directory:
	;bit	item_is_prgm,(iy + item_flag)		; check if program and attempt to execute
	;jq	z,main_loop

	; here are the considerations when executing from usb:
	; assembly programs can be copied directly as normal
	; basic programs must be copied to a temporary program to be executed

	;call	usb_open_tivar
	;call	usb_validate_tivar
	;jq	z,execute_usb_program

	jq	main_loop

execute_vat_check:
	xor	a,a
	ld	(return_info),a
	bit	prgm_is_usb_directory,(iy + prgm_flag)
	jq	nz,usb_init
	bit	setting_special_directories,(iy + settings_adv_flag)
	jq	z,execute_program
	compare_hl_zero
	jq	nz,execute_program			; check if on directory
	ld	a,screen_apps
	ld	(current_screen),a
	jq	main_find
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
	jq	main_find				; abort!

execute_app:
	bit	setting_ram_backup,(iy + settings_flag)
	call	nz,flash_clear_backup
	call	lcd_normal
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

; so why doesn't this work? because:
; 1) compressed programs
; 2) programs that use themselves
; 3) subprograms
; 4) i'm lazy
;execute_usb_program:
	;ld	hl,(usb_var_size)
	;call	util_check_free_ram
	;jq	z,main_loop				; ensure enough ram
	;call	execute_ram_backup
	;call	lcd_normal
	;bit	setting_enable_shortcuts,(iy + settings_flag)
	;call	nz,ti.ClrGetKeyHook
	;ld	hl,usb_sector + 74
	;ld	a,(hl)
	;cp	a,ti.tExtTok				; is it an assembly program
	;jr	nz,.program_is_basic
	;inc	hl
	;ld	a,(hl)
	;cp	a,ti.tAsm84CeCmp
	;jr	nz,.program_is_basic			; is it a basic program
.program_is_asm:
	;call	util_install_error_handler
	;ld	hl,ti.userMem
	;ld	de,(ti.asm_prgm_size)
	;add	hl,de
	;ex	de,hl
	;ld	hl,(usb_var_size)
	;push	hl
	;call	ti.InsertMem				; insert memory into usermem + (ti.asm_prgm_size)
	;call	usb_copy_tivar_to_ram			; copy variable to ram
	;call	usb_detach_only				; shift assembly program to ti.userMem, detach usb & libload
	;pop	hl
	;ld	(ti.asm_prgm_size),hl			; reload size of the program
	;jr	execute_assembly_program
.program_is_basic:
	;jq	main_loop

execute_ram_backup:
	bit	cesium_execute_alt,(iy + cesium_flag)
	ret	nz
	bit	setting_ram_backup,(iy + settings_flag)
	call	nz,gui_backup_ram_to_flash
	ret

execute_program:
	ld	a,(current_screen)
	cp	a,screen_appvars
	jq	z,main_loop
	call	execute_ram_backup
	call	util_move_prgm_name_to_op1
	call	util_backup_prgm_name
.entry:							; entry point, OP1 = name
	bit	setting_enable_shortcuts,(iy + settings_flag)
	call	nz,ti.ClrGetKeyHook
	bit	prgm_is_basic,(iy + prgm_flag)
	jr	nz,execute_ti.basic_program		; execute basic program
	call	util_move_prgm_to_usermem		; execute assembly program
	jq	nz,main_loop				; return on error
	call	lcd_normal
	ld	hl,return_asm_error
	ld	(persistent_sp_error),sp
	call	ti.PushErrorHandler
	ld	(persistent_sp),sp
execute_assembly_program:
	ld	hl,return_asm
	push	hl
	call	ti.DisableAPD
	set	ti.appAutoScroll,(iy + ti.appFlags)	; allow scrolling
	jq	ti.userMem

execute_ti.basic_program:
	call	lcd_normal
	ld	hl,(prgm_data_ptr)
	ld	a,(hl)
	cp	a,ti.tExtTok
	jr	nz,.not_unsquished			; check if actually an unsquished assembly program
	inc	hl
	ld	a,(hl)
	cp	a,ti.tAsm84CePrgm
	jq	z,squish_program			; we've already installed an error handler
.not_unsquished:
	call	ti.ClrTxtShd
	call	ti.HomeUp
	call	ti.RunIndicOn
	bit	setting_basic_indicator,(iy + settings_flag)
	call	nz,ti.RunIndicOff
	call	ti.DisableAPD
	call	hook_home.save
	ld	hl,hook_home
	call	ti.SetHomescreenHook
	bit	prgm_archived,(iy + prgm_flag)
	jr	z,.in_ram
	ld	hl,util_temp_program_object
	call	util_delete_var
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
	jq	po,.in_rom
	ldir
.in_rom:
	call	ti.OP4ToOP1
.in_ram:
	call	ti.ClrTxtShd
	xor	a,a
	ld	(ti.curRow),a
	ld	(ti.curCol),a
	ld	(ti.appErr1),a
	set	ti.graphDraw,(iy + ti.graphFlags)
	ld	hl,return_basic_error
	ld	(persistent_sp_error),sp
	call	ti.PushErrorHandler
	ld	(persistent_sp),sp
	set	ti.appTextSave,(iy + ti.appFlags)	; text goes to textshadow
	set	ti.progExecuting,(iy + ti.newDispF)
	res	7,(iy + $45)
	set	ti.appAutoScroll,(iy + ti.appFlags)	; allow scrolling
	set	ti.cmdExec,(iy + ti.cmdFlags) 		; set these flags to execute basic program
	res	ti.onInterrupt,(iy + ti.onFlags)
	res	appInpPrmptDone,(iy + ti.apiFlg2)
	ld	a,ti.cxCmd
	ld	(ti.cxCurApp),a
	call	ti.SaveCmdShadow
	call	ti.SaveShadow
	xor	a,a
	ld	(ti.kbdGetKy),a
	call	hook_chain_parser
	call	ti.EnableAPD
	ld	hl,return_basic
	push	hl
	ei
	jq	ti.ParseInp				; run program

