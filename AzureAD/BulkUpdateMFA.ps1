$CurrentDate = get-date -f dd-MM-yyyy_THH-mm-ss
$TranscriptPatch = "C:\MDMscripts\BulkUpdateMFA\REPORT$CurrentDate.txt"
Start-Transcript -Path $TranscriptPatch

if (Get-Module -ListAvailable -Name MSOnline) {
    Write-Host "MSOnline Module Installed"
} 
else {
    Write-Host MSOnline Module not installed. Please install the MSOnline module using below command: `nInstall-Module MSOnline  -ForegroundColor yellow
    #Install-Module MSOnline
    Pause
    exit
}
<#
If problem with log-in to O365 with MFA please update MSOnline with that
Install-module MSOnline -Force -AllowClobber
#>
Connect-MsolService

Import-Csv "C:\MDMscripts\BulkUpdateMFA\Users.csv" -Delimiter ',' |
 
ForEach-Object { 
$UPN = $_.UserPrincipalName
$DisplayName = $_.displayName

Write-Host "PERFORMING ACTION FOR: "$DisplayName "`r`n" -BackgroundColor Blue
$st = New-Object -TypeName Microsoft.Online.Administration.StrongAuthenticationRequirement
$st.RelyingParty = "*"
$st.State = "Enabled"
$sta = @($st)
try {
    Set-MsolUser -UserPrincipalName $UPN -StrongAuthenticationRequirements $sta
}
catch
{
   Write-Host "ACTION FOR: "$DisplayName " NOT SUCESS`r`n" -BackgroundColor Red
}
Write-Host "ACTION FOR: "$DisplayName " SUCESS`r`n" -BackgroundColor Green
}

Write-Host "Script Finished"
pause
Stop-Transcript
notepad.exe $TranscriptPatch
