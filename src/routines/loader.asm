cesiumLoader_Start:
relocate(cmdpixelshadow)
cesiumLoader:

 call DeletePgrmFromUserMem		; now we deleted ourselves. cool.
 call ArchiveCesium			; archive ourselves to perserve space when running other things
 
 call _clrlcd
 ld a,$2D
 ld (mpLcdCtrl),a			; Set LCD to 16bpp
 ld hl,(prgmNamePtr)
 call NamePtrToOP1
 ld (errorSP),sp
 bit isBasic,(iy+pgrmStatus)
 jp nz,RunBasicProgram
 call MovePgrmToUserMem			; the program is now stored at userMem -- Now we need to check and see what kind of file it is - C or assembly
 ld hl,userMem				; simply call userMem to execute the program
RunProgram:
 ld de,ReturnHere
 push de
  jp (hl)
  
RunBasicProgram:
 call _DrawStatusBar
 call _Runindicon
 ld a,(OnBreak)
 or a,a
 call nz,_Runindicoff
 ld a,(arcStatus)
 or a,a
 jr z,GoodInRAM
 ld hl,tmpPrgmName
 call _mov9toop1
 call _PushOP1
  call _chkfindsym
  call nc,_delvararc			; delete the temp prgm if it exists
 call _PopOP1
 ld hl,(actualSizePrgm)
 push hl
  call _createprog			; create a temp program so we can execute
  inc de
  inc de
 pop bc
 call _ChkBCIs0
 jr z,InROM				; there's nothing to copy
 ld hl,(prgmDataPtr)
 ldi
 call _ChkBCIs0
 jr z,InROM				; this way ldir doesn't throw a fit
 ldir
InROM:
 call _op4toop1
GoodInRAM:
 set graphdraw,(iy+graphFlags)
 ld hl,errcatch
 call _PushErrorHandler
  set ProgExecuting,(iy+newdispf)
  set allowProgTokens,(iy+newDispF)
  set cmdExec,(iy+cmdFlags) 		; set these flags to execute BASIC prgm
  res onInterrupt,(iy+onflags)
  ld hl,ReturnHereBASIC
  push hl
   xor a,a
   ld (kbdGetKy),a
   ei
   jp _parseinp				; run program
   
tmpPrgmName:
 .db tempprogobj,"ZTGP",0
endrelocate()
CesiumLoader_End: