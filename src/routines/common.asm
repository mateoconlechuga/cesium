;These are shared routines that are used by many parts of the program

CommonRoutines_Start:
relocate(SaveSScreen)
CommonRoutines:

NamePtrToOP1:
	ld	hl,(hl)
	push	hl				; VAT pointer
	ld	de,6
	add	hl,de
	ld	a,(hl)				; Get the type byte
	pop	hl
	ld	de,OP1				; store to OP1
	ld	(de),a
	inc	de
	ld	b,(hl)
	dec	hl
_:	ld	a,(hl)
	ld	(de),a
	inc	de
	dec	hl
	djnz	-_
	xor	a,a
	ld	(de),a				; terminate the string
	ret
 
RELOAD_CESIUM:					; reload the shell after execution
	di					; in case the launched program enabled interrupts... (fixes GitHub #1)
	res	ProgExecuting,(iy+newDispf)
	res	cmdExec,(iy+cmdFlags)
	res	textInverse,(iy+textFlags)
	res	allowProgTokens,(iy+newDispF)
	res	onInterrupt,(iy+onFlags)
	call	DeletePgrmFromUserMem		; shouldn't do anything if reloading from a basic prgm
	call	DeleteTempProgramGetName	; delete the basic temp program
	call	_DeleteTempPrograms
	call	_CleanAll
	call	_RunIndicOff
	ld	hl,CesiumAppVarNameReloader	; because TI was nice when they made the _delmem routine.
	call	_Mov9ToOP1			
	call	MovePgrmToUserMem
	xor	a,a 
	ld	(kbdGetKy),a			; flush keys
	call	_RunIndicOff			; in case the launched program re-enabled it
	ei
	jp	RELOADED_FROM_PRGM
 
ArchiveCesium:					; archive function
	ld	hl,CesiumPrgmName
	call	_Mov9ToOP1
	call	_ChkFindSym
	call	_ChkInRam
	jp	z,_Arc_Unarc			; archive the program when running so we don't get deleted
	ret

DeletePgrmFromUserMem:
	ld	de,(asm_prgm_size)		; load total program totalPrgmSize
	or	a,a
	sbc	hl,hl
	ld	(asm_prgm_size),hl		; delete whatever current program was there
	ld	hl,userMem
	jp	_DelMem				; HL->place to delete, DE=amount to delete
 
MovePgrmToUserMem:
	ld	a,09h				; 'add hl,bc'
	ld	(offset_SMC),a
	call	_ChkFindSym
	call	_ChkInRam
	ex	de,hl
	jr	z,AlreadyInRAM
	xor	a,a
	ld	(offset_SMC),a
	ld	de,9
	add	hl,de
	ld	e,(hl)
	add	hl,de
	inc	hl
AlreadyInRAM:					; HL->totalPrgmSize bytes
	call	_LoadDEInd_s
	inc	hl
	inc	hl				; bypass bytes $EF,$7B (texttok,tasm84cecmp)
	push	hl
	push	de
	ex	de,hl
	call	_ErrNotEnoughMem		; check and see if we have enough memory left for this operation
	pop	hl
	ld	(asm_prgm_size),hl		; store the totalPrgmSize of the program to asm_prgm_size for later use
	ld	de,userMem
	push	de
	call	_InsertMem			; insert memory into the userspace
	pop	de
	pop	hl				; HL->start of program
	ld	bc,(asm_prgm_size)		; load totalPrgmSize of current program
offset_SMC:
	add	hl,bc				; if in ram, do this; otherwise, smc it so it doesn't execute
	ldir					; copy the program to userMem
	ret					; return

DeleteTempProgramGetName:
	ld	hl,tmpPrgmName
	call	_Mov9ToOP1
	call	_PushOP1
	call	_ChkFindSym
	call	nc,_DelVarArc			; delete the temp prgm if it exists
	jp	_PopOP1
	
tmpPrgmName:
	.db	tempProgObj,"ZTGP",0
CesiumPrgmName:
	.db	protProgObj,"CESIUM",0
endrelocate()
CommonRoutines_End:
