; cesium
; slim gui based shell for the ti84+ce and ti83pce calculators
; feel free to use any code for your own use
; (c) 2015-2018 Matt "Mateoconlechuga" Waltz

cesium_name := 'Cesium'
cesium_version := '3.0.6'
cesium_copyright := '(C)  2015-2018 Matt Waltz'

include 'include/macros.inc'

; start by executing the installer code
; this is run once in order to create the application
include 'installer.asm'

; this is the start of the actual application
	app_start cesium_name, cesium_copyright
cesium_start:
	cesium_code.run

relocate cesium_code, cesium_execution_base
	include 'main.asm'
	include 'exit.asm'
	include 'edit.asm'
	include 'search.asm'
	include 'view-vat-items.asm'
	include 'view-apps.asm'
	include 'view-usb.asm'
	include 'features.asm'
	include 'settings.asm'
	include 'password.asm'
	include 'execute.asm'
	include 'squish.asm'
	include 'gui.asm'
	include 'lcd.asm'
	include 'util.asm'
	include 'libload.asm'
	include 'usb.asm'
	include 'find.asm'
	include 'sort.asm'
	include 'luts.asm'
	include 'sprites.asm'
	include 'strings.asm'
end relocate

; we want to keep these things in flash
include 'flash.asm'
include 'return.asm'
include 'hooks.asm'
include 'data.asm'

