; Copyright 2015-2021 Matt "MateoConLechuga" Waltz
;
; Redistribution and use in source and binary forms, with or without
; modification, are permitted provided that the following conditions are met:
;
; 1. Redistributions of source code must retain the above copyright notice,
;    this list of conditions and the following disclaimer.
;
; 2. Redistributions in binary form must reproduce the above copyright notice,
;    this list of conditions and the following disclaimer in the documentation
;    and/or other materials provided with the distribution.
;
; 3. Neither the name of the copyright holder nor the names of its contributors
;    may be used to endorse or promote products derived from this software
;    without specific prior written permission.
;
; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
; AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
; IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
; ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
; LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
; CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
; SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
; INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
; CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
; ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
; POSSIBILITY OF SUCH DAMAGE.

; routines for loading libload for using usbdrvce and fatdrvce libraries

; returns z if loaded, nz if not loaded
libload_load:
	call	libload_unload
	ld	de,lib_usbdrvce_tbl	; initialize default usbdrvce jump locations
	ld	hl,lib_usbdrvce
	ld	bc,lib_usbdrvce.size
	ldir
	ld	de,lib_fatdrvce_tbl	; initialize default fatdrvce jump locations
	ld	hl,lib_fatdrvce
	ld	bc,lib_fatdrvce.size
	ldir
	ld	de,lib_msddrvce_tbl	; initialize default fatdrvce jump locations
	ld	hl,lib_msddrvce
	ld	bc,lib_msddrvce.size
	ldir
	ld	a,$c0
	ld	(libload_libload),a
	ld	(libload_usbdrvce),a
	ld	(libload_msddrvce),a
	ld	(libload_fatdrvce),a	; reset loaded libraries that libload destroyed
	jq	.try
.inram:
	call	cesium.Arc_Unarc
.try:
	ld	hl,libload_name
	call	ti.Mov9ToOP1
	call	ti.ChkFindSym
	jr	c,.notfound
	call	ti.ChkInRam
	jr	z,.inram		; if in ram, archive LibLoad and search again
	ld	hl,9 + 3 + libload_name.len
	add	hl,de			; start of loader (required to be in hl)
	ld	a,(hl)
	cp	a,$1f			; ensure a valid libload version
	jr	c,.notfound
	dec	hl			; move to start of libload
	dec	hl
	ld	de,.relocations 	; start of relocation data
	ld	bc,.notfound
	push	bc
	ld	bc,$aa55aa		; tell libload to not show an error screen
	jp	(hl)			; jump to the loader -- it should take care of everything else
.notfound:
	call	libload_unload
	call	lcd_init.setup
	xor	a,a
	inc	a
	ret

.relocations:

; default libload library
libload_libload:
	db	$C0,"LibLoad",0,31

; usbdrvce library functions
libload_usbdrvce:
	db	$C0,"USBDRVCE",0,0

lib_usbdrvce_tbl:
lib_usb_Init:
	jp	0
lib_usb_Cleanup:
	jp	3
lib_usb_WaitForInterrupt:
	jp	15
lib_usb_ResetDevice:
	jp	39

; msddrvce library functions
libload_msddrvce:
	db	$C0,"MSDDRVCE",0,0

lib_msddrvce_tbl:
lib_msd_Open:
	jp	0
lib_msd_Close:
	jp	3
lib_msd_Info:
	jp	9
lib_msd_Read:
	jp	12
lib_msd_Write:
	jp	15
lib_msd_FindPartitions:
	jp	24

; fatdrvce library functions
libload_fatdrvce:
	db	$C0,"FATDRVCE",0,0

lib_fatdrvce_tbl:
lib_fat_Init:
	jp	0
lib_fat_Deinit:
	jp	3
lib_fat_DirList:
	jp	6
lib_fat_Open:
	jp	12
lib_fat_Close:
	jp	15
lib_fat_SetSize:
	jp	18
lib_fat_SetAttrib:
	jp	24
lib_fat_GetAttrib:
	jp	27
lib_fat_SetPos:
	jp	30
lib_fat_GetPos:
	jp	33
lib_fat_Read:
	jp	36
lib_fat_Write:
	jp	39
lib_fat_Create:
	jp	42
lib_fat_Delete:
	jp	45

	xor	a,a		; return z (loaded)
	pop	hl		; pop error return
	ret

; should match above entry points!
lib_usbdrvce:
	jp	0
	jp	3
	jp	15
	jp	39
.size := $ - lib_usbdrvce

; should match above entry points!
lib_msddrvce:
	jp	0
	jp	3
	jp	9
	jp	12
	jp	15
	jp	24
.size := $ - lib_msddrvce

; should match above entry points!
lib_fatdrvce:
	jp	0
	jp	3
	jp	6
	jp	12
	jp	15
	jp	18
	jp	24
	jp	27
	jp	30
	jp	33
	jp	36
	jp	39
	jp	42
	jp	45
.size := $ - lib_fatdrvce

; remove loaded libraries from usermem
libload_unload:
	jp	util_delete_prgm_from_usermem

libload_name:
	db	ti.AppVarObj, "LibLoad", 0
.len := $ - .
