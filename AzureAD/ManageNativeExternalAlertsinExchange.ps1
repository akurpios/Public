$RuleName="scam alert"
$EmailChosen=0
$CurrentDate = get-date -f dd-MM-yyyy_THH-mm-ss
$TranscriptPatch = "C:\Support\Scripts\ManageExternalsAlert\REPORT_v2$CurrentDate.txt"
Start-Transcript -Path $TranscriptPatch

cls
if (Get-Module -ListAvailable -Name ExchangeOnlineManagement) {
    Write-host "Module ExchangeOnlineManagement exists - skipping installation" -ForegroundColor Green
} 
else {
    Write-Warning "Module ExchangeOnlineManagement does not exist. Installing module"
    Set-ExecutionPolicy RemoteSigned
    Write-Host "Checking for admin rights"
    if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Insufficient permissions to install this module. Open the PowerShell console as an administrator and run this script again."
    Break
    }
    else {
    Write-Host "Console running as admin. Processing installation module" -ForegroundColor Green
    Install-Module -Name ExchangeOnlineManagement
    }
}

Import-Module ExchangeOnlineManagement
#$upn = Read-Host "Your Polaroid e-mail address"

Write-Host "Connecting to the Exchange Online Management" -ForegroundColor Yellow
Connect-ExchangeOnline #-UserPrincipalName $upn -ConnectionUri https://ps.compliance.protection.outlook.com/PowerShell-LiveID -AzureADAuthorizationEndPointUri https://login.microsoftonline.com/common


While(-not($type -eq 1) -and -not($type -eq 2)-and -not($type -eq 3)){
$type = Read-host "`n1 - List all trusted domains and addresses `n2 - add domain or address as trusted `n3 - remove domain or address as trusted`n`n SELECT OPTION"
if ($type -eq 1)
{

$GetExternal = Get-ExternalInOutlook
$allowed = $GetExternal.AllowList 
Write-host "Addresses already allowed:`n" -ForegroundColor Green
write-output $allowed
write-host "`n`n"


$getRule = Get-TransportRule -Identity $RuleName
$getTrusted = $getRule.ExceptIfSenderDomainIs
Write-host "Addresses excluded from mailflow rule:`n" -ForegroundColor Green
write-output $getTrusted
Write-Host

pause
}
elseif ($type -eq 2)
{
#GetTAG
$GetExternal = Get-ExternalInOutlook
$allowed = $GetExternal.AllowList
Write-host "Addresses already allowed:" -ForegroundColor Green
write-output $allowed
Write-Host
write-host

#GetRule
$getRule = Get-TransportRule -Identity $RuleName
$getTrusted = $getRule.ExceptIfSenderDomainIs
Write-host "Addresses excluded from mailflow rule:" -ForegroundColor Green
write-output $getTrusted
Write-Host
write-host

#GetAddressToAllow
$ToAllow = Read-host "Please type domain/address that should be allowed"


#CheckIfEmail
if ($ToAllow.Contains("@")){
Write-Host "You're allowing email address. To exclude it from Mail flow rule ask HD2 agent to create Exchnage contact and add it as a member of External_Safe_Senders_List@onepolaroid.onmicrosoft.com'
distribution group." -ForegroundColor Red
$EmailChosen=1
}
else {
$getTrusted.Add($ToAllow)
}

$allowed.Add($ToAllow)



if ($EmailChosen.Equals(1)){
Write-Host "You're allowing email address. To exclude it from Mail flow rule ask HD2 agent to create Exchnage contact and add it as a member of External_Safe_Senders_List@onepolaroid.onmicrosoft.com'
distribution group." -ForegroundColor Red
} else {
Write-Host  "updating rule"-ForegroundColor Red
Set-TransportRule -Identity $RuleName -ExceptIfSenderDomainIs $getTrusted

#IntegrityChecks-Rule
Write-Host  "Checking Rule integrity"-ForegroundColor yellow
write-host "values sent:"
write-output $getTrusted
write-host
write-host "values set:"
$IntegrityCheckRule = Get-TransportRule -Identity $RuleName
$IntegrityCheckRuleArray = $IntegrityCheckRule.ExceptIfSenderDomainIs
Write-Output $IntegrityCheckRuleArray

if (diff $getTrusted $IntegrityCheckRuleArray){
write-host "ARRAYS DON'T MATCH - PLEASE CHECK IT MANUALLY" -ForegroundColor Red
write-host "ARRAYS DON'T MATCH - PLEASE CHECK IT MANUALLY" -ForegroundColor Red
write-host "ARRAYS DON'T MATCH - PLEASE CHECK IT MANUALLY" -ForegroundColor Red

Get-ExternalInOutlook
} 
else {

Write-Host "RULE ARRAYS MATCH" -ForegroundColor Green

}
}

Write-Host  "updating TAG"-ForegroundColor Red
Set-ExternalInOutlook -AllowList $allowed
#IntegrityChecks-TAG

Write-Host  "Checking TAG integrity"-ForegroundColor yellow
write-host "values sent:"
write-output $allowed
write-host
write-host "values set:"
$IntegrityCheck = Get-ExternalInOutlook
$IntegrityCheckArray = $IntegrityCheck.AllowList
Write-Output $IntegrityCheckArray

if (diff $allowed $IntegrityCheckArray){
write-host "ARRAYS DON'T MATCH - PLEASE CHECK IT MANUALLY" -ForegroundColor Red
write-host "ARRAYS DON'T MATCH - PLEASE CHECK IT MANUALLY" -ForegroundColor Red
write-host "ARRAYS DON'T MATCH - PLEASE CHECK IT MANUALLY" -ForegroundColor Red

Get-ExternalInOutlook
} 
else {

Write-Host "TAG ARRAYS MATCH" -ForegroundColor Green

}

pause
}

elseif ($type -eq 3)
{

$GetExternal = Get-ExternalInOutlook
$allowed = $GetExternal.AllowList
Write-host "Addresses already allowed:"

for ($index = 0;$index -lt $allowed.count;$index++)
{
    "ID: $index  [{0}]" -f $allowed[$index] 
}

Write-Host
write-host


$ToRemove = Read-host "Please select the ID of domain/address that should be removed as trusted. If you want to skip please type '9999'"
if ($ToRemove -eq "9999"){
Write-Host "Skipping" -ForegroundColor Red
} else {
$allowed.RemoveAt($ToRemove)
}



$getRule = Get-TransportRule -Identity $RuleName
$getTrusted = $getRule.ExceptIfSenderDomainIs
Write-host "Addresses already allowed in Rule:"

for ($index = 0;$index -lt $getTrusted.count;$index++)
{
    "ID: $index  [{0}]" -f $getTrusted[$index] 
}

Write-Host
write-host


$ToRemoveRule = Read-host "Please select the ID of domain/address that should be removed as trusted. If you want to skip please type '9999'"
if ($ToRemoveRule -eq "9999"){
Write-Host "Skipping" -ForegroundColor Red
} else {
$getTrusted.RemoveAt($ToRemoveRule)
}





Write-Host  "updateing rule"-ForegroundColor Red
Set-ExternalInOutlook -AllowList $allowed
Set-TransportRule -Identity $RuleName -ExceptIfSenderDomainIs $getTrusted


#IntegrityChecks-TAG

Write-Host  "Checking TAG integrity"-ForegroundColor yellow
write-host "values sent:"
write-output $allowed
write-host
write-host "values set:"
$IntegrityCheck = Get-ExternalInOutlook
$IntegrityCheckArray = $IntegrityCheck.AllowList
Write-Output $IntegrityCheckArray

if (diff $allowed $IntegrityCheckArray){
write-host "ARRAYS DON'T MATCH - PLEASE CHECK IT MANUALLY" -ForegroundColor Red
write-host "ARRAYS DON'T MATCH - PLEASE CHECK IT MANUALLY" -ForegroundColor Red
write-host "ARRAYS DON'T MATCH - PLEASE CHECK IT MANUALLY" -ForegroundColor Red

Get-ExternalInOutlook
} 
else {

Write-Host "TAG ARRAYS MATCH" -ForegroundColor Green

}

#IntegrityChecks-Rule
Write-Host  "Checking Rule integrity"-ForegroundColor yellow
write-host "values sent:"
write-output $getTrusted
write-host
write-host "values set:"
$IntegrityCheckRule = Get-TransportRule -Identity $RuleName
$IntegrityCheckRuleArray = $IntegrityCheckRule.ExceptIfSenderDomainIs
Write-Output $IntegrityCheckRuleArray

if (diff $getTrusted $IntegrityCheckRuleArray){
write-host "ARRAYS DON'T MATCH - PLEASE CHECK IT MANUALLY" -ForegroundColor Red
write-host "ARRAYS DON'T MATCH - PLEASE CHECK IT MANUALLY" -ForegroundColor Red
write-host "ARRAYS DON'T MATCH - PLEASE CHECK IT MANUALLY" -ForegroundColor Red

Get-ExternalInOutlook
} 
else {

Write-Host "RULE ARRAYS MATCH" -ForegroundColor Green

}

pause

}
else {
write-Host ("Wrong Answer")
}
}

Write-Host "Disconnecting from the Exchange Online Management" -ForegroundColor Yellow
Disconnect-ExchangeOnline -Confirm:$false
Stop-Transcript
notepad.exe $TranscriptPatch
