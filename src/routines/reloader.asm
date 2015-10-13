;Reloader
;Reloads the shell after a program has finished running

cesiumReloader_Start:			
relocate(appdata)
cesiumReloader:

ReturnHereBASIC:
 call _poperrorhandler	 
 xor a,a
errcatch:
 push af
  call $020E9C				; _CleanAll
  call _DeleteTempPrograms
  res ProgExecuting,(IY+newDispf)
  res cmdExec,(IY+cmdFlags)
  res textInverse,(iy+textFlags)
  res allowProgTokens,(iy+newDispF)
  res onInterrupt,(iy+onFlags)
  res       6, (iy + $0C)
  ld hl,tmpPrgmName
  call _mov9toop1
  call _chkfindsym
  call nc,_delvararc
 pop af
 or a,a
 jr z,NoBASICError
 call _ClrLCDFull
 call _DispErrorScreen
 set textInverse, (iy + textFlags)
 ld hl,1
 ld (curRow),hl
 ld hl,QuitStr1
 call _PutS
 ld hl,QuitStr2
 res textInverse, (iy + textFlags)
 call _PutS
_Wait:
 call _getcsc
 cp skenter
 jr nz,_Wait
NoBASICError:
 call _RunIndicOff			; BASIC turns on the run indicator if the option is set
ReturnHere:				; handler for returning programs
 ld hl,CesiumAppVarName_2
 call _mov9toop1
 call _chkfindsym
 call _chkinram
 ex de,hl
 jr z,ExistsInRAM
 ld de,9
 add hl,de
 ld e,(hl)
 add hl,de
 inc hl
ExistsInRAM:				; HL->totalPrgmSize bytes
 inc hl
 inc hl					; HL->CESIUM PGRM DATA
 inc hl					; $CE
 inc hl					; $CE
 ld de,CommonRoutines_Start-CesiumStart-2
 add hl,de
 ld de,savesscreen
 ld bc,CommonRoutines_End-CommonRoutines_Start
 ldir
 jp RELOAD_CESIUM

MoveCommonToSafeRAM:
 ld hl,CommonRoutines_Start
MoveCommonToSafeRAM2:
 ld de,savesscreen
 ld bc,CommonRoutines_End-CommonRoutines_Start
 ldir
 ret
 
CesiumAppVarName_2:
 .db appVarObj,"CeOS",0
CesiumPrgmName:
 .db protprogObj,"CESIUM",0
QuitStr1:
 .db "1:",0
QuitStr2:
 .db "Quit",0
endrelocate()
cesiumReLoader_End: