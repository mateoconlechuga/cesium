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

port_setup:
	di
	ld	hl,($000008 + 5)
	ld	a,(hl)
	cp	a,$cd
	ret	nz
	inc	hl
	ld	de,(hl)
	ld	hl,(ti.CheckIfEmulated + 1)
	sbc	hl,de
	ret	nz
	ld	hl,(ti.KeypadScanFull + 1)
	ld	bc,10
	add	hl,bc
	push	hl
	ld	b,port_pattern.size
	ld	de,port_pattern
	call	ti.StrCmpre
	pop	hl
	ret	nz
	ld	(port_unlock.target), hl
	xor	a,a
	ret

port_pattern:
	db	$ed,$79,$78,$fe,$a0,$28,$01,$cf
.size := $-.

port_unlock:
	push	iy,de,bc,hl
	call	ti._frameset0
	ld	iy,.unlockfinish
	ld	sp,ti._indcall + 7
	ld	bc,$22
	xor	a,a

.target := $ + 1
	jp	0

.unlockfinish:
	ld	sp,ix
	pop	ix
	ld	a,$8c
	out0	($24),a
	in0	a,($06)
	or	a,4
	out0	($06),a
	jr	port_lock.pop

port_lock:
	push	iy,de,bc,hl
	xor	a,a
	out0	($28),a
	in0	a,($06)
	res	2,a
	out0	($06),a
	ld	a,$88
	out0	($24),a
	ld	a,$d1
	out0	($22),a

.pop:
	pop	hl,bc,de,iy
	ret

port_write:
	ld de,$c979ed
	ld hl,ti.heapBot - 3
	ld (hl),de
	jp (hl)

port_read:
	ld	de,$c978ed
	ld	hl,ti.heapBot - 3
	ld	(hl),de
	jp	(hl)
