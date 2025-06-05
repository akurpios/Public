$PSver = $psversiontable.PSversion.ToString()
cls
if ($PSver -lt 6){
    write-Host "currently running Powershell version" $PSver ". Starting Powershell ver. 7"
    pwsh "C:\Support\Scripts\PurgeEmails\PurgeEmailsv2.ps1"
    }
    else{
write-Host "Powershell ver. 7 is running."
$CurrentDate = get-date -f dd-MM-yyyy_THH-mm-ss
$TranscriptPatch = "C:\Support\Scripts\PurgeEmails\REPORT$CurrentDate.txt"
Start-Transcript -Path $TranscriptPatch
    
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
Write-Warning "Connecting to O365"
#$upn = Read-Host "Your Polaroid e-mail address"
Connect-IPPSSession #-UserPrincipalName upn -ConnectionUri https://ps.compliance.protection.outlook.com/PowerShell-LiveID -AzureADAuthorizationEndPointUri https://login.microsoftonline.com/common
$content = Read-host "Content search name (be aware it's case sensitive)"
$address = Read-host "Sender address (be aware it's case sensitive)"

Write-Host "Creating Content search $content"
New-ComplianceSearch -Name $content -ExchangeLocation All -ContentMatchQuery "SenderAuthor=$address"
Start-ComplianceSearch -Identity $content
$status = Get-ComplianceSearch -Identity $content | select Status, Items
write-host $status

do{
    write-host "`n"
    write-Host "$content Content search is running"
    write-host $status
    $nextCheck = (Get-Date).AddMinutes(2)
    write-host "Next check will be at $nextCheck"
    Start-Sleep -Seconds 120
    $status = Get-ComplianceSearch -Identity $content | select Status, Items
    $statusofstatus = $status.Status
}until($statusofstatus -eq "Completed")

write-Host "$content Content search is completed"
$foundItems = $status.Items

write-Host "Found $foundItems items."


While(-not($type -eq 1) -and -not($type -eq 2)){
$type = Read-host "1 - Soft delete (can be restored in the next 30 days) 2 - Hard (deleted forever)"
if ($type -eq 1)
{
New-ComplianceSearchAction -SearchName $content -Purge -PurgeType SoftDelete
Write-Host  "Content search" $content " soft deleted"-ForegroundColor Green
Write-Warning "Disconnecting from O365"
Disconnect-ExchangeOnline
}
elseif ($type -eq 2)
{
New-ComplianceSearchAction -SearchName $content -Purge -PurgeType HardDelete
Write-Host  "Content search" $content " hard deleted"-ForegroundColor Red
Write-Warning "Disconnecting from O365"
Disconnect-ExchangeOnline
}
else {
write-Host ("Wrong Answer")
}
}
}
Stop-Transcript
notepad.exe $TranscriptPatch
