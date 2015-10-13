CreateBASICprgm:				; Create a BASIC prgm called 'A'
 ld hl,Aname
 call _mov9toop1				; move to name to OP1
 call _chkfindsym				; try to find it
 call nc,_delvararc				; delete it if it exists (sorry user)
 ld hl,Aend-Astart
 push hl
  call _createprotprog
 pop bc
 inc de
 inc de						; bypass size bytes
 ld hl,Astart
 ldir						; copy in the data
 ret						; return
 
Aname:	.db 6,"A",0
Astart:
	.db $BB,$6A,"_CESIUM"		; Asm(prgmCESIUM	; nothing after, because TIOS is really good about BASIC cleanup. so we just get to sit and watch :)
Aend: