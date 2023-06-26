$DUID=(Get-Random -Minimum 0 -Maximum 99999).ToString('00000')
#$serial=(gwmi win32_bios).SerialNumber
write-host "NEW HOSTNAME: Prefix-$DUID"
Rename-Computer -NewName "Prefix-$DUID" -Force
