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
#define isAtBox                 07h
#define asmFlag			22h

#define clockIsOff		04h
#define clockFlag		22h

#define pgrmArchived		00h
#define pgrmLocked		01h
#define pgrmHidden		02h
#define isBasic			03h
#define pgrmStatus		30h

#define tmpPgrmArchived		00h
#define tmpPgrmLocked		01h
#define tmpPgrmHidden		02h
#define tmpIsBasic		03h
#define tmpPgrmStatus		21h

#define isDisabled		04h
#define isNLDisabled		05h
#define isOnAppsScreen		06h
#define bootEnter		07h
#define cesiumFlags		21h

firstprog			equ 0 ;flag in asm_Flag1
hideFlag			equ asm_Flag1
prog1hidden			equ 1
prog2hidden			equ 2
firstprogpointer 		equ pixelShadow2
endofsortedpartpointer		equ pixelShadow2+3
vatentrysize			equ pixelShadow2+6
vatentrynewloc			equ pixelShadow2+9
vatentrytempstart		equ pixelShadow2+12
vatentrytempend			equ pixelShadow2+12+15

tmpSpriteLoc	equ cursorImage

HomeHookAddr	equ appdata+50
currSel		equ appdata+200
inAppScreen	equ currSel+1
currSelAbs	equ inAppScreen+1
scrollamt	equ currSelAbs+3
HomeSave	equ scrollamt+3

tmpSettings	equ HomeSave+3
skinColor	equ tmpSettings
runIndic	equ tmpSettings+1
prgmCountDisp	equ tmpSettings+2
clockDisp	equ tmpSettings+3
autoBackup	equ tmpSettings+4
listApps	equ tmpSettings+5
shortcutKeys	equ tmpSettings+6
passLength      equ tmpSettings+7
passPtr		equ tmpSettings+8

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
