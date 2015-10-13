createDefaultSettings:
 ld hl,10
 call _EnoughMem
 jp c,FullExit
 ld hl,10
 call _createappvar
 inc de
 inc de
 ex de,hl
 push hl
  ld bc,10
  call _memclear
 pop hl
 ld (hl),107				; Default Color
 call _op4toop1
 ret

SaveSettings:
 ld hl,settingsAppVar
 call _mov9toop1
 call _chkfindsym
 call _chkinram
 push af
  call nz,_arc_unarc
 pop af
 jr nz,SaveSettings
 inc de
 inc de
 ld hl,tmpSettings
 ld bc,9
 ldir
NotArchivedSet:
 ld hl,settingsAppVar			; locate the appvar
 call _mov9toop1
 call _chkfindsym
 call _chkinram
 push af
  call z,_arc_unarc
 pop af
 jr z,NotArchivedSet
 ret

DrawSettingsMenu:
 xor a
 ld (curMenuSel),a						; start on the first menu item
RedrawSettings:
 res drawPrgmCnt,(iy+asmFlag)
 set clockIsOff,(iy+clockFlag)
 res shiftLwrAlph,(iy+shiftFlags)
 call DrawMainOSThings
 SetDefaultTextColor()
 print(GenSettingsStr,10,30)
 print(ColorStr,25,41+12)
 print(OnBreakStr,25,52+24)
 print(ProgramCountStr,25,63+36)				; draw the setting's option text
 print(ClockStr,25,74+48)
 ld a,107
 ld (cIndex),a
 drawRectOutline(10,41+11,18,41+19)
 drawRectOutline(10,52+11+12,18,52+19+12)
 drawRectOutline(10,63+11+24,18,63+19+24)
 drawRectOutline(10,74+11+36,18,74+19+36)			; draw the empty rectangles
 drawRectFilled(12,41+13,17,41+18)
 ld a,(OnBreak)
 or a,a
 jr z,BreakNotSet
 drawRectFilled(12,52+11+14,17,52+19+11)
BreakNotSet:							; option for OnBreak
 ld a,(programCnt)
 or a,a
 jr z,ProgCountNotSet
 drawRectFilled(12,63+11+26,17,63+19+23)
ProgCountNotSet:						; option for program count
 ld a,(clockDisp)
 or a,a
 jr z,ClockDispNotSet
 drawRectFilled(12,74+11+38,17,74+19+35)
ClockDispNotSet:						; option for clock on
 call HighlightBox
GetOptions: 
 call DrawTime
 call fullbufCpy
 call _getcsc
 ld hl,RedrawSettings
 push hl
  cp skleft
  jp z,decrementColor
  cp skright
  jp z,incrementColor
  cp skdown
  jp z,incrementSettingsOption
  cp skup
  jp z,decrementSettingsOption
  cp sk2nd
  jp z,SwapOption
  cp skEnter
  jp z,SwapOption
 pop hl
 cp skdel
 jr z,SetAndSaveOptions
 cp skclear
 jr z,SetAndSaveOptions
 jr GetOptions
SetAndSaveOptions:
 call SaveSettings
 jp MAIN_START_LOOP
 
HighlightBox:
 ld a,HIGHLIGHT_COLOR
 ld (cIndex),a
 ld a,(curMenuSel)
 or a,a
 jr nz,+_
 drawRectOutline(10,41+11,18,41+19)
 ret
_:
 dec a
 jr nz,+_
 drawRectOutline(10,52+11+12,18,52+19+12)
 ret
_:
 dec a
 jr nz,+_
 drawRectOutline(10,63+11+24,18,63+19+24)
 ret
_:
 drawRectOutline(10,74+11+36,18,74+19+36)
 ret

incrementSettingsOption:
  ld a,(curMenuSel)
  cp 3
  ret z
  inc a
  ld (curMenuSel),a
 ret
decrementSettingsOption:
  ld a,(curMenuSel)
  or a,a
  ret z
  dec a
  ld (curMenuSel),a
 ret
decrementColor:
 ld a,(curMenuSel)
 or a,a
 ret nz
 ld a,(skinColor)
 dec a
 jr LoadColor
incrementColor:
 ld a,(curMenuSel)
 or a,a
 ret nz
 ld a,(skinColor)
 inc a
LoadColor:
 ld (skinColor),a
 ret
SwapOption:
 ld a,(curMenuSel)
 or a,a
 ret z
 ld hl,tmpSettings
 ld a,(curMenuSel)
 call _addHLandA
 ld a,(hl)
 cpl
 ld (hl),a
 ret