password_modify:
	call	gui_draw_cesium_info

	print	string_new_password, 10, 30
	ld	bc,$600
	ld	hl,setting_password + 1
.loop:
	push	hl
	push	bc
	call	lcd_blit
.get_key:
	call	ti.GetCSC
	or	a,a
	jr	z,.get_key
	cp	a,ti.sk2nd
	jr	z,.done_fill
	cp	a,ti.skEnter
	jr	z,.done_fill
	push	af
	ld	a,'*'
	call	lcd_char
	pop	af
	pop	bc
	pop	hl
	ld	(hl),a
	inc	hl
	djnz	.loop
.done:
	ld	de,setting_password + 1
	or	a,a
	sbc	hl,de
	ld	a,l
	ld	(setting_password),a
	ret
.done_fill:
	pop	bc
	pop	hl
	jr	.done
