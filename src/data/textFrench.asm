CesiumTitle:				; This is displayed in the header
 .db "Cesium",0
GenSettingsStr:
 .db "Options g",$82,'n',$82,"rales",0
ColorStr:
 .db "Couleur de Cesium (Touches <>)",0
RunIndicStr:
 .db "Cacher l'indicateur de calcul en BASIC",0
ProgramCountStr:
 .db "Afficher le nombre de programmes",0
ClockStr:
 .db "Afficher l'horloge",0
AutoBackupStr:
 .db "Sauver la RAM avant de lancer des prgms",0
ErrorStr:
 .db "ERREUR : Version",0
LibStr:
 .db "ERREUR : Biblioth",$8A,"que",0
LibNameStr:
 .db "Nom de la biblioth",$8A,"que : ",0
DeleteStr:
 .db "Suppr",0
 .db 126,"SUPPR]",0
SettingsStr:
 .db "Options",0
 .db 126,"MODE]",0
AttributesStr:
 .db "Attrib",0
 .db 126,"ALPHA]",0
RenameStr:
 .db "Nom",0
 .db 126,"GRAPHE]",0
DeleteConfirmStr:
 .db "Supprimer ? ",126,"ZOOM]-Oui ",126,"GRAPH]-Non",0
LanguageStr:
 .db "Langage : ",0
ez80Str:
 .db "eZ80",0
CStr:
 .db "C",0
ICEStr:
 .db "ICE",0
ICESourceStr:
 .db "ICE",0
BasicStr:
 .db "Basic",0
ArchiveStatusStr:
 .db "Archiv",$82,0
HiddenStr:
 .db "Cach",$82,0
EditStatusStr:
 .db "Verrouill",$82,0
SizeStr:
 .db "Taille : ",0
RAMFreeStr:
 .db "RAM Libre : ",0
ROMFreeStr:
 .db "ROM Libre : ",0
FileInforamtionStr:
 .db "    Infos fichier",0
NewNameStr:
 .db "Nouveau Nom -",0
CheckIconBASICStr:
 .db $3E,$44,$43,$53,$3F,$2A
settingsAppVar:
 .db appVarObj,"Cesium",0
NoProgramsStr:
 .db "No programs found",0