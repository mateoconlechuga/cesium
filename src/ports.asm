; Copyright 2015-2023 Matt "MateoConLechuga" Waltz
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

port_setup:
	di
	ld	b,1
	or	a,a
	sbc	hl,hl
.find:
	ld	a,(hl)
	inc	hl
	cp	a,$80
	jq	z,.found_80
	cp	a,$ed
	jq	nz,.find
	ld	a,(hl)
	sub	a,$41
	jq	z,.found_ed41
	cp	a,$73
	jq	nz,.find
	dec	b
	dec	hl
	ld	(port_new.target),hl
	inc	hl
	jq	.find
.found_80:
	ld	a,(hl)
	cp	a,$0f
	jq	nz,.find
	and	a,b
	ret	nz
	ld	hl,port_new.unlock
	jq	.store_smc
.found_ed41:
	dec	hl
	ld	(port_old.target),hl
	inc	hl
	push	hl
	pop	ix
	bit	0,(ix+4)
	jq	nz,.find
	ld	hl,port_old.unlock
.store_smc:
	ld	(port_unlock.code),hl
	ret

port_old:
.unlock:
	call	.unlockhelper
.unlockfinish:
	ld	a,$8c
	out0	($24),a
	in0	a,($06)
	or	a,4
	out0	($06),a
	ret
.unlockhelper:
	call	ti._frameset0
	push	de
	ld	bc,$0022
	jp	0
.target := $-3
.write:
	ld	de,$c979ed
	ld	hl,ti.heapBot - 3
	ld	(hl),de
	jp	(hl)
.read:
	ld	de,$c978ed
	ld	hl,ti.heapBot - 3
	ld	(hl),de
	jp	(hl)

port_new:
.unlock:
	ld	de,$d19881
	push	de
	or	a,a
	sbc	hl,hl
	push	hl
	ld	de,$03d1
	push	de
	push	hl
	call	.unlockhelper
	ld	hl,12
	add	hl,sp
	ld	sp,hl
	jq	port_old.unlockfinish
.unlockhelper:
	push	hl
	ex	(sp),ix
	add	ix,sp
	push	hl
	push	de
	ld	de,$887c00
	push	de
	ld	bc,$10de
	ld	de,$0f22
	add	hl,sp
	jp	0
.target := $-3
.lock:
	xor	a,a
	out0	($28),a
	in0	a,($06)
	res	2,a
	out0	($06),a
	ld	a,$88
	out0	($24),a
	ld	a,$d1
	out0	($22),a
	ret

port_read:
	push	iy,de,bc,hl
	call	port_old.read
	jr	port_lock.pop

port_write:
	push	iy,de,bc,hl
	call	port_old.write
	jr	port_lock.pop

port_unlock:
	push	iy,de,bc,hl
	call	0
.code := $-3
	jr	port_lock.pop

port_lock:
	push	iy,de,bc,hl
	call	port_new.lock
.pop:
	pop	hl,bc,de,iy
	ret
