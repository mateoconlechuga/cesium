#include "include/ti84pce.inc"          ; TI84+CE include file
#include "include/macros.inc"           ; useful macros
#include "include/defines.inc"          ; cesium defines
#include "include/app.inc"              ; for creating the application

#define ENGLISH                         ; use english
;#define FRENCH                         ; use french

#include "routines/installer.asm"       ; if this is the first run, we want to run the installer

app_start("Cesium", "(c) 2017 Matt Waltz")

CesiumStart:

; program routines
#include "routines/main.asm"            ; stick the main file right here
#include "routines/pgrmoptions.asm"     ; options for prgms
#include "routines/settings.asm"        ; general settings
#include "routines/delete.asm"          ; prgm deletion stuff
#include "routines/usefulroutines.asm"  ; common routines
#include "routines/drawprgmnames.asm"   ; part of main loop
#include "routines/search.asm"          ; alphabetizer
#include "routines/loader.asm"          ; loads a program into memory and runs it
#include "routines/common.asm"          ; common routines used by many relocated chunks
#include "routines/reloader.asm"        ; reloader to reload after running a program
#include "routines/lcd.asm"             ; LCD routines
#include "routines/sort.asm"            ; sorting routines
#include "routines/find.asm"            ; program finder
#include "routines/exit.asm"            ; full exit routine
#include "routines/parserhooks.asm"     ; for hooks

; program data
#ifdef ENGLISH
 #include "data/textData.asm"           ; text data
  #else
 #include "data/textDataFrench.asm"
#endif

CesiumIcon: ; Signifies a CesiumOS program (haha)
 .db 16,16  ; Width, Height of sprite
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
 .db "Cesium Version 2.3.0",0
CesiumEnd:

app_data()
app_end()

 .echo "Reloader Size:\t\t",CesiumReLoader_End-CesiumReLoader_Start
 .echo "Prgm Loader Size:\t",CesiumLoader_End-CesiumLoader_Start
 .echo "Common Routines Size:\t",CommonRoutines_End-CommonRoutines_Start
 .echo "AppVar CeOS Size:\t",CesiumEnd-CesiumStart
