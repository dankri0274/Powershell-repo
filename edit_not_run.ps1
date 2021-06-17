#Oppdatert av Daniel / 03.06.2021
#USB-pinne for innmelding i domene narvik.kommune.no
#For du starter dette programmet, oppdater Windows 10 helt til den ikke laster ned oppdateringer mer
#Kjor filen i ettertid som Administrator

add-type -AssemblyName System.Windows.Forms

write-host "Velg:"
write-host "1. PC-Navn, NerFx3, SMB"
write-host "2. Legg til i domene"
write-host "3. Eier, grupper, TV, dw"

$valg = read-host "Velg ett av alternativene (1 / 2 / 3)"

$InNarkom = "Y" #Skal PC-en registreres i domenet narvik.kommune.no?

$testit3 = "Y"
$SettPwdIT = "N"
$DoDebug = "N"
$reply = ""

if ($valg -eq "1") {
	$pcname = read-host "Hva skal PC-en hete" #Navn på PC. >5 tegn
	rename-computer $pcname
	DISM /online /enable-feature /featurename:NetFx3 /NoRestart
	dism /online /enable-feature /all /featurename:SMB1Protocol /NoRestart
	dism /online /enable-feature /featurename:SMB1Protocol-client /NoRestart
	dism /online /disable-feature /featurename:SMB1Protocol-server /NoRestart
	dism /online /disable-feature /featurename:SMB1Protocol-deprecation /NoRestart

	pause
	restart-computer
}

if ($valg -eq "2") {
	if ($InNarkom -eq "Y") {
		$adminuser = read-host "Enter adminbruker"
		$addcomp = add-computer -domainname "narvik.kommune.no" -credential $adminuser
		pause
		restart-computer
	}
}

if ($valg -eq "3") {
	$Bruker = read-host "Skriv inn navnet på brukeren PC-en ble satt opp med, CASE SENSITIVE!"
	$eier = read-host "Owner username (check if you have written the correct username)"

	$NarvikVann = read-host "Narvik Vann? Nei = ENTER, Y = Ja"
	$Areal = read-host "Areal? Nei = ENTER, Y = Ja"
	$Okonomi = read-host "Okonomi? Nei = ENTER, Y = Ja"

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

	write-host "INFO:	Administratorkonto er administrator for hele systemet"
	$apwd = read-host -prompt "Oppgi passordet til lokal administrator" -AsSecureString
	$nyttapwd = [Runtime.InteropServices.Marshal]::PtrToStringAuto([runtime.Interop.Marshal]::SecureStringToBSTR($apwd))

	net user administrator $nyttapwd
	remove-variable $nyttapwd
	remove-variable $apwd
	net user administrator /active:yes

	if ($SettPwdIT = "Y" -eq "Y") {
		write-host "INFO:	Lokal IT konto er kontoen som PC-en ble satt opp med!"
		$ITpwd = read-host "Oppgi passordet til lokal IT-konto" -AsSecureString
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

	[System.Windows.MessageBox]::Show("PC is registered in domain", "Domain registration completed", "Information")

	if ($DoDebug -eq "Y") {
		$reply = read-host "Trykk en tast for reboot"
	}
	
	pause
	#invoke-command -command {shutdown -l}
	logoff
}
