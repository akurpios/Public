cls
$TranscriptCurrentDate = get-date -f dd-MM-yyyy_THH-mm-ss
$TranscriptPatch = "C:\SCRIPTS\JobChecker\REPORT$TranscriptCurrentDate.txt"
Start-Transcript -Path $TranscriptPatch
##OLD VEEAM DAY 0##
#$CurrentDate = get-date
#$CurrentDateMidnight = get-date -UFormat "%m/%d/%Y 12:00 AM"

##NEW VEEAM DAY 0##
$today=get-date

if ($today.DayOfWeek.value__ -eq 1){
write-host "Today is monday and everything is OK" -BackgroundColor Green
$CurrentDate = get-date
}
else{
write-host "Today is"$today "and it's " $today.DayOfWeek -BackgroundColor Red
$delta = ($today.DayOfWeek.value__ + 5) % 7 + 1

write-host "Days over Monday: "$delta
$monday = $today.AddDays(-$delta)
write-host "Today: "$today
write-host "Last monday: "$monday $monday.DayOfWeek
$CurrentDate = $monday
}
$CurrentDateMidnight = get-date -Date $CurrentDate -UFormat "%m/%d/%Y 12:00 AM"
write-host "Day 0 used by Veeam will be: " $CurrentDateMidnight

##Getting Veeam jobs##

$jobs=get-vbojob | Where-Object {$_.IsEnabled -eq $true} | Select ID

$jobscount = $jobs.Count
write-host "There are " $jobscount " jobs in Veeam"
Write-Host ""

##set counters to 0##
$jobsFinished=0
$jobsRunning=0
$jobsNotStarted=0

##checking each job status##
foreach ($job in $jobs){
    [string]$jobstring=$job
    $jobstring=$jobstring.Remove(0,5)
    $jobstring=$jobstring.Remove($jobstring.Length-1,1)
    $GetJob = Get-VBOJob -id $jobstring
    $JobLastRun = $GetJob.lastrun
    $JobLastStatus = $GetJob.laststatus
    [string]$jobname=Get-VBOJob -id $jobstring | Select Name
    $jobname=$jobname.Remove(0,7)
    $jobname=$jobname.Remove($jobname.Length-1,1)
    write-host "Job name: "$jobname
    
    if ($JobLastStatus -eq "Running"){
    Write-Host "Running" -BackgroundColor Blue
    $jobsRunning++
    }
    Else{
    if ($JobLastRun -gt $CurrentDateMidnight){
    Write-Host "already finished" -BackgroundColor Green
    $jobsFinished++
    }
    Else{
    Write-Host "not started yet" -BackgroundColor Red
    $jobsNotStarted++
    }}
}

##summary##
Write-Host ""
write-host "Jobs finished="$jobsFinished
write-host "Jobs running="$jobsRunning
write-host "Jobs not started yet="$jobsNotStarted
Write-Host ""


##check if all jobs finished##
if ($jobsFinished -eq $jobscount){
    Write-Host "All veeam jobs finished. Ready to deallocate VM" -BackgroundColor Green

    ##Deallocating VM##

    # Check if all necessary modules are installed
    $modules = @("Az.Compute", "Az.Accounts")
    foreach ($module in $modules) {
    if (!(Get-Module -Name $module -ListAvailable)) {
        write-host "Installing $module module"
        Install-Module -Name $module -Repository PSGallery -Force
        Write-Host "Module $module Installed"  
    }
    Import-Module $module
    }
    # Connect to Azure
    $hostname="AAAAbbbbbCCCCCCdddd"
    $username = "serviceaccount@contoso.com"
    $password = "5up3rS3cur3P@55w0rD"
    $SecurePassword = ConvertTo-SecureString $password -AsPlainText -Force
    $credentials = New-Object System.Management.Automation.PSCredential($username, $SecurePassword) 
    Connect-AzAccount -Credential $credentials
    write-host "connecting to Azure"
    Stop-AzVM -ResourceGroupName "RG-01" -Name $hostname -Force
    write-host "Stoping VM"
    }
    Else{
    Write-Host "Not all veeam jobs finished. Not Ready to deallocated VM" -BackgroundColor Red
    }
Write-Host ""
Write-Host "Script Finished"
Stop-Transcript
#notepad.exe $TranscriptPatch
#pause
