#Varibles#
$CurrentDate = get-date -f dd-MM-yyyy_THH-mm-ss
$TranscriptPath = "C:\Support\Scripts\GetDistributionGroupMembers\REPORT$CurrentDate.txt"
$CSVPath = "C:\Support\Scripts\GetDistributionGroupMembers\USdistlist.csv"
$ExportPath = "C:\Support\Scripts\GetDistributionGroupMembers\ExportedInfo"

Start-Transcript -Path $TranscriptPath

#Checks#
if (Test-Path -Path $ExportPath) {
    write-host "Export folder already exists"
} else {
    write-host "Export folder doesn't exist. Creating"
    mkdir -p $ExportPath
}

if (Get-Module -ListAvailable -Name ExchangeOnlineManagement) {
    Write-Host "ExchangeOnlineManagement Module Installed"
    Import-Module ExchangeOnlineManagement
    Connect-ExchangeOnline
    } 
else {
    Write-Host ExchangeOnlineManagement Module not installed. Please install the MSOnline module using below command: `nInstall-Module ExchangeOnlineManagement  -ForegroundColor yellow
    #Install-Module MSOnline
    Pause
    exit
    }

Import-Csv $CSVPath -Delimiter ';' |

ForEach-Object { 
$DistList = $_.DistList

write-host "Exporting GENERAL INFORMATION OF:" $DistList
Get-DistributionGroup -Identity $DistList | Format-Table DisplayName, ManagedBy, WhenCreated -Auto > "$ExportPath\$DistList-info.txt"
write-host "Exporting MEMBERS OF:" $DistList
Get-DistributionGroupMember -Identity $DistList >> "$ExportPath\$DistList-info.txt"
}

#Ending#

Disconnect-ExchangeOnline -Confirm:$false
Write-Host "Script Finished"
pause
ii $ExportPath
notepad.exe $TranscriptPath
Stop-Transcript
