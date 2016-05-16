@echo off
color 0F
:A
tools\spasm -E -T Cesium.asm bin\CESIUM.8xp
pause
goto A