#Oppdatert av Daniel / 28.05.2021
#USB-pinne for innmelding i domene narvik.kommune.no
#Før du starter dette programmet, oppdater Windows 10 helt til den ikke laster ned oppdateringer mer
#Kjør filen i ettertid som Administrator

write-host "Velg:"
write-host "1. PC-Navn, NerFx3, SMB"
write-host "2. Legg til i domene"
write-host "3. Eier, grupper, TV, dw"

$valg = read-host -prompt "Velg ett av alternativene (1 / 2 / 3)"

$InNarkom = "Y" #Skal PC-en registreres i domenet narvik.kommune.no ?

$testit3 = "Y"
$SettPwdIT = "N"
$DoDebug = "N"
$reply = ""
$Bruker = "it"

if ($valg -eq "1") {
	$pcname = read-host -prompt "Hva skal PC-en hete" #Navn på PC. >5 tegn
	rename-computer $pcname
	DISM /online /enable-feature /featurename:NetFx3 /NoRestart
	DISM /online /enable-feature /featurename:SMB1Protocol-client /NoRestart
	DISM /online /enable-feature /featurename:SMB1Protocol-client /NoRestart
	DISM /online /disable-feature /featurename:SMB1Protocol-server /NoRestart
	DISM /online /disable-feature /featurename:SMB1Protocol-deprecation /NoRestart

	pause
	restart-computer
}

if ($valg -eq "2") {
	if ($InNarkom -eq "Y") {
		$adminuser = read-host -prompt "Enter adminbruker"
		$addcomp = add-computer -domainname "narvik.kommune.no" -credential $adminuser
		pause
		restart-computer
	}
}

if ($valg -eq "3") {
	$eier = read-input -prompt "Eier"
	$NarvikVann = read-host -prompt "Narvik Vann? Hvis NEI, trykk ENTER, Y = Ja"
	$Areal = read-host -prompt "Areal? Hvis NEI, trykk ENTER, Y = Ja"
	$Okonomi = read-host -prompt "Okonomi? Hvis NEI, trykk ENTER, Y = Ja"
	if ($InNarkom -eq "Y") {
		if ($Narvikvann -eq "Y") {
			net localgroup administratorer grpNarvikVann /add
			if ($DoDebug -eq "Y") {
				write-host "grpNarvikvann lagt inn i lokale administratorer"
			}
		}
		if ($Areal -eq "Y") {
			net localgroup administratorer grpArealPCAdmins /add
			if ($DoDebug -eq "Y") {
				write-host "grpArealPCAdmins lagt inn i lokale administratorer"
			}
		}
		if ($Okonomi -eq "Y") {
			net localgroup administratorer grpOkonPCAdmins /add
			if ($DoDebug -eq "Y") {
				write-host "grpOkonPCAdmins lagt inn i lokale administratorer"
			}
		}
		if ($testit3 -eq "Y") {
			net localgroup administratorer testit3 /add
			if ($DoDebug -eq "Y") {
				write-host "NARKOM\testit3 lagt inn i lokale administratorer - malbruker i narkom"
			}
		}
		if ($eier.lenght -gt 0) {
			net localgroup administratorer $eier /add
			if ($DoDebug -eq "Y") {
				write-host "Eier lagt inn i lokale administratorer"
			}
		}
	}
	copy-item c:\download\TeamViewer.exe C:\Users\Public\Desktop

	$apwd = read-host -prompt "Oppgi passordet til lokal administrator" -AsSecureString
	$nyttapwd = [Runtime.InteropServices.Marshal]::PtrToStringAuto([runtime.Interop.Marshal]::SecureStringToBSR($apwd))

	net user administrator $nyttapwd
	remove-variable $nyttapwd
	remove-variable $apwd
	net user administrator /active:yes

	if ($SettPwdIT = "Y" -eq "Y") {
		$ITpwd = read-host -prompt "Oppgi passordet til lokal IT-konto" -AsSecureString
		$NyttITPwd = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($apwd))
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
		$reply = read-host "Trykk en tast for reboot"
	}
	pause
	invoke-command -command {shutdown -l}
}
