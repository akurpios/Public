Import-Module ExchangeOnlineManagement
Connect-ExchangeOnline

$CurrentDate = get-date -f dd-MM-yyyy_THH-mm-ss
$TranscriptPatch = "C:\Support\Scripts\BulkAddSharedMailboxMembers\REPORT$CurrentDate.txt"
Start-Transcript -Path $TranscriptPatch
Import-Csv "C:\Support\Scripts\BulkAddSharedMailboxMembers\MembersToAdd.csv" -Delimiter ',' |
 
ForEach-Object { 
$UPN = $_.UserPrincipalName
$DisplayName = $_.displayName

Write-Host "PERFORMING ACTION FOR: "$DisplayName "`r`n" -BackgroundColor Red
Remove-MailboxPermission -Identity SharedMailbox@contoso.com -User $UPN -AccessRights ReadPermission -InheritanceType All -confirm:$false
Add-MailboxPermission -Identity SharedMailbox@contoso.com -User $UPN -AccessRights FullAccess -InheritanceType All


}
Write-Host "Script Finished"
pause
Stop-Transcript
notepad.exe $TranscriptPatch
