; Copyright 2015-2021 Matt "MateoConLechuga" Waltz
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
	bit	item_is_prgm,(iy + item_flag)		; check if program and attempt to execute
	jq	z,main_loop

	; here are the considerations when executing from usb:
	; assembly programs can be copied directly as normal
	; basic programs must be copied to a temporary program to be executed

	call	usb_open_tivar
	jq	nz,main_loop
	call	usb_validate_tivar
	jq	z,execute_usb_program

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
	jq	nz,execute_app
.new:
	ld	(current_screen),a
	jq	main_find				; abort!

; when are some cases where this fails to work:
; 1) compressed programs
; 2) programs that use themselves
; 3) subprograms
execute_usb_program:
	di
	call	util_clear_backup_prgm_name
	ld	hl,(fat_file_size)
	call	util_check_free_ram
	jp	z,main_loop			; ensure enough ram
	call	execute_ram_backup
	bit	setting_enable_shortcuts,(iy + settings_flag)
	call	nz,ti.ClrGetKeyHook
	ld	hl,fat_sector + 74
	ld	a,(hl)
	cp	a,ti.tExtTok			; is it an assembly program
	jq	nz,.program_is_basic
	inc	hl
	ld	a,(hl)
	cp	a,ti.tAsm84CeCmp
	jq	nz,.program_is_basic		; is it a basic program
.program_is_asm:
	ld	hl,ti.userMem
	ld	de,(ti.asm_prgm_size)
	add	hl,de
	ex	de,hl
	ld	hl,(fat_file_size)
	push	hl
	push	de
	call	ti.InsertMem			; insert memory into usermem + (ti.asm_prgm_size)
	pop	hl
	push	de
	ld	bc,(fat_file_size)
	xor	a,a
	call	ti.MemSet			; zeroize just to be safe
	pop	de
	call	usb_copy_asm_var_to_ram		; copy variable to ram
	push	af
	call	usb_detach_only
	pop	af
	jr	nz,.fail_asm_copy
	pop	hl
	ld	(ti.asm_prgm_size),hl		; reload size of the program
	jq	execute_ti.asm_program_loaded
.fail_asm_copy:
	jp	main_loop
.program_is_basic:
	ld	hl,(fat_file_size)
	ld	(prgm_real_size),hl
	ld	de,(lcd_buffer)
	ld	(prgm_data_ptr),de
	call	usb_copy_var_to_ram		; copy variable to ram
	push	af
	call	usb_detach_only
	pop	af
	jr	nz,.fail_basic_copy
	jq	execute_ti.basic_program.from_temp
.fail_basic_copy:
	jp	main_loop

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
	call	util_move_prgm_name_to_op1
	bit	prgm_is_basic,(iy + prgm_flag)
	jr	nz,execute_ti.basic_program		; execute basic program
	jq	execute_ti.asm_program

execute_ti.asm_program:
	call	util_move_prgm_to_usermem		; execute assembly program
	jq	nz,main_loop				; return on error
execute_ti.asm_program_loaded:
	call	ti.DisableAPD
	set	ti.appAutoScroll,(iy + ti.appFlags)
	call	execute_setup_vectors
	ld	hl,execute_return
	push	hl
	jq	ti.userMem

execute_ti.basic_program:
	ld	hl,(prgm_data_ptr)
	ld	a,(hl)
	cp	a,ti.tExtTok
	jq	nz,.no_squish				; check if actually an unsquished assembly program
	inc	hl
	ld	a,(hl)
	cp	a,ti.tAsm84CePrgm
	jq	nz,.no_squish
.squish:
	call	util_move_prgm_name_to_op1
	ld	de,ti.basic_prog
	ld	hl,ti.OP1
	call	ti.Mov9b
	ld	hl,ti.OP1
	ld	de,backup_prgm_name
	call	ti.Mov9b
	ld	bc,(prgm_real_size)
	dec	bc
	dec	bc
	push	bc
	bit	0,c
	jp	nz,ti.ErrSyntax
	srl	b
	rr	c
	push	bc
	push	bc
	pop	hl
	call	util_check_free_ram
	pop	hl
	pop	bc
	jq	c,main_start
	push	bc
	ld	de,ti.userMem
	ld	(ti.asm_prgm_size),hl
	call	ti.InsertMem
	ld	hl,(prgm_data_ptr)
	ld	a,(prgm_data_ptr + 2)
	cp	a,$d0
	jr	c,.not_in_ram
	call	util_move_prgm_name_to_op1
	call	ti.ChkFindSym
	ex	de,hl
	inc	hl
	inc	hl
.not_in_ram:
	inc	hl
	inc	hl
	ld	(ti.begPC),hl
	ld	(ti.curPC),hl
	ld	de,ti.userMem
	pop	bc
.squish_me:
	ld	a,b
	or	a,c
	jp	z,execute_ti.asm_program_loaded
	push	hl
	ld	hl,(ti.curPC)
	inc	hl
	ld	(ti.curPC),hl
	pop	hl
	dec	bc
	ld	a,(hl)
	inc	hl
	cp	a,$3f
	jr	z,.squish_me
	push	de
	call	.squishy_check_byte
	ld	d,a
	ld	a,(hl)
	inc	hl
	call	.squishy_check_byte
	ld	e,a
	call	.squishy_convert_byte
	pop	de
	ld	(de),a
	inc	de
	dec	bc
	jr	.squish_me
.squishy_convert_byte:
	push	bc
	push	hl
	ld	a,d
	call	ti.ShlACC
	add	a,e
	pop	hl
	pop	bc
	ret
.squishy_check_byte:
	cp	a,$30
	jp	c,ti.ErrSyntax
	cp	a,$3A
	jr	nc,.skip
	sub	a,$30
	ret
.skip:
	cp	a,$41
	jp	c,ti.ErrSyntax
	cp	a,$47
	jp	nc,ti.ErrSyntax
	sub	a,$37
	ret
.no_squish:
	call	ti.RunIndicOn
	bit	setting_basic_indicator,(iy + settings_flag)
	call	nz,ti.RunIndicOff
	call	ti.DisableAPD
	bit	prgm_archived,(iy + prgm_flag)
	jr	z,.in_ram
.from_temp:
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
	set	ti.progExecuting,(iy + ti.newDispF)
	set	ti.cmdExec,(iy + ti.cmdFlags)
	set	ti.allowProgTokens,(iy + ti.newDispF)
	call	execute_setup_vectors
	call	ti.EnableAPD
	ei
	ld	hl,execute_return
	push	hl
	jp	ti.ParseInp

execute_return:
	call	ti.PopErrorHandler
	xor	a,a
execute_error:
	push	af
	res	ti.progExecuting,(iy + ti.newDispF)
	res	ti.cmdExec,(iy + ti.cmdFlags)
	res	ti.allowProgTokens,(iy + ti.newDispF)
	res	ti.textInverse,(iy + ti.textFlags)
	res	ti.onInterrupt,(iy + ti.onFlags)
	call	ti.ReloadAppEntryVecs
	pop	bc
	ld	a,(return_info)
	cp	a,return_edit				; return from editor
	jr	z,execute_quit
	ld	a,b
	or	a,a
	ld	a,return_prgm
	jr	z,execute_quit
	call	execute_show_error_screen
execute_quit:
	ld	(return_info),a
	call	ti.ReloadAppEntryVecs
	call	ti.ClrHomescreenHook
	call	ti.ClrAppChangeHook
	call	ti.ForceFullScreen
	call	hook_restore_parser
	ld	de,(ti.asm_prgm_size)
	or	a,a
	sbc	hl,hl
	ld	(ti.asm_prgm_size),hl
	ld	hl,ti.userMem
	call	ti.DelMem			; delete user program
	res	appWantHome,(iy + sysHookFlg)
.debounce:
	call	ti.GetCSC
	or	a,a
	jr	nz,.debounce			; debounce keys
	xor	a,a
	ld	(ti.kbdGetKy),a			; flush keys
	jp	cesium_start

execute_hook:
	add	a,e
	cp	a,3
	ret	nz
	bit	appInpPrmptDone,(iy + ti.apiFlg2)
	res	appInpPrmptDone,(iy + ti.apiFlg2)
	ld	a,return_prgm
	jr	z,execute_quit
	call	ti.ReloadAppEntryVecs
	ld	hl,execute_vectors
	call	ti.AppInit
	or	a,1
	ld	a,$58
	ld	(ti.cxCurApp),a
	ret

execute_setup_vectors:
	call	lcd_normal
	xor	a,a
	ld	(ti.appErr1),a
	ld	(ti.kbdGetKy),a
	ld	hl,execute_hook
	call	ti.SetHomescreenHook
	ld	hl,execute_vectors
	call	ti.AppInit
	call	ti.ForceFullScreen
	call	ti.ClrScrn
	call	ti.HomeUp
	call	util_clear_shadows
	ld	hl,execute_error
	jp	ti.PushErrorHandler

execute_vectors:
	dl	.ret
	dl	ti.SaveShadow
	dl	.putway
	dl	.restore
	dl	.ret
	dl	.ret
.restore:
	call	ti.HomeUp
	call	ti.ClrScrn
	jp	ti.RStrShadow
.ret:
	ret
.putway:
	xor	a,a
	ld	(ti.currLastEntry),a
	bit	appInpPrmptInit,(iy + ti.apiFlg2)
	jr	nz,.aipi
	call	ti.ClrHomescreenHook
	call	ti.ForceFullScreen
.aipi:
	call	ti.ReloadAppEntryVecs
	call	ti.PutAway
	ld	b,0
	ret

execute_show_error_screen:
	xor	a,a
	ld	(ti.menuCurrent),a
	ld	a,(ti.errNo)
	cp	a,ti.E_AppErr1
	ret	z			; if stop token, ignore
	call	ti.boot.ClearVRAM
	ld	a,$2d
	ld	(ti.mpLcdCtrl),a
	call	ti.CursorOff
	call	ti.DrawStatusBar
	call	ti.DispErrorScreen
	ld	hl,1
	ld	(ti.curRow),hl
	ld	hl,data_string_quit1
	set	ti.textInverse,(iy + ti.textFlags)
	call	ti.PutS
	res	ti.textInverse,(iy + ti.textFlags)
	call	ti.PutS
	ld	hl,backup_prgm_name
	ld	a,(hl)			; check if correct program
	cp	a,ti.ProtProgObj
	jq	z,.only_allow_quit
	ld	b,a
	ld	a,(ti.basic_prog)
	cp	a,b
	jq	nz,.only_allow_quit
	xor	a,a
	ld	(ti.curCol),a
	ld	a,2
	ld	(ti.curRow),a
	ld	hl,data_string_quit2
	call	ti.PutS
	call	ti.PutS
	call	ti.GetCSC
.input:
	call	ti.GetCSC
	cp	a,ti.skUp
	jr	z,.highlight_1
	cp	a,ti.skDown
	jr	z,.highlight_2
	cp	a,ti.sk2
	jr	z,.goto
	cp	a,ti.sk1
	jq	z,.quit
	cp	a,ti.skEnter
	jr	z,.get_option
	jr	.input
.highlight_1:
	ld	hl,1
	ld	de,2
	ld	a,'1'
	ld	b,'2'
	jr	.highlight
.highlight_2:
	ld	hl,2
	ld	de,1
	ld	a,'2'
	ld	b,'1'
.highlight:
	push	bc
	push	de
	ld.sis	(ti.curRow and $ffff),hl
	ld	hl,ti.OP6
	ld	(hl),a
	inc	hl
	ld	(hl),':'
	inc	hl
	ld	(hl),0
	dec	hl
	dec	hl
	push	hl
	scf
	sbc	hl,hl
	ld	(ti.fillRectColor),hl
	inc	hl
	ld	de,25
	ld	bc,(55 shl 8) or 96
	call	ti.FillRect
	pop	hl
	set	ti.textInverse,(iy + ti.textFlags)
	call	ti.PutS
	res	ti.textInverse,(iy + ti.textFlags)
	pop	de
	pop	bc
	ld.sis	(ti.curRow and $ffff),de
	ld	hl,ti.OP6
	ld	(hl),b
	call	ti.PutS
	jr	.input
.get_option:
	ld	a,(ti.curRow)
	dec	a
	jr	nz,.quit
.goto:
	ld	a,return_goto
	ret
.only_allow_quit:
	call	ti.GetCSC
	cp	a,ti.sk1
	jr	z,.quit
	cp	a,ti.skEnter
	jr	z,.quit
	jr	.only_allow_quit
.quit:
	ld	a,return_prgm
	ret
