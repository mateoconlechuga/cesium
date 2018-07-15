; duplicated icon; this is deleted anyway so it doesn't really matter
; only matters to show cesium inside cesium

	jp	installer_start

	db byte_description, 'Cesium Installer Version ', cesium_version, 0

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
	call	_ClrScrn
	call	_HomeUp

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
if config_english
	db 'Delete installer?', 0
	db 'del - yes',0
else
	db 'Suppr. l',$27,'installateur?', 0
	db 'suppr - oui',0
end if

end relocate

str_cesium_exists_error:
if config_english
	db 'Cesium already installed, Please delete first.',0
else
	db 'Cesium d',$96,'j',$8f,' install',$96,',     veuillez supprimer.',0
end if;
