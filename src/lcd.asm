; Copyright 2015-2024 Matt "MateoConLechuga" Waltz
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

; lcd handling routines for the pl1111

lcd_init:
	call	ti.RunIndicOff
	di					; turn off indicator
	call	ti.boot.ClearVRAM
.setup:
	ld	de,ti.mpLcdPalette	; address of mmio palette
	ld	b,e			; b = 0
.loop:
	ld	a,b
	rrca
	xor	a,b
	and	a,224
	xor	a,b
	ld	(de),a
	inc	de
	ld	a,b
	rla
	rla
	rla
	ld	a,b
	rra
	ld	(de),a
	inc	de
	inc	b
	jr	nz,.loop		; loop for 256 times to fill palette
	call	lcd_clear
	ld	a,ti.lcdBpp8
	ld	(ti.mpLcdCtrl),a	; operate in 8bpp
	ret

lcd_normal:
	ld	hl,ti.vRam
	ld	bc,((ti.lcdWidth * ti.lcdHeight) * 2) + 0
	ld	a,255
	call	ti.MemSet
	ld	a,$2d
	ld	(ti.mpLcdCtrl),a
	ret

lcd_clear:
	ld	hl,ti.vRam
	ld	bc,((ti.lcdWidth * ti.lcdHeight) * 2) + 0
	jr	lcd_fill.clear

lcd_fill:
	ld	hl,vRamBuffer
	ld	bc,ti.lcdWidth * ti.lcdHeight
.clear:
	ld	a,(color_senary)
	jp	ti.MemSet

lcd_blit:
	ld	hl,vRamBuffer
	ld	de,ti.vRam
	ld	bc,ti.lcdWidth * ti.lcdHeight
	ldir
	ret

; hl -> sprite
; bc = xy
lcd_sprite:
	push	hl
	or	a,a
	sbc	hl,hl
	ld	l,b
	add	hl,hl
	ld	de,(lcd_buffer)
	add	hl,de
	ld	b,ti.lcdWidth / 2
	mlt	bc
	add	hl,bc
	add	hl,bc				; draw location
	ld	b,0
	ex	de,hl
	pop	hl
	ld	a,(hl)
	ld	(.width),a			; width
	inc	hl
	ld	a,(hl)				; height
	inc	hl
	ld	ix,0
.width := $+1
.loop:	ld	c,0
	add	ix,de
	lea	de,ix
	ldir
	ld	de,ti.lcdWidth
	dec	a				; for height
	jr	nz,.loop
	ret

; hl -> sprite
; bc = xy
lcd_sprite_2x:
	ld	a,(hl) 				; width
	ld	(.width),a
	push	hl
	ld	hl,(.width)
	add	hl,hl
	ld	(.copy_amount),hl
	ld	de,0
	add	a,a
	ld	e,a
	ld	hl,ti.lcdWidth
	sbc	hl,de
	ld	(.incr),hl
	pop	hl
	inc	hl
	push	hl
	ld	l,c
	ld	h,ti.lcdWidth / 2
	mlt	hl
	add	hl,hl
	ld	de,(lcd_buffer)
	add	hl,de
	push	hl
	sbc	hl,hl
	ld	l,b
	add	hl,hl
	pop	de
	add	hl,de  				; hl -> sprite data
	ex	de,hl				; a = sprite height
	pop	hl
	ld	b,(hl)
	inc	hl
.loop:
	push	bc
.width := $+1
	ld	bc,0
	push	de				; save pointer to current line
.inner_loop:
	ld	a,(hl)
	ld	(de),a
	inc	de
	ld	(de),a
	inc	de
	inc	hl
	dec	bc
	ld 	a,b
	or	a,c
	jr	nz,.inner_loop
	ex	de,hl
.incr := $+1
	ld	bc,0				; increment amount per line
	add	hl,bc				; hl -> next place to draw
	push	de
	pop	ix				; ix -> location to get from
	ex	de,hl
.copy_amount := $+1
	ld	bc,0				; bc = real size to copy
	pop	hl				; hl -> previous line
	ldir
	ex	de,hl
	ld	bc,(.incr)
	add	hl,bc
	lea	de,ix
	ex	de,hl
	pop	bc
	djnz	.loop
	ret

; bc = width
; hl = x coordinate
; e = y coordinate
; a = height
lcd_rectangle:
	ld	d,ti.lcdWidth / 2
	mlt	de
	add	hl,de
	add	hl,de
	ex	de,hl
.computed:
	ld	ix,(lcd_buffer)			; de -> place to begin drawing
	ld	(.width),bc
.loop:
	add	ix,de
	lea	de,ix
	ld	bc,0
.width := $-3
	ld	hl,color_primary		; always just fill with the primary color
.color_ptr := $-3
	ldi					; check if we only need to draw 1 pixel
	jp	po,.skip
	scf
	sbc	hl,hl
	add	hl,de
	ldir					; draw the current line
.skip:
	ld	de,ti.lcdWidth			; move to next line
	dec	a
	jr	nz,.loop
	ret

; hl = x coordinate
; e = y coordinate
; bc = width
; d = height
lcd_rectangle_outline:
.computed:
	ld	a,(color_secondary)		; always use secondary color
.color:
	push	bc
	push	hl
	push	de
	call	lcd_horizontal			; top horizontal line
	pop	bc
	push	bc
	call	lcd_vertical.computed		; left vertical line
	pop	bc
	pop	hl
	ld	e,c
	call	lcd_vertical			; right vertical line
	pop	bc
	jr	lcd_horizontal.computed		; bottom horizontal line

; hl = x
; e = y
lcd_horizontal:
	call	lcd_compute			; hl -> drawing location
.computed:
	jp	ti.MemSet

; hl = x
; e = y
lcd_vertical:
	dec	b
	call	lcd_compute			; hl -> drawing location
.computed:
	ld	de,ti.lcdWidth
.loop:
	ld	(hl),a				; loop for height
	add	hl,de
	djnz	.loop
	ret

lcd_compute:
	ld	d,ti.lcdWidth / 2
	mlt	de
	add	hl,de
	add	hl,de
	ld	de,(lcd_buffer)
	add	hl,de
	ret

lcd_string:
	ld	de,ti.lcdWidth - 10
.loop:
	ld	a,(hl)
	or	a,a
	ret	z
	call	lcd_char			; saves de
	push	hl
	ld	hl,(lcd_x)
	or	a,a
	sbc	hl,de
	add	hl,de
	pop	hl
	ret	nc
	inc	hl
	jr	.loop

lcd_char:
character_width := 8
character_height := 8
	ld	bc,0
lcd_x := $-3
	push	hl
	push	af
	push	de
	push	bc
	ld	l,0
lcd_y := $-1
	ld	h,ti.lcdWidth / 2
	mlt	hl
	add	hl,hl
	ld	de,(lcd_buffer)
	add	hl,de
	add	hl,bc				; add x value
	push	hl
	sbc	hl,hl
	ld	l,a
	add	hl,hl
	add	hl,hl
	add	hl,hl
	ex	de,hl
	ld	hl,lut_character_data
	add	hl,de				; hl -> correct character
	pop	de				; de -> correct location
	ld	a,character_width
.vert_loop:
	ld	c,(hl)
	ld	b,character_height
	ex	de,hl
	push	de
lcd_text_fg := $+1
lcd_text_bg := $+2
	ld	de,0
.horiz_loop:
	ld	(hl),d
	rlc	c
	jr	nc,.bg
	ld	(hl),e
.bg:
	inc	hl
	djnz	.horiz_loop
	ld	(hl),d
	ld	bc,ti.lcdWidth - character_width
	add	hl,bc
	pop	de
	ex	de,hl
	inc	hl
	dec	a
	jr	nz,.vert_loop
	pop	bc
	pop	de
	pop	af				; character
	cp	a,128
	jr	c,.too_big
	xor	a,a
.too_big:
	ld	hl,lut_character_spacing
	call	ti.AddHLAndA
	ld	a,(hl)				; amount to step per character
	or	a,a
	sbc	hl,hl
	ld	l,a
	add	hl,bc
	ld	(lcd_x),hl
	pop	hl
	ret

lcd_num_7:
	ld	a,1
	jr	lcd_num
lcd_num_6:
	ld	a,2
	jr	lcd_num
lcd_num_5:
	ld	a,3
	jr	lcd_num
lcd_num_4:
	ld	a,4
	jr	lcd_num
lcd_num_3:
	ld	a,5
	jr	lcd_num
lcd_num:
	dec	a
	push	af
	call	util_num_convert
	ex	de,hl
	pop	af
	call	ti.AddHLAndA
	jp	lcd_string

lcd_buffer:
	dl	vRamBuffer
