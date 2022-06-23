Import-Csv aliases.csv | ForEach-Object{
  $name = $_.AD
  $proxy = $_.Gmail
Set-ADUser -Identity $name -Add @{proxyAddresses= "smtp:"+$proxy}
Write-Output $name
Write-Output $proxy
}
