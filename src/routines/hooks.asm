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
	cp	a,sk8
	jr	z,Good
	cp	a,sk5
	jr	z,Good
	cp	a,sk2
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
	jr	z,RelocateHook
	cp	a,skStat
	jr	z,RelocateHook
	cp	a,sk8
	jr	z,RelocateHook
	cp	a,sk5
	jr	z,RelocateHook
	cp	a,sk2
	jr	z,RelocateHook
	ret

NoOnKey:
	dec	a
	inc	a
	ret

RelocateHook:
	push	af
	ld	a,$E1
	ld	($E30800),a
	ld	a,$E9
	ld	($E30801),a
	pop	af
	ld	bc,HookEnd-HookStart
	ld	de,Hook
	push	bc
	call	$E30800
	ld	bc,12
	add	hl,bc
	pop	bc
	ldir
	jp	Hook
HookStart:
relocate(pixelshadow2)
Hook:
	cp	a,skPrgm
	jp	z,StartCesium
	cp	a,skStat
	jp	z,StartPassword
	cp	a,sk8
	jp	z,BackupRAM
	cp	a,sk5
	jp	z,ClearOldRAM
	cp	a,sk2
	jp	z,RestoreRAM
	ret

ClearOldRAM:
	ld	hl,$D00001
	xor	a,a
	ld	(hl),a
	inc	hl
	ld	(hl),a
	ld	a,($3C0000)
	or	a,a
	ret	z
	di
	ld.sis	sp,$ea1f
	call.is	unlocks & $ffff
	ld	b,0
	ld	de,$3C0000
	call	_WriteFlashByte
	call.is	locks & $ffff
	ret

RestoreRAM:
	di
	ld	hl,$3C0001
	ld	a,$A5
	cp	a,(hl)
	ret	nz
	dec	hl
	ld	a,$5a
	cp	a,(hl)
	ret	nz
	ld	hl,$D00002
	ld	a,$A5
	cp	a,(hl)
	ret	nz
	dec	hl
	cp	a,(hl)
	ret	nz
	jp	0

BackupRAM:
	call	_os_ClearStatusBarLow
	di
	ld	de,$e71c
	ld.sis	(drawFGColor & $ffff),de
	ld.sis	de,(statusBarBGColor & $ffff)
	ld.sis	(drawBGColor & $ffff),de
	ld	a,14
	ld	(penRow),a
	ld	de,2
	ld.sis	(penCol & $ffff), de
	ld	hl,savingstringhook
	call	_VPutS
	di					; let's do some crazy flash things so that way we can save the RAM state...
	ld.sis	sp,$ea1f
	call.is	unlocks & $ffff
	ld	a,$3F
	call	EraseSectorhook			; clean out the flash sectors
	ld	a,$3E
	call	EraseSectorhook
	ld	a,$3D
	call	EraseSectorhook
	ld	a,$3C
	call	EraseSectorhook			; this is so we can store the new RAM data \o/
	ld	hl,$D00002
	ld	(hl),$A5
	dec	hl
	ld	(hl),$A5
	dec	hl
	ld	(hl),$5A			; write some magical bytes
	ld	de,$3C0000			; we could just write all of ram
	ld	bc,$40000
	call	_WriteFlash
	call.is	locks & $ffff
	call	_DrawStatusBar
	dec	a
	inc	a
	ret
EraseSectorhook:
	ld	bc,$f8
	push	bc
	jp	_EraseFlashSector
savingstringhook:
#ifdef ENGLISH
	.db	"Backing up...",0
#else
	.db	"Sauvegarde en cours...",0
#endif

#include "routines/ramhook.asm"

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
	ld	hl,CesiumAppvarNameRelocated
	call	_Mov9ToOP1
	call	_ChkFindSym
	call	_ChkInRam
	push	af
	call	z,_Arc_Unarc			; archive it
	pop	af
	jr	z,StartPassword			; now lookup the settings appvar
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
	.db	appVarObj,"Cesium",0
PasswordStrRelocated:
#ifdef ENGLISH
	.db	"Password:",0
#else
	.db	"Mot de passe:",0
#endif
PasswordTemp:
	.dl	0
endrelocate()
HookEnd:
.echo "Hook Size:\t",HookEnd-HookStart
