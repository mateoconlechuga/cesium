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
	ld	a,(hl)
	ld	(settings_color),a
	inc	hl
	ld	a,(hl)
	ld	(iy + settings_flag),a
	ret

settings_create_default:
	ld	hl,settings_appvar_size * 2	; just have at least double this
	push	hl
	call	_EnoughMem
	pop	hl
	jp	c,exit_full
	call	_CreateAppVar
	ex	de,hl
	ld	de,color_bg_default
	inc	hl
	inc	hl
	ld	(hl),de				; default color index, settings, password length
	jr	settings_load

settings_save:
	ld	hl,settings_appvar
	call	util_find_var
	call	_ChkInRam
	push	af
	call	nz,_Arc_Unarc
	pop	af
	jr	nz,settings_save
	inc	de
	inc	de
	ld	a,(settings_color)
	ld	(de),a
	inc	de
	ld	a,(iy + settings_flag)
	ld	(de),a
	ld	hl,settings_password
	ld	bc,password_max_length + 1
	ldir
	ld	hl,settings_appvar
	call	util_find_var
	jp	_Arc_Unarc

settings_appvar:
	db	appvarObj, cesium_name, 0
