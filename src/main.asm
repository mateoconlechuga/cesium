
	call	_ClrGetKeyHook				; clear key hooks

	xor	a,a
	sbc	hl,hl
	ld	(current_selection_absolute),hl		; reset to defaults
	ld	(scroll_amount),hl
	ld	(current_selection),a

	call	_RunIndicOff
	di

	call	settings_load				; load the settings
	call	exit_full
	ret
	
