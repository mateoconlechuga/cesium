; duplicated icon; this is deleted anyway so it doesn't really matter
; only matters to show cesium inside cesium

	jp	start_installer

	db 1, 16,16  ; indicator, width, height
	db 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0deh,0d6h,0d6h,0deh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	db 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0d6h,0deh,0deh,0b5h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	db 0ffh,0ffh,0deh,0d6h,0d6h,0ffh,0d6h,0deh,0deh,0b5h,0ffh,0b5h,0b5h,0b6h,0ffh,0ffh
	db 0ffh,0deh,0deh,0feh,0deh,0b6h,0b5h,0d6h,0d6h,0b5h,0b5h,0d6h,0deh,0b5h,0b6h,0ffh
	db 0ffh,0deh,0b6h,0deh,0d6h,0deh,0deh,0d6h,0d6h,0deh,0d6h,0d6h,0d6h,06ch,0b5h,0ffh
	db 0ffh,0ffh,0deh,0d6h,0d6h,0d6h,0b5h,094h,094h,0b5h,0b6h,0b5h,0b5h,0b5h,0ffh,0ffh
	db 0d6h,0d6h,0b6h,0deh,0d6h,0b5h,094h,0deh,0deh,0b5h,0b6h,0b5h,0d6h,094h,094h,094h
	db 0b6h,0deh,0d6h,0d6h,0d6h,0b4h,0deh,0ffh,0ffh,0deh,0b5h,0b6h,0b5h,0b6h,0deh,06bh
	db 0b5h,0deh,0d6h,0b6h,0d6h,0b5h,0deh,0ffh,0ffh,0deh,0b5h,0b5h,0b5h,0b5h,0d6h,06bh
	db 0b5h,094h,0b4h,0d6h,0b6h,0d6h,0b5h,0deh,0deh,0b5h,0b5h,0b5h,0b5h,06bh,06bh,06bh
	db 0ffh,0ffh,0d6h,0b6h,0b5h,0b6h,0b6h,0b5h,0b5h,0b5h,0b5h,0b5h,0b5h,0b5h,0ffh,0ffh
	db 0ffh,0d6h,0b4h,0d6h,0b6h,0d6h,0d6h,0d6h,0b6h,0d6h,0b6h,0b5h,0d6h,06bh,0b5h,0ffh
	db 0ffh,0d6h,0b5h,0deh,0b4h,093h,093h,0b6h,0b5h,06bh,06bh,0b4h,0d6h,08ch,0b5h,0ffh
	db 0ffh,0ffh,0b5h,06bh,06bh,0ffh,094h,0d6h,0b6h,06bh,0feh,06bh,04ah,094h,0ffh,0ffh
	db 0ffh,0ffh,0ffh,0deh,0ffh,0ffh,094h,0b5h,0b5h,06bh,0ffh,0ffh,0deh,0ffh,0ffh,0ffh
	db 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0b6h,08ch,06ch,0b5h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	db 000h

start_installer:
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

	execute_cesium.run

relocate execute_cesium, mpLcdCrsrImage
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
