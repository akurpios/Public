Import-Csv "C:\Users\Administrator\Desktop\exportUser_2021-8-3.csv" -Delimiter ',' |

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

ForEach-Object { 
New-ADUser `
-SamAccountName $_."name" `
-Name $_."displayName" `
-GivenName $_.givenName `
-Surname $_.surname `
-Path "OU=Users,OU=Producion,DC=kurpiosit,DC=onmicrosoft,DC=com" `
-UserPrincipalName $_.userPrincipalName `
-AccountPassword (ConvertTo-SecureString "3gT(FE\#ayxh" -AsPlainText -Force) `
-EmailAddress $_."mail" `
-Enabled $true `
-DisplayName $_."displayName" `
-Title $_."jobTitle" `
-Department $_."department" `
-Company $_."companyName" `
} 
