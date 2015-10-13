;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Search for first program with the first char in A
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SearchAlphab:
 ld hl,CharTableNormal
 call _addhlanda		; find the offset
 ld a,(hl)
 or a,a
 jp z,GetKeys
 ld (SearchChar),a
 xor a,a \ sbc hl,hl
 ld (currSel),a
 ld (currSelAbs),hl
 ld (scrollamt),hl
 ld hl,pixelshadow2
 ld bc,(programCnt)		; loop through the prgms
FindAlpha:
 ld de,(hl)			; pointer to program name size
 dec de
 ld a,(de)
SearchChar: =$+1
 cp 0
 jr nc,foundit
 push hl
  call getNextPrgm
 pop hl
 inc hl
 inc hl
 inc hl
 inc hl
 dec b
 ld a,b
 or c
 jr nz,FindAlpha
foundit:
 jp MAIN_START_LOOP
 
CharTableNormal:
 .db 0,"WRMH",0,0   		; + - × ÷ ^ undefined
 .db 0,0,"VQLG",0,0 	; (-) 3 6 9 ) TAN VARS undefined
 .db 0,"ZUPKFC",0   		; . 2 5 8 ( COS PRGM STAT
 .db " YTOJEB",0,0		; 0 1 4 7 , SIN APPS XT?n undefined
 .db "XSNIDA"			; STO LN LOG x2 x-1 MATH