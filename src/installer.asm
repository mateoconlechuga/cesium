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

	jp	installer_start

	db byte_description, 'Cesium Installer Version ', cesium_version, 0

installer_start:
	call	.clear_screen

	installer_ports.copy

	call	installer.port_setup
	or	a,a
	ld	hl,str_invalid_os_install
	jq	nz,.print_message

	call	ti.PushOP1			; save the program name

	app_create

	jr	z,.app_created
	call	ti.PopOP1
	ld	hl,str_cesium_exists_error
.print_message:
	call	ti.PutS				; put error string if cesium exists
	call	ti.GetKey
.clear_screen:
	call	ti.ClrScrn			; clear the homescreen
	jp	ti.HomeUp
.app_created:

	installer_execute_cesium.run

relocate installer_execute_cesium, ti.mpLcdCrsrImage
	call	ti.ClrScrn
	call	ti.HomeUp
	ld	hl,str_cesium_installed
	call	ti.PutS
	call	ti.GetKey
	call	ti.NewLine
	call	ti.NewLine

	ld	hl,str_delete_installer
	call	ti.PutS
	call	ti.NewLine
	call	ti.PutS				; ask the user if they want to delete me
	call	ti.PopOP1			; restore installer name

.get_key:
	call	ti.GetCSC
	or	a,a
	jr	z,.get_key
	cp	a,ti.skDel
	jr	nz,.no_delete

	call	ti.ChkFindSym			; delete the installer if needed
	call	ti.DelVarArc
.no_delete:
	call	ti.ClrScrn
	jq	ti.HomeUp

end relocate

if config_english
str_invalid_os_install:
	db  'Cannot use this OS',0
str_cesium_installed:
	db 'Installed in ',$C1,'apps] menu.',0
str_cesium_exists_error:
	db 'Cesium already installed, Please delete first.',0
str_delete_installer:
	db 'Delete installer?', 0
	db 'del - yes',0
end if

if config_french
str_invalid_os_install:
	db  'Mauvaise version d''OS',0
str_cesium_installed:
	db 'Install',$96,' dans les apps.',0
str_cesium_exists_error:
	db 'Cesium d',$96,'j',$8f,' install',$96,',     veuillez supprimer.',0
str_delete_installer:
	db 'Suppr. l',$27,'installateur?', 0
	db 'suppr - oui',0
end if

if config_dutch
str_invalid_os_install:
	db	'Geen ondersteunde OS versie',0
str_cesium_installed:
	db	'Ge',$A1,'nstalleerd bij ',$C1,'apps].',0
str_cesium_exists_error:
	db	'Cesium is al ge',$A1,'nstalleerd verwijder de oude versie!',0
str_delete_installer:
	db	'Installer verwijderen?',0
	db	'del - ja',0
end if

relocate installer_ports, cesium_execution_base
define installer
namespace installer
	include 'ports.asm'
end namespace
end relocate


