FullExit:
 ld hl,vBuf1
 ld a,$FF
 ld bc,320*240*2			; clear out the screen
 call _MemSet
 ld a,$2D
 ld (mpLcdCtrl),a			; Set LCD to 16bpp
 set graphdraw,(iy+graphFlags)
 res useTokensInString,(iy+clockFlags)
 res onInterrupt,(iy+onFlags)		; [ON] break error destroyed
UnArchiveCesium:
 ld hl,CesiumPrgmName
 call _mov9toop1
 call _chkfindsym
 call _chkinram
 call nz,_arc_unarc
 call _clrlcdall
 call _ClrTxtShd			; clear text shadow
 call _DrawStatusBar
 ld hl,pixelshadow
 ld bc,saveSScreen-pixelShadow
 call _memclear
 call _clrparserhook
 xor a
 im 1 \ ei
 ld hl,stub
 ld de,appData
 ld bc,stubEnd-stub
 ldir
 jp appData
stub:
 ld hl,userMem
 ld de,(asm_prgm_size)
 call _DelMem
 ld a,kclear
 jp _JForceCmd				; clear the screen like a boss
stubEnd: