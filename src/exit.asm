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

; application exit handling routines

exit_full:
	ld	a,(current_screen)
	cp	a,screen_usb
	jq	nz,.notusb
	call	usb_detach_only
.notusb:
	exit_cleanup.run

relocate exit_cleanup, ti.mpLcdCrsrImage + 500
	bit	setting_ram_backup,(iy + settings_flag)
	call	nz,flash_clear_backup
	call	lcd_normal
	call	hook_restore_parser
	call	ti.ClrAppChangeHook
	call	util_setup_shortcuts
	call	ti.ClrScrn
	call	ti.HomeUp
	res	ti.useTokensInString,(iy + ti.clockFlags)
	res	ti.onInterrupt,(iy + ti.onFlags)
	set	ti.graphDraw,(iy + ti.graphFlags)
	ld	hl,ti.pixelShadow
	ld	bc,69090
	call	ti.MemClear
	call	ti.ClrTxtShd				; clear text shadow
	bit	3,(iy + $25)
	jr	z,.no_defrag
	ld	a,ti.cxErase
	call	ti.NewContext0				; trigger a defrag as needed
.no_defrag:
	res	ti.apdWarmStart,(iy + ti.apdFlags)
	call	ti.ApdSetup
	call	ti.EnableAPD				; restore apd
	im	1
	ei
	ld	a,ti.kQuit
	call	ti.NewContext0
	xor	a,a
	ld	(ti.menuCurrent),a
	ld	a,ti.kClear
	jp	ti.JForceCmd				; exit the application for good
end relocate
