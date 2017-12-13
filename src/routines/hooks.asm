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

sysHookFlg	equ 52
appInpPrmptInit	equ 0
appInpPrmptDone	equ 1
appWantHome	equ 4

HOMEHOOK_START:
relocate(HomeHookAddr)
HomescreenHook:
	add	a,e
	cp	a,3
	ret	nz
	bit	appInpPrmptDone,(iy+apiFlg2)
	res	appInpPrmptDone,(iy+apiFlg2)
	ld	b,0
	jr	z,RestoreHomescreenHooks
EstablishHome:
	call	_ReloadAppEntryVecs
	ld	hl,AppVectors
	call	_AppInit
	call	_ForceFullScreen
	or	a,1
	ld	a,cxExtApps
	ld	(cxCurApp),a
	ret
RestoreHomescreenHooks:
	push	bc
	call	_ClrHomescreenHook
	call	_ForceFullScreen
	res	AppWantHome,(iy+sysHookFlg)
	pop	bc
	ld	a,(HomeSave)
	or	a,a
	ret	z
	push	bc
	ld	hl,(HomeSave)
	call	_SetHomescreenHook
	set	AppWantHome,(iy+sysHookFlg)
	pop	bc
	ret
SaveHomescreenHooks:
	or	a,a
	sbc	hl,hl
	bit	AppWantHome,(iy+sysHookFlg)
	jr	z,+_
	ld	hl,(homescreenHookPtr)
_:	ld	(HomeSave),hl
	ret

AppPutAway:
	xor    a,a
	ld     (currLastEntry),a
	bit    appInpPrmptInit,(iy+apiFlg2)
	jr     nz,aipi
	call	_ClrHomescreenHook
	call	_ForceFullScreen
aipi:	call	_ReloadAppEntryVecs
	call	_PutAway
	ld	b,0
	ret
AppVectors:
	.dl	0F8h
	.dl	_SaveShadow
	.dl	AppPutAway
	.dl	_RstrShadow
	.dl	0F8h
	.dl	0F8h
endrelocate()
HOMEHOOK_END:

GetKeyHook:
	add	a,e
	cp	a,1Bh
        ret	nz
	ld	a,b
	cp	a,skPrgm
	jr	z,Good
	cp	a,skStat
	jr	z,Good
	ret

Good:
	di
	ld	hl,$f0202c
	ld	(hl),l
	ld	l,h
	bit	0,(hl)
	jr	z,NoOnKey
	cp	a,skPrgm
	jr	z,StartCesium
	cp	a,skStat
	jr	z,StartPassword
	cp	a,skEnter
	jr	z,LaunchProgram
	ret

NoOnKey:
	dec	a
	inc	a
	ret

LaunchProgram:
	ld	hl,progCurrent
	call	_Mov9ToOP1
	jr	NoOnKey

StartCesium:
	xor	a,a
	ld	(menuCurrent),a
	call	_CursorOff
	call	_RunIndicOff
	di
	ld	hl,$D0082e			; honestly I've no idea what this address is...
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
	ld	hl,$D0082e
	ld	de,progtoedit			; copy it here just to be safe
	ld	bc,8
	ldir
	ld	a,cxExtApps
	jp	_NewContext

StartPassword:
	ld	bc,reloacted_code_password_end-reloacted_code_password_start
	ld	de,pixelshadow2
	push	bc
	ld	a,$E1
	ld	($E30800),a
	ld	a,$E9
	ld	($E30801),a
	call	$E30800
	ld	bc,12
	add	hl,bc
	pop	bc
	ldir
	jp	FindSettings

reloacted_code_password_start:
relocate(pixelshadow2)
FindSettings:
	ld	hl,CesiumAppvarNameRelocated
	call	_Mov9ToOP1
	call	_ChkFindSym
	call	_ChkInRam
	push	af
	call	z,_Arc_Unarc			; archive it
	pop	af
	jr	z,FindSettings			; now lookup the settings appvar
	ex	de,hl
	ld	de,9
	push	de
	pop	bc
	add	hl,de
	ld	e,(hl)
	add	hl,de
	ld	de,11
	add	hl,de
	ld	(PasswordTemp),hl
	
WrongPassword:
	call	_CursorOff
	ld	a,cxCmd
	call	_NewContext0
	call	_CursorOff
	call	_ClrSCrn
	call	_HomeUp
	ld	hl,PasswordStrRelocated
	call	_PutS
	di
	call	_EnableAPD
	ld	a,1
	ld	hl,apdSubTimer
	ld	(hl),a
	inc	hl
	ld	(hl),a
	set	apdRunning,(iy+apdFlags)
	ei
	ld	hl,(PasswordTemp)
	dec	hl
	ld	a,(hl)
	or	a,a
	jr	z,CorrectPassword
	ld	b,a
	ld	c,0
	inc	hl
KeyPress: 
	call	GetKeyPress
	cp	a,(hl) 
	inc	hl
	jr	z,Asterisk
	inc	c
Asterisk:
	ld	a,'*'
	call	_PutC
	djnz	KeyPress
	dec	c
	inc	c
	jr 	nz,WrongPassword
CorrectPassword:
	ld	a,kClear
	jp	_SendKPress
	
GetKeyPress:
	push	hl
   	call	_GetCSC
	pop	hl
	or	a,a
	jr	z,GetKeyPress
	ret 
   
CesiumAppvarNameRelocated:
	.db	appVarObj,"CesiumS",0
PasswordStrRelocated:
#ifdef ENGLISH
	.db	"Password:",0
#else
	.db	"Mot de passe:",0
#endif
PasswordTemp:
	.dl	0
endrelocate()
reloacted_code_password_end:
