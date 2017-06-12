#ifndef APP_INC
#define APP_INC

; Created by Matt "MateoConLechuga" Waltz
; Performs things to create applications for the CE

#macro app_create()
	call	_app_create
#endmacro

#macro app_start(myappname, description)
	app_start(myappname, description, 0, 1)
#endmacro

#macro app_start(myappname, description, version)
	app_start(myappname, description, version, 1)
#endmacro

#macro app_start(myappname, description, version, use_splash)
#ifdef __app_start
	.error "App already defined."
#endif
#define __use_splash eval(use_splash)
#define __app_version eval(version)
#define __app_start eval($)
	.db	$81, $0F, $00
#define addr eval(__sig-$)
	.dl	(addr>>16)|(addr&$00FF00)|(addr<<16)
	.db	$81, $12, $13, $0F
	.db	$81, $2D, $0B, "5.0.0.0089", $00
	.db	$81, $32, $59, $00
	.db	$81, namelen, myappname
	.db	$81, $A1, $07
	.db	$03, $26, $09, __app_version
	.db	$21, $BB, $6E, $DC
#define freespace eval(247-($-__app_start))
	.db	$00, $0D, freespace
	.block	freespace
	.db	$81, $7F, $00
#define addr eval(__sig-$)
	.dl	(addr>>16)|(addr&$00FF00)|(addr<<16)
__ahs:
	.db	"eZ8"
_appname:
	.db	myappname
#define appnamelen eval($-_appname)
#define namelen eval(appnamelen + $40)
#if appnamelen <= 8
	.block 8-appnamelen
#else
	.error "App name is too long."
#endif
	.db	0
        .db	1
	.db	0, 0
	.dl	0
	.dl	___app_code_start-__ahs
	.dl	__data-__ahs
	.dl	__data_end-__data
	.dl	___app_code_start-__ahs
	.dl	0, 0
	.dl	___app_information_string-__ahs
	.dl	0, 0, 0, 0
___app_information_string:
	.db	description,0
___app_code_start:
#define _app_init eval($)
	ld	hl,___relocate_end-__relocate_start
	push	hl
	call	$02051C
	pop	hl
	jp	c,$020768
	ld	de,$D1A881
	push	hl
	ld	($D0118C),hl
	call	$020514
	ld	a,$E1
	ld	($E30800),a
	ld	a,$E9
	ld	($E30801),a
	call	$E30800
	ld	bc,12
	add	hl,bc
	pop	bc
	ldir
	jp	$D1A881
#define _app_init_size eval($-_app_init)
#define __old_app_location eval($)
	.org $D1A881
#define __g_app_location eval($D1A881)
#define __relocate_start eval($)
#endmacro

#macro app_create_code()
#define _app_create eval($)
	ld	hl,_appname
	push	hl
	call	$021100
	pop	bc
	jr	z,+_
	call	_HomeUp
	call	_ClrScrn
	ld	hl,__CANECREATE
	call	_PutS
	call	_GetKey
	call	_ClrScrn
	xor	a,a
	ret
__CANECREATE:
	.db	"Error: App exists; please delete from memory        management screen",0
_:	ld	hl,$3B0000             ; applications start here
_:	push	hl
	call	$022044                ; locates start of next application header
	pop	de
	jr	z,+_
	jr	-_
_:	ex	de,hl
	dec	hl
	dec	hl
	dec	hl
	push	hl
	ld	a,$d1
	ld	mb,a
	ld.sis	sp,$987e
	call.is	+_ & $ffff
	pop	hl
	ld	de,(__app_end)
	or	a,a
	sbc	hl,de
	ex	de,hl
	ld	hl,__app_start
	ld	bc,app_real_end-__app_start
	call	$02E0
	call.is	++_ & $ffff
	ld	a,$d0
	ld	mb,a
	ret

	.assume	adl = 0
	
_:	ld	a,$8C
	out0	($24),a
	ld	c,4
	in0	a,(6)
	or	c
	out0	(6),a
	out0	($28),c
	ret.l
_:	xor	a,a
	out0	($28),a
	in0	a,(6)
	res	2,a
	out0	(6),a
	ld	a,$88
	out0	($24),a
	ret.l
	
	.assume adl = 1
#endmacro

#macro app_data()
#ifndef __app_start
	.error "App not defined."
#endif
#define ___END eval($)
#define ___relocate_end eval($)
	.org $-__g_app_location+__old_app_location
#undefine __g_app_location
#undefine __old_app_location
#define __data eval($)
	.org	$D1787C
#endmacro

#macro app_end()
	.org	$-$D1787C+__data
#define __data_end eval($)
__sig:
	.db	$02,$3e,$01,$00
	.block	256
__app_end:
	.dl	__app_end-__app_start
#define app_real_end eval($)
	app_create_code()
#endmacro

#endif
