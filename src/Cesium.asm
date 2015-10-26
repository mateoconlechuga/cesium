#include "includes\ti84pce.inc"		; TI84+CE include file
#include "includes\macros.inc"		; useful macros
#include "includes\defines.inc"		; CesiumOS defines

#define ENGLISH 1			; use english
;#define FRENCH 1			; use french

 .org usermem-2
; if this is the first run, we want to run the installer -- this is literally 2 prgms in one
#include "routines\installer.asm"

CesiumStartLoc:
; this other program is copied to an AppVar
 .org usermem-2
CesiumStart:
 .db $CE,$CE				; magic bytes to satisfy other routines
 di					; disable interrupts
 call _runindicoff 			; turn off the indicator
#include "routines\main.asm"		; stick the main file right here

; program routines
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
#include "routines\text.asm"		; text routiness
#include "routines\lcd.asm"		; LCD routiness
#include "routines\sort.asm"		; sorting routiness
#include "routines\find.asm"		; program finder
#include "routines\exit.asm"		; full exit routine
#include "routines\parserhooks.asm"	; for hooks

; program data
#ifdef ENGLISH
 #include "data\textData.asm"		; text data
 #else
 #include "data\textDataFrench.asm"
#endif
PROGRAM_HEADER:									; Signifies a CesiumOS program (haha)
 .db 16,16								; Width, Height of sprite
 .db 255,255,255,255,000,000,000,000,255,255,255,255,255,000,000,000
 .db 255,255,000,000,000,000,000,000,255,255,255,000,000,000,000,000
 .db 255,000,000,000,000,000,000,000,255,255,000,000,000,000,000,000
 .db 255,000,000,000,000,000,000,000,255,000,000,000,000,000,000,000
 .db 000,000,000,000,000,000,255,255,255,000,000,000,000,000,255,255
 .db 000,000,000,000,000,255,255,255,000,000,000,000,000,255,255,255
 .db 000,000,000,000,255,255,255,255,000,000,000,000,000,000,000,000
 .db 000,000,000,000,255,255,255,255,000,000,000,000,000,000,000,000
 .db 000,000,000,000,255,255,255,255,000,000,000,000,000,000,000,000
 .db 000,000,000,000,255,255,255,255,000,000,000,000,000,000,000,000
 .db 000,000,000,000,000,255,255,255,000,000,000,000,000,255,255,255
 .db 000,000,000,000,000,000,255,255,255,000,000,000,000,000,255,255
 .db 255,000,000,000,000,000,000,000,255,000,000,000,000,000,000,000
 .db 255,000,000,000,000,000,000,000,255,255,000,000,000,000,000,000
 .db 255,255,000,000,000,000,000,000,255,255,255,000,000,000,000,000
 .db 255,255,255,255,000,000,000,000,255,255,255,255,255,000,000,000
VersionStr:
 .db "Cesium Version 1.1.3",0
CesiumEnd:

 .echo "Prgm Loader Size:\t",CesiumLoader_End-cesiumLoader_Start
 .echo "Reloader Size:\t\t",cesiumReLoader_End-cesiumReLoader_Start
 .echo "Avail. Reloader Size:\t",245-(cesiumReLoader_End-cesiumReLoader_Start)