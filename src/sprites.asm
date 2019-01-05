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
	db $ff,$ff,$8b,$83,$83,$83,$83,$83,$83,$83,$82,$82,$83,$8b,$ff,$ff
	db $ff,$a3,$ab,$ac,$ac,$ac,$ac,$ac,$ac,$ac,$ac,$ac,$ac,$a3,$8b,$ff
	db $83,$ab,$cc,$a3,$a3,$a3,$a3,$a2,$a2,$82,$82,$82,$8b,$ab,$83,$8b
	db $83,$cd,$a3,$a2,$a2,$a2,$82,$82,$82,$82,$82,$82,$82,$83,$ac,$82
	db $83,$ee,$f5,$ed,$ed,$ed,$ed,$ed,$ed,$ed,$ec,$ec,$ec,$ec,$ed,$82
	db $83,$ed,$ed,$ed,$ec,$ec,$ec,$ec,$cc,$cc,$cc,$cb,$cb,$cb,$ec,$82
	db $83,$ed,$ed,$ec,$ec,$ec,$ec,$cc,$cc,$cb,$cb,$cb,$cb,$cb,$ec,$82
	db $83,$ed,$ec,$ec,$ec,$cc,$cc,$cc,$cb,$cb,$cb,$cb,$cb,$c3,$cc,$82
	db $83,$ed,$ec,$cc,$cc,$cc,$cb,$cb,$cb,$cb,$cb,$c3,$c3,$c3,$cc,$82
	db $83,$ed,$ec,$cc,$cb,$cb,$cb,$cb,$cb,$c3,$c3,$c3,$c3,$c3,$cc,$82
	db $82,$ed,$cc,$cb,$cb,$cb,$cb,$cb,$c3,$c3,$c3,$c3,$c3,$c2,$cc,$82
	db $82,$cd,$ed,$ed,$ec,$ec,$ec,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$82
	db $8b,$82,$82,$82,$82,$82,$82,$82,$82,$82,$82,$82,$82,$82,$82,$8a
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

sprite_battery:
	db 6,8
	db $00,$00,$00,$00,$00,$00
	db $00,$25,$25,$25,$25,$00
	db $00,$25,$25,$25,$25,$00
	db $00,$25,$25,$25,$25,$00
	db $00,$25,$25,$25,$25,$00
	db $00,$25,$25,$25,$25,$00
	db $00,$25,$25,$25,$25,$00
	db $00,$00,$00,$00,$00,$00

sprite_directory_mask:
	db $ff,$ff
	db $ff,$ff
	db $c0,$03
	db $80,$01
	db $00,$00
	db $00,$00
	db $00,$00
	db $00,$00
	db $00,$00
	db $00,$00
	db $00,$00
	db $00,$00
	db $00,$00
	db $00,$00
	db $00,$00
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
