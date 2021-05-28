@echo off
powershell.exe -executionpolicy remotesigned -File "c:\download\edit_not_run.ps1"
IF EXIST c:\download\File3.dat (
	del c:\download\File3.dat
	del "c:\download\edit_not_run.ps1
)
pause

