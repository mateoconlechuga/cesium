DeletePrgm:
 call CheckIfCurrentProgramIsUs		; let's make sure we don't delete ourselves ;)
 jp z,DrawSettingsMenu
 call ClearLowerBar
 SetInvertedTextColor()
 print(DeleteStr,4,228)
 SetDefaultTextColor()
 call fullbufCpy
waitForInput:
 call _getcsc
 cp skZoom
 jr z,DeletePrgmYes
 cp skgraph
 jp z,MAIN_START_LOOP
 jr waitForInput
DeletePrgmYes:
 ld hl,(prgmNamePtr)
 call NamePtrToOP1			; move the selected name to OP1
 call _chkfindsym
 call _delvararc
 call getNextPrgmUp
 jp MAIN_START_LOOP_1			; reload everything