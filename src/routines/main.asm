CESIUM_OS_BEGIN:
 ld de,appdata				; first, we need to store the reloader to safeRAM so we can reload after a program executes
 ld hl,cesiumReLoader_Start
 ld bc,cesiumReLoader_End-cesiumReLoader_Start
 ldir
RunShell:
 call CreateBASICprgm			; recreate prgmA in case the user decided to muck with things
 ld hl,settingsAppVar
 call _mov9toop1
 call _chkfindsym			; now lookup the settings program
 call c,createDefaultSettings		; create it if it doesn't exist
 call _chkinram
 push af
  call z,_arc_unarc			; archive it
 pop af
 jr z,RunShell				; now lookup the settings program
 ex de,hl
 ld de,9				;
 push de \ pop bc
 add hl,de				;
 ld e,(hl)				;
 add hl,de				;
 inc hl					; HL->totalPrgmSize bytes
 inc hl
 inc hl
 ld de,tmpSettings
 ldir					; copy the temporary settings to appdata
 xor a,a \ sbc hl,hl
 ld (currSelAbs),hl
 ld (scrollamt),hl
 ld (currSel),a				; op1 holds the name of this program
RELOADED_FROM_PRGM:
 ld a,(IntEnableMask)
 or $01
 ld a,(IntLatchBits)
 or $01
 ld (IntLatchBits),a
 ld (IntEnableMask),a		
 res onInterrupt,(iy+OnFlags)		; this bit of stuff just enables the [on] key
 call clearscreen
 call _GetBatteryStatus			;> 75%=4 ;50%-75%=3 ;25%-50%=2 ;5%-25%=1 ;< 5%=0
 sub 4
 neg
 ld (batterystatus),a
MAIN_START_LOOP_1:
 ld hl,pixelshadow2
 ld (programNameLocationsPtr),hl

 xor a,a \ sbc hl,hl
 ld (numprograms),hl
 call sort				; sort the VAT alphabetically
 call FindPrograms			; Find available assembly programs in the VAT
 ld a,$27
 ld (mpLcdCtrl),a			; Set LCD to 8bpp
 call CopyHL1555Palette			; HIGH=LOW
 call MoveCommonToSafeRAM
MAIN_START_LOOP:
 call DrawMainOSThings
 ld a,107
 ld (cIndex),a
 drawRectOutline(3+2+185+3,22+2,318-2,238-2-15)
 drawRectOutline(193+44,54,316-42,91)
 drawHLine(3+2+185+9,22+2+3+9,112)
 SetDefaultTextColor()
 print(FileInforamtionStr,3+2+185+9,22+2+3)
 ld hl,$000FFF
 ld (APDtmmr),hl
 or a,a \ sbc hl,hl
 ld (posX),hl
 call DrawProgramNames
GetKeys:
 call DrawTime
 call fullbufCpy
 call _getCSC
 or a,a
 call z,DecrementAPD
 cp skAlpha
 jp z,LoadProgramOptions
 cp skclear
 jp z,FullExit
 cp skdel
 jp z,DeletePrgm
 cp skmode
 jp z,DrawSettingsMenu
 cp skUp
 jp z,moveselup
 cp skDown
 jp z,moveseldown
 cp sk2nd
 jr z,BootPrgm
 cp skEnter
 jr z,BootPrgm
 sub skAdd
 jp c,GetKeys
 cp skMath-skAdd+1
 jp nc,GetKeys
 jp SearchAlphab
BootPrgm:
 ld de,cmdpixelshadow
 ld hl,cesiumLoader_Start
 ld bc,CesiumLoader_End-cesiumLoader_Start
 ldir
 call MoveCommonToSafeRAM
 call CheckIfCurrentProgramIsUs					; let's make sure we don't boot ourselves ;)
 jp z,DrawSettingsMenu
 jp cesiumLoader

DecrementAPD:
APDtmmr: =$+1
 ld hl,0
 dec hl
 ld (APDtmmr),hl
 IsHLZero
 ret nz
 pop hl
 jp FullExit
 
moveselup:
 ld hl,MAIN_START_LOOP
 push hl
getNextPrgmUp:
  ld hl,(currSelAbs)
  IsHLZero
  ret z
  dec hl
  ld (currSelAbs),hl
  ld a,(currSel)
  or a						; 5 programs for now
  jp z,ScrollListUp
  dec a
  ld (currSel),a
  ret

ScrollListUp:
 ld hl,(scrollamt)
 dec hl
 ld (scrollamt),hl
 ret
 
moveseldown:
 ld hl,MAIN_START_LOOP
 push hl
getNextPrgm:
  ld hl,(currSelAbs)
  ld de,(numprograms)
  dec de
  call _cphlde
  ret z
  inc hl
  ld (currSelAbs),hl
  ld a,(currSel)
  cp 9						; 10 programs for now
  jr z,ScrollListDown
  inc a
  ld (currSel),a
  ret

ScrollListDown:
 ld hl,(scrollamt)
 inc hl
 ld (scrollamt),hl
 ret