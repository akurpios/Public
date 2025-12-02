$CurrentDate = get-date -f dd-MM-yyyy_THH-mm-ss
$TranscriptPatch = "C:\Support\Scripts\DirectReportsChecker\REPORT$CurrentDate.txt"
Start-Transcript -Path $TranscriptPatch

function Get-AllReports {  
    param(  
        [string]$Manager  
    )   
    $DirectReports = Get-ADUser -Filter {manager -eq $Manager} -properties * | Select Name, UserPrincipalName, Manager, DistinguishedName
    if($DirectReports){  
        Write-Output $DirectReports  
        $DirectReports | ForEach-Object {  
            Get-AllReports -Manager $_.DistinguishedName
        }      
    }  
}  
  
$ManagerName = Read-Host -Prompt 'Input manager samAccountName to check who reports' 
Get-AllReports -Manager $ManagerName | Export-csv "C:\Support\Scripts\DirectReportsChecker\Reports_$ManagerName.csv" -NoTypeInformation -Encoding UTF8

write-host 
write-host "*******************************`r`n"
Write-Host "Script Finished"
pause
Stop-Transcript
notepad.exe $TranscriptPatch
