Import-Module ExchangeOnlineManagement
Connect-ExchangeOnline

$CurrentDate = get-date -f dd-MM-yyyy_THH-mm-ss
$TranscriptPatch = "C:\Support\Scripts\BulkAddSharedMailboxMembers\REPORT$CurrentDate.txt"
$Identity = "SharedMailbox@contoso.com"
Start-Transcript -Path $TranscriptPatch
Import-Csv "C:\Support\Scripts\BulkAddSharedMailboxMembers\MembersToAdd.csv" -Delimiter ',' |
 
ForEach-Object { 
$UPN = $_.userPrincipalName
$DisplayName = $_.displayName

Write-Host "PERFORMING ACTION FOR: "$DisplayName "`r`n" -BackgroundColor Blue
Add-RecipientPermission -Identity $Identity -AccessRights SendAs -Trustee $UPN
If($?)  
 {  
 Write-Host $UPN Successfully added to $Identity as SendAs -ForegroundColor Green 
 }  
 Else  
 {  
 Write-Host $UPN has NOT BEEN added to $Identity as SendAs - Error occurred –ForegroundColor Red  
 }  
}
Write-Host "Script Finished"
pause
Stop-Transcript
notepad.exe $TranscriptPatch
