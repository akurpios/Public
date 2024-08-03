#Get date
$CurrentDate = get-date -f dd-MM-yyyy_THH-mm-ss

#Load RAW M$ SignIn logs
$MScsvPath = Read-Host -Prompt "Enter your Microsoft report CSV path without quotes "

#Set Path for temp file
$directoryPath = Split-Path -Path $MScsvPath
$TempMScsvPath = "$directoryPath/TempRaw-$CurrentDate.csv"

#Set Path for transcript
$TranscriptPatch = "$directoryPath/MsLogsVPNchecker-REPORT$CurrentDate.txt"

#Start transcript
Start-Transcript -Path $TranscriptPatch

#Set OutPath
$OutPath = "$directoryPath/ResolvedIPs-$CurrentDate.txt"

# Replace "Incoming token type" with "Token" in a file
$OldfirstLine = Get-Content -Path $MScsvPath | Select-Object -First 1
[regex]$pattern = "Incoming token type"
$NewfirstLine = $pattern.replace($OldfirstLine, "Token", 1) 

#Replace "IP Address" with "IP" in file
$NewfirstLine = $NewfirstLine.Replace("IP address","IP")

#Replace 1st line of string
$x = Get-Content $MScsvPath
$x[0] = $NewfirstLine
$x | Out-File $TempMScsvPath

#Import Fixed CSV
Import-Csv -Path $TempMScsvPath | ForEach-Object {
  $IP = $_.IP
  $APIKey = "$up3r$ecur3T0k3n"
  Write-Host $IP
  Write-Host $APIKey
  $URL= "https://vpnapi.io/api/"+$IP+"?key="+$APIKey
  Write-Host $URL

  #Obtain VPN data
  curl $URL | ConvertFrom-Json | ConvertTo-Csv >> $OutPath
}
Write-Host "Script Finished"
pause
Stop-Transcript
