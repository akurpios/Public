Import-Csv "KITuserReport.csv" -Delimiter ',' |
 
ForEach-Object { 
$upn = $_.UPN
$username=Get-ADUser -Filter "UserPrincipalName -eq '$upn'"
$guid=$username.ObjectGUID
write-host $upn GUID ID is: $guid
#Remove-ADGroupMember -Identity TestGroupA -Members $guid -Confirm:$false
write-host $upn removed  from TestGroupA
#Add-ADGroupMember -Identity TestGroupB -Members $guid
write-host $upn added  to TestGroupB
} 
