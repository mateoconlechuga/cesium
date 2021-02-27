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

; sprites used throughout cesium

sprite_usb:
	db 16,16
	db $ff,$ff,$ff,$ff,$ff,$29,$29,$29,$29,$29,$29,$29,$ff,$ff,$ff,$ff
	db $ff,$ff,$ff,$ff,$ff,$29,$de,$de,$de,$de,$de,$29,$ff,$ff,$ff,$ff
	db $ff,$ff,$ff,$ff,$ff,$29,$94,$d6,$b6,$d6,$94,$29,$ff,$ff,$ff,$ff
	db $ff,$ff,$ff,$ff,$ff,$29,$d6,$b5,$b5,$b5,$b5,$29,$ff,$ff,$ff,$ff
	db $ff,$ff,$ff,$ff,$00,$29,$6b,$6b,$6b,$6b,$6b,$29,$00,$ff,$ff,$ff
	db $ff,$ff,$ff,$ff,$00,$93,$6b,$94,$ff,$94,$6c,$93,$00,$ff,$ff,$ff
	db $ff,$ff,$ff,$ff,$00,$6c,$6b,$ff,$de,$ff,$6b,$6c,$00,$ff,$ff,$ff
	db $ff,$ff,$ff,$ff,$00,$6c,$6b,$4a,$ff,$4b,$6b,$6c,$00,$ff,$ff,$ff
	db $ff,$ff,$ff,$ff,$00,$6b,$6b,$6b,$ff,$6b,$ff,$6b,$00,$ff,$ff,$ff
	db $ff,$ff,$ff,$ff,$00,$6b,$fe,$6b,$fe,$94,$fe,$6b,$00,$ff,$ff,$ff
	db $ff,$ff,$ff,$ff,$00,$6b,$fe,$b4,$fe,$fe,$6b,$6b,$00,$ff,$ff,$ff
	db $ff,$ff,$ff,$ff,$00,$6b,$6b,$de,$de,$4a,$6b,$6b,$00,$ff,$ff,$ff
	db $ff,$ff,$ff,$ff,$00,$6b,$4a,$4a,$de,$4b,$4b,$6b,$00,$ff,$ff,$ff
	db $ff,$ff,$ff,$ff,$00,$6b,$4a,$b5,$de,$b5,$4b,$6b,$00,$ff,$ff,$ff
	db $ff,$ff,$ff,$ff,$00,$4a,$4a,$6b,$de,$6b,$6b,$4a,$00,$ff,$ff,$ff
	db $ff,$ff,$ff,$ff,$ff,$00,$00,$00,$00,$00,$00,$00,$ff,$ff,$ff,$ff

sprite_directory:
	db 16,16
	db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db $ff,$c4,$c4,$c4,$c4,$cc,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db $c4,$f7,$f7,$f7,$f7,$c4,$c4,$c4,$c4,$c4,$c4,$c4,$c4,$cc,$ff,$ff
	db $c4,$f7,$ed,$ed,$f6,$f7,$f7,$f7,$f7,$f7,$f7,$f7,$ff,$c4,$fe,$ff
	db $c4,$f7,$ee,$ee,$ee,$ee,$ee,$ee,$ee,$ed,$ed,$ed,$f6,$c4,$d6,$ff
	db $c4,$f7,$ee,$ee,$ee,$ee,$ee,$ee,$cc,$c4,$c4,$c4,$c4,$c4,$c4,$c4
	db $c4,$f7,$ee,$ed,$ed,$ed,$ed,$cc,$ed,$f7,$f7,$f7,$f7,$f7,$f7,$c4
	db $c4,$f6,$cc,$c4,$c4,$c4,$c4,$ed,$ee,$ee,$ee,$ee,$ee,$ee,$f6,$c4
	db $c4,$ee,$cc,$f7,$f7,$f7,$f7,$ee,$ee,$ee,$ee,$ee,$ee,$f6,$ed,$c4
	db $c4,$ed,$ed,$f7,$ee,$ee,$ee,$ee,$ee,$ee,$ee,$ee,$ee,$f6,$c4,$ff
	db $cc,$cc,$ee,$f6,$ee,$ee,$ee,$ee,$ee,$ee,$ee,$ee,$f6,$ee,$c4,$ff
	db $cc,$c4,$f7,$f6,$ef,$ef,$ef,$ef,$ef,$ef,$ef,$ef,$f7,$ed,$ff,$ff
	db $cc,$cc,$c4,$c4,$c4,$c4,$c4,$c4,$c4,$c4,$c4,$c4,$c4,$c4,$ff,$ff
	db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff

sprite_file_asm:
	db 16,16
	db $ff,$ff,$ff,$5d,$7d,$7d,$7d,$7d,$7d,$7d,$13,$13,$ff,$ff,$ff,$ff
	db $ff,$ff,$ff,$7d,$ff,$ff,$df,$df,$df,$df,$7d,$13,$13,$ff,$ff,$ff
	db $ff,$ff,$ff,$7d,$ff,$ff,$ff,$df,$df,$df,$df,$7d,$7d,$13,$ff,$ff
	db $ff,$ff,$ff,$7d,$ff,$ff,$ff,$df,$df,$df,$df,$7d,$ff,$7d,$13,$ff
	db $ff,$ff,$ff,$7d,$ff,$ff,$ff,$ff,$df,$df,$df,$7d,191,191,$7d,$13
	db $ff,$ff,$ff,$7d,$ff,$ff,$ff,$ff,$ff,$df,$df,$df,$df,$df,$7d,$13
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$13
	db $00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$00,$13
	db $00,$ff,$a0,$a0,$a0,$ff,$a0,$a0,$a0,$ff,$a0,$ff,$a0,$ff,$00,$13
	db $00,$ff,$a0,$ff,$a0,$ff,$a0,$ff,$ff,$ff,$a0,$a0,$a0,$ff,$00,$13
	db $00,$ff,$a0,$a0,$a0,$ff,$ff,$ff,$a0,$ff,$a0,$ff,$a0,$ff,$00,$13
	db $00,$ff,$a0,$ff,$a0,$ff,$a0,$a0,$a0,$ff,$a0,$ff,$a0,$ff,$00,$13
	db $00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$00,$13
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$13
	db $ff,$ff,$ff,$13,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$13
	db $ff,$ff,$ff,018,$13,$13,$13,$13,$13,$13,$13,$13,$13,$13,$13,018

sprite_file_c:
	db 16,16
	db $ff,$ff,$ff,$5d,$7d,$7d,$7d,$7d,$7d,$7d,$13,$13,$ff,$ff,$ff,$ff
	db $ff,$ff,$ff,$7d,$ff,$ff,$df,$df,$df,$df,$7d,$13,$13,$ff,$ff,$ff
	db $ff,$ff,$ff,$7d,$ff,$ff,$ff,$df,$df,$df,$df,$7d,$7d,$13,$ff,$ff
	db $ff,$ff,$ff,$7d,$ff,$ff,$ff,$df,$df,$df,$df,$7d,$ff,$7d,$13,$ff
	db $ff,$ff,$ff,$7d,$ff,$ff,$ff,$ff,$df,$df,$df,$7d,191,191,$7d,$13
	db $ff,$ff,$ff,$7d,$ff,$ff,$ff,$ff,$ff,$df,$df,$df,$df,$df,$7d,$13
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$13
	db $00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$00,$13
	db $00,$ff,$ff,$ff,$ff,$ff,$13,$13,$13,$ff,$ff,$ff,$ff,$ff,$00,$13
	db $00,$ff,$ff,$ff,$ff,$ff,$13,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$00,$13
	db $00,$ff,$ff,$ff,$ff,$ff,$13,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$00,$13
	db $00,$ff,$ff,$ff,$ff,$ff,$13,$13,$13,$ff,$ff,$ff,$ff,$ff,$00,$13
	db $00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$00,$13
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$13
	db $ff,$ff,$ff,$13,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$13
	db $ff,$ff,$ff,018,$13,$13,$13,$13,$13,$13,$13,$13,$13,$13,$13,018

sprite_file_ice:
	db 16,16
	db $ff,$ff,$ff,$5d,$7d,$7d,$7d,$7d,$7d,$7d,$13,$13,$ff,$ff,$ff,$ff
	db $ff,$ff,$ff,$7d,$ff,$ff,$df,$df,$df,$df,$7d,$13,$13,$ff,$ff,$ff
	db $ff,$ff,$ff,$7d,$ff,$ff,$ff,$df,$df,$df,$df,$7d,$7d,$13,$ff,$ff
	db $ff,$ff,$ff,$7d,$ff,$ff,$ff,$df,$df,$df,$df,$7d,$ff,$7d,$13,$ff
	db $ff,$ff,$ff,$7d,$ff,$ff,$ff,$ff,$df,$df,$df,$7d,191,191,$7d,$13
	db $ff,$ff,$ff,$7d,$ff,$ff,$ff,$ff,$ff,$df,$df,$df,$df,$df,$7d,$13
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$13
	db $00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$00,$13
	db $00,$ff,$05,$05,$05,$ff,$05,$05,$05,$ff,$05,$05,$05,$ff,$00,$13
	db $00,$ff,$ff,$05,$ff,$ff,$05,$ff,$ff,$ff,$05,$ff,$ff,$ff,$00,$13
	db $00,$ff,$ff,$05,$ff,$ff,$05,$ff,$ff,$ff,$05,$05,$ff,$ff,$00,$13
	db $00,$ff,$05,$05,$05,$ff,$05,$05,$05,$ff,$05,$05,$05,$ff,$00,$13
	db $00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$00,$13
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$13
	db $ff,$ff,$ff,$13,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$13
	db $ff,$ff,$ff,018,$13,$13,$13,$13,$13,$13,$13,$13,$13,$13,$13,018

sprite_file_app:
	db 16,16
	db $ff,$ff,$ff,$5d,$7d,$7d,$7d,$7d,$7d,$7d,$13,$13,$ff,$ff,$ff,$ff
	db $ff,$ff,$ff,$7d,$ff,$ff,$df,$df,$df,$df,$7d,$13,$13,$ff,$ff,$ff
	db $ff,$ff,$ff,$7d,$ff,$ff,$ff,$df,$df,$df,$df,$7d,$7d,$13,$ff,$ff
	db $ff,$ff,$ff,$7d,$ff,$ff,$ff,$df,$df,$df,$df,$7d,$ff,$7d,$13,$ff
	db $ff,$ff,$ff,$7d,$ff,$ff,$ff,$ff,$df,$df,$df,$7d,191,191,$7d,$13
	db $ff,$ff,$ff,$7d,$ff,$ff,$ff,$ff,$ff,$df,$df,$df,$df,$df,$7d,$13
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$13
	db $00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$00,$13
	db $00,$ff,$05,$05,$05,$ff,$05,$05,$05,$ff,$05,$05,$05,$ff,$00,$13
	db $00,$ff,$05,$ff,$05,$ff,$05,$ff,$05,$ff,$05,$ff,$05,$ff,$00,$13
	db $00,$ff,$05,$05,$05,$ff,$05,$05,$05,$ff,$05,$05,$05,$ff,$00,$13
	db $00,$ff,$05,$ff,$05,$ff,$05,$ff,$ff,$ff,$05,$ff,$ff,$ff,$00,$13
	db $00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$00,$13
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$13
	db $ff,$ff,$ff,$13,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$13
	db $ff,$ff,$ff,018,$13,$13,$13,$13,$13,$13,$13,$13,$13,$13,$13,018

sprite_file_appvar:
	db 16,16
	db $ff,$ff,$ff,$5d,$7d,$7d,$7d,$7d,$7d,$7d,$13,$13,$ff,$ff,$ff,$ff
	db $ff,$ff,$ff,$7d,$ff,$ff,$df,$df,$df,$df,$7d,$13,$13,$ff,$ff,$ff
	db $ff,$ff,$ff,$7d,$ff,$ff,$ff,$df,$df,$df,$df,$7d,$7d,$13,$ff,$ff
	db $ff,$ff,$ff,$7d,$ff,$ff,$ff,$df,$df,$df,$df,$7d,$ff,$7d,$13,$ff
	db $ff,$ff,$ff,$7d,$ff,$ff,$ff,$ff,$df,$df,$df,$7d,191,191,$7d,$13
	db $ff,$ff,$ff,$7d,$ff,$ff,$ff,$ff,$ff,$df,$df,$df,$df,$df,$7d,$13
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$13
	db $00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$00,$13
	db $00,$ff,$a8,$ff,$a8,$ff,$a8,$a8,$a8,$ff,$a8,$a8,$a8,$ff,$00,$13
	db $00,$ff,$a8,$ff,$a8,$ff,$a8,$ff,$a8,$ff,$a8,$ff,$a8,$ff,$00,$13
	db $00,$ff,$a8,$ff,$a8,$ff,$a8,$a8,$a8,$ff,$a8,$a8,$ff,$ff,$00,$13
	db $00,$ff,$ff,$a8,$ff,$ff,$a8,$ff,$a8,$ff,$a8,$ff,$a8,$ff,$00,$13
	db $00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$00,$13
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$13
	db $ff,$ff,$ff,$13,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$13
	db $ff,$ff,$ff,018,$13,$13,$13,$13,$13,$13,$13,$13,$13,$13,$13,018

sprite_file_basic:
	db 16,16
	db $ff,$ff,$ff,$5d,$7d,$7d,$7d,$7d,$7d,$7d,$13,$13,$ff,$ff,$ff,$ff
	db $ff,$ff,$ff,$7d,$ff,$ff,$df,$df,$df,$df,$7d,$13,$13,$ff,$ff,$ff
	db $ff,$ff,$ff,$7d,$ff,$ff,$ff,$df,$df,$df,$df,$7d,$7d,$13,$ff,$ff
	db $ff,$ff,$ff,$7d,$ff,$ff,$ff,$df,$df,$df,$df,$7d,$ff,$7d,$13,$ff
	db $ff,$ff,$ff,$7d,$ff,$ff,$ff,$ff,$df,$df,$df,$7d,191,191,$7d,$13
	db $ff,$ff,$ff,$7d,$ff,$ff,$ff,$ff,$ff,$df,$df,$df,$df,$df,$7d,$13
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$13
	db $00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$00,$13
	db $00,$ff,$ff,$ff,$e3,$e3,$e3,$ff,$e3,$e3,$e3,$ff,$ff,$ff,$00,$13
	db $00,$ff,$ff,$ff,$ff,$e3,$ff,$ff,$ff,$e3,$ff,$ff,$ff,$ff,$00,$13
	db $00,$ff,$ff,$ff,$ff,$e3,$ff,$ff,$ff,$e3,$ff,$ff,$ff,$ff,$00,$13
	db $00,$ff,$ff,$ff,$ff,$e3,$ff,$ff,$e3,$e3,$e3,$ff,$ff,$ff,$00,$13
	db $00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$00,$13
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$13
	db $ff,$ff,$ff,$13,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$13
	db $ff,$ff,$ff,018,$13,$13,$13,$13,$13,$13,$13,$13,$13,$13,$13,018

sprite_file_ti:
	db 16,16
	db $ff,$ff,$ff,$5d,$7d,$7d,$7d,$7d,$7d,$7d,$13,$13,$ff,$ff,$ff,$ff
	db $ff,$ff,$ff,$7d,$ff,$ff,$df,$df,$df,$df,$7d,$13,$13,$ff,$ff,$ff
	db $ff,$ff,$ff,$7d,$ff,$ff,$ff,$df,$df,$df,$df,$7d,$7d,$13,$ff,$ff
	db $ff,$ff,$ff,$7d,$ff,$ff,$ff,$df,$df,$df,$df,$7d,$ff,$7d,$13,$ff
	db $ff,$ff,$ff,$7d,$ff,$ff,$ff,$ff,$df,$df,$df,$7d,191,191,$7d,$13
	db $ff,$ff,$ff,$7d,$ff,$ff,$ff,$ff,$ff,$df,$df,$df,$df,$df,$7d,$13
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$13
	db $00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$00,$13
	db $00,$ff,$ff,$ff,$a0,$a0,$a0,$ff,$a0,$a0,$a0,$ff,$ff,$ff,$00,$13
	db $00,$ff,$ff,$ff,$ff,$a0,$ff,$ff,$ff,$a0,$ff,$ff,$ff,$ff,$00,$13
	db $00,$ff,$ff,$ff,$ff,$a0,$ff,$ff,$ff,$a0,$ff,$ff,$ff,$ff,$00,$13
	db $00,$ff,$ff,$ff,$ff,$a0,$ff,$ff,$a0,$a0,$a0,$ff,$ff,$ff,$00,$13
	db $00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$00,$13
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$13
	db $ff,$ff,$ff,$13,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$13
	db $ff,$ff,$ff,018,$13,$13,$13,$13,$13,$13,$13,$13,$13,$13,$13,018

sprite_file_unknown:
	db 16,16
	db $ff,$ff,$ff,$5d,$7d,$7d,$7d,$7d,$7d,$7d,$13,$13,$ff,$ff,$ff,$ff
	db $ff,$ff,$ff,$7d,$ff,$ff,$df,$df,$df,$df,$7d,$13,$13,$ff,$ff,$ff
	db $ff,$ff,$ff,$7d,$ff,$ff,$ff,$df,$df,$df,$df,$7d,$7d,$13,$ff,$ff
	db $ff,$ff,$ff,$7d,$ff,$ff,$ff,$df,$df,$df,$df,$7d,$ff,$7d,$13,$ff
	db $ff,$ff,$ff,$7d,$ff,$ff,$ff,$ff,$df,$df,$df,$7d,191,191,$7d,$13
	db $ff,$ff,$ff,$7d,$ff,$ff,$ff,$ff,$ff,$df,$df,$df,$df,$df,$7d,$13
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$13
	db $00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$00,$13
	db $00,$ff,$e3,$ff,$e3,$ff,$e3,$ff,$e3,$ff,$e3,$ff,$e3,$ff,$00,$13
	db $00,$ff,$e3,$ff,$e3,$ff,$e3,$e3,$e3,$ff,$e3,$e3,$ff,$ff,$00,$13
	db $00,$ff,$e3,$ff,$e3,$ff,$e3,$e3,$e3,$ff,$e3,$ff,$e3,$ff,$00,$13
	db $00,$ff,$e3,$e3,$e3,$ff,$e3,$ff,$e3,$ff,$e3,$ff,$e3,$ff,$00,$13
	db $00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$00,$13
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$13
	db $ff,$ff,$ff,$13,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$13
	db $ff,$ff,$ff,018,$13,$13,$13,$13,$13,$13,$13,$13,$13,$13,$13,018

sprite_egg:
	db 16,16
	db $ff,$ff,$ff,$ff,$ff,$ff,$f7,$d6,$d5,$d6,$ff,$ff,$ff,$ff,$ff,$ff
	db $ff,$ff,$ff,$ff,$ff,$f7,$f6,$d5,$ad,$8c,$ac,$fe,$ff,$ff,$ff,$ff
	db $ff,$ff,$ff,$ff,$f6,$d6,$b5,$ad,$8c,$8b,$6b,$6c,$ff,$ff,$ff,$ff
	db $ff,$ff,$ff,$d6,$d5,$d5,$ac,$ac,$6b,$6b,$6b,$4a,$b5,$ff,$ff,$ff
	db $ff,$ff,$ff,$ad,$cd,$8c,$8c,$8b,$6b,$6b,$4a,$6a,$6b,$ff,$ff,$ff
	db $ff,$ff,$d6,$ac,$ac,$8c,$8b,$6b,$6b,$6b,$42,$6a,$6a,$d6,$ff,$ff
	db $ff,$ff,$ad,$8c,$8c,$8b,$6b,$6b,$6a,$6a,$42,$6a,$6a,$94,$ff,$ff
	db $ff,$ff,$ad,$8c,$6b,$8b,$22,$42,$6a,$6a,$4a,$6a,$6a,$8c,$ff,$ff
	db $ff,$ff,$ac,$8b,$6b,$6b,$42,$4a,$6a,$6a,$6a,$6a,$6b,$8c,$ff,$ff
	db $ff,$ff,$8c,$6b,$6b,$6b,$6a,$6a,$6a,$6a,$4a,$6a,$6b,$8c,$ff,$ff
	db $ff,$ff,$94,$6b,$6a,$6a,$6a,$6a,$4a,$6a,$4a,$6b,$6b,$94,$ff,$ff
	db $ff,$ff,$b5,$6a,$6a,$6a,$6a,$6a,$4a,$4a,$22,$6b,$8c,$b5,$ff,$ff
	db $ff,$ff,$de,$6b,$6a,$6a,$4a,$6a,$6a,$6a,$6a,$8b,$ac,$fe,$ff,$ff
	db $ff,$ff,$ff,$b5,$6a,$6a,$6a,$6a,$6a,$6a,$6b,$8b,$b5,$ff,$ff,$ff
	db $ff,$ff,$ff,$ff,$b5,$6b,$6a,$6a,$6a,$6b,$8b,$b5,$ff,$ff,$ff,$ff
	db $ff,$ff,$ff,$ff,$ff,$de,$b4,$8c,$8c,$b5,$de,$ff,$ff,$ff,$ff,$ff

sprite_locked:
	db 6,8
	db $ff,$4b,$4b,$4b,$4b,$ff
	db $ff,$4b,$ff,$ff,$4b,$ff
	db $ff,$4b,$ff,$ff,$4b,$ff
	db $4b,$4b,$4b,$4b,$4b,$4b
	db $4b,$e4,$e4,$e4,$e4,$4b
	db $4b,$e4,$e4,$e4,$e4,$4b
	db $4b,$e4,$e4,$e4,$e4,$4b
	db $4b,$4b,$4b,$4b,$4b,$4b

sprite_archived:
	db 6,8
	db $4b,$4b,$4b,$4b,$4b,$4b
	db $4b,$ff,$4b,$ff,$ff,$4b
	db $4b,$ff,$ff,$4b,$ff,$4b
	db $4b,$ff,$4b,$ff,$ff,$4b
	db $4b,$e4,$e4,$4b,$e4,$4b
	db $4b,$e4,$4b,$e4,$e4,$4b
	db $4b,$e4,$e4,$4b,$e4,$4b
	db $4b,$4b,$4b,$4b,$4b,$4b

sprite_usb_mask:
	db $f8,$0f
	db $f8,$0f
	db $f8,$0f
	db $f8,$0f
	db $f0,$07
	db $f0,$07
	db $f0,$07
	db $f0,$07
	db $f0,$07
	db $f0,$07
	db $f0,$07
	db $f0,$07
	db $f0,$07
	db $f0,$07
	db $f0,$07
	db $f8,$0f

sprite_directory_mask:
	db $ff,$ff
	db $ff,$ff
	db $83,$ff
	db $00,$03
	db $00,$03
	db $00,$03
	db $00,$00
	db $00,$00
	db $00,$00
	db $00,$00
	db $00,$01
	db $00,$01
	db $00,$03
	db $80,$03
	db $ff,$ff
	db $ff,$ff

sprite_file_mask:
	db $e0,$0f
	db $e0,$07
	db $e0,$03
	db $e0,$01
	db $e0,$00
	db $e0,$00
	db $00,$00
	db $00,$00
	db $00,$00
	db $00,$00
	db $00,$00
	db $00,$00
	db $00,$00
	db $00,$00
	db $e0,$00
	db $e0,$00
