;here's what needs to be done:
;(1) copy this program to an App
;(2) delete this program

	.db tExtTok,tAsm84CECmp
	.org UserMem
	
	di					; disable interrupts
	call	_PushOP1
	
	app_create()
	or	a,a
	ret	z
	
	call	_PopOP1
	call	_ChkFindSym
	call	_DelVarArc			; delete ourselves
	
	xor	a,a
	ld	(keyExtend),a
	ld	a,kAppsMenu
	ld	(kbdKey),a
	set	5,(iy+graphFlags2)
	ret
