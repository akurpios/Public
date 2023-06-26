$DUID=(Get-Random -Minimum 0 -Maximum 99999).ToString('00000')
$serial=(gwmi win32_bios).SerialNumber
Rename-Computer -NewName "Prefix-$DUID-$serial" -Force
