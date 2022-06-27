$inNarkom = $true # Skal PC-en registreres i narvik.kommune.no?

$TESTMODE = $false #! Brukes på eget ansvar
$computerName = $env:computername
$nameAllowed = $false

$testit3 = $true
$settPwdIT = $false
$doDebug = $false

$domain = "narvik.kommune.no"
$bruker = $env:username

cls # Clear Screen

Write-Host " Innmelding av PC-er i $domain " -f Black -b Green
Write-Host " Navngivning av PC " -f White -b Blue
$valg = Read-Host "`n1. Med navnekontroll`n2. Uten navnekontroll`n3. Sett opp uten navn`nVelg [1-3]"
if ($valg -eq 1) {
	while ($nameAllowed -ne $true) {
		$pcname = Read-Host "Angi nytt navn pa PC-en"
		$regex = $pcname -Match '[a-z]+[-][0-9]{4}|[a-z]+[-][a-z0-9]+[-][0-9]{4}' # Regex for å se om PC-navn er gyldig

		if ($pcname -eq $computerName) {
			Write-Host "FEIL: PC heter allerede `"$computerName`"" -f Black -b Red
		}

		if ($pcname.Length -eq 0) {
			Write-Host " FEIL: Navnet kan ikke vaere tomt " -f Black -b Red
		}
		if ($regex -and $pcname -ne $computerName) {
			$nameAllowed = $true

			Rename-Computer $pcname

			DISM /Online /Enable-Feature /FeatureName:NetFx3 /NoRestart
			DISM /Online /Enable-Feature /All /FeatureName:SMB1Protocol /NoRestart
			DISM /Online /Enable-Feature /FeatureName:SMB1Protocol-client /NoRestart
			DISM /Online /Disable-Feature /FeatureName:SMB1Protocol-server /NoRestart
			DISM /Online /Disable-Feature /FeatureName:SMB1Protocol-deprecation /NoRestart
		}
		else {
			Write-Host "FEIL: Ikke gyldig navn`nRiktig: enhet-1234 / enhet-navn-1234,`nKUN SMÅ BOKSTAVER" -f Red
			Start-Sleep -s 8
			cls
		}
	}
}
elseif ($valg -eq 2) {
	while ($nameAllowed -eq $false) {
		$pcname = Read-Host "Angi nytt navn pa PC-en"

		if ($pcname -eq $computerName) {
			Write-Host " FEIL: PC heter allerede `"$computerName`" " -f Black -b Red
		}

		if ($pcname.Length -eq 0) {
			Write-Host " FEIL: Navnet kan ikke vaere tomt " -f Black -b Red
		}

		if ($pcname.Length -gt 0 -and $pcname -ne $computerName) {
			$nameAllowed = $true
		}

		if ($nameAllowed) {
			Rename-Computer $pcname

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
	Add-Computer -DomainName $domain -Credential $adminuser

	Pause
}

cls

Write-Host " Tildeling av eier " -f Black -b Cyan

$eier = Read-Host "Hvem skal bli lokal administrator"
$NarvikVann = Read-Host "Narvik Vann? ENTER = Nei, Y = Ja"
$Areal = Read-Host "Areal? ENTER = Nei, Y = Ja"
$Okonomi = Read-Host "Okonomi? ENTER = Nei, Y = Ja"

if ($eier.Length -eq 0) {
	net localgroup Administratorer $eier /add # Legg til bruker som lokal administrator
	if ($doDebug) {
		Write-Host "Eier lagt til i lokale administratorer"
	}
}

if ($inNarkom) {
	if ($NarvikVann -eq "Y") { # Narvik Vann
		net localgroup Administratorer grpNarvikVann /add
		if ($doDebug -eq "Y") {
			write-host "grpNarvikVann lagt inn i lokale administratorer"
		}
	}
}
if ($Areal -eq "Y") { # Areal og Samfunnsutvikling
	net localgroup Administratorer grpArealPCAdmins /add
	if ($DoDebug -eq "Y") {
		write-host "grpArealPCAdmins lagt inn i lokale administratorer"
	}
}
if ($Okonomi -eq "Y") { # Økonomienheten
	net localgroup Administratorer grpOkonPCAdmins /add
	if ($DoDebug -eq "Y") {
		write-host "grpOkonPCAdmins lagt inn i lokale administratorer"
	}
}
if ($testit3 -eq "Y") { # Bruker: testit3
	net localgroup Administratorer testit3 /add
	if ($DoDebug -eq "Y") {
		write-host "NARKOM\testit3 lagt inn i lokale administratorer - malbruker i narkom"
	}
}

Copy-Item C:\Download\TeamViewer.exe C:\Users\Public\Desktop

$apwd = Read-Host -Prompt "Oppgi passordet til lokal administrator (IKKE lokal IT-bruker)" -AsSecureString
$nyttapwd = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
			[System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($apwd)
)

Remove-Variable $ITpwd
Remove-Variable $NyttITPwd

if ($doDebug) {
	write-host "Passord på konto IT er satt"
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

Remove-Item -LiteralPath C:\Download -Force -Recurse # Slett setup-filene
Remove-Item C:\Users\*\Desktop\*Run-As-Admin-3X_SHORTCUT.lnk -Force # Slett snarvei på skrivebordet
Remove-Item C:\Users\*\Desktop\*PS_Script_SHORTCUT.lnk -Force # Slett snarvei på skrivebordet

cls

Write-Host " Installerer programmer... " -f Black -b Green

C:\Programmer\AcrobatReader.exe # Installer Adobe Acrobat Reader
C:\Programmer\TrendAntivirus.exe # Installer Trend Micro Antivirus
C:\Programmer\DameWare-Installer.exe # Installer DameWare
C:\Programmer\Google-Chrome-Installer.exe # Installer Google Chrome

cls

Write-Host "Installasjon fullfort" -f Black -b Green
Start-Sleep -S 5

cls

for ($countdown = 10; $countdown -ne 0; $countdown--) { # Just for fun :)
	Write-Host " Setup ferdig, maskinen starter pa nytt om $countdown sekunder " -f Black -b Green
	Write-Host " Konto $bruker blir deaktivert " -f Black -b Red
	Start-Sleep -S 1

	cls
}

Restart-Computer