hook_token_stop := $d9 - $ce
hook_parser:
	db	$83			; hook signifier
	cp	a,2
	jr	z,.maybe_stop
	xor	a,a
	ret
.maybe_stop:
	ld	a,hook_token_stop	; check if stop token
	cp	a,b
	ld	a,$ab
	jp	z,ti.JError
	xor	a,a
	ret

hook_app_change:
	db	$83
	;ld	c,a			; huh
	ld	a,b
	cp	a,ti.cxPrgmEdit		; only allow when editing
	ld	b,a
	ret	nz
	ld	a,c
	cp	a,ti.kEnter		; wut ti, this is how you run a program?
	jr	nz,.wut
	push	hl
	call	ti.PopOP1
	pop	hl
	ret
.wut:
	call	ti.CursorOff
	call	ti.CloseEditEqu
	call	ti.PopOP1
	call	ti.ChkFindSym
	jr	c,.dont_archive
	ld	a,(edit_status)
	or	a,a
	call	nz,ti.Arc_Unarc
.dont_archive:
	ld	a,return_prgm
	ld	(return_info),a
	jp	cesium_start

hook_get_key:
	db	$83
	cp	a,$1b
	ret	nz
	ld	a,b
	push	af
	push	hl
	ld	hl,$f0202c
	ld	(hl),l
	ld	l,h
	bit	0,(hl)
	pop	hl
	jr	nz,.check_for_shortcut_key
	pop	af
	cp	a,ti.sk2nd
	ret	nz
	ld	a,ti.sk2nd - 1				; maybe some other day
	inc	a
	ret
.check_for_shortcut_key:
	pop	af
	cp	a,ti.skStat
	jp	z,hook_password
	cp	a,ti.skGraph
	jr	z,hook_show_labels
	cp	a,ti.skPrgm
	jr	z,hook_execute_cesium
	cp	a,ti.sk8
	jr	z,hook_backup_ram
	cp	a,ti.sk5
	jr	z,hook_clear_backup
	cp	a,ti.sk2
	jr	z,hook_restore_ram
	ret

hook_show_labels:
	jr	hook_get_key_none

hook_clear_backup:
	call	flash_code_copy
	call	flash_clear_backup
	jr	hook_get_key_none

hook_restore_ram:
	push	hl
	push	af
	ld	hl,$3c0001
	ld	a,$a5
	cp	a,(hl)
	jr	nz,.none
	dec	hl
	ld	a,$5a
	cp	a,(hl)
	jp	z,0
.none:
	pop	af
	pop	hl
	inc	a
	dec	a
	ret

hook_get_key_none:
	xor	a,a
	inc	a
	dec	a
	ret

hook_backup_ram:
	call	ti.os.ClearStatusBarLow
	di
	ld	de,$e71c
	ld.sis	(ti.drawFGColor and $ffff),de
	ld.sis	de,(ti.statusBarBGColor and $ffff)
	ld.sis	(ti.drawBGColor and $ffff),de
	ld	a,14
	ld	(ti.penRow),a
	ld	de,2
	ld.sis	(ti.penCol and $ffff), de
	ld	hl,string_ram_backup
	call	ti.VPutS
	call	flash_code_copy
	call	flash_backup_ram
	call	ti.DrawStatusBar
	jr	hook_get_key_none

hook_execute_cesium:
	xor	a,a
	ld	(ti.menuCurrent),a
	call	ti.CursorOff
	call	ti.RunIndicOff
	di
	ld	hl,data_string_cesium_name	; execute app
	ld	de,$d0082e			; honestly no idea what this address is...
	push	de
	ld	bc,8
	push	bc
	ldir
	pop	bc
	pop	hl
	ld	de,ti.progToEdit		; copy it here just to be safe
	ldir
	ld	a,ti.kExtApps
	jp	ti.NewContext

hook_password:
	ld	hl,data_cesium_appvar
	call	ti.Mov9ToOP1
	call	ti.ChkFindSym
	call	ti.ChkInRam
	push	af
	call	z,ti.Arc_Unarc			; archive it
	pop	af
	jr	z,hook_password			; find the settings appvar
	ex	de,hl
	ld	de,9
	add	hl,de
	ld	e,(hl)
	add	hl,de
	inc	hl
	inc	hl
	inc	hl
	ld	de,settings_data
	ld	bc,settings_size
	ldir					; copy in the password
.wrong:
	call	ti.CursorOff
	ld	a,ti.cxCmd
	call	ti.NewContext0
	call	ti.CursorOff
	call	ti.ClrScrn
	call	ti.HomeUp
	ld	hl,data_string_password
	call	ti.PutS
	di
	call	ti.EnableAPD
	ld	a,1
	ld	hl,ti.apdSubTimer
	ld	(hl),a
	inc	hl
	ld	(hl),a
	set	ti.apdRunning,(iy + ti.apdFlags)
	ei
	ld	hl,setting_password
	ld	a,(hl)				; password length
	or	a,a
	jr	z,.correct
	ld	b,a
	ld	c,0
	inc	hl
.get_user_password:
	call	.get_key
	cp	a,(hl)
	inc	hl
	jr	z,.draw_character
	inc	c
.draw_character:
	ld	a,'*'
	call	ti.PutC
	djnz	.get_user_password
	dec	c
	inc	c
	jr 	nz,.wrong
.correct:
	ld	a,ti.kClear
	jp	ti.SendKPress
.get_key:
	push	hl
   	call	ti.GetCSC
	pop	hl
	or	a,a
	jr	z,.get_key
	ret

hook_home:
	db	$83
	cp	a,3
	ret	nz
	bit	appInpPrmptDone,(iy + ti.apiFlg2)
	res	appInpPrmptDone,(iy + ti.apiFlg2)
	ld	a,b
	ld	b,0
	jr	z,.restore_home_hooks
.establish:
	call	ti.ReloadAppEntryVecs
	ld	hl,.vectors
	call	ti.AppInit
	or	a,1
	ld	a,ti.kExtApps
	ld	(ti.cxCurApp),a
	ret
.set:
	ld	hl,hook_home
	call	ti.SetHomescreenHook
	jr	.establish
.restore_home_hooks:
	push	af
	push	bc
	call	ti.ClrHomescreenHook
	res	appWantHome,(iy + sysHookFlg)
	pop	bc
	pop	af
	cp	a,ti.cxError
	jr	z,.return_cesium_app
	jp	z,return_basic
	cp	a,ti.cxPrgmInput
	jp	z,.return_cesium_app
	ld	hl,backup_home_hook_location
	ld	a,(hl)
	or	a,a
	ret	z
	push	bc
	ld	hl,(hl)
	call	ti.SetHomescreenHook
	set	appWantHome,(iy + sysHookFlg)
	pop	bc
	ret
.return_cesium_app:
	cesium_code.copy
	jp	return_basic
.save:
	xor	a,a
	sbc	hl,hl
	bit	appWantHome,(iy + sysHookFlg)
	jr	z,.done
	ld	hl,(ti.homescreenHookPtr)
.done:
	ld	(backup_home_hook_location),hl
	ret

.put_away:
	xor	a,a
	ld	(ti.currLastEntry),a
	bit	appInpPrmptInit,(iy + ti.apiFlg2)
	jr	nz,.skip
	call	ti.ClrHomescreenHook
.skip:
	call	ti.ReloadAppEntryVecs
	call	ti.PutAway
	ld	b,0
	ret
.vectors:
	dl	$f8
	dl	ti.SaveShadow
	dl	.put_away
	dl	ti.RStrShadow
	dl	$f8
	dl	$f8
	db	0
