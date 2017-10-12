StopToken equ $D9-$CE			; "Stop" token

ParserHook:
	.db	83h			; Required for all hooks
	cp	a,2
	jr	z,StopTokenMaybeEncountered
_:	xor	a,a
	ret

StopTokenMaybeEncountered:
	ld	a,StopToken		; Did we hit a stop token?
	cp	a,b
	jr	z,StopEverything
	jr	-_

StopEverything:
	ld	a,$AB
	jp	_JError

GetKeyHook:
	add	a,e
	cp	a,kPrgm
	jr	z,StartCesium
	ret

StartCesium:
	di
	ld	hl,$f0202c
	ld	(hl),l
	ld	l,h
	bit	0,(hl)
	ret	z
	xor 	a,a
	ld	(menuCurrent),a
	res	curAble, (iy + curFlags)
	call	_CloseEditEqu
	ld	de,(asm_prgm_size)	; load total program size
	or	a,a
	sbc	hl,hl
	ld	(asm_prgm_size),hl	; delete whatever current program was there (in case someone uses getkey in a program)
	ld	hl,userMem
	call	_DelMem
	ld	hl,OP1			; execute app
	push	hl
	ld	(hl),'C'
	inc	hl
	ld	(hl),'e'
	inc	hl
	ld	(hl),'s'
	inc	hl
	ld	(hl),'i'
	inc	hl
	ld	(hl),'u'
	inc	hl
	ld	(hl),'m'
	inc	hl
	ld	(hl),0
	pop	hl
	call	_FindAppStart		; This locates the start of executable code for an app
	ld	a,E_Validation
	jp	c,_JError		; If we can't find it, that's a problem (throw a validation error)
	push	hl
	call	_ReloadAppEntryVecs
	call	_RunIndicOff
	call	_AppSetup
	set	appRunning,(iy+APIFlg)	; turn on apps
	set	6,(iy+$28)
	res	0,(iy+$2C)		; set some app flags
	set	appAllowContext,(iy+APIFlg)	; turn on apps
	pop	hl			; hl -> start of app
	ld	bc,$100			; bypass some header info
	add	hl,bc
	push	hl
	ld	bc,$12			; offset
	add	hl,bc
	ld	hl,(hl)
	pop	bc
	add	hl,bc
	xor	a,a
	jp	(hl)
