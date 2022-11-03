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
        [string]$Title = 'Hide From GAL'
    )
    Clear-Host
    Write-Host "================ $Title ================"
    
    Write-Host "1: Hide form GAL"
    Write-Host "2: UnHide from GAL"
    
    Write-Host "Q: Press 'Q' to quit."
}
	
do
 {
     Show-Menu
$selection = Read-Host "Please select type of sync"
     switch ($selection)
     {
         '1' {
			 Write-Host "Hide form GAL choosed"
             $upn = Read-Host "Type UPN"
			 $mailnickname = $upn.Split('@')[0]
			 $SAMA = Get-ADUser -Filter "userPrincipalName -like '$upn'" | select sAMAccountName
			 $SAMA = $SAMA -replace "@{sAMAccountName=",""
			 $SAMA = $SAMA -replace "}",""
			 
			 
			 Set-ADUser $SAMA -replace @{'msExchHideFromAddressLists' = "TRUE" }
			 Set-ADUser $SAMA -replace @{'mailNickname' = $mailnickname}

			 Start-ADSyncSyncCycle -PolicyType Delta
             }
         '2' {
             Write-Host "UnHide form GAL choosed"
             $upn = Read-Host "Type UPN"
			 $mailnickname = $upn.Split('@')[0]
			 $SAMA = Get-ADUser -Filter "userPrincipalName -like '$upn'" | select sAMAccountName
			 $SAMA = $SAMA -replace "@{sAMAccountName=",""
			 $SAMA = $SAMA -replace "}",""
			
			
			Set-ADUser $SAMA -Clear mailNickname,msExchHideFromAddressLists
			 
		     Start-ADSyncSyncCycle -PolicyType Delta       
			}
             
     }
     pause
 }
 until ($selection -eq 'q')
