; lcd handling routines for the pl1111

lcd_init:
	call	_RunIndicOff
	di						; turn off indicator
	call	lcd_clear
	ld	a,lcdBpp8
	ld	(mpLcdCtrl),a				; operate in 8bpp
	ld	hl,mpLcdPalette
	ld	b,0
.loop:
	ld	d,b
	ld	a,b
	and	a,192
	srl	d
	rra
	ld	e,a
	ld	a,31
	and	a,b
	or	a,e
	ld	(hl),a
	inc	hl
	ld	(hl),d
	inc	hl
	inc	b
	jr	nz,.loop
	ret

lcd_normal:
	call	lcd_clear
	ld	a,$2d
	ld	(mpLcdCtrl),a
	jp	_DrawStatusBar

lcd_clear:
	ld	hl,vRam
	ld	bc,((lcdWidth * lcdHeight) * 2) - 1
	jr	lcd_fill.clear

lcd_fill:
	ld	hl,vRamBuffer
	ld	bc,lcdWidth * lcdHeight - 1
.clear:
	ld	a,color_white
	jp	_MemSet

lcd_blit:
	ld	hl,vRamBuffer
	ld	de,vRam
	ld	bc,lcdWidth * lcdHeight
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
	ld	de,vRamBuffer
	add	hl,de
	ld	b,lcdWidth / 2
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
	ld	de,lcdWidth
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
	ld	hl,lcdWidth
	sbc	hl,de
	ld	(.incr),hl
	pop	hl
	inc	hl
	push	hl
	ld	l,c
	ld	h,lcdWidth / 2
	mlt	hl
	add	hl,hl
	ld	de,vRamBuffer
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
	ld	d,lcdWidth / 2
	mlt	de
	add	hl,de
	add	hl,de
	ex	de,hl
.computed:
	ld	ix,vRamBuffer			; de -> place to begin drawing
	ld	(.width),bc
.loop:
	add	ix,de
	lea	de,ix
	ld	bc,0
.width := $-3
	ld	hl,color_primary		; always just fill with the primary color
	ldi					; check if we only need to draw 1 pixel
	jp	po,.skip
	scf
	sbc	hl,hl
	add	hl,de
	ldir					; draw the current line
.skip:
	ld	de,lcdWidth			; move to next line
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
	jp	_MemSet				; bottom horizontal line

; hl = x
; e = y
lcd_horizontal:
	call	lcd_compute			; hl -> drawing location
.computed:
	jp	_MemSet

; hl = x
; e = y
lcd_vertical:
	dec	b
	call	lcd_compute			; hl -> drawing location
.computed:
	ld	de,lcdWidth
.loop:
	ld	(hl),a				; loop for height
	add	hl,de
	djnz	.loop
	ret

lcd_compute:
	ld	d,lcdWidth / 2
	mlt	de
	add	hl,de
	add	hl,de
	ld	de,vRamBuffer
	add	hl,de
	ret

lcd_string:
	ld	de,lcdWidth - 10
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
	ld	h,lcdWidth / 2
	mlt	hl
	add	hl,hl
	ld	de,vRamBuffer
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
	ld	bc,lcdWidth - character_width
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
	call	_AddHLAndA
	ld	a,(hl)				; amount to step per character
	or	a,a
	sbc	hl,hl
	ld	l,a
	add	hl,bc
	ld	(lcd_x),hl
	pop	hl
	ret

; a = amount of characters to display
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
	ld	de,string_temp
	push	de
	call	lcd_num_conv
	pop	hl
	pop	af
	call	_AddHLAndA
	jp	lcd_string

lcd_num_conv:
	ld	bc,-1000000
	call	.aqu
	ld	bc,-100000
	call	.aqu
	ld	bc,-10000
	call	.aqu
	ld	bc,-1000
	call	.aqu
	ld	bc,-100
	call	.aqu
	ld	c,-10
	call	.aqu
	ld	c,b
.aqu:
	ld	a,'0' - 1
.under:
	inc	a
	add	hl,bc
	jr	c,.under
	sbc	hl,bc
	ld	(de),a
	inc	de
	ret
