.assume adl = 1

; inputs:
;  shortcutKeys - Check if shortcut keys are enabled
;  prgmNamePtr - Pointer to program name
;
; flags:
;  bootEnter - Was enter used to launch?
CesiumLoader:
	bit	bootEnter,(iy+cesiumFlags)
	jr	nz,SkipSave
	ld	a,(AutoBackup)
	or	a,a
	call	nz,SaveRAMState			; Save ram state if option is set

SkipSave:
	ld	hl,HOMEHOOK_START
	ld	bc,HOMEHOOK_END-HOMEHOOK_START
	ld	de,HomeHookAddr
	ldir
	call	SaveHomescreenHooks
	ld	hl,HomescreenHook
	call	_SetHomescreenHook
	call	EstablishHome
	ld	a,(shortcutKeys)
	or	a,a
	call	nz,$0213E4
	call	_boot_ClearVRAM
	ld	a,$2D
	ld	(mpLcdCtrl),a			; Set LCD to 16bpp
	call	_DrawStatusBar
	call	GetProgramName
	ld	de,EditProgramName
	ld	hl,OP1
	call	_Mov9b
	bit	isBasic,(iy+pgrmStatus)
	jp	nz,RunBasicProgram
	call	MovePgrmToUserMem		; the program is now stored at userMem -- Now we need to check and see what kind of file it is - C or assembly
	call	InstallAsmErrHandler
RunAsm:
ASMSTART_HANDLER:
	ld	hl,0
	push	hl
	call	_APDSetup
	call	_DisableAPD
	di
	jp	UserMem				 ; simply call userMem to execute the program

InstallAsmErrHandler:
ASMERROR_HANDLER:
	ld	hl,0
	jp	_PushErrorHandler

NeedsSquish:
	call	GetProgramName
	ld	de,basic_prog
	ld	hl,OP1
	call	_Mov9b
	call	InstallAsmErrHandler
	ld	bc,(actualSizePrgm)
	dec	bc
	dec	bc
	push	bc
	bit	0,c
	jp	nz,_ErrSyntax
	srl	b
	rr	c
	push	bc
	push	bc
	pop	hl
	call	_EnoughMem
	pop	hl
	pop	bc
	jp	c,_ErrMemory
	push	bc
	ld	de,UserMem
	ld	(asm_prgm_size),hl
	call	_InsertMem
	ld	hl,(prgmDataPtr)
	ld	a,(prgmDataPtr+2)
	cp	a,$d0
	jr	c,NotRam
	call	GetProgramName
	call	_ChkFindSym
	ex	de,hl
	inc	hl
	inc	hl
NotRam:
	inc	hl
	inc	hl
	ld	(begPC),hl
	ld	(curPC),hl
	ld	de,UserMem
	pop	bc
Squishy:
	ld	a,b
	or	a,c
	jp	z,RunAsm
	push	hl
	ld	hl,(curPC)
	inc	hl
	ld	(curPC),hl
	pop	hl
	dec	bc
	ld	a,(hl)
	inc	hl
	cp	a,$3f
	jr	z,Squishy
	push	de
	call	CheckSquishyByte
	ld	d,a
	ld	a,(hl)
	inc	hl
	call	CheckSquishyByte
	ld	e,a
	call	ConvertSquishyByte
	pop	de
	ld	(de),a
	inc	de
	dec	bc
	jr	Squishy

ConvertSquishyByte:
	push	hl
	ld	a,d
	call	_SHLAcc
	add	a,e
	pop	hl
	ret
CheckSquishyByte:
	cp	a,$30
	jp	c,_ErrSyntax
	cp	a,$3A
	jr	nc,+_
	sub	a,$30
	ret
_:	cp	a,$41
	jp	c,_ErrSyntax
	cp	a,$47
	jp	nc,_ErrSyntax
	sub	a,$37
	ret

RunBasicProgram:
	ld	hl,(prgmDataPtr)
	ld	a,(hl)
	cp	a,$ef
	jr	nz,+_
	inc	hl
	ld	a,(hl)
	cp	a,$7a
	jp	z,NeedsSquish
_:	call	_RunIndicOn
	call	_DisableAPD
	ld	a,(RunIndic)
	or	a,a
	call	nz,_RunIndicOff
	di
	ld	a,(arcStatus)
	or	a,a
	jr	z,GoodInRAM
	call	DeleteTempProgramGetName
	ld	hl,(actualSizePrgm)
	push	hl
	call	_CreateProg			; create a temp program so we can execute
	inc	de
	inc	de
	pop	bc
	call	_ChkBCIs0
	jr	z,InROM				; there's nothing to copy
	ld	hl,(prgmDataPtr)
	ldi
	jp	po,InROM
	ldir
InROM:	call	_OP4ToOP1
GoodInRAM:
	ld	de,apperr1
	ld	hl,StopError
	ld	bc,StopErrorEnd-StopError
	ldir
	set	graphdraw,(iy+graphFlags)
BASICERROR_HANDLER:
	ld	hl,0
	call	_PushErrorHandler
	res	apptextsave,(iy+appflags)	;text goes to textshadow
	set	progExecuting,(iy+newdispf)
	set	allowProgTokens,(iy+newDispF)
	res	7,(iy + $45)
	set	cmdExec,(iy+cmdFlags) 		; set these flags to execute BASIC prgm
	res	onInterrupt,(iy+onflags)
BASICSTART_HANDLER:
	ld	hl,0
	push	hl
	sub	a,a
	ld	(kbdGetKy),a
	ei
	jp	_ParseInp			; run program

SaveRAMState:
	ld	hl,skinColor
	ld	a,(hl)
	ld	(cIndex),a
	push	af
	ld	(hl),$FF
#ifdef ENGLISH
	drawRectFilled(114,105,114+92,105+16)
	drawRectOutline(113,104,113+94,104+17)
	pop	af
	ld	(skinColor),a			; draw stuff saying we are saving ram
	SetDefaultTextColor()
	print(savingstring,119,109)
#else
	drawRectFilled(89,105,256,121)
	drawRectOutline(88,104,257,121)
	pop	af
	ld	(skinColor),a			; draw stuff saying we are saving ram
	SetDefaultTextColor()
	print(savingstring,119-24,109)
#endif
	call	FullBufCpy

	di					; let's do some crazy flash things so that way we can save the RAM state...
	ld.sis	sp,$ea1f
	call.is	unlock & $ffff

	ld	a,$3F
	call	EraseSector			; clean out the flash sectors
	ld	a,$3E
	call	EraseSector
	ld	a,$3D
	call	EraseSector
	ld	a,$3C
	call	EraseSector			; this is so we can store the new RAM data \o/

	ld	hl,$D00001
	ld	(hl),$A5
	dec	hl
	ld	(hl),$5A			; write some magical bytes
	ld	de,$3C0000			; we could just write all of ram
	ld	bc,$40000
	call	_WriteFlash

	call.is	lock & $ffff

	ret

EraseSector:
	ld	bc,$0000F8			; apparently we can't erase sectors unless we call this routine from flash... Well, I called it from flash now :) (lol, what a secuity flaw)
	push	bc
	jp	_EraseFlashSector

savingstring:
#ifdef ENGLISH
	.db	"Backing up...",0
#else
	.db	"Sauvegarde en cours...",0
#endif

StopError:
	.db "Stop",0
StopErrorEnd:

#include "routines/ramsave.asm"
