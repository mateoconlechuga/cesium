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

; made by martin warmer, mmartin@xs4all.nl
; modified for ez80 architecture and hidden programs by matt waltz
;
; uses insertion sort to sort the vat alphabetically

sort_vat:
	ld	a,$30
	ld	(sort_next.smc_jump),a
	ld	hl,(ti.progPtr)
sort_next:
	call	sort_find_next_item
	ret	nc
.found_item:
	jr	nc,.already_found_first_item
.smc_jump := $-2
	ld	(.smc_first_item_found_ptr),hl		; to make it only execute once
	call	sort_skip_name
	ld	(.smc_end_of_part_ptr),hl
	ld	a,$18
	ld	(sort_next.smc_jump),a
	jr	sort_next
.already_found_first_item:
	push	hl
	call	sort_skip_name
	pop	de
	push	hl					; to continue from later on
	ld	hl,0
.smc_first_item_found_ptr := $-3
	jr	.search_next_start			; could speed up sorted list by first checking if it's the last item (not neccessary)
.search_next:
	call	sort_skip_name
	ld	bc,0
.smc_end_of_part_ptr := $-3
	or	a,a					; reset carry flag
	push	hl
	sbc	hl,bc
	pop	hl
	jr	z,.location_found
	ld	bc,-6
	add	hl,bc
.search_next_start:
	push	hl
	push	de
	call	sort_compare_names
	pop	de
	pop	hl
	jr	nc,.search_next
.search_next_end:
	ld	bc,6
	add	hl,bc					; goto start of entry
.location_found:
	ex	de,hl
	ld	a,(hl)
	add	a,7
	ld	bc,6					; rewind six bytes
	add	hl,bc					; a = number of bytes to move
	ld	c,a					; hl -> bytes to move
	ld	(.smc_vat_entry_size),bc		; de -> move to location
	ld	(.smc_vat_entry_new_loc),de
	push	de
	push	hl
	or	a,a
	sbc	hl,de
	pop	hl
	pop	de
	jr	z,.no_move_needed
	push	hl
	ld	de,sort_temp_entry
	lddr						; copy entry to move to sort_temp_entry

	ld	hl,0
.smc_vat_entry_new_loc := $-3
	pop	bc
	push	bc
	or	a,a
	sbc	hl,bc
	push	hl
	pop	bc
	pop	hl
	inc	hl
	push	hl
	ld	de,0
.smc_vat_entry_size := $-3
	or	a,a
	sbc	hl,de
	ex	de,hl
	pop	hl
	ldir
	ld	hl,sort_temp_entry
	ld	bc,(.smc_vat_entry_size)
	ld	de,(.smc_vat_entry_new_loc)
	lddr
	ld	hl,(.smc_end_of_part_ptr)
	ld	bc,(.smc_vat_entry_size)
	or	a,a
	sbc	hl,bc
	ld	(.smc_end_of_part_ptr),hl
	pop	hl					; pointer to continue from
	jp	sort_next				; to skip name and rest of entry
.no_move_needed:
	pop	hl
	ld	(.smc_end_of_part_ptr),hl
	jp	sort_next

sort_skip_name:
	ld	bc,0
	ld	c,(hl)					; number of bytes in name
	inc	c					; to get pointer to data type byte of next entry
	or	a,a					; reset carry flag
	sbc	hl,bc
	ret

sort_compare_names:					; hl and de pointers to strings output=carry if de is first
	ld	b,(hl)
	ld	a,(de)
	ld	c,0
	cp	a,b					; check if same length
	jr	z,.hl_longer
	jr	nc,.hl_longer				; b = smaller than a
	inc	c					; to remember that b was larger
	ld	b,a					; b was larger than a
.hl_longer:
	push	bc
	ld	b,64
	dec	hl
	dec	de
	ld	a,(hl)
	cp	a,b
	jr	nc,.first_not_hidden			; check if files are hidden
	add	a,b
.first_not_hidden:
	ld	c,a
	ld	a,(de)
	cp	a,b
	jr	nc,.second_not_hidden
	add	a,b
.second_not_hidden:
	cp	a,c
	pop	bc
	jr	.start
.loop:
	dec	hl
	dec	de
	ld	a,(de)
	cp	a,(hl)
.start:
	ret	nz
	djnz	.loop
	dec	c
	ret	nz
	ccf
	ret

sort_find_next_item:					; carry = found, nc = notfound
	ex	de,hl
	ld	hl,(ti.pTemp)
	or	a,a					; reset carry flag
	sbc	hl,de
	ret	z
	ex	de,hl					; load progptr into hl
	ld	a,(hl)
	and	a,$1f					; mask out state bytes
	cp	a,ti.ProgObj
	jr	z,.noskip
	cp	a,ti.ProtProgObj
	jr	z,.noskip
	cp	a,ti.AppVarObj
	jr	z,.noskip
	ld	bc,-6
	add	hl,bc
	call	sort_skip_name
	jr	sort_find_next_item			; look for next item
.noskip:
	dec	hl					; add check for folders here if needed
	dec	hl
	dec	hl					; to pointer
	ld	e,(hl)
	dec	hl
	ld	d,(hl)					; pointer now in de
	dec	hl
	ld	a,(hl)					; high byte now in a
	dec	hl					; add check: do I need to sort this program
	scf
	ret

	db	0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0
sort_temp_entry:
