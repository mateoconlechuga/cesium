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

flash_backup_ram:
	call	port_unlock
	ld	a,$3f
	call	flash_erase_sector		; clean out the flash sectors
	ld	a,$3e
	call	flash_erase_sector
	ld	a,$3d
	call	flash_erase_sector
	ld	a,$3c
	call	flash_erase_sector
	ld	hl,$d00001
	ld	(hl),$a5
	dec	hl
	ld	(hl),$5a			; write some magical bytes
	ld	de,$3c0000			; write all of ram
	ld	bc,$40000
	call	ti.WriteFlash
	jp	port_lock

flash_erase_sector:
	ld	bc,$f8
	push	bc
	jp	ti.EraseFlashSector

flash_clear_backup:
	ld	de,$3c0000			; backup address
	ld	hl,$d00001
	xor	a,a
	ld	b,a				; write 0
	ld	(hl),a
	inc	hl
	ld	(hl),a
	ld	a,(de)
	or	a,a
	ret	z				; dont clear if done already
	call	port_unlock
	call	ti.WriteFlashByte		; clear old backup
	jp	port_lock

if config_english
string_ram_backup:
	db	'Backing up...',0
end if

if config_french
string_ram_backup:
	db	'Sauvegarde en cours...',0
end if

if config_dutch
string_ram_backup:
	db	'Backup wordt gemaakt...',0
end if
