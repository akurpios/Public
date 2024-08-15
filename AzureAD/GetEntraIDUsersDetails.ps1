cls
#Echo
echo "----------------------------------"
echo "Get EntraID users and their details"
echo "By Aleksander Kurpios"
echo "----------------------------------"
$CurrentDate = get-date -f dd-MM-yyyy_THH-mm-ss #Get Current date and time
$RootdirectoryPath = (Get-Location).path #Get Current location
New-Item -Path $RootdirectoryPath -Name $CurrentDate -ItemType "directory" #Create new folder for this job
$directoryPath = "$RootdirectoryPath\$CurrentDate" #Set work folder
$exportPath = "$RootdirectoryPath\$CurrentDate\GrpahExportedUsers.csv" #Set path for exporting CSV
$TranscriptPatch = "$directoryPath\Graph-GetUsers-REPORT$CurrentDate.txt" #Set location for transcript
Start-Transcript -Path $TranscriptPatch

Connect-MgGraph -Scopes "User.Read.All", "AuditLog.Read.All", "Organization.Read.All"
$producttable = Invoke-RestMethod 'https://gist.githubusercontent.com/krzydoug/84aa5af47335c219f42a820c84c1371d/raw/13de15e8768adb73595ce226259af96510906337/Product%2520Table.psd1' | Invoke-Expression

$UserLastEntraIDLoginData = Get-MgUser -All -Property DisplayName,UserPrincipalName,AccountEnabled,SignInActivity,lastPasswordChangeDateTime | select DisplayName,UserPrincipalName,AccountEnabled,@{N='LastSignInDate';E={$_.SignInActivity.LastSignInDateTime}},lastPasswordChangeDateTime,@{N='License';E={$producttable[(Get-MgUserLicenseDetail -UserId $_.id).skuid] -join '; '}}

$UserLastEntraIDLoginData | Export-Csv -Path $ExportPath -Encoding UTF8 -NoTypeInformation -Append


Disconnect-MgGraph  

Write-Host "Script Finished, output file is "$ExportPath
Pause
Stop-Transcript
