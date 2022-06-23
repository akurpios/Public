cls
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
#credits#
$credits=@"
#
#
#
#SCRIPT CREATED BY ALEKSANDER KUPRIOS
#ALL RIGHTS RESERVED
#CONTACT: kontakt@kurpios.it
#
#
#
########################################################################

"@
Write-Host $credits
 Import-Module ADSync
function Show-Menu
{
    param (
        [string]$Title = 'Push AD Sync'
    )
    Clear-Host
    Write-Host "================ $Title ================"
    
    Write-Host "1: Sync change."
    Write-Host "2: Full sync."
    
    Write-Host "Q: Press 'Q' to quit."
}
    
do
 {
     Show-Menu
$selection = Read-Host "Please select type of sync"
     switch ($selection)
     {
         '1' {
             Write-Host "changes  sync choosed"
             Start-ADSyncSyncCycle -PolicyType Initial
             }
         '2' {
             Write-Host "Full sync choosed"
             Start-ADSyncSyncCycle -PolicyType Delta
             }
             
     }
     pause
 }
 until ($selection -eq 'q') 
