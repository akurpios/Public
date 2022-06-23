$jsonFile = "Computers export.json"
$csvFile = "Computers export.csv"
$tvAccessToken = read-host "Please type your token "​
$devicesResponse = Invoke-RestMethod -Uri "https://webapi.teamviewer.com/api/v1/devices?full_list=true" -Method Get -Headers @{authorization = "Bearer $tvAccessToken"}
$devicesResponse.devices | ConvertTo-Json | Out-File $jsonFile
$devicesResponse.devices | Export-Csv -Path $csvFile -Delimiter ',' -Encoding UTF8 -NoTypeInformation
