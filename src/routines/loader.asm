cesiumLoader_Start:
relocate(cmdpixelshadow)
cesiumLoader:

 call DeletePgrmFromUserMem		; now we deleted ourselves. cool.
 call ArchiveCesium			; archive ourselves to perserve space when running other things
 
 ld hl,vBuf1
 ld a,$FF
 ld bc,320*240*2			; clear out the screen
 call _MemSet
 ld a,$2D
 ld (mpLcdCtrl),a			; Set LCD to 16bpp
 ld hl,(prgmNamePtr)
 call NamePtrToOP1
 ld (errorSP),sp
 bit isBasic,(iy+pgrmStatus)
 jp nz,RunBasicProgram
 call MovePgrmToUserMem			; the program is now stored at userMem -- Now we need to check and see what kind of file it is - C or assembly
 
 ld hl,libraryLocations
 ld (currLibPtr),hl
 ld hl,userMem
 ld a,(hl)
 inc hl
 cp $C9					; magic return byte
 jp nz,RegularAsm
 ld a,(hl)
 inc hl
 cp CESIUM_BYTE				; is it a C program?
 jp nz,RegularAsm
 ld a,(hl)
 inc hl
 cp CESIUM_VERSION+1			; make sure it is a compatible program
 jp nc,ReturnHere
CPgrm:					; okay, it is a C program, so treat it accordinlly
 ld a,(hl)				; HL->maybe LIB_BYTE -- If the C program is including libs
 cp LIBRARY_BYTE			; is there a library we have to extract and manipulte?
 jp nz,NoLibrariesCPgrm			; if not, just run it from here
 res relocDependentLib,(iy+asmFlag)
CSharedLibPgrm:				; okay, now we should be looking at the name of a null-terminated library, with the $CE byte info
currLibPtr: =$+1			; HL->$CE,"SAMPlELIB",0
 ld de,0				; going to just trash the op variables for free ram
 push hl				; hl->NULL terminated string
  push hl
   ld (hl),appvarobj			; change $CE byte to mark as extracted -- win win
   call _mov9toop1			; move name of library to op1
  pop hl
  inc hl
  res previouslyExtracted,(iy+asmFlag)
  call CheckIfLibHasBeenExtracted	; check and see if we have previously extracted this library
  jr nz,HasntBeenExtractedYet		; z flag set if library has been previously extracted -- we just need to fixup entry points
  ld de,(hl)				; DE=location of extracted library in RAM
  inc hl
  inc hl
  inc hl
  ld (RAMLibPtr),de			; store to RAMLibPtr
  ld de,(hl)				; DE->vector table totalPrgmSize for this library, followed by the vector table itself
  ld (vectorTblSizePtr),de
  set previouslyExtracted,(iy+asmFlag)	; set the flag that this library was previously extracted, so we don't resolve absolutes
 pop hl					; restore pointer to library name
 ld bc,0
 ld a,c
 cpir					; move to end of library name
 inc hl					; i think this is the verison byte
 push hl				; save the pointer
  jp ResolveEntryPointsExtracted	; only need to resolve the entry points for this library
HasntBeenExtractedYet:
  call _mov8b				; copy the string. It shouldn't be bigger than that!
  xor a
  ld (de),a
  inc de
  ld (currLibPtr),de			; Now we are looking after the null byte -- I'm going to store the location of the library right after this for later resolution
 pop hl
 ld bc,0
 ld a,c
 cpir
 push hl				; save the location in the C program we are on
RetrySearch:
  call _chkfindsym
  jp c,LibNotFound			; throw an error if the library doesn't exist
  call _chkinram
  ex de,hl
  jp nz,LibFoundInArc			; if the library is found in ram, quit because that scares me
  call _pushop1
  call _arc_unarc
  call _popop1
  jr RetrySearch
LibFoundInArc:
  ld de,9
  add hl,de
  ld e,(hl)
  add hl,de
  inc hl				; HL->totalPrgmSize bytes
  call _LoadDEInd_s
  push de
  pop bc
  dec bc
  dec bc
  ld a,(hl)				; $CE
  inc hl
  cp (hl)				; $CE - Magic number checks
  jp nz,LibNotFound			; throw an error if the library doesn't match the magic numbers
  ex de,hl
  inc de
 pop hl
 ld (libSize),bc			; need to -4-relocation table off for relocation table totalPrgmSize bytes+version
 ld a,(de)				; A=on-calc lib version
 cp (hl)				; check if library version in program is greater than library version on-calc
 jp c,ErrorLib				; c flag set if on-calc lib version is less than the one used in the program
 inc hl					; now, HL->dependencies for program, 00h if none
 push hl				; if we made it here, that means the library exists and the versions match. HL->Cprgm, DE->library relocation data
  ex de,hl
  push hl				; HL->Version
   inc hl				; Bypass version byte
   ld (relocationTblSizePtr),hl
   ld bc,(hl)
   call BCTimes3
   inc hl
   inc hl
   inc hl				; HL->start of relocation table
   add hl,bc				; HL->number of library functions
   ld bc,(hl)				; BC=number of library functions
   call BCTimes3
   ld (vectorTblSizePtr),hl
   inc hl	
   inc hl
   inc hl
   ld (vectorTblPtr),hl			; Add the size of the vector table
   add hl,bc				; HL->start of dependencies
  pop de
  push hl
   or a,a \ sbc hl,de			; subtract offset, HL=size to subract from libsize
   ld (excessLibSize),hl		;
   ex de,hl
   ld hl,(libSize)			; load old size
   or a,a \ sbc hl,de
   ld (libSize),hl			; store the size of the library
   push hl
    call _ErrNotEnoughMem		; HL=size of library
    ld hl,userMem
    ld de,(asm_prgm_size)
    add hl,de				; HL->end of C program+libaries
    ld (RAMLibPtr),hl
    ex de,hl
   pop hl
   call _InsertMem			; insert memory for the library
   ld hl,(libSize)
   ld de,(asm_prgm_size)
   add hl,de
   ld (asm_prgm_size),hl		; store new size of program
  pop hl				; HL->start of dependencies
  ld de,(RAMLibPtr)			; DE->insertion place
libSize: =$+1
  ld bc,0				; BC=lib size
  ldir					; copy in the library to ram
ResolveEntryPointsExtracted:
vectorTblSizePtr: =$+1
  ld hl,0				; BC=#VECTORS
  ld bc,(hl)
 pop hl					; HL->C program version
ResolveEntryPoints:
 inc hl					; bypass jump byte ($C3)
 push hl
  ld de,(hl)				; offset in vector table
  push hl
vectorTblPtr: =$+1
   ld hl,0				; HL->start of vector table
   add hl,de				; HL->correct vector entry
   ld de,(hl)				; DE=offest in lib for function
  pop hl
  ld hl,(RAMLibPtr)
  add hl,de				; add the location of the library to the offset bytes for the function
  ex de,hl				; DE<->HL
 pop hl
 ld (hl),de				; resolved address :)
 inc hl
 inc hl
 inc hl					; move to next jump (or whatever is there)
 dec bc
 ld a,b
 or c
 jr nz,ResolveEntryPoints

 ld (NextLibPtr),hl	
 bit previouslyExtracted,(iy+asmFlag)	; have we already resolved the absolute addresses for this library?
 jp nz,DontRelocateAbsolutes
					; save it for now; we have to relocate the current library
 					; okay, so I need to store the location of the vector table and the location the the library in RAM
					; for later resolution
 ld hl,(currLibPtr)
 ld de,(RAMLibPtr) 
 ld (hl),de				; store the location of the library in RAM
 inc hl					; bypass
 inc hl
 inc hl
 ld de,(vectorTblSizePtr)		; get the location of the vector table totalPrgmSize vectorTblSizePtr+3->VECTOR TABLE
 ld (hl),de
 inc hl					; bypass
 inc hl
 inc hl
 ld (currLibPtr),hl			; store it as a pointer
relocationTblSizePtr: =$+1
 ld hl,0				; HL->relocation table totalPrgmSize
 ld bc,(hl)				; BC=total totalPrgmSize of relocation table (a.k.a. relocation table totalPrgmSize bytes)
relocateAbsolutes
 inc hl
 inc hl
 inc hl
 ld de,(RAMLibPtr)			; okay, so whatever the offset is from here,  we much relocate it
 push hl
  push bc
   ld hl,(hl)
   add hl,de				; okay, now we are looking at the right 'stuff'	--- HL->$C3,$CD, etc...
   ;inc hl
   push hl
    ld hl,(hl)				; hl->offset
excessLibSize: =$+1
    ld de,0
    or a,a \ sbc hl,de			; offset needs to be recomputed
    inc hl
    inc hl
    inc hl
    inc hl
    ld de,(RAMLibPtr)
    add hl,de				; absolute offset+RAMLibPtr	
    ex de,hl				; HL<->DE
   pop hl
   ld (hl),de				; store relocate
  pop bc
  dec bc
  sbc hl,hl
  adc hl,bc
 pop hl
 jr nz,relocateAbsolutes
DontRelocateAbsolutes:
 					; okay, now the entire library should be realocated and entry points are taken care of
RAMLibPtr: =$+1				; now we need to find the dependent libraries that a library may be using
 ld hl,0				; Now relocate the dependencies
 ld a,(hl)				; The first byte of this pointer will be the number of dependencies
 or a,a					; reload previous pointers and values
 jr z,NoDependencies

 inc hl
 ld de,(NextLibPtr)			; If we are here, we need to see what dependencies there are, and how we can extract them or check if they have been extracted
 push de
  set relocDependentLib,(iy+asmFlag)
  call CSharedLibPgrm			; HL->first string of dependency (I am insane for calling this function :P)
  res relocDependentLib,(iy+asmFlag)
 pop hl
 ld (NextLibPtr),hl
NoDependencies:
 bit relocDependentLib,(iy+asmFlag)
 ret nz

NextLibPtr: =$+1
 ld hl,0
 ld a,(hl)				; HL->maybe LIB_BYTE -- If the C program is including libs
 cp LIBRARY_BYTE
 jp z,CSharedLibPgrm			; there's another library we have to extract now :)
CPgrmWithLibs:
RunProgram:
 ld de,ReturnHere
 push de
  jp (hl)
NoLibrariesCPgrm:
 ld hl,userMem+3			; bypass the bytes signifying a C prgm
 jr RunProgram
LibNotFound:				; can't find a dependent lib
 ld hl,LibStr
ThrowError:				; draw the error message onscreen
 ld sp,(errorSP)
 push hl
  call _homeup
  call _drawstatusbar
  set textInverse,(iy+textFlags)
 pop hl
 ld a,2
 ld (curcol),a
 call _puts
 res textInverse,(iy+textFlags)
 call _newline
 call _newline
 ld hl,LibNameStr
 call _puts
 ld hl,op1+1
 call _puts
 call _getkey
 jp ReturnHere
ErrorLib:				; we had an error: verison
 jr ThrowError
RegularAsm:
 ld hl,userMem				; simply call userMem to execute the assembly program
 jr RunProgram
RunBasicProgram:
 call _DrawStatusBar
 call _Runindicon
 ld a,(OnBreak)
 or a,a
 call nz,_Runindicoff
 ld a,(arcStatus)
 or a,a
 jr z,GoodInRAM
 ld hl,tmpPrgmName
 call _mov9toop1
 call _PushOP1
  call _chkfindsym
  call nc,_delvararc			; delete the temp prgm if it exists
 call _PopOP1
 ld hl,(actualSizePrgm)
 push hl
  call _createprotprog			; create a temp program so we can execute
  inc de
  inc de
 pop bc
 call _ChkBCIs0
 jr z,InROM				; there's nothing to copy
 ld hl,(prgmDataPtr)
 ldi
 call _ChkBCIs0
 jr z,InROM				; this way ldir doesn't throw a fit
 ldir
InROM:
 call _op4toop1
GoodInRAM:
 set graphdraw,(iy+graphFlags)
 ld hl,errcatch
 call _PushErrorHandler
  set ProgExecuting,(iy+newdispf)
  set allowProgTokens,(iy+newDispF)
  set cmdExec,(iy+cmdFlags) 		; set these flags to execute BASIC prgm
  res onInterrupt,(iy+onflags)
  ld hl,ReturnHereBASIC
  push hl
   xor a,a
   ld (kbdGetKy),a
   ei
   jp _parseinp				; run program 

CheckIfLibHasBeenExtracted:
 ld de,libraryLocations			; DE->place to start search, HL->name to search for
CheckLibLoop:
 push hl
  push de
   ld b,9				; maximum totalPrgmSize of the name of a library
SearchLoopStr:
   ld a,(de)
   cp (hl)
   jr nz,noMatch
   inc hl
   inc de
   or a					; means we've reached the end of the string
   jr z,match
   jr SearchLoopStr
noMatch:
  pop hl
  ld de,15
  add hl,de
  ex de,hl
  ld hl,(currLibPtr)
  call _cphlde
 pop hl
 jr nc,CheckLibLoop
 xor a
 inc a
 ret
match:
  pop hl
  ld de,9
  add hl,de
 pop de					; HL->location of library in RAM, HL+3->library's vector table, DE->string of library found
 xor a
 ret
 
BCTimes3:				; multiply the value in BC by 3
 push hl
  or a,a
  sbc hl,hl
  add hl,bc
  add hl,bc
  add hl,bc
  ex (sp),hl
 pop bc
 ret
 
tmpPrgmName:
 .db protprogobj,"ZTGP",0
endrelocate()
CesiumLoader_End: