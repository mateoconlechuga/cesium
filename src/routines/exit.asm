;-------------------------------------------------------------------------------
FullExit:
	call	CleanUp
	ld	hl,WipeSafeRam_Start
	ld	de,WipeSafeRam
	ld	bc,WipeSafeRam_End-WipeSafeRam_Start
	ldir
	jp	WipeSafeRam

ClearOldBackup:
	di                                       ; let's do some crazy flash things so that way we can save the RAM state...
	ld.sis	sp,$ea1f
	call.is	funlock & $ffff
	
	ld	b,0
	ld	de,$3C0000
	call	_WriteFlashByte                  ; this is so we can store the new RAM data \o/
	
	call.is	flock & $ffff

	ret

CleanUp:
	call	_boot_ClearVRAM
	ld	a,$2D
	ld	(mpLcdCtrl),a                   ; Set LCD to 16bpp
	res	useTokensInString,(iy+clockFlags)
	res	onInterrupt,(iy+onFlags)        ; [ON] break error destroyed
	call	_DrawStatusBar
	call	_ClrParserHook
	res	apdWarmStart, (iy + apdFlags)
	ld	a,(AutoBackup)
	or	a,a
	call	nz,ClearOldBackup
	call	SetKeyHookPtr
	ld	hl,appdata
	ld	bc,250
	call	_MemClear
	set	graphdraw,(iy+graphFlags)
	im	1
	ei
	ret

WipeSafeRam_Start:
relocate(cursorimage)
WipeSafeRam:
	ld	hl,pixelShadow
	ld	bc,69090
	call	_MemClear
	call	_ClrTxtShd                      ; clear text shadow
	bit	3,(iy+$25)
	jr	z,+_
	ld	a,cxErase
	call	_NewContext0			; trigger a defrag
_:	ld	a,kClear
	jp	_JForceCmd	                 ; exit like a boss
endrelocate()
WipeSafeRam_End:

#include "routines/ramquit.asm"
