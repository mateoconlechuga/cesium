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
	ret	nz
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
	ld	hl,OP1                      ; execute app
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
	ld	hl,OP1
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
	ld	bc,$100			; bypass some header info
	add	hl,bc
	push	hl
	pop	de
	ld	bc,$12			; offset
	add	hl,bc
	ld	hl,(hl)
	add	hl,de
	jp	(hl)
