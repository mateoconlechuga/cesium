;here's what needs to be done:
;(1) create BASIC prgm that says Asm(prgmCESIUM <-- Call it 'A'; just like Ion so that way users don't have to scroll to find the program
;(2) copy this program to an AppVar and archive it
;(3) delete this program
;(3) create an ASM prgm loader called CESIUM
;(4) this loader will be called by the BASIC prgm
;(5) it will copy the AppVar from the archive, and run it, making sure to skip all of these orignial steps.
; we are .orged at usermem-2 here

 .db texttok,tasm84cecmp
 di					; disable interrupts
 call _runindicoff 			; turn off the indicator
 call _chkfindsym
 call _delvararc			; delete ourselves

 ld hl,CesiumAppVarName_Install
 call _mov9toop1
 call _pushop1
  call _pushop1
   call _chkfindsym
   call nc,_delvararc			; delete the appvar if it already exists
  call _popop1
  ld hl,CesiumEnd-CesiumStart
  push hl
   call _createappvar
  pop bc
  inc de
  inc de
  ld hl,CesiumStartLoc
  ldir					; copy the copied verion to an AppVar
 call _popop1
 call _arc_unarc			; archive it
 ld hl,CesiumPrgmName_Install
 call _mov9toop1
 ld hl,InstallerEnd-InstallerStart
 push hl
  call _createprotprog			; create the launched of the launcher program
 pop bc
 inc de
 inc de
 ld hl,InstallerStart
 ldir					; copy the launcher section to the program
 call _homeup
 call _clrlcd
 ld hl,CesiumInstalledStr
 call _puts
 call _newline
 res donePrgm,(iy+doneFlags)
 ret
CesiumAppVarName_Install:
 .db appVarObj,"CeOS",0
CesiumPrgmName_Install:
 .db protprogObj,"CESIUM",0
CesiumInstalledStr:
 .db "Cesium "
#ifdef ENGLISH
 .db "Installed."
 #else
 .db "Install",$96
#endif
 .db 0
 
InstallerStart:

relocateNest(usermem-2)
 .db texttok,tasm84cecmp						; ASM prgm
INSTALLER_START:
 ld hl,LoaderOfLoader_Start
 ld bc,LoaderOfLoader_End-LoaderOfLoader_Start
 ld de,cmdpixelshadow
 ldir					; copy the loader routine to safeRAM
INSTALLER_ARC:
 ld hl,CesiumAppVarName_Installer
 call _mov9toop1
 call _chkfindsym
 ;ret c					; return if we can't find it
 call _chkinram
 push af
  call z,_arc_unarc
 pop af
 jr z,INSTALLER_ARC
 ex de,hl
 ld de,3+6
 add hl,de				; skip VAT stuff
 ld e,(hl)
 add hl,de
 inc hl					; size of name
 call _loaddeind_s			; now we are looking at size bytes :)
 ld a,(hl)				; $CE
 inc hl
 cp (hl)				; $CE
 ret nz					; magic byte check complete :)
 ld de,CommonRoutines_Start-CesiumStart-1
 push hl
  add hl,de				; now we are looking at the common routines
  ld de,savesscreen
  ld bc,CommonRoutines_End-CommonRoutines_Start
  ldir					; copy the common routines to safeRAM
 pop hl
 ld de,ParserHook-CesiumStart-1
 add hl,de
 call _setparserhook
 jp cmdpixelshadow
LoaderOfLoader_Start:
relocate(cmdpixelshadow)
 call DeletePgrmFromUserMem		; delete the loader from UserMem
 ld hl,CesiumAppVarName_Installer
 call _mov9toop1
 call MovePgrmToUserMem			; copy the AppVar to UserMem
 jp userMem
CesiumAppVarName_Installer:
 .db appVarObj,"CeOS",0
endrelocate()
endrelocateNest()

LoaderOfLoader_End:

InstallerEnd: