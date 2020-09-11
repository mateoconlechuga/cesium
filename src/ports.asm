; Copyright 2015-2020 Matt "MateoConLechuga" Waltz
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

os_num = 0

macro ports? v, lock, unlock
	match major.mid.minor.build, v
    		db major, mid, minor
		dl build
	end match
	dl	lock
	dl	unlock
	os_num = os_num + 1
end macro

os_table:
	ports	5.6.0.0020, port_os560.lock, port_os560.unlock
	ports	5.5.5.0011, port_os560.lock, port_os555.unlock
	ports	5.5.2.0044, port_os560.lock, port_os552.unlock
	ports	5.5.1.0038, port_os560.lock, port_os551.unlock

port_setup:
	di
	call    $21ED4
	push	hl
	pop	ix
	lea	de,ix + 6
	ld	a,(de)
	cp	a,5
	jq	nz,.invalid_os
	inc	de
	ld	a,(de)
	cp	a,5
	jq	c,.ospre55
	dec	de
	ld	b,os_num
	ld	ix,os_table
.find:
	lea	hl,ix
	push	de,bc
	ld	b,6
	call	ti.StrCmpre
	pop	bc,de
	jq	z,.found
	lea	ix,ix + 12
	djnz	.find
.invalid_os:
	inc	a
	ret
.found:
	ld	de,(ix + 6)
	ld	hl,(ix + 9)
.store_smc:
	ld	(port_unlock.code),hl
	ld	(port_lock.code),de
	xor	a,a
	ret
.ospre55:
	ld	hl,port_ospre55.unlock
	ld	de,port_ospre55.lock
	jq	.store_smc

port_ospre55:
.unlock:
	ld	bc,$24
	ld	a,$8c
	call	.write
	ld	bc,$06
	call	.read
	or	a,4
	call	.write
	ld	bc,$28
	ld	a,$4
	jq	.write
.lock:
	ld	bc,$28
	xor	a,a
	call	.write
	ld	bc,$06
	call	.read
	res	2,a
	call	.write
	ld	bc,$24
	ld	a,$88
	jq	.write
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

port_os555:
.unlock:
	ld	ix,$b96df
	jq	port_os560.unlock0

port_os552:
.unlock:
	ld	ix,$bd573
	jq	port_os560.unlock0

port_os551:
.unlock:
	ld	ix,$bd55f
	jq	port_os560.unlock0

port_os560:
.unlock:
	ld	ix,$b99bb
.unlock0:
	ld	hl,.unlockhelper
	push	hl
	ld	hl,$d09466
	push	hl
	push	de
	xor	a,a
	jp	(ix)
.unlockhelper:
	ld	a,$8c
	out0	($24),a
	in0	a,($06)
	or	a,$04
	out0	($06),a
	ld	a,$04
	out0	($28),a
	ret
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

port_unlock:
	push	de,bc,hl
	call	0
.code := $-3
.pop:
	pop	hl,bc,de
	ret

port_lock:
	push	de,bc,hl
	call	0
.code := $-3
	jq	port_unlock.pop


