;here's what needs to be done:
;(1) copy this program to App
;(2) delete this installer

	.db tExtTok,tAsm84CECmp
	.org UserMem

; duplicated icon; this is deleted anyway so it doesn't really matter
; only matters to show Cesium inside Cesium lol

	jp	StartInstaller

	.db 1, 16,16  ; Indicator, Width, Height
	.db 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0DEh,0D6h,0D6h,0DEh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
	.db 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0D6h,0DEh,0DEh,0B5h,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
	.db 0FFh,0FFh,0DEh,0D6h,0D6h,0FFh,0D6h,0DEh,0DEh,0B5h,0FFh,0B5h,0B5h,0B6h,0FFh,0FFh
	.db 0FFh,0DEh,0DEh,0FEh,0DEh,0B6h,0B5h,0D6h,0D6h,0B5h,0B5h,0D6h,0DEh,0B5h,0B6h,0FFh
	.db 0FFh,0DEh,0B6h,0DEh,0D6h,0DEh,0DEh,0D6h,0D6h,0DEh,0D6h,0D6h,0D6h,06Ch,0B5h,0FFh
	.db 0FFh,0FFh,0DEh,0D6h,0D6h,0D6h,0B5h,094h,094h,0B5h,0B6h,0B5h,0B5h,0B5h,0FFh,0FFh
	.db 0D6h,0D6h,0B6h,0DEh,0D6h,0B5h,094h,0DEh,0DEh,0B5h,0B6h,0B5h,0D6h,094h,094h,094h
	.db 0B6h,0DEh,0D6h,0D6h,0D6h,0B4h,0DEh,0FFh,0FFh,0DEh,0B5h,0B6h,0B5h,0B6h,0DEh,06Bh
	.db 0B5h,0DEh,0D6h,0B6h,0D6h,0B5h,0DEh,0FFh,0FFh,0DEh,0B5h,0B5h,0B5h,0B5h,0D6h,06Bh
	.db 0B5h,094h,0B4h,0D6h,0B6h,0D6h,0B5h,0DEh,0DEh,0B5h,0B5h,0B5h,0B5h,06Bh,06Bh,06Bh
	.db 0FFh,0FFh,0D6h,0B6h,0B5h,0B6h,0B6h,0B5h,0B5h,0B5h,0B5h,0B5h,0B5h,0B5h,0FFh,0FFh
	.db 0FFh,0D6h,0B4h,0D6h,0B6h,0D6h,0D6h,0D6h,0B6h,0D6h,0B6h,0B5h,0D6h,06Bh,0B5h,0FFh
	.db 0FFh,0D6h,0B5h,0DEh,0B4h,093h,093h,0B6h,0B5h,06Bh,06Bh,0B4h,0D6h,08Ch,0B5h,0FFh
	.db 0FFh,0FFh,0B5h,06Bh,06Bh,0FFh,094h,0D6h,0B6h,06Bh,0FEh,06Bh,04Ah,094h,0FFh,0FFh
	.db 0FFh,0FFh,0FFh,0DEh,0FFh,0FFh,094h,0B5h,0B5h,06Bh,0FFh,0FFh,0DEh,0FFh,0FFh,0FFh
	.db 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0B6h,08Ch,06Ch,0B5h,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
	.db 000h

StartInstaller:
	di					; disable interrupts
	call	_PushOP1

	app_create()
	or	a,a
	ret	z

	call	_PopOP1
	call	_ChkFindSym
	call	_DelVarArc			; delete ourselves

	ld	hl,executeapp_start
	ld	de,executeapp
	ld	bc,executeapp_end-executeapp_start
	ldir
	jp	executeapp

;--------------------------------------------------------------------
executeapp_start:
relocate(cursorimage)
executeapp:
	ld	de,(asm_prgm_size)	; load total program prgmSize
	or	a,a
	sbc	hl,hl
	ld	(asm_prgm_size),hl	; delete whatever current program was there
	ld	hl,userMem
	call	_DelMem			; HL->place to delete, DE=amount to delete
	ld	hl,$100
	call	_EnoughMem
	pop	hl
	jp	c,_ErrMemory

	ld	hl,CesiumNameOfApp
	ld	de,progToEdit
	ld	bc,8
	ldir
	ld	a,cxExtApps
	jp	_NewContext

CesiumNameOfApp:
	.db	"Cesium",0

endrelocate()
executeapp_end:

.echo "Execute size:\t",executeapp_end-executeapp_start
