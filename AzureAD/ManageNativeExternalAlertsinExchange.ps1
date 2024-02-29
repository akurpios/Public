$CurrentDate = get-date -f dd-MM-yyyy_THH-mm-ss
$TranscriptPatch = "C:\Support\Scripts\ManageExternalsAlert\REPORT$CurrentDate.txt"
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

Write-Host "Connecting to the Exchange Online Management" -ForegroundColor Yellow
Connect-ExchangeOnline #-UserPrincipalName $upn -ConnectionUri https://ps.compliance.protection.outlook.com/PowerShell-LiveID -AzureADAuthorizationEndPointUri https://login.microsoftonline.com/common


While(-not($type -eq 1) -and -not($type -eq 2)-and -not($type -eq 3)){
$type = Read-host "`n1 - List all trusted domains and addresses `n2 - add domain or address as trusted `n3 - remove domain or address as trusted`n`n SELECT OPTION"
if ($type -eq 1)
{

$GetExternal = Get-ExternalInOutlook
$allowed = $GetExternal.AllowList
Write-host "Addresses already allowed:`n"
write-output $allowed
write-host "`n`n"
pause

}
elseif ($type -eq 2)
{

$GetExternal = Get-ExternalInOutlook
$allowed = $GetExternal.AllowList
Write-host "Addresses already allowed:"
write-output $allowed
Write-Host
write-host

$ToAllow = Read-host "Please type domain/address that should be allowed"
$allowed.Add($ToAllow)

Write-Host  "updateing rule"-ForegroundColor Red
Set-ExternalInOutlook -AllowList $allowed

Write-Host  "Checking integrity"-ForegroundColor yellow
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

Write-Host "ARRAYS MATCH" -ForegroundColor Green

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


$ToRemove = Read-host "Please select the ID of domain/address that should be removed"
$allowed.RemoveAt($ToRemove)


Write-Host  "updateing rule"-ForegroundColor Red
Set-ExternalInOutlook -AllowList $allowed

Write-Host  "Checking integrity"-ForegroundColor yellow
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

Write-Host "ARRAYS MATCH" -ForegroundColor Green

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
