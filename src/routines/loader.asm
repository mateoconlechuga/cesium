flashRAMCode equ ramcode
.assume adl = 1

cesiumLoader_Start:
relocate(cursorImage)
cesiumLoader:
	call	DeletePgrmFromUserMem		; now we deleted ourselves. cool.
	
	ld	a,(AutoBackup)
	or	a,a
	call	nz,SaveRAMState			; Save ram state if option is set
	
	call	_boot_ClearVRAM
	ld	a,$2D
	ld	(mpLcdCtrl),a			; Set LCD to 16bpp
	call	_DrawStatusBar
	ld	hl,(prgmNamePtr)
	call	NamePtrToOP1
	bit	isBasic,(iy+pgrmStatus)
	jp	nz,RunBasicProgram
	call	MovePgrmToUserMem		; the program is now stored at userMem -- Now we need to check and see what kind of file it is - C or assembly
	push	hl
	ld	hl,ReturnHereIfError
	call	_PushErrorHandler
	ld	de,ReturnHereNoError
	push	de
	jp	UserMem				; simply call userMem to execute the program

RunBasicProgram:
	call	_RunIndicOn
	ld	a,(RunIndic)
	or	a,a
	call	nz,_RunIndicOff
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
	ld	hl,ErrCatchBASIC
	call	_PushErrorHandler
	set	progExecuting,(iy+newdispf)
	set	allowProgTokens,(iy+newDispF)
	set	cmdExec,(iy+cmdFlags) 		; set these flags to execute BASIC prgm
	res	onInterrupt,(iy+onflags)
	ld	hl,ReturnHereBASIC
	push	hl
	sub	a,a
	ld	(kbdGetKy),a
	ei
	jp	_ParseInp			; run program
	
SaveRAMState:
	ld	hl,ramsave_sectors_start
	ld	bc,ramsave_sectors_end-ramsave_sectors_start_start
	ld	de,$D18C7C
	ldir
	
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
	drawRectFilled(114-25,105,114+92+50,105+16)
	drawRectOutline(113-25,104,113+94+50,104+17)
	pop	af
	ld	(skinColor),a			; draw stuff saying we are saving ram
	SetDefaultTextColor()
	print(savingstring,119-24,109)
#endif
	call	FullBufCpy
	
	jp	$D18C7C
	
StopError:
	.db "Stop",0
StopErrorEnd:
ramsave_sectors_start:
endrelocate()

ramsave_sectors_start_start:
relocate(flashRAMCode)

	di					; let's do some crazy flash things so that way we can save the RAM state...
	ld	a, $D1
	ld	mb,a
	ld.sis	sp,$987E
	call.is	unlock - $D10000
	
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
	
	call.is	lock - $D10000
	ld	a,$D0
	ld	mb,a

	ret

EraseSector:
	ld	bc,$0000F8			; apparently we can't erase sectors unless we call this routine from flash... Well, I called it from flash now :) (lol, what a secuity flaw)
	push	bc
	jp	_EraseFlashSector

#include "routines/ramsave.asm"

savingstring:

#ifdef ENGLISH
	.db	"Backing up...",0
#else
	.db	"Sauvegarde en cours...",0
#endif

endrelocate()
ramsave_sectors_end:

CesiumLoader_End:
