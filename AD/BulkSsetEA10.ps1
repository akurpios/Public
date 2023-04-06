$CurrentDate = get-date -f dd-MM-yyyy_THH-mm-ss
$TranscriptPatch = "C:\Support\Scripts\BulkAddEA10-SSPR\REPORT$CurrentDate.txt"
Start-Transcript -Path $TranscriptPatch
Import-Csv "C:\Support\Scripts\BulkAddEA10-SSPR\SSPR.csv" -Delimiter ',' |
 
ForEach-Object { 
$SAMA = $_.samAccountName
$UPN = $_.UserPrincipalName
$DisplayName = $_.displayName
$SSPRvalue = $_.SSPR

$Checks=Get-ADUser -Identity $SAMA -Properties extensionAttribute10 | select Name, extensionAttribute10


$mailnickname = $upn.Split('@')[0]
write-host "Working on account: "$SAMA

Write-host "status before action:"
Write-Output "$Checks`r`n"
Write-Host "PERFORMING ACTION`r`n" -BackgroundColor Red
Set-ADUser $SAMA -replace @{'extensionAttribute10' = $SSPRvalue}
write-host "status after action:"
Write-Output "$Checks"
write-host "*******************************`r`n"
write-host 
}
Write-Host "Script Finished"
pause
Stop-Transcript
notepad.exe $TranscriptPatch
