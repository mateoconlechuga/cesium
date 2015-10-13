clearScreen:
 call clearVBuf2
 jp clearVBuf1
 
clearVBuf2:
 ld hl,vBuf2
 jr clearBuffer
clearVBuf1:
 ld hl,vBuf1
clearBuffer:
 ld a,$FF
 ld bc,320*240
 jp _MemSet
 
CopyHL1555Palette:
 ld hl,$E30200    ; palette mem
 ld b,0
_cp1555loop:
 ld d,b
 ld a,b
 and %11000000
 srl d
 rra
 ld e,a
 ld a,%00011111
 and b
 or e
 ld (hl),a
 inc hl
 ld (hl),d
 inc hl
 inc b
 jr nz,_cp1555loop
 ret
 
fullbufCpy:
 ld bc,320*240
 ld hl,vBuf2
 ld de,vBuf1
 ldir
 ret

; hl -> sprite
; bc = xy
drawSprite8bpp255:
 ld a,(hl)  ; width
 ld (SpriteWidth_SMC),a
 push hl
  ld de,0
  ld e,a
  ld hl,320
  or a,a
  sbc hl,de
  ld (SpriteWidth255_SMC),hl
 pop hl
 inc hl
 push hl
  or a
  sbc hl,hl
  ld l,b
  ld a,c
  add hl,hl
  push hl  ; Save X
   call compute8bpp
  pop de  ; de = X
  add hl,de  ; Add X ; Returns hl -> sprite data, a = sprite height
  ex de,hl
 pop hl
 ld b,(hl)
 inc hl
InLoop8bpp:
 push bc
SpriteWidth_SMC: =$+1
  ld bc,0
loop8bpp:
  ldir
  ex de,hl
SpriteWidth255_SMC: =$+1
   ld bc,0   ; Increment amount per line
   add hl,bc
  ex de,hl
 pop bc
 djnz InLoop8bpp
 ret
 
drawSprite8bpp255_2x:
 ld a,(hl)  ; width
 ld (SpriteWidth_2x_SMC),a
 push hl
  ld de,0
  add a,a
  ld e,a
  ld hl,320
  or a,a
  sbc hl,de
  ld (SpriteWidth255_2x_SMC),hl
 pop hl
 inc hl
 push hl
  or a
  sbc hl,hl
  ld l,b
  ld a,c
  add hl,hl
  push hl  ; Save X
   call compute8bpp
  pop de  ; de = X
  add hl,de  ; Add X ; Returns hl -> sprite data, a = sprite height
  ex de,hl
 pop hl
 ld b,(hl)
 inc hl
InLoop8bpp_2x:
 push bc
SpriteWidth_2x_SMC: =$+1
  ld bc,0
  push de		; save pointer to current line
_:
   ld a,(hl)
   ld (de),a
   inc de
   ld (de),a
   inc de
   inc hl
   dec bc
   ld a,b
   or c
   jr nz,-_
   ex de,hl
SpriteWidth255_2x_SMC: =$+1
   ld bc,0	; Increment amount per line
   add hl,bc	; HL->next place to draw, DE->location to get from
   push de
   pop ix	; ix->location to get from
   ex de,hl	; hl
   ld hl,(SpriteWidth_2x_SMC)
   add hl,hl
   ld b,h
   ld c,l	; BC=real size to copy
  pop hl	; HL->pervious line
  ldir
  ex de,hl
  ld bc,(SpriteWidth255_2x_SMC)
  add hl,bc
  push ix
  pop de
  ex de,hl
 pop bc
 djnz InLoop8bpp_2x
 ret
 
asmFileSprite:
 .db 16,16
 .db 255,255,255,093,125,125,125,125,125,125,019,019,255,255,255,255
 .db 255,255,255,125,255,255,223,223,223,223,125,019,019,255,255,255
 .db 255,255,255,125,255,255,255,223,223,223,223,125,125,019,255,255
 .db 255,255,255,125,255,255,255,223,223,223,223,125,255,125,019,255
 .db 255,255,255,125,255,255,255,255,223,223,223,125,191,191,125,019
 .db 255,255,255,125,255,255,255,255,255,223,223,223,223,223,125,019
 .db 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,019
 .db 000,255,255,255,255,255,255,255,255,255,255,255,255,255,000,019
 .db 000,255,160,160,160,255,160,160,160,255,160,255,160,255,000,019
 .db 000,255,160,255,160,255,160,255,255,255,160,160,160,255,000,019
 .db 000,255,160,160,160,255,255,255,160,255,160,255,160,255,000,019
 .db 000,255,160,255,160,255,160,160,160,255,160,255,160,255,000,019
 .db 000,255,255,255,255,255,255,255,255,255,255,255,255,255,000,019
 .db 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,019
 .db 255,255,255,019,255,255,255,255,255,255,255,255,255,255,255,019
 .db 255,255,255,018,019,019,019,019,019,019,019,019,019,019,019,018
cFileSprite:
 .db 16,16
 .db 255,255,255,093,125,125,125,125,125,125,019,019,255,255,255,255
 .db 255,255,255,125,255,255,223,223,223,223,125,019,019,255,255,255
 .db 255,255,255,125,255,255,255,223,223,223,223,125,125,019,255,255
 .db 255,255,255,125,255,255,255,223,223,223,223,125,255,125,019,255
 .db 255,255,255,125,255,255,255,255,223,223,223,125,191,191,125,019
 .db 255,255,255,125,255,255,255,255,255,223,223,223,223,223,125,019
 .db 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,019
 .db 000,255,255,255,255,255,255,255,255,255,255,255,255,255,000,019
 .db 000,255,255,255,255,255,019,019,019,255,255,255,255,255,000,019
 .db 000,255,255,255,255,255,019,255,255,255,255,255,255,255,000,019
 .db 000,255,255,255,255,255,019,255,255,255,255,255,255,255,000,019
 .db 000,255,255,255,255,255,019,019,019,255,255,255,255,255,000,019
 .db 000,255,255,255,255,255,255,255,255,255,255,255,255,255,000,019
 .db 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,019
 .db 255,255,255,019,255,255,255,255,255,255,255,255,255,255,255,019
 .db 255,255,255,018,019,019,019,019,019,019,019,019,019,019,019,018
basicFileSprite:
 .db 16,16
 .db 255,255,255,093,125,125,125,125,125,125,019,019,255,255,255,255
 .db 255,255,255,125,255,255,223,223,223,223,125,019,019,255,255,255
 .db 255,255,255,125,255,255,255,223,223,223,223,125,125,019,255,255
 .db 255,255,255,125,255,255,255,223,223,223,223,125,255,125,019,255
 .db 255,255,255,125,255,255,255,255,223,223,223,125,191,191,125,019
 .db 255,255,255,125,255,255,255,255,255,223,223,223,223,223,125,019
 .db 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,019
 .db 000,255,255,255,255,255,255,255,255,255,255,255,255,255,000,019
 .db 000,255,255,255,227,227,227,255,227,227,227,255,255,255,000,019
 .db 000,255,255,255,255,227,255,255,255,227,255,255,255,255,000,019
 .db 000,255,255,255,255,227,255,255,255,227,255,255,255,255,000,019
 .db 000,255,255,255,255,227,255,255,227,227,227,255,255,255,000,019
 .db 000,255,255,255,255,255,255,255,255,255,255,255,255,255,000,019
 .db 000,000,000,000,000,000,000,000,000,000,000,000,000,000,000,019
 .db 255,255,255,019,255,255,255,255,255,255,255,255,255,255,255,019
 .db 255,255,255,018,019,019,019,019,019,019,019,019,019,019,019,018
lockedSprite:
 .db 6,8
 .db 255,75,75,75,75,255
 .db 255,75,255,255,75,255
 .db 255,75,255,255,75,255
 .db 75,75,75,75,75,75
 .db 75,228,228,228,228,75
 .db 75,228,228,228,228,75
 .db 75,228,228,228,228,75
 .db 75,75,75,75,75,75
archivedSprite:
 .db 6,8
 .db 75,75,75,75,75,75
 .db 75,255,75,255,255,75
 .db 75,255,255,75,255,75
 .db 75,255,75,255,255,75
 .db 75,228,228,75,228,75
 .db 75,228,75,228,228,75
 .db 75,228,228,75,228,75
 .db 75,75,75,75,75,75
batterySprite:
 .db 6,8
 .db 000,000,000,000,000,000
 .db 000,037,037,037,037,000
 .db 000,037,037,037,037,000
 .db 000,037,037,037,037,000
 .db 000,037,037,037,037,000
 .db 000,037,037,037,037,000
 .db 000,037,037,037,037,000
 .db 000,000,000,000,000,000
 
DrawRect:
 ld a,(cIndex)
 push af
  ld a,(skinColor)
  ld (cIndex),a
DrawRectLoop:
  push bc
   push hl
RectWidth_SMC: =$+1
    ld bc,0
    call drawHLine8
   pop hl
   ld de,320
   add hl,de
  pop bc
  djnz DrawRectLoop
 pop af
 ld (cIndex),a
 ret
 
drawHLine8:
  ld a,(cIndex)
  ld (hl),a
  inc hl
  dec bc
  ld a,b
  or c
  jr nz,drawHLine8
  ret
 
drawVLine8:
 ld a,(cIndex)
Vloop:
 ld (hl),a
 ld de,320
 add hl,de
 djnz drawVLine8
 ret
 
cIndex:
 .db 0