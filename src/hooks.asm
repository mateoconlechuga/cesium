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

hook_token_stop := $d9 - $ce
hook_parser:
	db	$83			; hook signifier
	push	af
	cp	a,2
	jq	z,.maybe_stop
.chain:
	ld	a,(ti.appErr2)
	cp	a,$7f
	jq	nz,.no_chain
	pop	af
	ld	ix,(ti.appErr2 + 1)
	jp	(ix)
.no_chain:
	pop	af
	xor	a,a
	ret
.maybe_stop:
	ld	a,hook_token_stop	; check if stop token
	cp	a,b
	jq	nz,.chain
.stop:
	pop	af
	ld	a,ti.E_AppErr1
	jq	ti.JError

hook_app_change:
	db	$83
	ld	c,a
	ld	a,b
	cp	a,ti.cxPrgmEdit		; only allow when editing
	ld	b,a
	ret	nz
	ld	a,c
	or	a,a
	jq	z,.close_editor
	cp	a,ti.cxMode
	ret	z
	cp	a,ti.cxFormat
	ret	z
	cp	a,ti.cxTableSet
	ret	z
	call	.close_editor
	ld	a,return_prgm
	ld	(return_info),a
	jp	cesium_start
.close_editor:
	push	af, bc, hl
	call	ti.CursorOff
	call	ti.CloseEditEqu
	call	ti.PopOP1
	call	ti.ChkFindSym
	jr	c,.noarc
	ld	a,(edit_status)
	or	a,a
	call	nz,cesium.Arc_Unarc
.noarc:
	pop	hl, bc, af
	ret

hook_get_key:
	db	$83
	cp	a,$1b
	ret	nz
	ld	a,b
	push	af
	push	hl
	ld	hl,$f0202c
	ld	(hl),l
	ld	l,h
	bit	0,(hl)
	pop	hl
	jr	nz,.check_for_shortcut_key
	pop	af
	cp	a,ti.sk2nd
	ret	nz
	ld	a,ti.sk2nd - 1				; maybe some other day
	inc	a
	ret
.check_for_shortcut_key:
	pop	af
	cp	a,ti.skStat
	jp	z,hook_password
	cp	a,ti.skGraph
	jr	z,hook_show_labels
	cp	a,ti.skPrgm
	jq	z,hook_execute_cesium
	cp	a,ti.sk8
	jq	z,hook_backup_ram
	cp	a,ti.sk5
	jq	z,hook_clear_backup
	cp	a,ti.sk2
	jq	z,hook_restore_ram
	cp	a,ti.skStore
	jq	z,hook_invert_colors
	ret

hook_invert_colors:
	push	hl
	ld	hl,$F80818
	ld	(hl),h
	ld	(hl),$44
	ld	(hl),$21
	ld	l,h
	ld	(hl),$01
	pop	hl
	xor	a,a
	inc	a
	ret

label_number := ti.cursorImage + 3
label_number_of_pages := label_number + 3
label_page := label_number_of_pages + 3
label_name := label_page + 3

hook_show_labels:
	di
	ld	a,(ti.cxCurApp)
	cp	a,ti.cxPrgmEdit
	jq	nz,hook_get_key_none

	hook_strings.copy

	call	ti.CursorOff

	or	a,a
	sbc	hl,hl
	ld	(label_page),hl
	inc	l
	inc	l
	ld	(label_number),hl
	call	ti.ClrTxtShd
	call	ti.BufToTop

	call	.countlabels

	ld	bc,0
.getlabelloop:
	call 	ti.ClrScrn
	call	ti.BufToTop

	call	.drawlabels

	ld	hl,(label_page)
	ld	de,.current_page_string
	inc	hl
	call	helper_num_convert

	ld	hl,.page_string
	call	helper_vputs_toolbar

.getkey:
	di
	call	ti.DisableAPD
	call	ti.GetCSC
	or	a,a
	jq	z,.getkey
	ld	bc,1
	cp	a,ti.sk0
	jq	z,.movetolabel
	inc	c
	cp	a,ti.sk1
	jq	z,.movetolabel
	inc	c
	cp	a,ti.sk2
	jq	z,.movetolabel
	inc	c
	cp	a,ti.sk3
	jq	z,.movetolabel
	inc	c
	cp	a,ti.sk4
	jq	z,.movetolabel
	inc	c
	cp	a,ti.sk5
	jq	z,.movetolabel
	inc	c
	cp	a,ti.sk6
	jq	z,.movetolabel
	inc	c
	cp	a,ti.sk7
	jq	z,.movetolabel
	inc	c
	cp	a,ti.sk8
	jq	z,.movetolabel
	inc	c
	cp	a,ti.sk9
	jq	z,.movetolabel
	cp	a,ti.skLeft
	jq	z,.prevpage
	cp	a,ti.skRight
	jq	z,.nextpage
	jq	.getkey

.movetolabel:
	ld	a,(ti.curRow)
	cp	a,c
	jr	z,.okay
	jr	c,.getkey
.okay:
	ld	hl,(label_page)
        add	hl,de
	or	a,a
	sbc	hl,de
	jr	nz,.normallabel
	ld	a,c
	dec	c
	dec	c
	dec	a
	jq	nz,.nottop
	call	ti.BufToTop
	jq	.gotoeditor
.nottop:
	dec	a
	jq	nz,.normallabel
	call	ti.BufToBtm
	jq	.gotoeditor
.normallabel:
	call	.computepageoffsethl
	add	hl,bc
	push	hl
	call	ti.BufToTop
	pop	bc
	call	.skiplabels
	call	ti.BufLeft
.gotoeditor:
	call 	ti.ClrScrn
	xor	a,a
	ld	(ti.curCol),a
	ld	(ti.curRow),a
	ld	a,(ti.winTop)
	or	a,a
	jr	z,.incesiumeditor	; check if using cesium feature
	ld	hl,.program_string
	call	ti.PutS
	ld	hl,ti.progToEdit
	call	ti.PutS
	call	ti.NewLine
.incesiumeditor:
	ld	a,':'
	call	ti.PutMap
	ld	a,1
	ld	(ti.curCol),a
.backup:
	call	ti.BufLeft
	jr	z,.done
	ld	a,d
	or	a,a
	jr	nz,.backup
	ld	a,e
	cp	a,ti.tEnter
	jr	nz,.backup
	call	ti.BufRight
.done:
	call	ti.DispEOW
	call	ti.CursorOn
	call	ti.DrawStatusBar
	jq	hook_get_key_none

.nextpage:
	ld	hl,(label_page)
	ld	de,(label_number_of_pages)
	or	a,a
	sbc	hl,de
	add	hl,de
	jr	z,.firstpage
	inc	hl
	jr	.setpage
.firstpage:
	or	a,a
	sbc	hl,hl
.setpage:
	ld	(label_page),hl
	jq	.getlabelloop
.prevpage:
	ld	hl,(label_page)
	add	hl,de
	or	a,a
	sbc	hl,de
	jr	z,.lastpage
	dec	hl
	jr	.setpage
.lastpage:
	ld	hl,(label_number_of_pages)
	jr	.setpage

.countlabels:
	call	ti.BufToTop
.loop:
	call	ti.BufRight
	jr	z,.getnumpages
	ld	a,d
	cp	a,ti.t2ByteTok
	jr	z,.loop
	ld	a,e
	cp	a,ti.tLbl
	jr	nz,.loop
	ld	hl,(label_number)
	inc	hl
	ld	(label_number),hl
	jr	.loop
.getnumpages:
	ld	hl,(label_number)
	dec	hl
	ld	a,10
	call	ti.DivHLByA
	ld	(label_number_of_pages),hl
	inc	hl
	ld	de,.total_page_string
	jp	helper_num_convert

.skiplabelsloop:
	push	bc
	call	ti.BufRight
	pop	bc
	ret	z
	ld	a,d
	cp	a,ti.t2ByteTok
	jr	z,.skiplabelsloop
	ld	a,e
	cp	a,ti.tLbl
	jr	nz,.skiplabelsloop
	dec	bc
.skiplabels:
	sbc	hl,hl
	adc	hl,bc
	jr	nz,.skiplabelsloop
	ret

.drawlabels:
	xor	a,a
	ld	(ti.curCol),a
	ld	(ti.curRow),a
	ld	hl,(label_page)
        add	hl,de
	or	a,a
	sbc	hl,de
	jr	nz,.normalpage
	ld	hl,.top_label
	call	ti.PutS
	xor	a,a
	ld	(ti.curCol),a
	inc	a
	ld	(ti.curRow),a
	ld	hl,.bottom_label
	call	ti.PutS
	call	ti.BufToTop
	xor	a,a
	ld	(ti.curCol),a
	ld	a,2
	ld	(ti.curRow),a
.normalpage:
	call	.computepageoffset
	call	.skiplabels
	ld	hl,label_name
.parse_labels:
	push	hl
	call	ti.BufRight
	pop	hl
	ret	z
	ld	a,d
	or	a,a
	jr	nz,.parse_labels
	ld	a,e
	cp	a,ti.tLbl
	jr	nz,.parse_labels
.add_label:
	push	hl
	call	ti.BufRight
	pop	hl
	jr	z,.added_label
	ld	a,e
	cp	a,ti.tColon
	jr	z,.added_label
	cp	a,ti.tEnter
	jr	z,.added_label
	ld	a,d
	or	a,a
	jr	z,.single
	ld	(hl),a
	inc	hl
.single:
	ld	(hl),e
	inc	hl
	jr	.add_label
.added_label:
	xor	a,a
	ld	(hl),a
	ld	(ti.curCol),a
	ld	a,(ti.curRow)
	add	a,'0'
	call	ti.PutC
	ld	a,':'
	call	ti.PutC
	ld	hl,label_name
	push	hl
.displayline:
	ld	a,(hl)
	or	a,a
	jr	z,.leftedge
	inc	hl
	call	ti.Isa2ByteTok
	ld	d,0
	jr	nz,.singlebyte
.multibyte:
	ld	d,a
	ld	e,(hl)
	inc	hl
	jr	.getstring
.singlebyte:
	ld	e,a
.getstring:
	push	hl
	call	ti.GetTokString
	ld	b,(hl)
	inc	hl
.loopdisplay:
	ld	a,(ti.curCol)
	cp	a,$19
	jr	z,.leftedgepop
	ld	a,(hl)
	inc	hl
	call	ti.PutC
	djnz	.loopdisplay
	pop	hl
	jr	.displayline
.leftedgepop:
	pop	hl
.leftedge:
	ld	a,(ti.curRow)
	inc	a
	ld	(ti.curRow),a
	cp	a,10
	pop	hl
	jq	nz,.parse_labels
	ret

.computepageoffsethl:
	push	bc
	call	.computepageoffset
	pop	bc
	ret
.computepageoffset:
	ld	hl,(label_page)
	add	hl,de
	or	a,a
	sbc	hl,de
	push	hl
	pop	bc
	ret	z
	ld	bc,10
	call	ti._imulu
	dec	hl
	dec	hl
	push	hl
	pop	bc
	ret

relocate hook_strings, ti.plotSScreen
.program_string:
	db	"PROGRAM:",0
.page_string:
	db	"Use <> to switch page:     <"
.current_page_string:
	db	"000"
	db	" of "
.total_page_string:
	db	"000"
	db	">",0
.top_label:
	db	"0:PRGM TOP",0
.bottom_label:
	db	"1:PRGM BOTTOM",0
end relocate

hook_flash_code_copy:
	hooks_ports.copy
	call	hooks.port_setup
	or	a,a
	ret	z
	pop	hl
	jq	hook_get_key_none

hook_clear_backup:
	call	hook_flash_code_copy
	call	hooks.flash_clear_backup
	jr	hook_get_key_none

hook_restore_ram:
	push	hl
	push	af
	ld	hl,$3c0001
	ld	a,$a5
	cp	a,(hl)
	jr	nz,.none
	dec	hl
	ld	a,$5a
	cp	a,(hl)
	jp	z,0
.none:
	pop	af
	pop	hl
	inc	a
	dec	a
	ret

hook_get_key_none:
	xor	a,a
	inc	a
	dec	a
	ret

hook_backup_ram:
	call	ti.os.ClearStatusBarLow
	ld	hl,string_ram_backup
	call	helper_vputs_toolbar
	call	hook_flash_code_copy
	call	hooks.flash_backup_ram
	call	ti.DrawStatusBar
	jr	hook_get_key_none

hook_execute_cesium:
	ld	iy,ti.flags
	call	ti.CursorOff
	call	ti.RunIndicOff
	di
	call	ti.ClrGetKeyHook
	ld	a,(ti.menuCurrent)
	cp	a,ti.kWindow
	jr	nz,.notinwindow
	ld	a,ti.kClear
	call	ti.PullDownChk			; exit from alpha + function menus
.notinwindow:
	ld	a,ti.kQuit
	call	ti.PullDownChk			; exit from randInt( and related menus
	ld	a,ti.kQuit
	call	ti.NewContext0			; just attempt a cleanup now
	call	ti.CursorOff
	call	ti.RunIndicOff
	xor	a,a
	ld	(ti.menuCurrent),a		; make sure we aren't on a menu
	ld	hl,data_string_cesium_name	; execute app
	ld	de,$d0082e			; I have absolutely no idea what this is
	push	de
	ld	bc,8
	push	bc
	ldir
	pop	bc
	pop	hl
	ld	de,ti.progToEdit		; copy it here just to be safe
	ldir
	ld	a,ti.kExtApps
	call	ti.NewContext0
	ld	a,ti.kClear
	jp	ti.JForceCmd

hook_password:
	ld	hl,data_cesium_appvar
	call	ti.Mov9ToOP1
	call	ti.ChkFindSym
	call	ti.ChkInRam
	push	af
	call	z,cesium.Arc_Unarc		; archive it
	pop	af
	jr	z,hook_password			; find the settings appvar
	ex	de,hl
	ld	de,9
	add	hl,de
	ld	e,(hl)
	add	hl,de
	inc	hl
	inc	hl
	inc	hl
	ld	de,settings_data
	ld	bc,settings_size
	ldir					; copy in the password
.wrong:
	call	ti.CursorOff
	ld	a,ti.cxCmd
	call	ti.NewContext0
	call	ti.CursorOff
	call	ti.ClrScrn
	call	ti.HomeUp
	ld	hl,data_string_password
	call	ti.PutS
	di
	call	ti.EnableAPD
	ld	a,1
	ld	hl,ti.apdSubTimer
	ld	(hl),a
	inc	hl
	ld	(hl),a
	set	ti.apdRunning,(iy + ti.apdFlags)
	ei
	ld	hl,setting_password
	ld	a,(hl)				; password length
	or	a,a
	jr	z,.correct
	ld	b,a
	ld	c,0
	inc	hl
.get_user_password:
	call	.get_key
	cp	a,(hl)
	inc	hl
	jr	z,.draw_character
	inc	c
.draw_character:
	ld	a,'*'
	call	ti.PutC
	djnz	.get_user_password
	dec	c
	inc	c
	jr 	nz,.wrong
.correct:
	ld	a,ti.kClear
	jp	ti.SendKPress
.get_key:
	push	hl
   	call	ti.GetCSC
	pop	hl
	or	a,a
	jr	z,.get_key
	ret

hook_home:
	db	$83
	cp	a,3
	ret	nz
	bit	appInpPrmptDone,(iy + ti.apiFlg2)
	res	appInpPrmptDone,(iy + ti.apiFlg2)
	ld	a,b
	ld	b,0
	ret	nz
.restore_home_hooks:
	push	af
	push	bc
	call	ti.ClrHomescreenHook
	res	appWantHome,(iy + sysHookFlg)
	pop	bc
	pop	af
	cp	a,ti.cxError
	jr	z,.return_cesium_app
	cp	a,ti.cxPrgmInput
	jr	z,.return_cesium_app
	ld	hl,backup_home_hook_location
	ld	a,(hl)
	or	a,a
	ret	z
	push	bc
	ld	hl,(hl)
	call	ti.SetHomescreenHook
	set	appWantHome,(iy + sysHookFlg)
	pop	bc
	ret
.return_cesium_app:
	cesium_code.copy
	jp	return.user_exit
.save:
	xor	a,a
	sbc	hl,hl
	bit	appWantHome,(iy + sysHookFlg)
	jr	z,.done
	ld	hl,(ti.homescreenHookPtr)
.done:
	ld	(backup_home_hook_location),hl
	ret

.put_away:
	xor	a,a
	ld	(ti.currLastEntry),a
	bit	appInpPrmptInit,(iy + ti.apiFlg2)
	jr	nz,.skip
	call	ti.ClrHomescreenHook
.skip:
	call	ti.ReloadAppEntryVecs
	call	ti.PutAway
	ld	b,0
	ret
.vectors:
	dl	$f8
	dl	ti.SaveShadow
	dl	.put_away
	dl	ti.RStrShadow
	dl	$f8
	dl	$f8
	db	0

hook_chain_parser:
	xor	a,a
	ld	(ti.appErr2),a
	bit	ti.parserHookActive,(iy + ti.hookflags4)
	jq	z,.no_chain
	ld	hl,(ti.parserHookPtr)
	ld	de,hook_parser
	or	a,a
	sbc	hl,de
	add	hl,de
	jq	z,.check_if_bad_exit
.chain_hooks:
	ld	a,(hl)
	cp	a,$83
	jq	nz,.no_chain
	ex	de,hl
	inc	de
	ld	hl,ti.appErr2
	ld	(hl),$7f
	inc	hl
	ld	(hl),de
	jq	.no_chain
.check_if_bad_exit:
	ld	hl,ti.appErr2
	ld	a,(hl)
	cp	a,$7f
	jq	nz,.no_chain
	inc	hl
	ld	hl,(hl)
	dec	hl
	jq	.chain_hooks
.no_chain:
	ld	hl,hook_parser
	jq	ti.SetParserHook

hook_restore_parser:
	bit	ti.parserHookActive,(iy + ti.hookflags4)
	jq	z,.clear_parser
	ld	hl,(ti.parserHookPtr)
	ld	de,hook_parser
	or	a,a
	sbc	hl,de
	add	hl,de
	ret	nz
	ld	hl,ti.appErr2
	ld	a,(hl)
	cp	a,$7f
	jq	nz,.clear_parser
	inc	hl
	ld	hl,(hl)
	dec	hl
	xor	a,a
	ld	(ti.appErr2),a
	jq	ti.SetParserHook
.clear_parser:
	jq	ti.ClrParserHook

helper_vputs_toolbar:
	di
	ld	a,$d0
	ld	mb,a
	ld	de,$e71c
	ld.sis	(ti.drawFGColor and $ffff),de
	ld.sis	de,(ti.statusBarBGColor and $ffff)
	ld.sis	(ti.drawBGColor and $ffff),de
	ld	a,14
	ld	(ti.penRow),a
	ld	de,2
	ld.sis	(ti.penCol and $ffff), de
	jp	ti.VPutS

helper_num_convert:
	ld	a,4
.entry:
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

relocate hooks_ports, cesium_execution_base
define hooks
namespace hooks
	include 'ports.asm'
	include 'flash.asm'
end namespace
end relocate


