
#####VARIBLES#####
###TV DEFAULT LOCATIONS###
$TVx86="C:\Program Files (x86)\TeamViewer\TeamViewer.exe"
$TVx64="C:\Program Files\TeamViewer\TeamViewer.exe"
$TVx86U="C:\Program Files (x86)\TeamViewer\Uninstall.exe"
$TVx64U="C:\Program Files\TeamViewer\Uninstall.exe"
##TV INSTALLER LOCATION##
$tvMSI="C:\TV\TeamViewer_Host.msi"
$ConfigID=""
$AssignmentID="="
$TVexe="C:\Program Files\TeamViewer\TeamViewer.exe"

#credits#
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
#LogFile
$logfilePath="$($ENV:Temp)\TVHost_LogFile.txt"

##SCRIPT##
Start-Transcript -Path $logfilePath
Write-Host $credits
Write-Host "Checking working place"
if(Test-Path C:\TV){
Write-Host "Working place exist"
cd c:\TV}
else{
cd C:\
write-host "Creating working place"
mkdir TV
cd TV}
if (get-process TeamViewer -ea SilentlyContinue) {
write-host "Killing working TeamViewer"
taskkill /IM TeamViewer.exe /F}
else{
write-host "No TeamViewer process found"}
write-host "Detecting TeamViewer installed"
If (Test-Path $TVx86){ 
write-host "uninstalling TeamViewer"
$TV=get-wmiobject -Class Win32_Product -Filter "Vendor = 'TeamViewer'"
Try {
$TV.Uninstall()}
catch {
write-host "No Win32_Product found. Uninstalling by path"
Try {
Start-Process -FilePath ($TVx86u) -Wait -ArgumentList "/S" -WindowStyle Hidden}
catch{
Write-Host "cannot uninstall TeamVIewer x86 by path. Please uninstall it manually"}
}}
If (Test-Path $TVx64){ 
write-host "uninstalling TeamViewer"
$TV=get-wmiobject -Class Win32_Product -Filter "Vendor = 'TeamViewer'"
Try {
$TV.Uninstall()}
catch {
write-host "No Win32_Product found. Uninstalling by path"
Try {
Start-Process -FilePath ($TVx64u) -Wait -ArgumentList "/S" -WindowStyle Hidden}
catch{
Write-Host "cannot uninstall TeamVIewer x64 by path. Please uninstall it manually"}

}
}
write-host "Installing TeamViewer"
cmd.exe /c start /wait MSIEXEC.EXE /i $tvMSI /qn CUSTOMCONFIGID=$ConfigID 

Start-Sleep -Seconds 30

Write-Host "Configuring TeamViewer"
cmd.exe /c $TVexe assignment --id $AssignmentID


Stop-Transcript
notepad.exe $logfilePath
