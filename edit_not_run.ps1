# USB-pinne for innmelding i domene narvik.kommune.no
# Før du starter dette programmet, oppdater Windows 10 helt til den ikke laster ned oppdateringer mer
# Kjør filen i ettertid som Administrator
# Med navnekontroll f.eks "vegpark-XXXX" <-- må være slik

write-host "IT-Avdelingens domeneinnmelding for PC-er, m/navnekontroll`n" -foregroundcolor green

write-host "Velg:"
write-host "`t1. PC-Navn, NerFx3, SMB"
write-host "`t2. Legg til i domene"
write-host "`t3. Eier, grupper, TV, dw`n"

$valg = read-host -prompt "Velg ett av alternativene (1 / 2 / 3)"

$InNarkom	= "Y"	#* Skal PC-en registreres i domenet narvik.kommune.no ?

$testit3	= "Y"
$SettPwdIT	= "N"
$DoDebug	= "N"
$Bruker		= "it"

if ($valg -eq "1") {
	$pcname = read-host -prompt "Hva skal PC-en hete" # Navn på PC. >5 tegn
	$regex = $pcname -match '[a-z]+[-][0-9]{4}|[a-z]+[-][a-z0-9]+[-][0-9]{4}'	# Regex for å se om PC-navn er gyldig

	if ($regex) {
		rename-computer $pcname
		DISM /online /enable-feature /featurename:NetFx3 /NoRestart
		DISM /online /enable-feature /all /featurename:SMB1Protocol /NoRestart
		DISM /online /enable-feature /featurename:SMB1Protocol-client /NoRestart
		DISM /online /disable-feature /featurename:SMB1Protocol-server /NoRestart
		DISM /online /disable-feature /featurename:SMB1Protocol-deprecation /NoRestart
	}
	else {
		write-host "Ikke gylgig navn`nRiktig: enhet-1234 / navn-navn2-1234, kun små bokstaver" -foregroundcolor red
	}

	pause
	restart-computer
}

if ($valg -eq "2") {
	if ($InNarkom -eq "Y") {
		$adminuser = read-host -prompt "Skriv inn admin-brukernavn"
		add-computer -domainname "narvik.kommune.no" -credential $adminuser
		pause
		restart-computer
	}
}

if ($valg -eq "3") {
	$eier = read-host "Hvem skal vaere eier av PC"
	$NarvikVann = read-host "Narvik Vann? Nei = ENTER, Y = Ja"
	$Areal = read-host "Areal? Nei = ENTER, Y = Ja"
	$Okonomi = read-host "Okonomi? Nei = ENTER, Y = Ja"
	
	if ($InNarkom -eq "Y") {
		if ($Narvikvann -eq "Y") {
			net localgroup Administratorer grpNarvikVann /add
			if ($DoDebug -eq "Y") {
				write-host "grpNarvikvann lagt inn i lokale administratorer"
			}
		}
		if ($Areal -eq "Y") {
			net localgroup Administratorer grpArealPCAdmins /add
			if ($DoDebug -eq "Y") {
				write-host "grpArealPCAdmins lagt inn i lokale administratorer"
			}
		}
		if ($Okonomi -eq "Y") {
			net localgroup Administratorer grpOkonPCAdmins /add
			if ($DoDebug -eq "Y") {
				write-host "grpOkonPCAdmins lagt inn i lokale administratorer"
			}
		}
		if ($testit3 -eq "Y") {
			net localgroup Administratorer testit3 /add
			if ($DoDebug -eq "Y") {
				write-host "NARKOM\testit3 lagt inn i lokale administratorer - malbruker i narkom"
			}
		}
	}

	if ($eier.length -gt 0) {
		net localgroup Administratorer $eier /add
		if ($DoDebug -eq "Y") {
			write-host "Eier lagt inn i lokale administratorer"
		}
	}

	copy-item C:\Download\TeamViewer.exe C:\Users\Public\Desktop

	# Kjører nå uten problemer!

	$apwd = read-host -prompt "Oppgi passordet til lokal administrator (IKKE lokal IT-bruker)" -AsSecureString
	$nyttapwd = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
				[System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($apwd)
	)

	net user administrator $nyttapwd
	net user administrator /active:yes

	if ($SettPwdIT -eq "Y") {
		$ITpwd = read-host -prompt "Oppgi passordet til lokal IT-konto (IT-bruker)" -AsSecureString
		$NyttITPwd = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
						[Runtime.InteropServices.Marshal]::SecureStringToBSTR($apwd)
		)
		remove-variable $ITpwd
		remove-variable $NyttITPwd

		if ($DoDebug -eq "Y") {
			write-host "Passord på konto IT er satt"
		}
	}
	if ($InNarkom -eq "Y") {
		net user $Bruker /active:no
		if ($DoDebug -eq "Y") {
			write-host "Konto IT er deaktivert"
		}
	}
	if ($DoDebug -eq "Y") {
		read-host "Trykk en tast for reboot"
	}
	
	Remove-Item -LiteralPath C:\Download -Force -Recurse
	Remove-Item C:\Users\*\Desktop\*Run-As-Admin-3X_SHORTCUT.lnk -Force
	Remove-Item C:\Users\*\Desktop\*PS_Script_SHORTCUT.lnk -Force

	restart-computer
}
