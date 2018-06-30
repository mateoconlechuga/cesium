; cesium
; slim gui based shell for the ti84+ce and ti83pce calculators
; feel free to use any code for your own use
; (c) 2015-2018 matt "mateoconlechuga" waltz

include 'include/macros.inc'

; start by executing the installer code
; this is run once in order to create the application
include 'installer.asm'

; this is the start of the actual application
	app_start cesium_name, cesium_copyright, cesium_version
	cesium_code.run

relocate cesium_code, cesium_execution_base
	include 'main.asm'
	include 'exit.asm'
	include 'settings.asm'
	include 'password.asm'
	include 'gui.asm'
	include 'util.asm'
	include 'text.asm'
	include 'flash.asm'
end relocate

include 'data.asm'
