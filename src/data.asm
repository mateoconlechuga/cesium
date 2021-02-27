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

; unrelocated data

; safely unarchive a varible and restore screen mode
; in the case of a garbage collect
; returns nz if okay, z if garbage collect
; derived from https://github.com/calc84maniac/tiboyce/blob/350e414dfc345d5e754eb87c1b87bc4e06131e71/tiboyce.asm#L468
cesium.Arc_Unarc:
	call	ti.ChkFindSym
	ret	c
	ex	de,hl
	push	hl
	add	hl,hl
	pop	hl
	jr	nc,.no_garbage_collect
	ld	hl,(hl)
	ld	a,c
	add	a,12
	ld	c,a
	ld	b,0
	add.s	hl,bc
	jr	c,.garbage_collect
	push	hl
	pop	bc
	call	ti.FindFreeArcSpot
	jr	nz,.no_garbage_collect
.garbage_collect:
	xor	a,a
	push	af
	call	ti.boot.ClearVRAM
	ld	a,$2d
	ld	(ti.mpLcdCtrl),a
	call	ti.DrawStatusBar
	jr	.archive_or_unarchive
.no_garbage_collect:
	xor	a,a
	inc	a
	push	af
.archive_or_unarchive:
	ld	hl,data_lcd_init
	call	ti.PushErrorHandler
	call	ti.Arc_Unarc
	call	ti.PopErrorHandler
data_lcd_init:
	call	ti.boot.ClearVRAM
	ld	a,ti.lcdBpp8
	ld	(ti.mpLcdCtrl),a		; operate in 8bpp
	ld	hl,ti.mpLcdPalette
	ld	b,0
.loop:
	ld	d,b
	ld	a,b
	and	a,192
	srl	d
	rra
	ld	e,a
	ld	a,31
	and	a,b
	or	a,e
	ld	(hl),a
	inc	hl
	ld	(hl),d
	inc	hl
	inc	b
	jr	nz,.loop
	pop	af
	ret

data_cesium_appvar:
	db	ti.AppVarObj
data_string_cesium_name:
	db	cesium_name,0

data_string_password:
if config_english
	db	'Password:',0
else if config_french
	db	'Mot de passe:',0
else
    db  'Wachtwoord:',0
end if

data_string_quit1:
	db	'1:',0,'Quit',0
data_string_quit2:
	db	'2:',0,'Goto',0

; data in this location is allowed to be modified at runtime
	app_data
