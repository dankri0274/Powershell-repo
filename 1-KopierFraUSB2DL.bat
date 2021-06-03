Rem @Echo off
Rem tms Opprett katalog og kopier filer dit - kjør fra USB.
Rem Bytt til drive på usb pinnen.
%CD:~0,2%
md c:\download
copy kjor-som-admin-3x.bat c:\download
copy edit_not_run.ps1 c:\download
copy Programmer\TeamViewer.exe c:\download
copy Programmer\DW-Inst.msi c:\download
copy Programmer\agent_cloud_x64.msi c:\download
copy Programmer\Adobe-reader-Installer c:\download

Rem Til desktop
copy "edit_not_run_SHORTCUT.lnk" %userprofile%\Desktop\ /Y
copy "kjor-som-admin-3x_SNARVEI.lnk" "%userprofile%\Desktop\" /Y

Rem Se resultatet.
pause

