$CurrentDate = get-date -f dd-MM-yyyy_THH-mm-ss
$TranscriptPath = "C:\Support\Scripts\SaBcAddSendAs\REPORT$CurrentDate.txt"
$CSVpath = "C:\Support\Scripts\SaBcAddSendAs\UsersToAdd.csv"
$Delimiter = ","
$DestinationMailbox = "SharedMailbox@contoso.com"
Start-Transcript -Path $TranscriptPath

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
Connect-ExchangeOnline

Import-Csv $CSVpath -Delimiter $Delimiter |
ForEach-Object { 
    $UPN = $_.userPrincipalName
    $Name = $_.displayName

    write-host "Adding SendAs permissions to "$DestinationMailbox" for "$Name -BackgroundColor DarkCyan
    Add-RecipientPermission -Identity $DestinationMailbox -AccessRights SendAs -Trustee $UPN -Confirm:$false
    If($?)  
     {  
     Write-Host $UPN" Successfully added to "$Identity" as SendAs." -ForegroundColor Green 
     }  
     Else  
     {  
     Write-Host $UPN" has NOT BEEN added to "$Identity" as SendAs." - Error occurred –ForegroundColor Red  
     }  

    write-host "*******************************`r`n"
    write-host 
}
 write-host "Script Finished. Closing Exchange Online connection." -BackgroundColor Green
Disconnect-ExchangeOnline -Confirm:$false

Write-Host "Script Finished." -BackgroundColor Green
pause
Stop-Transcript
notepad.exe $TranscriptPath
