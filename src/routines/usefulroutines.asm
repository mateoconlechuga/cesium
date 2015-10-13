CheckIfCurrentProgramIsUs:					; returns Z if we try to do anything to this program
 ld hl,(prgmNamePtr)
 jr +_
CheckIfCurrentTmpProgramIsUs:
 ld hl,(tmpPrgmNamePtr)
_:
 call NamePtrToOP1
 ld hl,CesiumPrgmName
 ld de,OP1
 ld b,8
CheckNameLoop:
 ld a,(de)
 cp (hl)
 ret nz
 inc hl
 inc de
 djnz CheckNameLoop
 xor a
 ret
 
DrawTime:
 ld a,(clockDisp)
 or a,a
 ret z
 set clockOn,(iy+clockFlags)
 set useTokensInString,(iy+clockFlags)
 ld de,OP6
 push de
  call _formtime
  ld bc,255
  ld (posX),bc
  ld a,7
  ld (posY),a
 pop hl
 SetInvertedTextColor()
 call drawString
 SetDefaultTextColor()
 di
 ret
 
DrawMainOSThings:
 call clearvbuf2
 SetInvertedTextColor()
 drawRectFilled(1,1,319,21)
 call ClearLowerBar
 ld a,107
 ld (cIndex),a
 drawRectOutline(1,22,318,238-15)
 print(CesiumTitle,15,7)
 print(RAMFreeStr,4,228)
 call _MemChk
 call DispHL
 inc hl
 call drawString
 print(ROMFreeStr,196,228)
 call _ArcChk
 ld hl,(tempFreeArc)
 call DispHL
 call drawString
 drawSpr255(batterySprite, 3,7)
 ld a,255
 ld (cIndex),a
batterystatus: =$+1
 ld a,0
 or a,a
 ret z
 ld hl,320*6+vBuf2+5
 ld (RectWidth_SMC),hl
 call DrawRectLoop
 ret
 
ClearLowerBar:
 push bc
  drawRectFilled(1,238-15+2,319,239)
 pop bc
 ret