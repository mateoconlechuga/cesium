;-------------------------------------------------------------------------------
FullExit:
	call	_boot_ClearVRAM
	ld	a,$2D
	ld	(mpLcdCtrl),a                   ; Set LCD to 16bpp
	set	graphdraw,(iy+graphFlags)
	res	useTokensInString,(iy+clockFlags)
	res	onInterrupt,(iy+onFlags)        ; [ON] break error destroyed
	call	_ClrTxtShd                      ; clear text shadow
	call	_DrawStatusBar
	call	_ClrParserHook
	res	apdWarmStart, (iy + apdFlags)
	ld	a,(AutoBackup)
	or	a,a
	call	nz,ClearOldBackup
	im	1
	ei
	jp	_JForceCmdNoChar                 ; clear the screen like a boss

ClearOldBackup:
	di                                       ; let's do some crazy flash things so that way we can save the RAM state...
	ld.sis	sp,$ea1f
	call.is	funlock & $ffff
	
	ld	b,0
	ld	de,$3C0000
	call	_WriteFlashByte                  ; this is so we can store the new RAM data \o/
	
	call.is	flock & $ffff

	ret

#include "routines/ramquit.asm"
