;here's what needs to be done:
;(1) create BASIC prgm that says Asm(prgmCESIUM <-- Call it 'A'; just like Ion so that way users don't have to scroll to find the program
;(2) copy this program to an AppVar and archive it
;(3) delete this program
;(3) create an ASM prgm loader called CESIUM
;(4) this loader will be called by the BASIC prgm
;(5) it will copy the AppVar from the archive, and run it, making sure to skip all of these orignial steps.
; we are .orged at usermem-2 here

	.db tExtTok,tAsm84CECmp
	.org UserMem
	
	di					; disable interrupts
	call	_ChkFindSym
	call	_DelVarArc			; delete ourselves

	ld	hl,CesiumAppVarName_Install
	call	_Mov9ToOP1
	call	_PushOP1
	call	_PushOP1
	call	_ChkFindSym
	call	nc,_DelVarArc			; delete the appvar if it already exists
	call	_PopOP1
	ld	hl,CesiumEnd-CesiumStart
	push	hl
	call	_CreateAppVar
	pop	bc
	inc	de
	inc	de
	ld	hl,CesiumStartLoc
	ldir					; copy the copied verion to an AppVar
	call	_PopOP1
	call	_Arc_Unarc			; archive it
	ld	hl,CesiumPrgmName_Install
	call	_Mov9ToOP1
	ld	hl,InstallerEnd-InstallerStart
	push	hl
	call	_CreateProtProg			; create the launched of the launcher program
	pop	bc
	inc	de
	inc	de
	ld	hl,InstallerStart
	ldir					; copy the launcher section to the program
	call	_HomeUp
	call	_boot_ClearVRAM
	call	_DrawStatusBar
	ld	hl,CesiumInstalledStr
	call	_PutS
	call	_NewLine
	res	donePrgm,(iy+doneFlags)
	ret

CesiumAppVarName_Install:
	.db appVarObj,"CeOS",0
CesiumPrgmName_Install:
	.db	protProgObj,"CESIUM",0
CesiumInstalledStr:
	.db	"Cesium "
#ifdef ENGLISH
	.db	"Installed",0
#else
	.db	"Install",$96,0
#endif
 
InstallerStart:
relocate(usermem-2)
	.db tExtTok,tAsm84CECmp

_:	ld	hl,CesiumAppVarName_Installer
	call	_Mov9ToOP1
	call	_ChkFindSym
	ret	c				; return if we can't find it
	call	_ChkInRam
	push	af
	call	z,_Arc_Unarc
	pop	af
	jr	z,-_
	ex	de,hl
	ld	de,9
	add	hl,de				; skip VAT stuff
	ld	e,(hl)
	add	hl,de
	inc	hl				; size of name
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	inc	hl				; now we are looking at size bytes :)
	ld	a,(hl)				; $CE
	inc	hl
	cp	a,(hl)				; $CE
	ret	nz				; magic byte check complete :)
	inc	hl
	jp	(hl)
CesiumAppVarName_Installer:
	.db	appVarObj,"CeOS",0
endrelocate()

InstallerEnd: