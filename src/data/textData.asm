CesiumTitle:				; This is displayed in the header
 .db "Cesium",0
LanguageStr:				; Language string
 .db "Language: ",0
ez80Str:
 .db "eZ80",0
CStr:
 .db "C",0
BasicStr:
 .db "Basic",0
ArchiveStatusStr:
 .db "Archived",0
HiddenStr:
 .db "Hidden",0
EditStatusStr:
 .db "Locked",0
SizeStr:
 .db "Size: ",0
RAMFreeStr:
 .db "RAM Free: ",0
FileInforamtionStr:
 .db "File Information",0
DeleteStr:
 .db "Delete",0
 .db 126,"DEL]",0
SettingsStr:
 .db "Settings",0
 .db 126,"MODE]",0
AttributesStr:
 .db "Attrib",0
 .db 126,"ALPHA]",0
RenameStr:
 .db "Rename",0
 .db 126,"GRAPH]",0
DeleteConfirmStr:
 .db "Delete?: ",126,"ZOOM]-Yes  ",126,"GRAPH]-No",0
settingsAppVar:
 .db appVarObj,"Cesium",0
GenSettingsStr:
 .db "General Settings",0
ColorStr:
 .db "Cesium Color (Use <> Keys)",0
RunIndicStr:
 .db "Turn off indicator in BASIC programs",0
ProgramCountStr:
 .db "Show program count",0
ClockStr:
 .db "Display clock",0
AutoBackupStr:
 .db "Backup RAM before executing programs",0
ErrorStr:
 .db "ERROR: Library Version",0
LibStr:
 .db "ERROR: Missing Library",0
LibNameStr:
 .db "Library Name: ",0
ROMFreeStr:
 .db "ROM Free: ",0
NewNameStr:
 .db "New Name -",0
CheckIconBASICStr:
 .db $3E,$44,$43,$53,$3F,$2A
CesiumAppVarName:
 .db appVarObj,"CeOS",0
