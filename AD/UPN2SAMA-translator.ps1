$CurrentDate = get-date -f dd-MM-yyyy_THH-mm-ss
$TranscriptPath = "C:\Support\Scripts\UPN2SAMA-translator\REPORT$CurrentDate.txt"
$IntputPath = "C:\Support\Scripts\UPN2SAMA-translator\SAMAs.csv"
$OutputPath = "C:\Support\Scripts\UPN2SAMA-translator\TranslatedUPNs.csv"

Start-Transcript -Path $TranscriptPath
Import-Csv $IntputPath -Delimiter ';' |
 
ForEach-Object { 
$UPN = $_.UserPrincipalName

write-host "Working on account: "$UPN

Get-ADUser -Filter {UserPrincipalName -eq $UPN} -Properties * | Select Name, SamAccountName, UserPrincipalName | export-csv $OutputPath -Encoding UTF8 -NoTypeInformation -Append

write-host "*******************************`r`n"
write-host 
}
Write-Host "Script Finished"
pause
Stop-Transcript
notepad.exe $TranscriptPath
