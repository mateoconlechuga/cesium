; SORT.asm
;
; Made by Martin Warmer, mmartin@xs4all.nl
; Modified for ez80 architechure and hidden programs by Matt Waltz
;
; Uses insertion sort to sort the VAT alphabettically.
; This is a lot faster than sorting during runtime.

sort:	
	res	firstprog,(iy+asm_Flag1)
	ld	hl,(progptr)
sort_next:
	call	findnextitem
	ret	nc
	bit	firstprog,(iy+asm_Flag1)
	jp	z,firstprogfound
	push	hl
	call	skipname
	pop	de	
	push	hl					; to continue from later on
	ld	hl,(firstprogpointer)
	jr	searchnext_start			; could speed up sorted list by first checking if it's the last item (not neccessary)
searchnext:
	call	skipname
	ld	bc,(endofsortedpartpointer)
	or	a,a					; reset carry flag
	push	hl
	sbc	hl,bc
	pop	hl
	jr	z,locationfound
	ld	bc,-6
	add	hl,bc
searchnext_start:
	push	hl
	push	de
	call	comparestrings
	pop	de
	pop	hl
	jr	nc,searchnext
searchnext_end:
	ld	bc,6
	add	hl,bc					; goto start of entry
locationfound:
	ex	de,hl
	ld	a,(hl)
	add	a,7
	ld	bc,6					; rewind six bytes
	add	hl,bc

	ld	bc,0					; A=number of bytes to move
	ld	c,a					; HL->bytes to move
	ld	(vatentrysize),bc			; DE->move to location
	ld	(vatentrynewloc),de
	push	de
	push	hl
	or	a,a
	sbc	hl,de
	pop	hl
	pop	de
	jr	z,nomoveneeded
	push	hl
	ld	de,vatentrytempend
	lddr						; copy entry to move to vatentrytempend

	ld	hl,(vatentrynewloc)
	pop	bc
	push	bc
	or	a,a
	sbc	hl,bc
	push	hl
	pop	bc
	pop	hl
	inc	hl
	push	hl
	ld	de,(vatentrysize)
	or	a,a
	sbc	hl,de	
	ex	de,hl
	pop	hl
	ldir

	ld	hl,vatentrytempend
	ld	bc,(vatentrysize)
	ld	de,(vatentrynewloc)
	lddr
	ld	hl,(endofsortedpartpointer)
	ld	bc,(vatentrysize)
	or	a,a
	sbc	hl,bc
	ld	(endofsortedpartpointer),hl
	pop	hl					; pointer to continue from
	jp	sort_next				; to skip name and rest of entry

nomoveneeded:
	pop	hl
	ld	(endofsortedpartpointer),hl
	jp	sort_next
	
firstprogfound:
	set	firstprog,(IY+asm_Flag1)		; to make it only execute once
	ld	(firstprogpointer),hl
	call	skipname
	ld	(endofsortedpartpointer),hl
	jp	sort_next

skiptonext6:
	ld	bc,-6
	add	hl,bc
	call	skipname
	jp	findnextitem				; look for next item
skipname:
	ld	bc,0
	ld	c,(hl)					; number of bytes in name
	inc	c					; to get pointer to data type byte of next entry
	or	a,a					; reset carry flag
	sbc	hl,bc
	ret

comparestrings:						; hl and de pointers to strings output=carry if de is first
	res	prog1Hidden,(iy+hideFlag)
	res	prog2Hidden,(iy+hideFlag)
	
	dec	hl
	dec	de
	ld	a,(hl)
	cp	a,64
	jr	nc,prog1NotHidden			; check if files are hidden
	add	a,64
	ld	(hl),a
	set	prog1Hidden,(iy+hideFlag)
prog1NotHidden:
	ld	a,(de)
	cp	a,64
	jr	nc,prog2NotHidden
	add	a,64
	ld	(de),a
	set	prog2Hidden,(iy+hideFlag)
prog2NotHidden:
	push	hl
	push	de
	inc	hl
	inc	de
	ld	b,(hl)
	ld	a,(de)
	ld	c,0
	cp	a,b					; check if same length
	jr	z,comparestrings_continue
	jr	nc,comparestrings_continue		; b = smaller than a
	inc	c					; to remember that b was larger
	ld	b,a					; b was larger than a
comparestrings_continue:
	dec	hl
	dec	de
	ld	a,(de)
	cp	a,(hl)
	jr	nz,+_
	djnz	comparestrings_continue
_:	pop	de
	pop	hl
	push	af
	call	resetHiddenFlags
	pop	af
comparestrings_checklength:
	dec	c
	ret	nz
	ccf
	ret
resetHiddenFlags:
	bit	prog1Hidden,(iy+hideFlag)
	jr	z,prog1NotHidden_chk
	ld	a,(hl)
	sub	a,64
	ld	(hl),a
prog1NotHidden_chk:
	bit	prog2Hidden,(iy+hideFlag)
	ret	z
	ld	a,(de)
	sub	a,64
	ld	(de),a
	ret
	
findnextitem:						; carry=found nc=notfound
	ex	de,hl
	ld	hl,(ptemp)
	or	a,a					; reset carry flag
	sbc	hl,de
	ret	z
	ex	de,hl					; load progptr into hl
	ld	a,(hl)
	and	1Fh					; mask out state bytes
	push	hl
	ld	hl,programtypes
	ld	bc,2
	cpir
	pop	hl
	jp	nz,skiptonext6				; skip to next entry
	dec	hl					; add check for folders here if needed
	dec	hl
	dec	hl					; to pointer
	ld	e,(hl)
	dec	hl
	ld	d,(hl)					; pointer now in de
	dec	hl
	ld	a,(hl)					; high byte now in a
	dec	hl					; add check: do I need to sort this program (not neccessary)
	scf
	ret
	
programtypes:
	.db	progobj,protprogobj