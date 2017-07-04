#define HIGHLIGHT_COLOR 230
#define BG_COlOR_INDEX  107
#define CESIUM_VERSION	001h
#define CESIUM_BYTE	0CEh

#define vbuf1			vram
#define vbuf2			vram+(320*240)
#define relocDependentLib	00h
#define previouslyExtracted	01h
#define scrollDown		02h
#define drawingSelected		03h
#define drawPrgmCnt		05h
#define isspecialprog		06h
#define asmFlag			22h

#define clockIsOff		04h
#define clockFlag		22h

#define pgrmArchived		00h
#define pgrmLocked		01h
#define pgrmHidden		02h
#define isBasic			03h
#define pgrmStatus		23h

#define tmpPgrmArchived		00h
#define tmpPgrmLocked		01h
#define tmpPgrmHidden		02h
#define tmpIsBasic		03h
#define tmpPgrmStatus		21h


IntEnableMask	equ	0F00004h
IntLatchBits	equ	0F0000Ch

firstprog				equ 0 ;flag in asm_Flag1
hideFlag				equ asm_Flag1
prog1hidden				equ 1
prog2hidden				equ 2
firstprogpointer 			equ savesscreen
endofsortedpartpointer			equ savesscreen+3
vatentrysize				equ savesscreen+6
vatentrynewloc				equ savesscreen+9
vatentrytempstart			equ savesscreen+12
vatentrytempend				equ savesscreen+12+15

tmpSpriteLoc	equ cursorImage

stubLocation	equ appdata

currSel		equ stubLocation+121	; 121 bytes in which to place the reloader
currSelAbs	equ currSel+3
scrollamt	equ currSelAbs+3
tmpSettings	equ scrollamt+3

skinColor	equ tmpSettings
RunIndic	equ tmpSettings+1
PrgmCountDisp	equ tmpSettings+2
clockDisp	equ tmpSettings+3
AutoBackup	equ tmpSettings+4

prgmNamePtr	equ tmpSettings+10
prgmDataPtr	equ prgmNamePtr+3
actualSizePrgm	equ prgmDataPtr+3
totalPrgmSize	equ actualSizePrgm+3
prgmbyte	equ totalPrgmSize+3
arcStatus	equ prgmbyte+1
tmpPrgmNamePtr	equ arcStatus+1
PgrmOptions	equ tmpPrgmNamePtr+3
ArchiveSet	equ PgrmOptions
LockSet		equ ArchiveSet+1
HideSet		equ LockSet+1
currMenuSel	equ HideSet+1

#macro relocateNest(newlocation)
 #ifdef oldlocation
 .echo "Mateo: ",__file,":",__line,": Error: You cannot nest relocated blocks."
 #else
 #define oldlocation eval($)
 .org newlocation
 #define glocation eval(newlocation)
 #endif
#endmacro

#macro endrelocateNest()
 #ifdef glocation
 .org $-glocation + oldlocation
 #undefine glocation
 #undefine oldlocation
 #else
 .echo "Error line ",__line,": No relocate statements corresponds to this endrelocate."
 #endif
#endmacro

#macro relocate(new_location)
 #ifdef old_location
 .echo "Mateo: ",__file,":",__line,": Error: You cannot nest relocated blocks."
 #else
 #define old_location eval($)
 .org new_location
 #define g_location eval(new_location)
 #endif
#endmacro

#macro endrelocate()
 #ifdef g_location
 .org $-g_location + old_location
 #undefine g_location
 #undefine old_location
 #else
 .echo "Error line ",__line,": No relocate statements corresponds to this endrelocate."
 #endif
#endmacro
