write-host "Velg:"
write-host "1. PC-Navn, NerFx3, SMB"
write-host "2. Legg til i domene"
write-host "3. Eier, grupper, TV, dw"

$valg = read-host -prompt "Velg ett av alternativene (1 / 2 / 3)"

$eier = ""
$InNarkom = "Y" #Skal PC-en registreres i domenet narvik.kommune.no ?

#___Underenheter av Narvik Kommune___

$NarvikVann = "N"
$Areal = "N"
$Okonomi = "N"

#______

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
	copy-item C:\Download\TeamViewer.exe C:\Users\Public\Desktop

	$apwd = read-host -prompt "Oppgi passordet til lokal administrator"
	$nyttapwd = [Runtime.InteropServices.Marshal]::PtrToStringAuto([runtime.Interop.Marshal]::SecureStringToBSR($apwd))

	net user administrator $nyttapwd
	remove-variable $nyttapwd
	remove-variable $apwd
	net user administrator /activ:yes

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
		net user $Bruker /activ:no
		if ($DoDebug -eq "Y") {
			write-host "Konto IT r deaktivert"
		}
	}
	if ($DoDebug -eq "Y") {
		$reply = read-host "Trykk en tast for reboot"
	}
	pause
	invoke-command -command {shutdown -l}
}
