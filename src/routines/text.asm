;Text routines by Matt waltz

drawString:
 ld a,(hl)
 or a
 ret z
 call DrawChar
 push hl
  ld de,320-10
  ld hl,(posX)
  call _cphlde
 pop hl
 ret nc
 inc hl
 jr drawString

DrawBigChar:
 ld bc,(posX)
 push hl
 push af
 push de
 push bc
 push af
  ld a,(posY)
  push bc	; Save X
   call compute8bpp
  pop de	; de = Y
  add hl,de	; Add X
 pop af
 push hl
  or a
  sbc hl,hl
  ld l,a
  add hl,hl
  add hl,hl
  add hl,hl
  ex de,hl
  ld hl,char000
  add hl,de	; hl -> Correct Character
 pop de		; de -> correct place to draw
 ld b,8
_iloop2:
 push bc
  ld c,(hl)
  ld b,8
  ex de,hl
  push de
  push hl
   ld de,(ForeColor)
_i2loop2:
   ld a,d
   rlc c
   jr nc,$+1
   ld a,e
   ld (hl),a
   inc hl
   ld (hl),a
   inc hl
   djnz _i2loop2
   ld bc,320-16
   add hl,bc	; next line
   ex de,hl
   pop hl
   ld bc,16
   ldir
   ex de,hl
   ld bc,320-16
   add hl,bc	; next line
  pop de
  ex de,hl
  inc hl
 pop bc
 djnz _iloop2
 pop bc
 pop de
 pop af		; character
 cp 128
 jr c,+_
 xor a
_:
 ld hl,CharSpacing
 call _AddHLAndA
 ld a,(hl)	; A holds the amount to increment per character
 add a,a
 jp AddToPosistion
 
DispHL:     ; hl = 8-bit score
  push de
   push bc
    ld de,tmpStr  ; de = converted string loc
    push de
     call str
     xor a,a
     ld (de),a
    pop hl ; hl points to converted string
   pop bc
  pop de
 ret
 
tmpStr:
 .dl 0,0,0,0,0,0,0,0,0,0
 
str:
 ld bc,-1000000
 call Num13
 ld bc,-100000
 call Num13
 ld bc,-10000
 call Num13
 ld bc, -1000
 call Num13
 ld bc, -100
 call Num13
 ld c, -10
 call Num13
 ld c, b
Num13:
 ld a, '0'-1
Num21:
 inc a
 add hl, bc
 jr c, Num21
 sbc hl, bc
 ld (de), a
 inc de
 ret
 
DrawChar:
 ld bc,(posX)
 push hl
 push af
 push de
 push bc
 push af
  ld a,(posY)
  push bc	; Save X
   call compute8bpp
  pop de	; de = Y
  add hl,de	; Add X
 pop af
 push hl
  or a
  sbc hl,hl
  ld l,a
  add hl,hl
  add hl,hl
  add hl,hl
  ex de,hl
  ld hl,char000
  add hl,de	; hl -> Correct Character
 pop de		; de -> correct place to draw
 ld b,8
_iloop:
 push bc
  ld c,(hl)
  ld b,8
  ex de,hl
  push de
   ld de,(ForeColor)
_i2loop:
   ld (hl),d
   rlc c
   jr nc,+_
   ld (hl),e
_:
   inc hl
   djnz _i2loop
   ld (hl),d
NextL:
   ld bc,320-8
   add hl,bc
  pop de
  ex de,hl
  inc hl
 pop bc
 djnz _iloop
 pop bc
 pop de
 pop af		; character
 cp 128
 jr c,+_
 xor a
_:
 ld hl,CharSpacing
 call _AddHLAndA
 ld a,(hl)	; A holds the amount to increment per character
AddToPosistion:
 or a,a
 sbc hl,hl
 ld l,a
 add hl,bc
 push hl
 pop bc
 inc bc
 ld (posX),bc
 pop hl
 ret
 
ForeColor:
 .db 0
BackColor:
 .db 255
 
compute8bpp:
 ld de,320
 call $000348				; MultDEA
 ld de,vbuf2
 add hl,de
 ret
 
CharSpacing:
 ;   0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,F
 .db 8,8,8,7,7,7,8,8,8,8,8,8,8,1,8,8
 .db 7,7,8,8,8,8,8,8,8,8,8,8,8,8,8,8
 .db 2,3,5,7,7,7,7,4,4,4,8,6,3,6,2,7
 .db 7,6,7,7,7,7,7,7,7,7,2,3,5,6,5,6
 .db 7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7
 .db 7,7,7,7,8,7,7,7,7,7,7,4,7,4,7,8
 .db 3,7,7,7,7,7,7,7,7,4,7,7,4,7,7,7
 .db 7,7,7,7,6,7,7,7,7,7,7,6,2,6,7,7
 .db 7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7
 
Char000: .db $00,$00,$00,$00,$00,$00,$00,$00	; .
Char001: .db $7E,$81,$A5,$81,$BD,$BD,$81,$7E	; .
Char002: .db $7E,$FF,$DB,$FF,$C3,$C3,$FF,$7E	; .
Char003: .db $6C,$FE,$FE,$FE,$7C,$38,$10,$00	; .
Char004: .db $10,$38,$7C,$FE,$7C,$38,$10,$00	; .
Char005: .db $38,$7C,$38,$FE,$FE,$10,$10,$7C	; .
Char006: .db $00,$18,$3C,$7E,$FF,$7E,$18,$7E	; .
Char007: .db $00,$00,$18,$3C,$3C,$18,$00,$00	; .
Char008: .db $FF,$FF,$E7,$C3,$C3,$E7,$FF,$FF	; .
Char009: .db $00,$3C,$66,$42,$42,$66,$3C,$00	; .
Char010: .db $FF,$C3,$99,$BD,$BD,$99,$C3,$FF	; .
Char011: .db $0F,$07,$0F,$7D,$CC,$CC,$CC,$78	; .
Char012: .db $3C,$66,$66,$66,$3C,$18,$7E,$18	; .
Char013: .db $3F,$33,$3F,$30,$30,$70,$F0,$E0	; .
Char014: .db $7F,$63,$7F,$63,$63,$67,$E6,$C0	; .
Char015: .db $99,$5A,$3C,$E7,$E7,$3C,$5A,$99	; .
Char016: .db $80,$E0,$F8,$FE,$F8,$E0,$80,$00	; .
Char017: .db $02,$0E,$3E,$FE,$3E,$0E,$02,$00	; .
Char018: .db $18,$3C,$7E,$18,$18,$7E,$3C,$18	; .
Char019: .db $66,$66,$66,$66,$66,$00,$66,$00	; .
Char020: .db $7F,$DB,$DB,$7B,$1B,$1B,$1B,$00	; .
Char021: .db $3F,$60,$7C,$66,$66,$3E,$06,$FC	; .
Char022: .db $00,$00,$00,$00,$7E,$7E,$7E,$00	; .
Char023: .db $18,$3C,$7E,$18,$7E,$3C,$18,$FF	; .
Char024: .db $18,$3C,$7E,$18,$18,$18,$18,$00	; .
Char025: .db $18,$18,$18,$18,$7E,$3C,$18,$00	; .
Char026: .db $00,$18,$0C,$FE,$0C,$18,$00,$00	; .
Char027: .db $00,$30,$60,$FE,$60,$30,$00,$00	; .
Char028: .db $00,$00,$C0,$C0,$C0,$FE,$00,$00	; .
Char029: .db $00,$24,$66,$FF,$66,$24,$00,$00	; .
Char030: .db $00,$18,$3C,$7E,$FF,$FF,$00,$00	; .
Char031: .db $00,$FF,$FF,$7E,$3C,$18,$00,$00	; .
Char032: .db $00,$00,$00,$00,$00,$00,$00,$00	;  
Char033: .db $C0,$C0,$C0,$C0,$C0,$00,$C0,$00	; !
Char034: .db $D8,$D8,$D8,$00,$00,$00,$00,$00	; "
Char035: .db $6C,$6C,$FE,$6C,$FE,$6C,$6C,$00	; #
Char036: .db $18,$7E,$C0,$7C,$06,$FC,$18,$00	; $
Char037: .db $00,$C6,$CC,$18,$30,$66,$C6,$00	; %
Char038: .db $38,$6C,$38,$76,$DC,$CC,$76,$00	; &
Char039: .db $30,$30,$60,$00,$00,$00,$00,$00	; '
Char040: .db $30,$60,$C0,$C0,$C0,$60,$30,$00	; (
Char041: .db $C0,$60,$30,$30,$30,$60,$C0,$00	; )
Char042: .db $00,$66,$3C,$FF,$3C,$66,$00,$00	; *
Char043: .db $00,$30,$30,$FC,$FC,$30,$30,$00	; +
Char044: .db $00,$00,$00,$00,$00,$60,$60,$C0	; ,
Char045: .db $00,$00,$00,$FC,$00,$00,$00,$00	; -
Char046: .db $00,$00,$00,$00,$00,$C0,$C0,$00	; .
Char047: .db $06,$0C,$18,$30,$60,$C0,$80,$00	; /
Char048: .db $7C,$CE,$DE,$F6,$E6,$C6,$7C,$00	; 0
Char049: .db $30,$70,$30,$30,$30,$30,$FC,$00	; 1
Char050: .db $7C,$C6,$06,$7C,$C0,$C0,$FE,$00	; 2
Char051: .db $FC,$06,$06,$3C,$06,$06,$FC,$00	; 3
Char052: .db $0C,$CC,$CC,$CC,$FE,$0C,$0C,$00	; 4
Char053: .db $FE,$C0,$FC,$06,$06,$C6,$7C,$00	; 5
Char054: .db $7C,$C0,$C0,$FC,$C6,$C6,$7C,$00	; 6
Char055: .db $FE,$06,$06,$0C,$18,$30,$30,$00	; 7
Char056: .db $7C,$C6,$C6,$7C,$C6,$C6,$7C,$00	; 8
Char057: .db $7C,$C6,$C6,$7E,$06,$06,$7C,$00	; 9
Char058: .db $00,$C0,$C0,$00,$00,$C0,$C0,$00	; :
Char059: .db $00,$60,$60,$00,$00,$60,$60,$C0	; ;
Char060: .db $18,$30,$60,$C0,$60,$30,$18,$00	; <
Char061: .db $00,$00,$FC,$00,$FC,$00,$00,$00	; =
Char062: .db $C0,$60,$30,$18,$30,$60,$C0,$00	; >
Char063: .db $78,$CC,$18,$30,$30,$00,$30,$00	; ?
Char064: .db $7C,$C6,$DE,$DE,$DE,$C0,$7E,$00	; @
Char065: .db $38,$6C,$C6,$C6,$FE,$C6,$C6,$00	; A
Char066: .db $FC,$C6,$C6,$FC,$C6,$C6,$FC,$00	; B
Char067: .db $7C,$C6,$C0,$C0,$C0,$C6,$7C,$00	; C
Char068: .db $F8,$CC,$C6,$C6,$C6,$CC,$F8,$00	; D
Char069: .db $FE,$C0,$C0,$F8,$C0,$C0,$FE,$00	; E
Char070: .db $FE,$C0,$C0,$F8,$C0,$C0,$C0,$00	; F
Char071: .db $7C,$C6,$C0,$C0,$CE,$C6,$7C,$00	; G
Char072: .db $C6,$C6,$C6,$FE,$C6,$C6,$C6,$00	; H
Char073: .db $7E,$18,$18,$18,$18,$18,$7E,$00	; I
Char074: .db $06,$06,$06,$06,$06,$C6,$7C,$00	; J
Char075: .db $C6,$CC,$D8,$F0,$D8,$CC,$C6,$00	; K
Char076: .db $C0,$C0,$C0,$C0,$C0,$C0,$FE,$00	; L
Char077: .db $C6,$EE,$FE,$FE,$D6,$C6,$C6,$00	; M
Char078: .db $C6,$E6,$F6,$DE,$CE,$C6,$C6,$00	; N
Char079: .db $7C,$C6,$C6,$C6,$C6,$C6,$7C,$00	; O
Char080: .db $FC,$C6,$C6,$FC,$C0,$C0,$C0,$00	; P
Char081: .db $7C,$C6,$C6,$C6,$D6,$DE,$7C,$06	; Q
Char082: .db $FC,$C6,$C6,$FC,$D8,$CC,$C6,$00	; R
Char083: .db $7C,$C6,$C0,$7C,$06,$C6,$7C,$00	; S
Char084: .db $FF,$18,$18,$18,$18,$18,$18,$00	; T
Char085: .db $C6,$C6,$C6,$C6,$C6,$C6,$FE,$00	; U
Char086: .db $C6,$C6,$C6,$C6,$C6,$7C,$38,$00	; V
Char087: .db $C6,$C6,$C6,$C6,$D6,$FE,$6C,$00	; W
Char088: .db $C6,$C6,$6C,$38,$6C,$C6,$C6,$00	; X
Char089: .db $C6,$C6,$C6,$7C,$18,$30,$E0,$00	; Y
Char090: .db $FE,$06,$0C,$18,$30,$60,$FE,$00	; Z
Char091: .db $F0,$C0,$C0,$C0,$C0,$C0,$F0,$00	; [
Char092: .db $C0,$60,$30,$18,$0C,$06,$02,$00	; \
Char093: .db $F0,$30,$30,$30,$30,$30,$F0,$00	; ]
Char094: .db $10,$38,$6C,$C6,$00,$00,$00,$00	; ^
Char095: .db $00,$00,$00,$00,$00,$00,$00,$FF	; _
Char096: .db $C0,$C0,$60,$00,$00,$00,$00,$00	; `
Char097: .db $00,$00,$7C,$06,$7E,$C6,$7E,$00	; a
Char098: .db $C0,$C0,$C0,$FC,$C6,$C6,$FC,$00	; b
Char099: .db $00,$00,$7C,$C6,$C0,$C6,$7C,$00	; c
Char100: .db $06,$06,$06,$7E,$C6,$C6,$7E,$00	; d
Char101: .db $00,$00,$7C,$C6,$FE,$C0,$7C,$00	; e
Char102: .db $1C,$36,$30,$78,$30,$30,$78,$00	; f
Char103: .db $00,$00,$7E,$C6,$C6,$7E,$06,$FC	; g
Char104: .db $C0,$C0,$FC,$C6,$C6,$C6,$C6,$00	; h
Char105: .db $60,$00,$E0,$60,$60,$60,$F0,$00	; i
Char106: .db $06,$00,$06,$06,$06,$06,$C6,$7C	; j
Char107: .db $C0,$C0,$CC,$D8,$F8,$CC,$C6,$00	; k
Char108: .db $E0,$60,$60,$60,$60,$60,$F0,$00	; l
Char109: .db $00,$00,$CC,$FE,$FE,$D6,$D6,$00	; m
Char110: .db $00,$00,$FC,$C6,$C6,$C6,$C6,$00	; n
Char111: .db $00,$00,$7C,$C6,$C6,$C6,$7C,$00	; o
Char112: .db $00,$00,$FC,$C6,$C6,$FC,$C0,$C0	; p
Char113: .db $00,$00,$7E,$C6,$C6,$7E,$06,$06	; q
Char114: .db $00,$00,$FC,$C6,$C0,$C0,$C0,$00	; r
Char115: .db $00,$00,$7E,$C0,$7C,$06,$FC,$00	; s
Char116: .db $30,$30,$FC,$30,$30,$30,$1C,$00	; t
Char117: .db $00,$00,$C6,$C6,$C6,$C6,$7E,$00	; u
Char118: .db $00,$00,$C6,$C6,$C6,$7C,$38,$00	; v
Char119: .db $00,$00,$C6,$C6,$D6,$FE,$6C,$00	; w
Char120: .db $00,$00,$C6,$6C,$38,$6C,$C6,$00	; x
Char121: .db $00,$00,$C6,$C6,$C6,$7E,$06,$FC	; y
Char122: .db $00,$00,$FE,$0C,$38,$60,$FE,$00	; z
Char123: .db $1C,$30,$30,$E0,$30,$30,$1C,$00	; {
Char124: .db $C0,$C0,$C0,$00,$C0,$C0,$C0,$00	; |
Char125: .db $E0,$30,$30,$1C,$30,$30,$E0,$00	; }
Char126: .db $76,$DC,$00,$00,$00,$00,$00,$00	; ~
Char127: .db $00,$10,$38,$6C,$C6,$C6,$FE,$00	; .
Char128: .db $7C,$C6,$C0,$C0,$C0,$D6,$7C,$30	; .
Char129: .db $C6,$00,$C6,$C6,$C6,$C6,$7E,$00	; .
Char130: .db $0E,$00,$7C,$C6,$FE,$C0,$7C,$00	; .
Char131: .db $7E,$81,$3C,$06,$7E,$C6,$7E,$00	; .
Char132: .db $66,$00,$7C,$06,$7E,$C6,$7E,$00	; .
Char133: .db $E0,$00,$7C,$06,$7E,$C6,$7E,$00	; .
Char134: .db $18,$18,$7C,$06,$7E,$C6,$7E,$00	; .
Char135: .db $00,$00,$7C,$C6,$C0,$D6,$7C,$30	; .
Char136: .db $7E,$81,$7C,$C6,$FE,$C0,$7C,$00	; .
Char137: .db $66,$00,$7C,$C6,$FE,$C0,$7C,$00	; .
Char138: .db $E0,$00,$7C,$C6,$FE,$C0,$7C,$00	; .
Char139: .db $66,$00,$38,$18,$18,$18,$3C,$00	; .
Char140: .db $7C,$82,$38,$18,$18,$18,$3C,$00	; .
Char141: .db $70,$00,$38,$18,$18,$18,$3C,$00	; .
Char142: .db $C6,$10,$7C,$C6,$FE,$C6,$C6,$00	; .
Char143: .db $38,$38,$00,$7C,$C6,$FE,$C6,$00	; .
Char144: .db $0E,$00,$FE,$C0,$F8,$C0,$FE,$00	; .
Char145: .db $00,$00,$7F,$0C,$7F,$CC,$7F,$00	; .
Char146: .db $3F,$6C,$CC,$FF,$CC,$CC,$CF,$00	; .
Char147: .db $7C,$82,$7C,$C6,$C6,$C6,$7C,$00	; .
Char148: .db $66,$00,$7C,$C6,$C6,$C6,$7C,$00	; .
Char149: .db $E0,$00,$7C,$C6,$C6,$C6,$7C,$00	; .
Char150: .db $7C,$82,$00,$C6,$C6,$C6,$7E,$00	; .
Char151: .db $E0,$00,$C6,$C6,$C6,$C6,$7E,$00	; .
Char152: .db $66,$00,$66,$66,$66,$3E,$06,$7C	; .
Char153: .db $C6,$7C,$C6,$C6,$C6,$C6,$7C,$00	; .
Char154: .db $C6,$00,$C6,$C6,$C6,$C6,$FE,$00	; .
Char155: .db $18,$18,$7E,$D8,$D8,$D8,$7E,$18	; .
Char156: .db $38,$6C,$60,$F0,$60,$66,$FC,$00	; .
Char157: .db $66,$66,$3C,$18,$7E,$18,$7E,$18	; .
Char158: .db $F8,$CC,$CC,$FA,$C6,$CF,$C6,$C3	; .
Char159: .db $0E,$1B,$18,$3C,$18,$18,$D8,$70	; .
Char160: .db $0E,$00,$7C,$06,$7E,$C6,$7E,$00	; .
Char161: .db $1C,$00,$38,$18,$18,$18,$3C,$00	; .
Char162: .db $0E,$00,$7C,$C6,$C6,$C6,$7C,$00	; .
Char163: .db $0E,$00,$C6,$C6,$C6,$C6,$7E,$00	; .
Char164: .db $00,$FE,$00,$FC,$C6,$C6,$C6,$00	; .
Char165: .db $FE,$00,$C6,$E6,$F6,$DE,$CE,$00	; .
Char166: .db $3C,$6C,$6C,$3E,$00,$7E,$00,$00	; .
Char167: .db $3C,$66,$66,$3C,$00,$7E,$00,$00	; .
Char168: .db $18,$00,$18,$18,$30,$66,$3C,$00	; .
Char169: .db $00,$00,$00,$FC,$C0,$C0,$00,$00	; .
Char170: .db $00,$00,$00,$FC,$0C,$0C,$00,$00	; .
Char171: .db $C6,$CC,$D8,$3F,$63,$CF,$8C,$0F	; .
Char172: .db $C3,$C6,$CC,$DB,$37,$6D,$CF,$03	; .
Char173: .db $18,$00,$18,$18,$18,$18,$18,$00	; .
Char174: .db $00,$33,$66,$CC,$66,$33,$00,$00	; .
Char175: .db $00,$CC,$66,$33,$66,$CC,$00,$00	; .
Char176: .db $22,$88,$22,$88,$22,$88,$22,$88	; .
Char177: .db $55,$AA,$55,$AA,$55,$AA,$55,$AA	; .
Char178: .db $DD,$77,$DD,$77,$DD,$77,$DD,$77	; .
Char179: .db $18,$18,$18,$18,$18,$18,$18,$18	; .
Char180: .db $18,$18,$18,$18,$F8,$18,$18,$18	; .
Char181: .db $18,$18,$F8,$18,$F8,$18,$18,$18	; .
Char182: .db $36,$36,$36,$36,$F6,$36,$36,$36	; .
Char183: .db $00,$00,$00,$00,$FE,$36,$36,$36	; .
Char184: .db $00,$00,$F8,$18,$F8,$18,$18,$18	; .
Char185: .db $36,$36,$F6,$06,$F6,$36,$36,$36	; .
Char186: .db $36,$36,$36,$36,$36,$36,$36,$36	; .
Char187: .db $00,$00,$FE,$06,$F6,$36,$36,$36	; .
Char188: .db $36,$36,$F6,$06,$FE,$00,$00,$00	; .
Char189: .db $36,$36,$36,$36,$FE,$00,$00,$00	; .
Char190: .db $18,$18,$F8,$18,$F8,$00,$00,$00	; .
Char191: .db $00,$00,$00,$00,$F8,$18,$18,$18	; .
Char192: .db $18,$18,$18,$18,$1F,$00,$00,$00	; .
Char193: .db $18,$18,$18,$18,$FF,$00,$00,$00	; .
Char194: .db $00,$00,$00,$00,$FF,$18,$18,$18	; .
Char195: .db $18,$18,$18,$18,$1F,$18,$18,$18	; .
Char196: .db $00,$00,$00,$00,$FF,$00,$00,$00	; .
Char197: .db $18,$18,$18,$18,$FF,$18,$18,$18	; .
Char198: .db $18,$18,$1F,$18,$1F,$18,$18,$18	; .
Char199: .db $36,$36,$36,$36,$37,$36,$36,$36	; .
Char200: .db $36,$36,$37,$30,$3F,$00,$00,$00	; .
Char201: .db $00,$00,$3F,$30,$37,$36,$36,$36	; .
Char202: .db $36,$36,$F7,$00,$FF,$00,$00,$00	; .
Char203: .db $00,$00,$FF,$00,$F7,$36,$36,$36	; .
Char204: .db $36,$36,$37,$30,$37,$36,$36,$36	; .
Char205: .db $00,$00,$FF,$00,$FF,$00,$00,$00	; .
Char206: .db $36,$36,$F7,$00,$F7,$36,$36,$36	; .
Char207: .db $18,$18,$FF,$00,$FF,$00,$00,$00	; .
Char208: .db $36,$36,$36,$36,$FF,$00,$00,$00	; .
Char209: .db $00,$00,$FF,$00,$FF,$18,$18,$18	; .
Char210: .db $00,$00,$00,$00,$FF,$36,$36,$36	; .
Char211: .db $36,$36,$36,$36,$3F,$00,$00,$00	; .
Char212: .db $18,$18,$1F,$18,$1F,$00,$00,$00	; .
Char213: .db $00,$00,$1F,$18,$1F,$18,$18,$18	; .
Char214: .db $00,$00,$00,$00,$3F,$36,$36,$36	; .
Char215: .db $36,$36,$36,$36,$FF,$36,$36,$36	; .
Char216: .db $18,$18,$FF,$18,$FF,$18,$18,$18	; .
Char217: .db $18,$18,$18,$18,$F8,$00,$00,$00	; .
Char218: .db $00,$00,$00,$00,$1F,$18,$18,$18	; .
Char219: .db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF	; .
Char220: .db $00,$00,$00,$00,$FF,$FF,$FF,$FF	; .
Char221: .db $F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0	; .
Char222: .db $0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F	; .
Char223: .db $FF,$FF,$FF,$FF,$00,$00,$00,$00	; .
Char224: .db $00,$00,$76,$DC,$C8,$DC,$76,$00	; .
Char225: .db $38,$6C,$6C,$78,$6C,$66,$6C,$60	; .
Char226: .db $00,$FE,$C6,$C0,$C0,$C0,$C0,$00	; .
Char227: .db $00,$00,$FE,$6C,$6C,$6C,$6C,$00	; .
Char228: .db $FE,$60,$30,$18,$30,$60,$FE,$00	; .
Char229: .db $00,$00,$7E,$D8,$D8,$D8,$70,$00	; .
Char230: .db $00,$66,$66,$66,$66,$7C,$60,$C0	; .
Char231: .db $00,$76,$DC,$18,$18,$18,$18,$00	; .
Char232: .db $7E,$18,$3C,$66,$66,$3C,$18,$7E	; .
Char233: .db $3C,$66,$C3,$FF,$C3,$66,$3C,$00	; .
Char234: .db $3C,$66,$C3,$C3,$66,$66,$E7,$00	; .
Char235: .db $0E,$18,$0C,$7E,$C6,$C6,$7C,$00	; .
Char236: .db $00,$00,$7E,$DB,$DB,$7E,$00,$00	; .
Char237: .db $06,$0C,$7E,$DB,$DB,$7E,$60,$C0	; .
Char238: .db $38,$60,$C0,$F8,$C0,$60,$38,$00	; .
Char239: .db $78,$CC,$CC,$CC,$CC,$CC,$CC,$00	; .
Char240: .db $00,$7E,$00,$7E,$00,$7E,$00,$00	; .
Char241: .db $18,$18,$7E,$18,$18,$00,$7E,$00	; .
Char242: .db $60,$30,$18,$30,$60,$00,$FC,$00	; .
Char243: .db $18,$30,$60,$30,$18,$00,$FC,$00	; .
Char244: .db $0E,$1B,$1B,$18,$18,$18,$18,$18	; .
Char245: .db $18,$18,$18,$18,$18,$D8,$D8,$70	; .
Char246: .db $18,$18,$00,$7E,$00,$18,$18,$00	; .
Char247: .db $00,$76,$DC,$00,$76,$DC,$00,$00	; .
Char248: .db $38,$6C,$6C,$38,$00,$00,$00,$00	; .
Char249: .db $00,$00,$00,$18,$18,$00,$00,$00	; .
Char250: .db $00,$00,$00,$00,$18,$00,$00,$00	; .
Char251: .db $0F,$0C,$0C,$0C,$EC,$6C,$3C,$1C	; .
Char252: .db $78,$6C,$6C,$6C,$6C,$00,$00,$00	; .
Char253: .db $7C,$0C,$7C,$60,$7C,$00,$00,$00	; .
Char254: .db $00,$00,$3C,$3C,$3C,$3C,$00,$00	; .
Char255: .db $00,$10,$00,$00,$00,$00,$00,$00	; NULL