; common routines for working with things involving settings

settings_load:
	ld	hl,settings_appvar
	call	util_find_var			; lookup the settings appvar
	jr	c,settings_create_default	; create it if it doesn't exist
	call	_ChkInRam
	push	af
	call	z,_Arc_Unarc			; archive it
	pop	af
	jr	z,settings_load			; find it again
settings_get_data:
	ex	de,hl
	ld	de,9
	add	hl,de
	ld	e,(hl)
	add	hl,de
	inc	hl
	inc	hl
	inc	hl
	ld	de,settings_data
	ld	bc,settings_size
	ldir
	ld	a,(setting_config)
	ld	(iy + settings_flag),a
	ret

settings_create_default:
	ld	hl,settings_appvar_size * 2	; just have at least double this
	push	hl
	call	_EnoughMem
	pop	hl
	jp	c,exit_full
	call	_CreateAppVar
	inc	de
	inc	de
	ex	de,hl
	ld	(hl),color_primary_default
	inc	hl
	ld	(hl),color_secondary_default
	inc	hl
	ld	(hl),setting_config_default
	inc	hl
	ld	(hl),0
	jr	settings_load

settings_save:
	ld	hl,settings_appvar
	call	util_find_var
	call	_ChkInRam
	push	af
	call	nz,_Arc_Unarc
	pop	af
	jr	nz,settings_save
	ld	a,(iy + settings_flag)
	ld	(setting_config),a
	inc	de
	inc	de
	ld	hl,settings_data
	ld	bc,settings_size
	ldir
	ld	hl,settings_appvar
	call	util_find_var
	jp	_Arc_Unarc

settings_launch:
	jp	main_settings

settings_appvar:
	db	appvarObj, cesium_name, 0
