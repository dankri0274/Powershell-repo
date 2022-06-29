$inNarkom = $true # Skal PC-en registreres i narvik.kommune.no?

$computerName = $env:computername
$nameAllowed = $false

$testit3 = $true
$settPwdIT = $false
$doDebug = $false

$domain = "narvik.kommune.no" # Domene PC skal inn i
$bruker = $env:username
$rename = ""

cls # Clear Screen

Write-Host " Innmelding av PC-er i $domain " -f Black -b Green
Write-Host " Navngivning av PC " -f White -b Blue
$valg = Read-Host "`n1. Med navnekontroll`n2. Uten navnekontroll`n3. Sett opp uten navn`nVelg [1-3]"
if ($valg -eq 1) {
	while ($nameAllowed -ne $true) {
		$pcname = Read-Host "Angi nytt navn pa PC-en"
		$regex = $pcname -Match '[a-z]+[-][0-9]{4}|[a-z]+[-][a-z0-9]+[-][0-9]{4}' # Regex for å se om PC-navn er gyldig

		if ($pcname -eq $computerName) { # Nytt navn kan ikke være det samme som det gamle
			Write-Host "FEIL: PC heter allerede `"$computerName`"" -f Black -b Red
		}

		if ($pcname.Length -eq 0) { # Navn kan ikke være tomt
			Write-Host " FEIL: Navnet kan ikke vaere tomt " -f Black -b Red
		}
		if ($regex -and $pcname -ne $computerName) { # Hvis regex og navn er godkjent, fortsett
			$nameAllowed = $true

			$rename = $pcname

			DISM /Online /Enable-Feature /FeatureName:NetFx3 /NoRestart
			DISM /Online /Enable-Feature /All /FeatureName:SMB1Protocol /NoRestart
			DISM /Online /Enable-Feature /FeatureName:SMB1Protocol-client /NoRestart
			DISM /Online /Disable-Feature /FeatureName:SMB1Protocol-server /NoRestart
			DISM /Online /Disable-Feature /FeatureName:SMB1Protocol-deprecation /NoRestart
		}
		else {
			Write-Host "FEIL: Ikke gyldig navn`nRiktig: enhet-1234 / enhet-navn-1234,`nKUN SMAA BOKSTAVER" -f Red
			Start-Sleep -s 8
			cls
		}
	}
}
elseif ($valg -eq 2) {
	while ($nameAllowed -eq $false) {
		$pcname = Read-Host "Angi nytt navn pa PC-en"

		if ($pcname -eq $computerName) { # Hvis ønsket nytt navn er det samme som den allerede heter, print varsel
			Write-Host " FEIL: PC heter allerede `"$computerName`" " -f Black -b Red
		}

		if ($pcname.Length -eq 0) { # PC-navn kan ikke være tomt
			Write-Host " FEIL: Navnet kan ikke vaere tomt " -f Black -b Red
		}

		if ($pcname.Length -gt 0 -and $pcname -ne $computerName) { # Hvis lengde på PC-navn > 0 og PC ikke har samme navn fra før, godkjenn
			$nameAllowed = $true
		}

		if ($nameAllowed) {
			$rename = $pcname

			DISM /Online /Enable-Feature /FeatureName:NetFx3 /NoRestart
			DISM /Online /Enable-Feature /All /FeatureName:SMB1Protocol /NoRestart
			DISM /Online /Enable-Feature /FeatureName:SMB1Protocol-client /NoRestart
			DISM /Online /Disable-Feature /FeatureName:SMB1Protocol-server /NoRestart
			DISM /Online /Disable-Feature /FeatureName:SMB1Protocol-deprecation /NoRestart
		}
	}
}

if ($inNarkom) {
	cls
	Write-Host " Domeneinnmelding " -f Black -b Magenta

	$adminuser = Read-Host -Prompt "Skriv inn ditt admin-brukernavn" # Skriv inn ditt admin-brukernavn, f.eks admin{ditt NARKOM-brukernavn}
	Add-Computer -DomainName $domain -Credential $adminuser # Åpne et popup-vindu der du skriver inn adminbruker-passordet ditt

	Pause
}

cls

Write-Host " Tildeling av eier " -f Black -b Cyan
Write-Host "`"/u`" = Uten lokal admin" -f Green

$eier = Read-Host "Hvem skal bli lokal administrator"

if ($eier -ne "/u") {
	if ($eier.Length -gt 0) {
		net localgroup Administratorer $eier /add # Legg til bruker som lokal administrator
		if ($doDebug) {
			Write-Host "Eier lagt til i lokale administratorer"
		}
	}
}
else {
	Write-Host "PC vil bli satt opp uten lokal administrator" -f Black -b Red
}

$NarvikVann = Read-Host "Narvik Vann? ENTER = Nei, Y = Ja"
$Areal = Read-Host "Areal? ENTER = Nei, Y = Ja"
$Okonomi = Read-Host "Okonomi? ENTER = Nei, Y = Ja"

if ($inNarkom) {
	if ($NarvikVann -eq "Y") { # Narvik Vann
		net localgroup Administratorer grpNarvikVann /add # Legg til gruppen til narvik vann som lokal admin
		$narVann = "Y"
		if ($doDebug -eq "Y") {
			write-host "grpNarvikVann lagt inn i lokale administratorer"
		}
	}
}
if ($Areal -eq "Y") { # Areal og Samfunnsutvikling
	net localgroup Administratorer grpArealPCAdmins /add # Legg til gruppen til areal og samfunn. som lokal admin
	$areal = "Y"
	if ($DoDebug -eq "Y") {
		write-host "grpArealPCAdmins lagt inn i lokale administratorer"
	}
}
if ($Okonomi -eq "Y") { # Økonomienheten
	net localgroup Administratorer grpOkonPCAdmins /add # Legg til gruppen til økonomi som lokal admin
	$okon = "Y"
	if ($DoDebug -eq "Y") {
		write-host "grpOkonPCAdmins lagt inn i lokale administratorer"
	}
}
if ($testit3 -eq "Y") { # Bruker: testit3
	net localgroup Administratorer testit3 /add # Legg til testit3 som lokal admin
	if ($DoDebug -eq "Y") {
		write-host "NARKOM\testit3 lagt inn i lokale administratorer - malbruker i narkom"
	}
}

Copy-Item C:\Download\TeamViewer.exe C:\Users\Public\Desktop # Kopier TeamViewer til felles desktop

$apwd = Read-Host -Prompt "Oppgi passordet til lokal administrator (IKKE lokal IT-bruker)" -AsSecureString
$nyttapwd = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
			[System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($apwd))

if ($doDebug) {
	write-host "Passord pa konto IT er satt"
}

if ($inNarkom) {
	net user $bruker /active:no # Deaktiverer den lokale kontoen, f.eks "it"

	if ($doDebug) {
		Write-Host "Kontoen: $bruker er deaktivert" -f Red
	}
}
if ($doDebug) {
	Read-Host "Trykk en knapp for omstart"
}

cls

Write-Host " Installerer programmer... " -f Black -b Green

C:\Programmer\AcrobatReader.exe # Installer Adobe Acrobat Reader
Write-Host "1/4 Installerer Adobe Acrobat Reader, vennligst vent..." -f Black -b Green
Start-Sleep -S 20
Pause

C:\Programmer\TrendAntivirus.msi # Installer Trend Micro Antivirus
Write-Host "2/4 Installerer Trend Micro Antivirus, vennligst vent..." -f White -b Magenta
Start-Sleep -S 20
Pause

C:\Programmer\DameWare-Installer.msi # Installer DameWare
Write-Host "3/4 Installerer DameWare, vennligst vent..." -f Black -b Yellow
Pause

C:\Programmer\Google-Chrome-Installer.exe # Installer Google Chrome
Write-Host "4/4 Installerer Google Chrome, vennligst vent..." -f Black -b Red
Pause

cls

Write-Host "Installasjon fullfort" -f Black -b Green
Start-Sleep -S 5

cls

Write-Host "Oppsummering:`nEier:`t`t$eier`nEnhetsnavn:`t$rename"
Write-Host "Domene:`t`t$domain`nOkonomi:`t$okon`nAreal:`t`t$areal`nNarvik Vann:`t$narvann"

$can = Read-Host "Press ENTER to confirm or type CANCEL to cancel"

if ($can -eq "CANCEL") {
	Exit
}

cls

Remove-Item -LiteralPath C:\Download -Force -Recurse # Slett setup-filene
Remove-Item C:\Users\$bruker\Desktop\*Run-As-Admin.lnk -Force # Slett snarvei på skrivebordet

Write-Host " Konto $bruker blir deaktivert " -f Black -b Red
for ($countdown = 10; $countdown -ne 0; $countdown--) { # En liten nedtelling
	if ($countdown -eq 1) {
		Write-Host "`r Setup ferdig, maskinen starter pa nytt om $countdown sekund   " -f Black -b Green -NoNewLine
	}
	else {
		Write-Host "`r Setup ferdig, maskinen starter pa nytt om $countdown sekunder " -f Black -b Green -NoNewLine
	}
	
	Start-Sleep -S 1
}

Rename-Computer $rename
if ($?) { # Hvis forrige kommando var vellykket, restart maskinen
	Write-Host " Renaming successful " -f Black -b Green
	Restart-Computer
}
else { # Hvis kommandoen for å gi nytt navn feilet, gå til "Instillinger > Om" og manuelt gi nytt navn
	Write-Host " ERROR: Could not give computer `"$env:computername`" new name " -f Black -b Red
	Start-Sleep -S 6
	Restart-Computer
}
