LoadProgramOptions:
 call CheckIfCurrentProgramIsUs
 jp z,DrawSettingsMenu				; don't change the options if we are the program!
 ld hl,PgrmOptions
 ld bc,4
 call _memclear
 cpl						; A=0FFh
 bit pgrmArchived,(iy+pgrmStatus)
 jr z,NotInArc
 ld (ArchiveSet),a				; mark archive as set
NotInArc:
 bit pgrmLocked,(iy+pgrmStatus)
 jr z,NotLocked
 ld (LockSet),a
NotLocked:
 bit pgrmHidden,(iy+pgrmStatus)
 jr z,DrawPrgmOptions
 ld (HideSet),a
DrawPrgmOptions:
 call GetOptionPixelOffset
 ld a,230
 ld (backColor),a
 ld a,(curMenuSel)
 call GetRightString
 ld bc,199
 ld (posX),bc
 call drawString
 SetDefaultTextColor()
GetKeys2:
 call fullbufCpy
 call _getCSC
 ld hl,DrawPrgmOptions
 push hl
  cp skdown
  jp z,incrementOption
  cp skup
  jp z,decrementOption
 pop hl
 cp skalpha
 jp z,SetOptions
 cp skmode
 jp z,SetOptions
 cp skdel
 jp z,SetOptions
 cp skclear
 jp z,SetOptions
 cp skdel
 jp z,SetOptions
 cp sk2nd
 jp z,CheckWhatToDo
 cp skenter
 jr nz,GetKeys2
 jp CheckWhatToDo
 
incrementOption:
  call EraseSel
  cp 2
  ret z
  inc a
  ld (curMenuSel),a
 ret
GetOptionPixelOffset:
 ld a,(curMenuSel)
 ld l,a
 ld h,11
 mlt hl
 ld a,118
 add a,l
 ld bc,199
 ld (posX),bc
 ld (posY),a
 ret
decrementOption:
  call EraseSel
  or a
  ret z
  dec a
  ld (curMenuSel),a
 ret
EraseSel:
 call GetOptionPixelOffset
 ld a,(curMenuSel)
 call GetRightString
 call drawString
 ld a,(curMenuSel)
 ret
GetRightString:
 ld hl,ArchiveStatusStr
 or a
 ret z
 ld hl,EditStatusStr
 dec a
 ret z
 ld hl,HiddenStr
 dec a
 ret
CheckWhatToDo:
 ld hl,DrawPrgmOptions
  push hl
  ld hl,PgrmOptions
  ld a,(curMenuSel)
  dec a
  jr nz,NotOnLock
  ld a,(prgmbyte)
  cp $BB
  ret nz					; only want to be able to lock and unlock BASIC programs
NotOnLock:
  ld a,(curMenuSel)
  call _addhlanda
  ld a,(hl)					; get the status of the current byte
  cpl
  ld (hl),a					; invert it, so we can check it later
  ld a,(skinColor)
  push af
   ld a,255
   ld (skinColor),a
   drawRectFilled(302,120,307,125)  		; now let's redraw all the options :P
   drawRectFilled(302,120+11,307,125+11)
   drawRectFilled(302,120+22,307,125+22)
  pop af
  ld (skinColor),a
  ld a,(ArchiveSet)
  or a,a
  jr z,_j1
  drawRectFilled(302,120,307,125) 
_j1:
  ld a,(LockSet)
  or a,a
  jr z,_j2
  drawRectFilled(302,120+11,307,125+11)
_j2:
  ld a,(HideSet)
  or a,a
  jr z,_j3
  drawRectFilled(302,120+22,307,125+22)
_j3:
  ret
SetOptions:
 ld hl,(prgmNamePtr)
 call NamePtrToOP1				; if 255, archive it
 call _chkfindsym
 call _chkinram
 push af
  ld a,(ArchiveSet)
  or a,a
  jr z,UnarchivePrgm
ArchivePrgm:
 pop af
 call z,_arc_unarc
 jr CheckLock
UnarchivePrgm:
 pop af
 call nz,_arc_unarc
CheckLock:
 ld hl,(prgmNamePtr)
 call NamePtrToOP1
 call _chkfindsym
 ld a,(LockSet)
 or a,a
 jr z,UnlockPrgm
LockPrgm:
 ld (hl),$06
 jr CheckHide
UnlockPrgm:
 ld (hl),$05
CheckHide:
 ld hl,(prgmNamePtr)
 ld hl,(hl)
 dec hl						; bypass name totalPrgmSize byte
 ld a,(hl)
 cp 64
 push af
  ld a,(HideSet)
  or a,a
  jr z,Unhide
Hide:
 pop af
 jr c,ReturnToMain				; already hidden
 sub a,64
 ld (hl),a
 jr ReturnToMain
Unhide:
 pop af
 jr nc,ReturnToMain				; already hidden
 add a,64
 ld (hl),a
ReturnToMain:
 jp MAIN_START_LOOP