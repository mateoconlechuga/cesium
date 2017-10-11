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
	ld	hl,CesiumInstallerName	; start ourselves
	push	hl
	ld	de,(asm_prgm_size)	; load total program prgmSize
	or	a,a
	sbc	hl,hl
	ld	(asm_prgm_size),hl	; delete whatever current program was there
	ld	hl,userMem
	call	_DelMem			; HL->place to delete, DE=amount to delete
	ld	hl,$100
	call	_EnoughMem
	pop	hl
	jp	c, _ErrMemory
	call	_FindAppStart		; This locates the start of executable code for an app
	ld	a,E_Validation
	jp	c,_JError		; If we can't find it, that's a problem (throw a validation error)
	push	hl			; push location of start of app
	call	_ReloadAppEntryVecs
	call	_RunIndicOff
	call	_AppSetup
	set	appRunning,(iy+APIFlg)	; turn on apps
	set	6,(iy+$28)
	res	0,(iy+$2C)		; set some app flags
	set	appAllowContext,(iy+APIFlg)	; turn on apps
	ld	hl,$D1787C		; copy to ram data location
	ld	bc,$FFF
	call	_MemClear		; zero out the ram data section
	pop	hl			; hl -> start of app
	push	hl			; de -> start of code for app
	ld	bc,$100			; bypass header information
	add	hl,bc
	ex	de,hl
	ld	hl,$18			; find the start of the data to copy to ram
	add	hl,de
	ld	hl,(hl)
	call	__icmpzero		; initialize the bss if it exists
	jr	z,+_
	push	hl
	pop	bc
	ld	hl,$15
	add	hl,de
	ld	hl,(hl)
	add	hl,de
	ld	de,$D1787C		; copy it in
	ldir
_:	pop	hl			; hl -> start of app
	call	FindStartOfAppCode	; After this, hl -> start of code for app
	jp	(hl)

CesiumInstallerName:
	.db	"Cesium",0

;----------------------------------------------------------------------------
FindStartOfAppCode:
; Finds the start of the actual executable from the start of an App
; inputs:
;  hl : contains the start of the app address
	ld	bc,$100			; bypass some header info
	add	hl,bc
	push	hl
	pop	de
	ld	bc,$12			; offset
	add	hl,bc
	ld	hl,(hl)
	add	hl,de
	ret

endrelocate()
executeapp_end:

.echo "Execute size:\t",executeapp_end-executeapp_start