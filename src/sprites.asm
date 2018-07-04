; sprites used throughout cesium

sprite_directory:
	db 16,16
	db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db $ff,$ff,$8B,$83,$83,$83,$83,$83,$83,$83,$82,$82,$83,$8B,$ff,$ff
	db $ff,$a3,$ab,$ac,$ac,$ac,$ac,$ac,$ac,$ac,$ac,$ac,$ac,$a3,$8B,$ff
	db $83,$ab,$cc,$a3,$a3,$a3,$a3,$a2,$a2,$82,$82,$82,$8B,$ab,$83,$8B
	db $83,$cd,$a3,$a2,$a2,$a2,$82,$82,$82,$82,$82,$82,$82,$83,$ac,$82
	db $83,$ee,$f5,$ed,$ed,$ed,$ed,$ed,$ed,$ed,$ec,$ec,$ec,$ec,$ed,$82
	db $83,$ed,$ed,$ed,$ec,$ec,$ec,$ec,$cc,$cc,$cc,$cb,$cb,$cb,$ec,$82
	db $83,$ed,$ed,$ec,$ec,$ec,$ec,$cc,$cc,$cb,$cb,$cb,$cb,$cb,$ec,$82
	db $83,$ed,$ec,$ec,$ec,$cc,$cc,$cc,$cb,$cb,$cb,$cb,$cb,$c3,$cc,$82
	db $83,$ed,$ec,$cc,$cc,$cc,$cb,$cb,$cb,$cb,$cb,$c3,$c3,$c3,$cc,$82
	db $83,$ed,$ec,$cc,$cb,$cb,$cb,$cb,$cb,$c3,$c3,$c3,$c3,$c3,$cc,$82
	db $82,$ed,$cc,$cb,$cb,$cb,$cb,$cb,$c3,$c3,$c3,$c3,$c3,$c2,$cc,$82
	db $82,$cd,$ed,$ed,$ec,$ec,$ec,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$82
	db $8B,$82,$82,$82,$82,$82,$82,$82,$82,$82,$82,$82,$82,$82,$82,$8a
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
