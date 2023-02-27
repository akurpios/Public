cls
$csvFile = ".\example.csv"
$tvAccessToken = read-host "Please type your token "

 $headers = @{}
$headers["Accept"] = "application/json"
$headers["Authorization"] = "Bearer $tvAccessToken"
 

  Import-CSV $csvFile | Foreach-Object {
curl -Method Post -ContentType application/json -Headers $headers -Body "{
  'alias': '$($_.alias)', 
  'groupid': '$($_.groupid)', 
  'remotecontrol_id': '$($_.remotecontrol_id)', 
  'description': '$($_.description)', 
  'password': '$($_.password)' 
}" 'https://webapi.teamviewer.com/api/v1/devices'
}
