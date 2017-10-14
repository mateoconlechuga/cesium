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
	jr	z,Good
	cp	a,kStat
	jr	z,Good
	ret

Good:
	di
	ld	hl,$f0202c
	ld	(hl),l
	ld	l,h
	bit	0,(hl)
	ret	z
	cp	a,kPrgm
	jr	z,StartCesium
	cp	a,kStat
	jr	z,StartPassword
	ret

StartCesium:
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
	ld	de,progToEdit
	ld	bc,8
	ldir
	ld	a,cxExtApps
	jp	_NewContext

StartPassword:
	call	_ClrScrn
	call	_HomeUp
	call	_EnableAPD
	ld	a,1
	ld	hl,apdSubTimer
	ld	(hl),a
	inc	hl
	ld	(hl),a
	set	apdRunning,(iy+apdFlags)
	ld	hl,OP1
	push	hl
	ld	(hl),'P'
	inc	hl
	ld	(hl),'a'
	inc	hl
	ld	(hl),'s'
	inc	hl
	ld	(hl),'s'
	inc	hl
	ld	(hl),'w'
	inc	hl
	ld	(hl),'o'
	inc	hl
	ld	(hl),'r'
	inc	hl
	ld	(hl),'d'
	inc	hl
	ld	(hl),':'
	inc	hl
	ld	(hl),' '
	inc	hl
	ld	(hl),0
	pop	hl
	call	_PutS
	ld	bc,$400
KeyPress:
	push	hl
	call	_GetCSC
	pop	hl
	or	a,a
	jr	z,KeyPress
	cp	a,sk5
	jr	z,Asterisk
	inc	c
Asterisk: 
	ld	a,'*'
	call	_PutC
	djnz	KeyPress 
	dec	c
	inc	c
	jr	nz,StartPassword
	call	_ClrScrn
	call	_HomeUp
	ld	a,skClear
	jp	_SendKPress

