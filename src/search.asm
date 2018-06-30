; search routines for searching the item list

; a = alphabet name to find
search_alpha_item:
	ld	hl,lut_character_standard
	call	_AddHLAndA			; find the offset
	ld	a,(hl)
	or	a,a
	ret	z
	ld	(.search_character),a
	call	util_init_selection_screen
	ld	hl,item_location_base
	ld	bc,(selection_max)		; loop through the prgms
.find:
	ld	de,(hl)				; pointer to program name size
	dec	de
	ld	a,(de)
	cp	a,64
	jr	nc,.hidden
	add	a,64
.hidden:
	cp	a,0
.search_character := $-1
	jr	nc,search_complete
	push	hl
	call	main_move_down
	pop	hl
	inc	hl
	inc	hl
	inc	hl
	inc	hl
	dec	bc
	ld	a,b
	or	a,c
	jr	nz,.find
search_complete:
	xor	a,a
	inc	a
	ret

search_name:
	call	_StrLength
	ld	a,c
	ld	(.length),a
	push	hl
	call	util_init_selection_screen
	ld	hl,item_location_base
	ld	bc,(selection_max)		; loop through the items
	pop	ix
	dec	ix
.find:
	ld	de,(hl)				; pointer to program name size

	push	bc
	push	ix
	ld	b,0
.length := $-1
.compare:
	dec	de
	inc	ix
	ld	a,(de)
	cp	a,(ix)
	jr	nz,.loop
	djnz	.compare
	pop	ix
	pop	bc
	jr	search_complete

.loop:
	pop	ix
	pop	bc
	push	hl
	call	main_move_down
	pop	hl
	inc	hl
	inc	hl
	inc	hl
	inc	hl
	dec	bc
	ld	a,b
	or	a,c
	jr	nz,.find
	jr	search_complete
