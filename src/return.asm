; this program handles the return of execution, and any errors encountered

return_basic_error:
return_asm_error:
	call	_boot_ClearVRAM
	ld	a,$2d
	ld	(mpLcdCtrl),a
	call	_DrawStatusBar
	call	_DispErrorScreen
	ld	hl,1
	ld	(curRow),hl
	ld	hl,data_string_quit1
	set	textInverse,(iy + textFlags)
	call	_PutS
	res	textInverse,(iy + textFlags)
	call	_PutS
	ld	hl,backup_prgm_name
	ld	a,(hl)					; check if correct program
	cp	a,protProgObj
	jp	z,.only_allow_quit
	xor	a,a
	ld	(curCol),a
	ld	a,2
	ld	(curRow),a
	ld	hl,data_string_quit2
	call	_PutS
	call	_PutS
	call	_GetCSC
.input:
	call	_GetCSC
	cp	a,skUp
	jr	z,.highlight_1
	cp	a,skDown
	jr	z,.highlight_2
	cp	a,sk2
	jr	z,.goto
	cp	a,sk1
	jp	z,return.quit
	cp	a,skEnter
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
	ld.sis	(curRow and $ffff),hl
	ld	hl,OP6
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
	ld	(fillRectColor),hl
	inc	hl
	ld	de,25
	ld	bc,(40 shl 8) or 96
	call	_FillRect
	pop	hl
	set	textInverse,(iy + textFlags)
	call	_PutS
	res	textInverse,(iy + textFlags)
	pop	de
	pop	bc
	ld.sis	(curRow and $ffff),de
	ld	hl,OP6
	ld	(hl),b
	call	_PutS
	jr	.input
.get_option:
	ld	a,(curRow)
	dec	a
	jr	nz,return.quit
.goto:
	ld	a,return_goto
	jr	return.skip
.only_allow_quit:
	call	_GetCSC
	cp	a,sk1
	jr	z,return.quit
	cp	a,skEnter
	jr	z,return.quit
	jr	.only_allow_quit
return_basic:
return_asm:					; handler for assembly / basic return
return:
	call	_PopErrorHandler
.quit:
.error:						; error handler for returning programs
	ld	a,return_prgm
.skip:
	ld	(return_info),a
	call	_RunIndicOff			; in case the launched program re-enabled it
	di					; in case the launched program enabled interrupts...
	call	_ClrAppChangeHook		; clear me!
	res	progExecuting,(iy + newDispf)
	res	cmdExec,(iy + cmdFlags)
	res	textInverse,(iy + textFlags)
	res	allowProgTokens,(iy + newDispF)
	res	onInterrupt,(iy + onFlags)
	call	_ReloadAppEntryVecs
	call	_DeleteTempPrograms
	call	_CleanAll
	di
	ld	de,(asm_prgm_size)
	or	a,a
	sbc	hl,hl
	ld	(asm_prgm_size),hl
	ld	hl,userMem
	call	_DelMem				; delete user program

	call	_ClrHomescreenHook
	res	appWantHome,(iy + sysHookFlg)
	ld	a,(backup_home_hook_location)
	or	a,a
	jr	z,.no_hook_restore
	ld	hl,(backup_home_hook_location)
	call	_SetHomescreenHook
	set	appWantHome,(iy + sysHookFlg)

.no_hook_restore:
.debounce:
	call	_GetCSC
	or	a,a
	jr	nz,.debounce			; debounce keys
	xor	a,a
	ld	(kbdGetKy),a			; flush keys
	jp	cesium_start
