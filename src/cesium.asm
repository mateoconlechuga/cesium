include 'include/fasmg-ez80/ez80.inc'
include 'include/fasmg-ez80/tiformat.inc'
format ti executable 'CESIUM'
include 'include/ti84pceg.inc'
include 'include/app.inc'

; ------------------------------------------------
; create application
; returns nz if could not create the application
; i.e. already installed
	app_create
	
	ret	nz
	call	_ChkFindSym
	jp	_DelVarArc		; delete installer code

; ------------------------------------------------
; start of actual application code
	app_start 'Cesium', '(C) 2018 MateoConLechuga', '0.0.3.0', 3
	
	jp	_JForceCmdNoChar

; ------------------------------------------------
; Anything placed after app_data is essentially
; written to ram on start. This can be at most 4kB
; in size.
	app_data
	
Dummybyte:
	db	0
