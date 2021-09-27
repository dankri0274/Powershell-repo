Rem @Echo off
Rem Bytt til drive på usb pinnen.
%CD:~0,2%
md C:\Download
copy \Nyttig\SetupPc\Run-As-Admin-3X.bat							C:\Download
copy \Nyttig\SetupPc\edit_not_run.ps1								C:\Download
copy \Nyttig\SetupPc\Programmer\TeamViewer.exe						C:\Download
copy \Nyttig\SetupPc\Programmer\DW-Inst.msi							C:\Download
copy \Nyttig\SetupPc\Programmer\agent_cloud_x64.msi					C:\Download
copy \Nyttig\SetupPc\Programmer\AcroRdrDC1900820071_nb_NO.exe		C:\Download
copy \Nyttig\SetupPc\Programmer\Google-Chrome-Installer.exe			C:\Download

Rem Til desktop
copy \Nyttig\SetupPc\edit_not_run_SHORTCUT.lnk						%userprofile%\Desktop\ /Y
copy \Nyttig\SetupPc\Run-As-Admin-3X.lnk							"%userprofile%\Desktop\" /Y

Rem Se resultatet.
pause
