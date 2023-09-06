# Credits: Dawid Szwala :)
cls
Set-Location C:\
$path="C:\MDM"
$UsgeReportPath="C:\config\UsageReport.txt"
$TranscriptPath="C:\config\TranscriptReport.txt"
$isthere=Test-Path -Path $path
$date=Get-Date -Format "dddd MM/dd/yyyy HH:mm:ss"
$quser=quser
Start-Transcript -Path $TranscriptPath -Append
write-host "TRANSCRIPT STARTED AT: $date"

if ($isthere -eq "True") {
    #Add-Content -Path $UsgeReportPath `r`n$date`r`n$quserResult
     Add-Content -Path $UsgeReportPath `r`n$quserResult
}else {
    mkdir c:\config
    Set-Location C:\config
    $quserResult=$quser | Out-String
    #Add-Content -Path $UsgeReportPath $date`r`n$quserResult
    Add-Content -Path $UsgeReportPath `r`n$quserResult
}    
if ($quser -like '*active*' -or $quser -like '*disconnected*') {
    write-host "quser report:"`n
    write-host $quserResult
    write-host "Users logged in. Skipping shutdown"
	
}else {
  write-host "quser report:"`n
    write-host $quserResult
 write-host "No users logged in. Shutdown in process. Shutting down disabled. Just reporting"
#Add-Content -Path $UsgeReportPath $date`r`n "No users logged in. Shutdown in process. Shutting down disabled. Just reporting"
$hostname=Hostname
write-host "hostname = $hostname"
# Check if all necessary modules are installed
$modules = @("Az.Compute", "Az.Accounts")
foreach ($module in $modules) {
    if (!(Get-Module -Name $module -ListAvailable)) {
        Write-Host "Installing $module module"
	#Add-Content -Path $UsgeReportPath $date`r`n "Installing $module module"
        Install-Module -Name $module -Repository PSGallery -Force
        Write-Host "Module $module Installed" 
	#Add-Content -Path $UsgeReportPath $date`r`n "Module $module Installed" 
    }
    Import-Module $module
}
# Connect to Azure
$username = "sa-azure.VPS.PowerOnOffContributor@polaroid.com"
$password = "aFCabZ28JepQkeq6U7RNwBP87yGDfQt4d2C99tmB3DnqFydaUdwrBHADextdLntw"
$SecurePassword = ConvertTo-SecureString $password -AsPlainText -Force
$credentials = New-Object System.Management.Automation.PSCredential($username, $SecurePassword) 
#Connect-AzAccount -Credential $credentials
#Add-Content -Path $UsgeReportPath $date`r`n "connecting to Azure"
#Stop-AzVM -ResourceGroupName "RG-VPS-TEST-001" -Name $hostname -Force
#Add-Content -Path $UsgeReportPath $date`r`n "Stoping VM"
}
#pause
Stop-Transcript
