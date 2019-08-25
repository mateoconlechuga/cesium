; this program handles the return of execution, and any errors encountered

return_basic_error:
	xor	a,a
	ld	(ti.menuCurrent),a
	ld	a,(ti.errNo)
	cp	a,ti.E_AppErr1
	jp	z,return_basic				; if stop token, just ignore >.>
return_asm_error:
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
	ld	a,(hl)					; check if correct program
	cp	a,ti.ProtProgObj
	jp	z,.only_allow_quit
	ld	b,a
	ld	a,(ti.basic_prog)
	cp	a,b
	jp	nz,.only_allow_quit
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
	jp	z,return.quit
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
	jr	nz,return.quit
.goto:
	ld	a,return_goto
	jr	return.skip
.only_allow_quit:
	call	ti.GetCSC
	cp	a,ti.sk1
	jr	z,return.quit
	cp	a,ti.skEnter
	jr	z,return.quit
	jr	.only_allow_quit
return_basic:
return_asm:						; handler for assembly / basic return
return:
	ld	sp,(persistent_sp)
	call	ti.PopErrorHandler
.user_exit:
	ld	sp,(persistent_sp_error)
	ld	a,(return_info)
	cp	a,return_edit
	jr	z,.skip					; return properly from external editors
.quit:
.error:
	ld	a,return_prgm				; error handler for returning programs
.skip:
	ld	(return_info),a
	call	ti.RunIndicOff				; in case the launched program re-enabled it
	di						; in case the launched program enabled interrupts...
	call	ti.ClrAppChangeHook			; clear me!
	res	ti.progExecuting,(iy + ti.newDispF)
	res	ti.cmdExec,(iy + ti.cmdFlags)
	res	ti.textInverse,(iy + ti.textFlags)
	res	ti.allowProgTokens,(iy + ti.newDispF)
	res	ti.onInterrupt,(iy + ti.onFlags)
	call	ti.ReloadAppEntryVecs
	call	ti.ResetStacks
	call	ti.DeleteTempPrograms
	call	ti.CleanAll
	di
	ld	de,(ti.asm_prgm_size)
	or	a,a
	sbc	hl,hl
	ld	(ti.asm_prgm_size),hl
	ld	hl,ti.userMem
	call	ti.DelMem				; delete user program

	call	ti.ClrHomescreenHook
	res	appWantHome,(iy + sysHookFlg)
	ld	a,(backup_home_hook_location)
	or	a,a
	jr	z,.no_hook_restore
	ld	hl,(backup_home_hook_location)
	call	ti.SetHomescreenHook
	set	appWantHome,(iy + sysHookFlg)

.no_hook_restore:
.debounce:
	call	ti.GetCSC
	or	a,a
	jr	nz,.debounce				; debounce keys
	xor	a,a
	ld	(ti.kbdGetKy),a				; flush keys
	jp	cesium_start
