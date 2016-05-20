#include "includes\ti84pce.inc"		; TI84+CE include file
#include "includes\macros.inc"		; useful macros
#include "includes\defines.inc"		; Cesium defines

;define ENGLISH 1			; use english
#define FRENCH 1			; use french

#include "routines\installer.asm"	; if this is the first run, we want to run the installer -- this is literally 2 prgms in one

CesiumStartLoc:				; this other program is copied to an AppVar
	.org	UserMem-2
CesiumStart:
	.db	$CE,$CE			; magic bytes to satisfy other routines

#include "routines\loaderofloader.asm"	; loads the appvar into usermem

; program routines
#include "routines\main.asm"		; stick the main file right here
#include "routines\pgrmoptions.asm"	; options for prgms
#include "routines\settings.asm"	; general settings
#include "routines\delete.asm"		; prgm deletion stuff
#include "routines\usefulroutines.asm"	; common routines
#include "routines\drawprgmnames.asm"	; part of main loop
#include "routines\search.asm"		; alphabetizer
#include "routines\createbasic.asm"	; creates prgmA
#include "routines\loader.asm"		; loads a program into memory and runs it
#include "routines\common.asm"		; common routines used by many relocated chunks
#include "routines\reloader.asm"	; reloader to reload after running a program
#include "routines\lcd.asm"		; LCD routines
#include "routines\sort.asm"		; sorting routines
#include "routines\find.asm"		; program finder
#include "routines\exit.asm"		; full exit routine
#include "routines\parserhooks.asm"	; for hooks

; program data
#ifdef ENGLISH
 #include "data\textData.asm"		; text data
  #else
 #include "data\textDataFrench.asm"
#endif

CesiumIcon:								; Signifies a CesiumOS program (haha)
 .db 16,16								; Width, Height of sprite
 .db 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0DEh,0D6h,0D6h,0DEh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
 .db 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0D6h,0DEh,0DEh,0B5h,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
 .db 0FFh,0FFh,0DEh,0D6h,0D6h,0FFh,0D6h,0DEh,0DEh,0B5h,0FFh,0B5h,0B5h,0B6h,0FFh,0FFh
 .db 0FFh,0DEh,0DEh,0FEh,0DEh,0B6h,0B5h,0D6h,0D6h,0B5h,0B5h,0D6h,0DEh,0B5h,0B6h,0FFh
 .db 0FFh,0DEh,0B6h,0DEh,0D6h,0DEh,0DEh,0D6h,0D6h,0DEh,0D6h,0D6h,0D6h,06Ch,0B5h,0FFh
 .db 0FFh,0FFh,0DEh,0D6h,0D6h,0D6h,0B5h,094h,094h,0B5h,0B6h,0B5h,0B5h,0B5h,0FFh,0FFh
 .db 0D6h,0D6h,0B6h,0DEh,0D6h,0B5h,094h,0DEh,0DEh,0B5h,0B6h,0B5h,0D6h,094h,094h,094h
 .db 0B6h,0DEh,0D6h,0D6h,0D6h,0B4h,0DEh,0FFh,0FFh,0DEh,0B5h,0B6h,0B5h,0B6h,0DEh,06Bh
 .db 0B5h,0DEh,0D6h,0B6h,0D6h,0B5h,0DEh,0FFh,0FFh,0DEh,0B5h,0B5h,0B5h,0B5h,0D6h,06Bh
 .db 0B5h,094h,0B4h,0D6h,0B6h,0D6h,0B5h,0DEh,0DEh,0B5h,0B5h,0B5h,0B5h,06Bh,06Bh,06Bh
 .db 0FFh,0FFh,0D6h,0B6h,0B5h,0B6h,0B6h,0B5h,0B5h,0B5h,0B5h,0B5h,0B5h,0B5h,0FFh,0FFh
 .db 0FFh,0D6h,0B4h,0D6h,0B6h,0D6h,0D6h,0D6h,0B6h,0D6h,0B6h,0B5h,0D6h,06Bh,0B5h,0FFh
 .db 0FFh,0D6h,0B5h,0DEh,0B4h,093h,093h,0B6h,0B5h,06Bh,06Bh,0B4h,0D6h,08Ch,0B5h,0FFh
 .db 0FFh,0FFh,0B5h,06Bh,06Bh,0FFh,094h,0D6h,0B6h,06Bh,0FEh,06Bh,04Ah,094h,0FFh,0FFh
 .db 0FFh,0FFh,0FFh,0DEh,0FFh,0FFh,094h,0B5h,0B5h,06Bh,0FFh,0FFh,0DEh,0FFh,0FFh,0FFh
 .db 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0B6h,08Ch,06Ch,0B5h,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
VersionStr:
 .db "Cesium Version 2.0.1",0
CesiumEnd:

 .echo "Reloader Size:\t\t",CesiumReLoader_End-CesiumReLoader_Start
 .echo "Cesium Prgm Size:\t",InstallerEnd-InstallerStart+15
 .echo "Prgm Loader Size:\t",CesiumLoader_End-CesiumLoader_Start
 .echo "Common Routines Size:\t",CommonRoutines_End-CommonRoutines_Start
 .echo "AppVar CeOS Size:\t",CesiumEnd-CesiumStart+15
