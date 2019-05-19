; search routines for searching the item list

; a = alphabet name to find
search_alpha_item:
	ld	hl,lut_character_standard
	call	ti.AddHLAndA			; find the offset
	ld	a,(hl)
	or	a,a
	ret	z
	ld	(.search_character),a
	call	find_lists.reset_selection
	ld	hl,item_location_base
	ld	bc,(number_of_items)		; loop through the prgms
.find:
	ld	a,(current_screen)
	cp	a,screen_programs
	jr	z,.vat_list
	cp	a,screen_appvars
	jr	z,.vat_list
.app_list:
	ld	de,(hl)
	push	hl
	push	de
	ex	de,hl
	ld	hl,(hl)
	compare_hl_zero
	pop	de
	pop	hl
	jr	z,.next				; check if metadata directory
	inc	de
	inc	de
	inc	de
	ld	a,(de)
	jr	.compare
.vat_list:
	ld	de,(hl)				; pointer to program name size
	push	de
	push	hl
	ex	de,hl
	ld	de,6
	add	hl,de
	ld	a,(hl)
	inc	a				; check if metadata directory
	pop	hl
	pop	de
	jr	z,.next
	dec	de
	ld	a,(de)
	cp	a,64
	jr	nc,.compare
	add	a,64
.compare:
	cp	a,0
.search_character := $-1
	jr	nc,search_complete
.next:
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
	call	ti.StrLength
	ld	a,c
	ld	(.length),a
	push	hl
	call	find_lists.reset_selection
	ld	hl,item_location_base
	ld	bc,(number_of_items)		; loop through the items
	pop	ix
	dec	ix
.find:
	ld	de,(hl)				; pointer to program name
	push	bc
	push	ix
	ld	b,0
.length := $-1
	ld	a,(de)
	cp	a,b
	jr	nz,.next			; check lengths
.compare:
	dec	de
	inc	ix
	ld	a,(de)
	cp	a,(ix)
	jr	nz,.next
	djnz	.compare
	pop	ix
	pop	bc
	jr	search_complete

.next:
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
	call	find_lists.reset_selection
	jr	search_complete
