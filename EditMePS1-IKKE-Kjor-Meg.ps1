#290120 USB pinne for setup av pc.
#Oppdatert: 220420-0810,1052,1400, 100221
# Set-ExecutionPolicy RemoteSigned
#Forberedelser:
# Del2 - sjekk domene bruker for å medlde pc inn i domenet.
# Finn:
#	-pc-navn i regnearket eller registre det der.
#	-brukernavn til eier.
#	-lokal administratorer gruppen: legg inn brukere som testit3, eier og andre grupper som grpNarvikVann.
#
# Installer og oppdater win10. Ofte 2-3 runder.
# Opprett c:\download og kopier inn doit.txt og teamviewer.exe - slett etter installasjonen.
# Åpne powershell i administrator modus.
# -lim inn og kjør fortløpende del1, 2 og 3 - restart mellom delene.
#
#########################################################
#--Start del0-- Velg del 1,2 eller 3
#
#Sette verdier på variable.
#1-Sette - Gi navn , .Net 3.4, smb1.0, restart
#2-Melde inn i narkom og restarte.
#3-Medlemskap i grupper, kopier ut programmer, 
#
$Valg = read-host "Oppgi valg 1 (PcNavn, NetFx3, smb) - 2 (domene) eller 3 (eier, grupper, tv, dw) "
#Sjekk 1-2-3
#
#########################################################
#Bruker: .\it
#Initiere variable - felles.

#Navn på pc. Bør sjekke dette - feks. >5 tegn.
$Pc1="abcdef-2001"

#Owner vil bli lokal administrator.
$Owner=""

#Meld inn i narkom Y/N
$InNarkom="Y"

#For enheter N/Y - dersom InNarkom=Y skal en av de under være Y og den andre N
$NarvikVann="N"
$Areal="N"
$Okonomi="N"

#testit3 - malbruker i narkom
$testit3="Y"

#Sette passord på .\it til 100000it Y/N - i narkom deaktiveres .\it så har ingen betydning.
$SettPwdIT="N"

#For debug Y/N
$DoDebug="N"

#Svar
$reply = ""

# Lokal admin bruker ved installasjon: it - nk - ?
$Bruker="it"

#########################################################
#--Start del1--ps som administrator--------------------------
#Pålogget med bruker = $Bruker
if ($Valg -eq "1") {
#Gi pc nytt navn - $Pc1
# Powershell
# ...
# Start-Process powershell -Verb runAs
# Ender opp med ps som administrator - uten å kjøre rename...
rename-computer $Pc1

#NetFx3 - også mulig med iso.
DISM /Online /Enable-Feature /FeatureName:NetFx3 /NoRestart

#SMB 1.0 enable
# disse spør om restart av pc - svarer n. Hvordan automatisere?
dism /online /enable-feature /all /featurename:SMB1Protocol /NoRestart
dism /online /enable-feature /featurename:SMB1Protocol-client /NoRestart
dism /online /disable-feature /featurename:SMB1Protocol-server /NoRestart
dism /online /disable-feature /featurename:SMB1Protocol-deprecation /NoRestart
#
pause
restart-computer
#
#--End del1----------------------------
}
#########################################################
#--Start del2--ps som administrator--------------------------
#Pålogget med bruker = $Bruker
#-------------------
if ($Valg -eq "2") {
if ($InNarkom -eq "Y") {
	$adminuser = Read-Host -Prompt "Enter your admin username" #28.05.2021 Daniel / Lagt til funksjon som setter inn brukernavnet brukeren skrev inn
	$adminuserpassword = Read-Host -Prompt "Enter admin user password" -AsSecureString #28.05.2021 Daniel / Fungerer foreløpig ikke
	Add-computer -DomainName "narvik.kommune.no" -Credential $adminuser
	Send-Keys $adminuserpassword
	Send-Keys ENTER
	#Melding om restart vises...
pause
restart-computer
}
}
#--End del2----------------------------
#########################################################
#--Start del3--ps som administrator--------------------------
#Pålogget med bruker = $Bruker
#-------------------
if ($Valg -eq "3") {
#Nb! 
#	$InNarkom
#	$DoDebug

#Test her...
#New-Item -Path 'c:\download\File3.dat' -ItemType File -Force
#pause
#break
#Test her...	
	
#For NarvikVann med i narkom.
if ($InNarkom -eq "Y") {
	if ($NarvikVann -eq "Y") {
		net localgroup administratorer grpNarvikVann /add
		if ($DoDebug -eq "Y") {"grpNarvikVann lagt inn i lokale administratorer."}
	}
}

#For Areal med i narkom.
if ($InNarkom -eq "Y") {
	if ($Areal -eq "Y") {
		net localgroup administratorer grpArealPCAdmins /add
		if ($DoDebug -eq "Y") {"grpArealPCAdmins lagt inn i lokale administratorer."}
	}
}

#For økonomi med i narkom.
if ($InNarkom -eq "Y") {
	if ($Okonomi -eq "Y") {
		net localgroup administratorer grpOkonPCAdmins /add
		if ($DoDebug -eq "Y") {"grpNarvikVann lagt inn i lokale administratorer."}
	}
}

#testit3
if ($InNarkom -eq "Y") {
	if ($testit3 -eq "Y") {
		net localgroup administratorer testit3 /add
		if ($DoDebug -eq "Y") {"testit3 lagt inn i lokal admin gruppe - malbruker i narkom."}
	}
}

#Eier.
if ($Owner.length -gt 0) {
	net localgroup administratorer $Owner /add
	if ($DoDebug -eq "Y") {"Eier lagt inn i lokale administratorer."}
}

#Kopier inn teamviewer.exe til felles desktop.
copy-item c:\download\TeamViewer.exe C:\Users\Public\Desktop\
# DameWare og Trend må installeres manuelt fra c:\Download 

#Sette passord til lokal administrator - utgår ikke - og enable den.
$apwd=Read-Host "Oppgi passord til lokal administrator" -AsSecureString
$Nyttapwd=[Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($apwd))
net user administrator $Nyttapwd
Remove-Variable Nyttapwd
Remove-Variable apwd
net user administrator /activ:yes

#Set passord til .\It - konto utløper aldri er default. For feks. skypepcer.
if ($SettPwdIt="Y" -eq "Y") {
	$itpwd=Read-Host "Oppgi passord til lokal it konto" -AsSecureString
	$Nyttitpwd=[Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($apwd))
	Remove-Variable itpwd
	Remove-Variable Nyttitpwd

	#TODO - kommenter ut. Dette er for test.
#	$Bruker="itadmin"#
#	net user $Bruker $Nyttitpwd
#	Remove-Variable Bruker 
#	Remove-Variable itpwd

	if ($DoDebug -eq "Y") {"Passord på konto it er satt."}
}

#Dersom i narkom deaktiverer vi konto .\it
if ($InNarkom -eq "Y") {
	net user $Bruker /activ:no
	if ($DoDebug -eq "Y") {"konto it er deaktivert."}
}

#Log ut 
#Stopp slik at vi får se output under test.
if ($DoDebug -eq "Y") {
    $reply=Read-Host "Trykk en tast for restart."
}

#Angi at denne filen skal slettes - med å opprette filen File3.dat
#Hvis filen finnes skal Edit...ps1 slettes når var 3 er ferdig.
New-Item -Path 'c:\download\File3.dat' -ItemType File -Force

pause
invoke-command -command {shutdown -l}
#3
}

#--End del3----------------------------
#########################################################
#
break

#Gjenstår:
# Dameware
# Trend
#--Ferdig---------------------
#Etterpå:
#Log inn med testit3 - installerer office2016 og websak.
#Oppdater.
#Start word...
#Installer Dameware og Trend fra c:\download

#Kode for senere bruk....
#net localgroup administratorer toei /add

#cript for Visma Enteprise - kjør når pålogget som bruker...
# \\fil-enterprise\uq\local\EnterpriseLauncher\VismaEnterpriseClientSettings\VismaEnterpriseClientSettings.cmd

#copy \\njord\stdprog\Bginfo\apps\TeamViewer.exe C:\Users\Public\Desktop\


#Enabling feature(s)
#[==========================100.0%==========================]
#The operation completed successfully.
#Restart Windows to complete this operation.
#Do you want to restart the computer now? (Y/N) N


