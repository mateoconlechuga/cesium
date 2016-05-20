;-------------------------------------------------------------------------------
FullExit:
	call	_boot_ClearVRAM
	ld	a,$2D
	ld	(mpLcdCtrl),a				; Set LCD to 16bpp
	set	graphdraw,(iy+graphFlags)
	res	useTokensInString,(iy+clockFlags)
	res	onInterrupt,(iy+onFlags)		; [ON] break error destroyed
	ld	hl,CesiumPrgmName
	call	_Mov9ToOP1
	call	_ChkFindSym
	call	_ChkInRam
	call	nz,_Arc_Unarc
	call	_ClrTxtShd				; clear text shadow
	call	_DrawStatusBar
	ld	hl,pixelshadow
	ld	bc,SaveSScreen-pixelShadow
	call	_MemClear
	call	_ClrParserHook
	xor	a,a
	im	1
	ei
	ld	hl,stub
	ld	de,flashRAMCode
	ld	bc,stubEnd-stub
	ldir
	jp	flashRAMCode
stub:
relocate(flashRAMCode)
	ld	hl,userMem
	ld	de,(asm_prgm_size)
	call	_DelMem
	res	apdWarmStart, (iy + apdFlags)
	call	ClearOldBackup
	ld	a,kClear
	jp	_JForceCmd			; clear the screen like a boss

ClearOldBackup:
	di					; let's do some crazy flash things so that way we can save the RAM state...
	ld	a, $D1
	ld	mb,a
	ld.sis	sp,$987E
	call.is	funlock - $D10000
	
	ld	a,$3C
	call	EraseSectorBackup			; this is so we can store the new RAM data \o/
	
	call.is	flock - $D10000
	ld	a,$D0
	ld	mb,a

	ret

EraseSectorBackup:
	ld	bc,$0000F8			; apparently we can't erase sectors unless we call this routine from flash... Well, I called it from flash now :) (lol, what a secuity flaw)
	push	bc
	jp	_EraseFlashSector

#include "routines/ramquit.asm"
endrelocate()
stubEnd: