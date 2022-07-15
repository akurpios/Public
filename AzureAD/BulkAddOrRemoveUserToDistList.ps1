#ADD#
$UPN = Read-Host -Prompt 'Input your UPN'
Connect-EXOPSSession -UserPrincipalName $UPN
$name = Read-Host -Prompt 'Input user FQDN'
$path = Read-Host -Prompt 'Drag and drop the CSV file (remove the " signs)'
Import-Csv $path | ForEach-Object{
$Identity = $_.Identity
#Add-RecipientPermission $Identity -AccessRights SendAs -Trustee $name -Confirm:$false
Write-Host "name: " $name "has been added to" $Identity
}
pause





#REMOVE#
Import-Csv list.csv | ForEach-Object{
  $name = "mail@domain.com"
  $Identity = $_.Identity
Remove-DistributionGroupMember -Identity $Identity -Member $name
Write-Host "Identity: " $Identity
#Write-Output $proxy
}
pause
