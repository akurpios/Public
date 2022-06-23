#TRANSLATE FROM EMAIL TO OBJECTGUID#
Import-CSV Input.csv | ForEach-Object { 
    Get-ADUser -Filter "UserPrincipalName -like '*$($_.email)*'"  -Properties UserPrincipalName, name, Enabled, ObjectGUID, DistinguishedName, MemberOf | select UserPrincipalName, name, Enabled, ObjectGUID, DistinguishedName, MemberOf
} | Export-CSV -Encoding UTF8 Output.csv

#CHECK IF SOURCE FILE EQUALS TO OUTPUT FILE#
$fileA = @(Get-Content Input.csv).Length
$fileB = @(Get-Content Output.csv).Length
$fileB = $fileB-1

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
#LOGs file (TVHost_LogFile.txt) available at TEMP folder. 
########################################################################

"@

Write-Host $credits

Write-Host "Input file lines ="$fileA
Write-Host "Output file lines ="$fileB



if ($fileB -eq $fileA)
{
Write-Host "START AD REPORT?"
pause
###AD GROUP REPORT###
 Import-CSV output.csv | ForEach-Object  {
 $guid=$_.ObjectGUID
Get-ADUser -filter "ObjectGUID -eq '$guid'" -Properties DisplayName, MemberOf | select name, @{n="MemberOf";e={($_.memberof -replace 'CN=(.+?),(OU|DC)=.+','$1')}}} | Export-CSV -Encoding UTF8 ADGroupsReports\ADGroupReport$(get-date -f yyyy-MM-dd-hhmmss).csv
Write-Host "START OFFBOARDING?"
pause
###OFFBOARDING###
    Import-CSV Output.csv | ForEach-Object { 
    $guid=$_.ObjectGUID
    #MOVE USER TO OFFBOARDED OU#
    Move-ADObject $guid -TargetPath 'OU=Users-Disabled,OU=Accounts,OU=Production,DC=domain,DC=se'
    $ADUser = Get-ADUser -Identity $guid -Properties memberOf
    ForEach ($Group In $ADUser.memberOf)
    {
    #REMOVE USER FROM AD GROUPS#
    Remove-ADGroupMember -Identity $Group -Members $ADUser -Confirm:$false
    }
     #DISABLE ACCOUNT#
    Set-ADuser -Identity $guid -Enabled 0
    ###AD GROUP REPORT AFTER OFFBOARDING###
    Get-ADUser -Filter "ObjectGUID -eq '$guid'"  -Properties name, MemberOf | select name, MemberOf
    } 
     Write-Host "AD GROUPS REPORT AFTER OFFBOARDING BELOW"
     Write-Host "DONE?"
pause
}
else
{
Write-Host "ERROR - SOME EMAIL ADDRESSES HAVE AT LEAST MORE THEN 1 REPLY. REMOVE IT FROM output.csv AND RUN MassOffboarding-MANUAL SCRIPT"
}
