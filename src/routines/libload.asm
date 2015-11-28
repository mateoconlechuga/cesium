;=========================================================================
;  Copyright (C) 2015 Matt Waltz.  All rights reserved.
;
;  Redistribution and use in source and binary forms, with or without
;  modification, are permitted provided that the following conditions
;  are met:
;  1. Redistributions of source code must retain the above copyright
;     notice, this list of conditions and the following disclaimer.
;  2. Redistributions in binary form must reproduce the above
;     copyright notice, this list of conditions and the following
;     disclaimer in the documentation and/or other materials
;     provided with the distribution.
;
;  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
;  ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
;  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
;  A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL ANY
;  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
;  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
;  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
;  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
;  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
;  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
;  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
;=========================================================================
; Performs dynamic relocation for shared libraries and interdependencies
; inputs: de->start of library relocation table
; output: once relocation of program and library dependencies is complete,
;         jumps to start of program block after relocation block and begins execution
;	  note updated size is added to the copy in ram of the program for libraries
; notes:  all code is location independent; no need to relocate to absolute address.
;         keeping in archive is safe
;	  uses some saferam areas (see below)
;=========================================================================

; includes
;#include "ti84pce.inc"

; global equates
liblocations			.equ cmdpixelshadow

currlibptr			.equ cursorimage
nextlibptr			.equ currlibptr+3
reloctblsizeptr			.equ nextlibptr+3
ramptr				.equ reloctblsizeptr+3
vectortblsizeptr		.equ ramptr+3
libSize				.equ vectortblsizeptr+3
excesslibsize			.equ libSize+3
__saveSP			.equ excesslibsize+3
vectortblptr			.equ __saveSP+3
libloadloc			.equ vectortblptr+3

_versionlibstrloc		.equ libloadloc+3
_missinglibstrloc		.equ _versionlibstrloc+3
_libnamestrloc			.equ _missinglibstrloc+3

_errorversionloc		.equ _libnamestrloc+3
_errormissingloc		.equ _errorversionloc+3
_reslovextractedeentrypointsloc	.equ _errormissingloc+3
_extractnextlibloc		.equ _reslovextractedeentrypointsloc+3

; macro definitions
#define LIB_BYTE		$CE
#define asmflag			$22
#define relocdependent		$00
#define prevextracted		$01

;.org 0000

_libload:
 push de 
  push hl
   call _clrscrn			; clean up the screen a bit
   call _homeup
  pop hl
  
  ld (libloadloc),hl			; if we are comming here with a jp (hl), cool. if not, prepare for crash
  ld bc,_versionlibstr
  add hl,bc
  ld (_versionlibstrloc),hl
 
  ld hl,(libloadloc)
  ld bc,_missinglibstr
  add hl,bc
  ld (_missinglibstrloc),hl
 
  ld hl,(libloadloc)
  ld bc,_libnamestr
  add hl,bc
  ld (_libnamestrloc),hl
  
  ld hl,(libloadloc)
  ld bc,_versionerror
  add hl,bc
  ld (_errorversionloc),hl
 
  ld hl,(libloadloc)
  ld bc,_missingerror
  add hl,bc
  ld (_errormissingloc),hl
  
  ld hl,(libloadloc)
  ld bc,_reslovextractedeentrypoints
  add hl,bc
  ld (_reslovextractedeentrypointsloc),hl
 
  ld hl,(libloadloc)
  ld bc,_extractnextlib
  add hl,bc
  ld (_extractnextlibloc),hl
  
  ld iy,$D00080				; make sure iy is correct
  ld hl,liblocations
  ld (currlibptr),hl
 pop hl					; hl->start of library relocation table
 ld (__saveSP),sp			; save the stack pointer
 
 res relocdependent,(iy+asmflag)
 ld a,(hl)				; hl->maybe LIB_BYTE -- If the program is including libs
 cp LIB_BYTE				; is there a library we have to extract and manipulte?
 jr z,_extractlib			; if not, just run it from wherever de was pointing
 jp (hl)				; return to execution if there are no libs
_extractnextlib:
 ex de,hl				; since hl is being used to jump here, use de to store hl temporarily
_extractlib:				; okay, now we should be looking at the name of a null-terminated library, with the $CE byte info
 push hl				; hl->NULL terminated libray name string :: $CE,"LIBNAME",0
  push hl
   ld (hl),appvarobj			; change $CE byte to mark as extracted -- win win
   call _mov9toop1			; move name of library to op1
  pop hl
  inc hl
  res prevextracted,(iy+asmflag)

_isextracted:				; check if the next lib has already been extracted before
 ld de,liblocations			; de->place to start search, hl->name to search for
_checkextractedloop:
 push hl
  push de
_searchextractedtbl:
   ld a,(de)
   cp (hl)
   jr nz,_nomatch
   inc hl
   inc de
   or a,a				; means we've reached the end of the string
   jr z,_match
   jr _searchextractedtbl
_nomatch:
  pop hl
  ld de,15
  add hl,de
  ex de,hl
  ld hl,(currlibptr)
  call _cphlde
 pop hl
 jr nc,_checkextractedloop
 jr _notextracted			; hasn't been extracted yet
_match:
  pop hl
  ld de,9
  add hl,de
 pop de					; hl->location of library in ram, hl+3->library's vector table, de->string of library found
_donesearch:

  ld de,(hl)				; de->location of library in ram
  ld (ramptr),de
  inc hl
  inc hl
  inc hl				; de->vector table size for this library, followed by the vector table itself
  ld de,(hl)
  ld (vectortblsizeptr),de
  ld de,0
  ld (vectortblptr),de
  set prevextracted,(iy+asmflag)	; set the flag that this library was previously extracted, so we don't resolve absolutes
 pop hl					; restore pointer to library name
 ld bc,0
 ld a,c
 cpir					; move to end of library name
 inc hl					; bypass version byte
 push hl				; save the pointer
  ld hl,(_reslovextractedeentrypointsloc)
  jp (hl)				; only need to resolve the entry points for this library
_notextracted:
  call _mov8b				; copy the string. it shouldn't be bigger than this
  xor a
  ld (de),a
  inc de
  ld (currlibptr),de			; now we are looking after the null byte -- I'm going to store the location of the library right after this for later resolution
 pop hl
 
 ld bc,0
 cpir					; a=0 from the xor above already
 push hl				; save the location in the program we are on
_findbinary:
  call _chkfindsym
  jr nc,_foundlibrary			; throw an error if the library doesn't exist
  ld hl,(_errormissingloc)
  jp (hl)
_foundlibrary:
  call _chkinram
  jr nz,_libinarc			; if the library is found in ram, archive the library and search again
  call _pushop1
   call _arc_unarc
  call _popop1
  jr _findbinary
_libinarc:
  ex de,hl
  ld de,9
  add hl,de
  ld e,(hl)
  add hl,de
  inc hl				; hl->size bytes
  call _loaddeind_s
  push de
  pop bc
  dec bc
  dec bc
  ld a,(hl)				; $CE
  inc hl
  cp (hl)				; $CE - Magic number checks
  jr z,_libexists			; throw an error if the library doesn't match the magic numbers
  ld hl,(_errormissingloc)
  jp (hl)
_libexists:
  ex de,hl
  inc de
 pop hl
 ld (libsize),bc			; need to -4-relocation table off for relocation table size bytes+version
 ld a,(de)				; A=on-calc lib version
 cp (hl)				; check if library version in program is greater than library version on-calc
 jr c,_vers				; c flag set if on-calc lib version is less than the one used in the program
 jr _notverserr
_vers:
 ld hl,(_errorversionloc)
 jp (hl)
_notverserr:
 inc hl					; now, hl->dependencies for program, 00h if none
 push hl				; if we made it here, that means the library exists and the versions match. hl->Cprgm, de->library relocation data
  ex de,hl
  push hl				; hl->Version
   inc hl				; Bypass version byte
   ld (reloctblsizeptr),hl
   ld bc,(hl)

   push hl				; multiply the value in bc by 3
    or a,a
    sbc hl,hl
    add hl,bc
    add hl,bc
    add hl,bc
    ex (sp),hl
   pop bc
 
   inc hl
   inc hl
   inc hl				; hl->start of relocation table
   add hl,bc				; hl->number of library functions
   ld bc,(hl)				; bc=number of library functions
   
   push hl				; multiply the value in bc by 3
    or a,a
    sbc hl,hl
    add hl,bc
    add hl,bc
    add hl,bc
    ex (sp),hl
   pop bc
 
   ld (vectortblsizeptr),hl
   inc hl	
   inc hl
   inc hl
   ld (vectortblptr),hl			; Add the size of the vector table
   add hl,bc				; hl->start of dependencies
  pop de
  push hl
   or a,a \ sbc hl,de			; subtract offset, hl=size to subract from libsize
   ld (excesslibsize),hl		;
   ex de,hl
   ld hl,(libsize)			; load old size
   or a,a \ sbc hl,de
   ld (libsize),hl			; store the size of the library
   push hl
    call _errnotenoughmem		; hl=size of library
    ld hl,usermem
    ld de,(asm_prgm_size)
    add hl,de				; hl->end of C program+libaries
    ld (ramptr),hl
    ex de,hl
   pop hl
   call _insertmem			; insert memory for the library
   ld hl,(libsize)
   ld de,(asm_prgm_size)
   add hl,de
   ld (asm_prgm_size),hl		; store new size of program
  pop hl				; hl->start of dependencies
  ld de,(ramptr)			; de->insertion place
  ld bc,(libsize)			; bc=lib size
  ldir					; copy in the library to ram
_reslovextractedeentrypoints:
  ld hl,(vectortblsizeptr)		; bc=#VECTORS
  ld bc,(hl)
 pop hl					; hl->program version
_resloveentrypoints:
 inc hl					; bypass jump byte ($C3)
 push hl
  ld de,(hl)				; offset in vector table
  
  bit relocdependent,(iy+asmflag)
  jr nz,_nos
  push hl
   ld hl,(vectortblptr)			; hl->start of vector table
   add hl,de				; hl->correct vector entry
   ld de,(hl)				; de=offest in lib for function
  pop hl
_nos:
  ld hl,(ramptr)
  add hl,de				; add the location of the library to the offset bytes for the function
  ex de,hl				; de<->hl
 pop hl
 ld (hl),de				; resolved address
 inc hl
 inc hl
 inc hl					; move to next jump (or whatever is there)
 dec bc
 ld a,b
 or c
 jr nz,_resloveentrypoints
 
 ld (nextlibptr),hl	
 bit prevextracted,(iy+asmflag)		; have we already resolved the absolute addresses for this library?
 jr nz,_norelocabsolutes
					; save it for now; we have to relocate the current library
 					; okay, so I need to store the location of the vector table and the location the the library in RAM
					; for later resolution
 ld hl,(currlibptr)
 ld de,(ramptr) 
 ld (hl),de				; store the location of the library in RAM
 inc hl					; bypass
 inc hl
 inc hl
 ld de,(vectortblsizeptr)		; get the location of the vector table size vectortblsizeptr+3->VECTOR TABLE
 ld (hl),de
 inc hl					; bypass
 inc hl
 inc hl
 ld (currlibptr),hl			; store it as a pointer
 ld hl,(reloctblsizeptr)		; hl->relocation table size
 ld bc,(hl)				; bc=total size of relocation table (a.k.a. relocation table size bytes)
_relocabsolutes:
 inc hl
 inc hl
 inc hl
 call _chkbcis0
 jr z,_norelocabsolutes
 ld de,(ramptr)				; okay, so whatever the offset is from here,  we must relocate it
 push hl
  push bc
   ld hl,(hl)
   add hl,de				; okay, now we are looking at the right 'stuff'	--- hl->$C3,$CD, etc...
   push hl
    ld hl,(hl)				; hl->offset
    ld de,(excesslibsize)
    or a,a \ sbc hl,de			; offset needs to be recomputed
    inc hl
    inc hl
    inc hl
    inc hl
    ld de,(ramptr)
    add hl,de				; absolute offset+ramptr	
    ex de,hl				; hl<->de
   pop hl
   ld (hl),de				; store relocate
  pop bc
  dec bc
  or a,a \ sbc hl,hl
  adc hl,bc
 pop hl
 jr nz,_relocabsolutes
_norelocabsolutes:
					; okay, now the entire library should be realocated and entry points are taken care of
 ld hl,(ramptr)			; now we need to find the dependent libraries that a library may be using
 ld a,(hl)				; The first byte of this pointer will be the number of dependencies
 or a,a					; reload previous pointers and values
 jr z,_nodependentlibs

 inc hl
 ld de,(nextlibptr)			; If we are here, we need to see what dependencies there are, and how we can extract them or check if they have been extracted
 push de
  set relocdependent,(iy+asmflag)
  ex de,hl				; temporarily save hl
  ld hl,(_extractnextlibloc)
  jp (hl)				; hl->first string of dependency (I am insane for calling this function. Recursion is awesome! :P)
_recursionend:
  res relocdependent,(iy+asmflag)
 pop hl
 ld (nextlibptr),hl
_nodependentlibs:
 bit relocdependent,(iy+asmflag)
 jr nz,_recursionend			; return from recursive routine

 ld hl,(nextlibptr)
 ld a,(hl)				; hl->maybe LIB_BYTE -- If the C program is including libs
 cp LIB_BYTE
 jr nz,_runprgm
 ex de,hl				; temporarily save hl
 ld hl,(_extractnextlibloc)
 ;jp (hl)
 
_runprgm:
 jp (hl)				; passed all the checks; let's start execution! :)

_versionerror:
 ld hl,(_versionlibstrloc)
 jr _throwerror
_missingerror:				; can't find a dependent lib
 ld hl,(_missinglibstrloc)
_throwerror:				; draw the error message onscreen
 ld sp,(__saveSP)
 set textInverse,(iy+textFlags)
 ld a,2
 ld (curcol),a
 call _puts
 res textInverse,(iy+textFlags)
 call _newline
 call _newline
 ld hl,(_libnamestrloc)
 call _puts
 ld hl,op1+1
 call _puts
 call _getkey
 call _clrscrn
 call _homeup
 ret					; stop execution of the program
 
_versionlibstr:
 .db "ERROR: Library Version",0
_missinglibstr:
 .db "ERROR: Missing Library",0
_libnamestr:
 .db "Library Name: ",0
