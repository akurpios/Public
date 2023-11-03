Get-ADUser -Properties *  -Filter * | Where-Object {$_.Manager -like "*offboarded*" -and $_.Name -notlike "*offboarded*"} | select Name, SamAccountName, Manager | Export-Csv C:\Users\akurpios\Desktop\UsersWithOffboardedManagers.csv -Encoding UTF8 -NoTypeInformation