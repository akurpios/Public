$date=Get-Date -Format "dddd MM-dd-yyyyTHH-mm-ss"
$int=0
$whoFull=whoami
$who=$whoFull.substring(4)
$TranscriptPath="C:\config\LogOffButtonReports\transcript-$who-$date.txt"

do{
$int++
Start-Transcript -Path $TranscriptPath -Append
$sessionID = ((quser | ? { $_ -match "$who" -and $_ -match "Disc" }) -split ' +')[2]
write-output quser
write-host "whoami: " $whoami
write-host  "who: "$who
write-host "SessionID: " $sessionID
logoff $sessionID
Stop-Transcript
}while($int -ne 5)

logoff


##Convert the PS1 to the EXE using Invoke-PS2EXE PS module
#Invoke-PS2EXE C:\MDMscripts\logoff.ps1 C:\MDMscripts\logoff.exe
