#Kickstart Windows update on remote servers#

$CurrentDate = get-date -f dd-MM-yyyy_THH-mm-ss
$TranscriptPatch = "C:\Support\Scripts\RemoteWindowsUpdate\REPORT$CurrentDate.txt"
Start-Transcript -Path $TranscriptPatch

function Show-Menu
{
    param (
        [string]$Title = Kickstart Windows update on remote servers'
    )
    Clear-Host
    Write-Host "================ $Title ================"
    Write-Host "================ Kickstart for: ================"
    
    Write-Host "1: Site1"
    Write-Host "2: Site2"
    Write-Host "3: Site3"
    Write-Host "4: Site4"
    Write-Host "5: Site5"
    
    Write-Host "Q: Press 'Q' to quit."
}

function Update ($DomainComputers, $NonDomainComputers)
{
    if (!$DomainComputers) { Write-Host "DomainComputers is null. Skipping" }
    Else{
    foreach ($server in $DomainComputers){
	write-host "Working for: $server"
	Invoke-Command -ComputerName $server -ScriptBlock {
    write-host "connected to: $env:computername"
    write-host "Checking if module PSWindowsUpdate is installed on $env:computername"
    if (Get-Module -ListAvailable -Name PSWindowsUpdate) {
    Write-host "Module PSWindowsUpdate exists - skipping installation" -ForegroundColor Green
    } 
    else {
        Write-Warning "Module PSWindowsUpdate does not exist. Installing module"
        Set-ExecutionPolicy RemoteSigned
        Write-Host "Checking for admin rights"
        if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
            [Security.Principal.WindowsBuiltInRole] "Administrator")) {
            Write-Warning "Insufficient permissions to install this module. Open the PowerShell console as an administrator and run this script again."
            Break
            }
        else {
        Write-Host "Console running as admin. Processing installation module" -ForegroundColor Green
        #Install-Module -Name PSWindowsUpdate
        write-host "DEMO - NOT INSTALLING NOW!!!!!"
        }
    }
    write-host "Pushing updates for: "$env:computername
    try {write-host "DEMO - NOT PUSHING NOW!!!!!"
        }
	    catch{Write-Host "UPDATE OF: "$env:computername " NOT SUCESS`r`n" -BackgroundColor Red
        }
	}
 }}
    ##Restart service on non-domain servers
    $credentials = $Credential = $host.ui.PromptForCredential("Need credentials", "Please enter WMI user name and password", "", "NetBiosUserName")
    if (!$NonDomainComputers) { Write-Host "NonDomainComputers is null. Skipping" }
    Else{
    foreach ($server in $NonDomainComputers){
	write-host "Working for: $server"
	Invoke-Command -ComputerName $server -Credential $credentials -ScriptBlock {
    write-host "connected to: $env:computername"
    write-host "Checking if module PSWindowsUpdate is installed on $env:computername"
    if (Get-Module -ListAvailable -Name PSWindowsUpdate) {
    Write-host "Module PSWindowsUpdate exists - skipping installation" -ForegroundColor Green
    } 
    else {
        Write-Warning "Module PSWindowsUpdate does not exist. Installing module"
        Set-ExecutionPolicy RemoteSigned
        Write-Host "Checking for admin rights"
        if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
            [Security.Principal.WindowsBuiltInRole] "Administrator")) {
            Write-Warning "Insufficient permissions to install this module. Open the PowerShell console as an administrator and run this script again."
            Break
            }
        else {
        Write-Host "Console running as admin. Processing installation module" -ForegroundColor Green
        #Install-Module -Name PSWindowsUpdate
        write-host "DEMO - NOT INSTALLING NOW!!!!!"
        }
    }
    write-host "Pushing updates for: "$env:computername
    try {write-host "DEMO - NOT PUSHING NOW!!!!!"
        }
	    catch{Write-Host "UPDATE OF: "$env:computername " NOT SUCESS`r`n" -BackgroundColor Red
        }
	}
 }}
   
}


$1DomainServers=""
$2DomainServers=""
$3DomainServers=""
$4DomainServers=""
$5DomainServers=""

$1NonDomainServers=""
$2NonDomainServers=""
$3onDomainServers=""
$4NonDomainServers=""
$5NonDomainServers=""

	
do
 {
    Show-Menu
    $selection = Read-Host "Please select location"
     switch ($selection)
     {
         '1' {
             Write-Host "Enforcing for 1"
             $DomainComputers=$1DomainServers
             $NonDomainComputers=$2NonDomainServers
             Update $DomainComputers $NonDomainComputers
             }
         '2' {
             Write-Host "Enforcing for 2"
             $DomainComputers=$2DomainServers
             $NonDomainComputers=$2NonDomainServers
             Update $DomainComputers $NonDomainComputers
             }
         '3' {
             Write-Host "Enforcing for 3"
             $DomainComputers=$3DomainServers
             $NonDomainComputers=$3NonDomainServers
             Update $DomainComputers $NonDomainComputers
             }
         '4' {
             Write-Host "Enforcing for 4"
             $DomainComputers=$4DomainServers
             $NonDomainComputers=$4NonDomainServers
             Update $DomainComputers $NonDomainComputers
             }
         '5' {
             Write-Host "Enforcing for 5"
             $DomainComputers=$5DomainServers
             $NonDomainComputers=$5NonDomainServers
             Update $DomainComputers $NonDomainComputers
             }
             
     }
     pause
 }
 until ($selection -eq 'q')

Write-Host "Script Finished"
Stop-Transcript
notepad.exe $TranscriptPatch
