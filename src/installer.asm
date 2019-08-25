; duplicated icon; this is deleted anyway so it doesn't really matter
; only matters to show cesium inside cesium

	jp	installer_start

	db byte_description, 'Cesium Installer Version ', cesium_version, 0

installer_start:
	call	ti.PushOP1			; save the program name
	call	.clear_screen

	app_create				; create the application

	jr	z,.app_created
	call	ti.PopOP1
	ld	hl,str_cesium_exists_error
	call	ti.PutS				; put error string if cesium exists
	call	ti.GetKey
.clear_screen:
	call	ti.ClrScrn			; clear the homescreen
	jp	ti.HomeUp
.app_created:

	installer_execute_cesium.run

relocate installer_execute_cesium, ti.mpLcdCrsrImage
	call	ti.ClrScrn
	call	ti.HomeUp
	ld	hl,str_cesium_installed
	call	ti.PutS
	call	ti.GetKey
	call	ti.NewLine
	call	ti.NewLine

	ld	hl,str_delete_installer
	call	ti.PutS
	call	ti.NewLine
	call	ti.PutS				; ask the user if they want to delete me
	call	ti.PopOP1			; restore installer name

.get_key:
	call	ti.GetCSC
	or	a,a
	jr	z,.get_key
	cp	a,ti.skDel
	jr	nz,.no_delete

	call	ti.ChkFindSym			; delete the installer if needed
	call	ti.DelVarArc
	call	ti.ClrScrn
	call	ti.HomeUp

.no_delete:
	ld	de,(ti.asm_prgm_size)		; load this program size
	ld	hl,ti.userMem
	call	ti.DelMem
	or	a,a
	sbc	hl,hl
	ld	(ti.asm_prgm_size),hl
	inc	h
	call	ti.EnoughMem
	jp	c,ti.ErrMemory

	call	ti.ClrScrn
	jp	ti.HomeUp

str_delete_installer:
if config_english
	db 'Delete installer?', 0
	db 'del - yes',0
else
	db 'Suppr. l',$27,'installateur?', 0
	db 'suppr - oui',0
end if
str_cesium_installed:
if config_english
	db 'Installed in ',$C1,'apps] menu.',0
else
	db 'Install',$96,' dans les apps.',0
end if;

end relocate

str_cesium_exists_error:
if config_english
	db 'Cesium already installed, Please delete first.',0
else
	db 'Cesium d',$96,'j',$8f,' install',$96,',     veuillez supprimer.',0
end if;

