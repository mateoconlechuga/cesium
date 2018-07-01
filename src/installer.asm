; duplicated icon; this is deleted anyway so it doesn't really matter
; only matters to show cesium inside cesium

	jp	installer_start

	db 1,16,16	; indicator, width, height
	db $ff,$ff,$ff,$ff,$ff,$ff,$de,$d6,$d6,$de,$ff,$ff,$ff,$ff,$ff,$ff
	db $ff,$ff,$ff,$ff,$ff,$ff,$d6,$de,$de,$b5,$ff,$ff,$ff,$ff,$ff,$ff
	db $ff,$ff,$de,$d6,$d6,$ff,$d6,$de,$de,$b5,$ff,$b5,$b5,$b6,$ff,$ff
	db $ff,$de,$de,$fe,$de,$b6,$b5,$d6,$d6,$b5,$b5,$d6,$de,$b5,$b6,$ff
	db $ff,$de,$b6,$de,$d6,$de,$de,$d6,$d6,$de,$d6,$d6,$d6,$6c,$b5,$ff
	db $ff,$ff,$de,$d6,$d6,$d6,$b5,$94,$94,$b5,$b6,$b5,$b5,$b5,$ff,$ff
	db $d6,$d6,$b6,$de,$d6,$b5,$94,$de,$de,$b5,$b6,$b5,$d6,$94,$94,$94
	db $b6,$de,$d6,$d6,$d6,$b4,$de,$ff,$ff,$de,$b5,$b6,$b5,$b6,$de,$6b
	db $b5,$de,$d6,$b6,$d6,$b5,$de,$ff,$ff,$de,$b5,$b5,$b5,$b5,$d6,$6b
	db $b5,$94,$b4,$d6,$b6,$d6,$b5,$de,$de,$b5,$b5,$b5,$b5,$6b,$6b,$6b
	db $ff,$ff,$d6,$b6,$b5,$b6,$b6,$b5,$b5,$b5,$b5,$b5,$b5,$b5,$ff,$ff
	db $ff,$d6,$b4,$d6,$b6,$d6,$d6,$d6,$b6,$d6,$b6,$b5,$d6,$6b,$b5,$ff
	db $ff,$d6,$b5,$de,$b4,$93,$93,$b6,$b5,$6b,$6b,$b4,$d6,$8c,$b5,$ff
	db $ff,$ff,$b5,$6b,$6b,$ff,$94,$d6,$b6,$6b,$fe,$6b,$4a,$94,$ff,$ff
	db $ff,$ff,$ff,$de,$ff,$ff,$94,$b5,$b5,$6b,$ff,$ff,$de,$ff,$ff,$ff
	db $ff,$ff,$ff,$ff,$ff,$ff,$b6,$8c,$6c,$b5,$ff,$ff,$ff,$ff,$ff,$ff
	db 'Cesium Installer Version ',cesium_version,$00	; description

installer_start:
	call	_PushOP1			; save the program name
	call	.clear_screen

	app_create				; create the application

	jr	z,.app_created
	call	_PopOP1
	ld	hl,str_cesium_exists_error
	call	_PutS				; put error string if cesium exists
	call	_GetKey
.clear_screen:
	call	_ClrScrn			; clear the homescreen
	jp	_HomeUp
.app_created:

	installer_execute_cesium.run

relocate installer_execute_cesium, mpLcdCrsrImage
	ld	hl,str_delete_installer
	call	_PutS
	call	_NewLine
	call	_PutS
	call	_NewLine
	call	_PutS				; ask the user if they want to delete me
	call	_PopOP1				; restore installer name

.get_key:
	call	_GetCSC
	or	a,a
	jr	z,.get_key
	cp	a,skDel
	jr	nz,.no_delete

	call	_ChkFindSym			; delete the installer if needed
	call	_DelVarArc

.no_delete:
	ld	de,(asm_prgm_size)		; load this program size
	ld	hl,userMem
	call	_DelMem
	or	a,a
	sbc	hl,hl
	ld	(asm_prgm_size),hl
	inc	h
	call	_EnoughMem
	jp	c,_ErrMemory

	ld	hl,str_cesium_name_installer
	ld	de,progToEdit
	ld	bc,8
	ldir
	ld	a,cxExtApps
	jp	_NewContext

str_cesium_name_installer:
	db	cesium_name,0

str_delete_installer:
	db 'Delete installer?', 0
	db 'del - yes',0
	db '2nd - no',0

end relocate

str_cesium_exists_error:
	db 'Cesium already installed, Please delete first.',0
