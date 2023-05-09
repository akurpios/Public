Import-Module ExchangeOnlineManagement
Connect-ExchangeOnline

$CurrentDate = get-date -f dd-MM-yyyy_THH-mm-ss
$TranscriptPatch = "C:\Support\Scripts\BulkAddSharedMailboxMembers\REPORT$CurrentDate.txt"
$Identity = "SharedMailbox@contoso.com"
Start-Transcript -Path $TranscriptPatch
Import-Csv "C:\Support\Scripts\BulkAddSharedMailboxMembers\MembersToAdd.csv" -Delimiter ',' |
 
ForEach-Object { 
$UPN = $_.UserPrincipalName
$DisplayName = $_.displayName

Write-Host "PERFORMING ACTION FOR: "$DisplayName "`r`n" -BackgroundColor Blue
Set-Mailbox -Identity $Identity -GrantSendOnBehalfTo $UPN
If($?)  
 {  
 Write-Host $UPN Successfully added to $Identity as SendOnBehalf -ForegroundColor Green 
 }  
 Else  
 {  
 Write-Host $UPN has NOT BEEN added to $Identity as SendOnBehalf - Error occurred –ForegroundColor Red  
 }  
}
Write-Host "Script Finished"
pause
Stop-Transcript
notepad.exe $TranscriptPatch
