#Main Script
$CurrentDate = get-date -f dd-MM-yyyy_THH-mm-ss
$TranscriptPatch = "C:\Support\Scripts\Revoke Sessions\REPORT$CurrentDate.txt"
Start-Transcript -Path $TranscriptPatch
$csvPath = Read-Host -Prompt "Enter your CSV path without quotes "
Import-Csv $csvPath -Delimiter ';' |


ForEach-Object { 
$UPN = $_.UserPrincipalName
$SAMA = $_.SamAccountName

write-host "Working on account: "$SAMA 

Write-Host "PERFORMING ACTION`r`n"

try{
$UserObject = get-aduser $SAMA
$tempUPN = $UserObject.UserPrincipalName
Set-ADUser $SAMA -PasswordNeverExpires:$false
Set-ADUser $SAMA -ChangePasswordAtLogon:$true
$ObjectID = (Get-AzureADUser -SearchString $tempUPN).ObjectID
Revoke-AzureADUserAllRefreshToken -ObjectId $ObjectID

} catch {

Write-Host "ACTION for: "$UPN " not success`r`n" -BackgroundColor Red

}

Write-Host "ACTION for: "$UPN " success`r`n" -BackgroundColor Green

write-host "*******************************`r`n"
write-host 
}

Start-ADSyncSyncCycle -PolicyType Delta

Write-Host "Script Finished"
pause
Stop-Transcript
#notepad.exe $TranscriptPatch

#Checker
$CurrentDate = get-date -f dd-MM-yyyy_THH-mm-ss
$TranscriptPatch = "C:\Support\Scripts\Revoke Sessions\REPORTChecker$CurrentDate.txt"
Start-Transcript -Path $TranscriptPatch
$csvPath = Read-Host -Prompt "Enter your CSV path without quotes "
$OutputPath = "C:\Support\Scripts\Revoke Sessions\REPORTChecker$CurrentDate.csv"
Import-Csv $csvPath  -Delimiter ';' |


ForEach-Object { 
$UPN = $_.UserPrincipalName
$SAMA = $_.SamAccountName

write-host "Working on account: "$UPN

Write-Host "PERFORMING ACTION`r`n"

try{

Get-ADUser -identity $SAMA  -properties * | Select SamAccountName,Name,UserPrincipalName,@{Name='PwdLastSet';Expression={[DateTime]::FromFileTime($_.PwdLastSet)}} | export-csv $OutputPath -Encoding UTF8 -NoTypeInformation -Append

} catch {

Write-Host "ACTION for: "$UPN " not success`r`n" -BackgroundColor Red

}

Write-Host "ACTION for: "$UPN " success`r`n" -BackgroundColor Green

write-host "*******************************`r`n"
write-host 
}

Write-Host "Script Finished"
pause
Stop-Transcript
#notepad.exe $TranscriptPatch



