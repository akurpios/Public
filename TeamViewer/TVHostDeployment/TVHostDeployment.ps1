
#####VARIBLES#####
###TV DEFAULT LOCATIONS###
$TVx86="C:\Program Files (x86)\TeamViewer\TeamViewer.exe"
$TVx64="C:\Program Files\TeamViewer\TeamViewer.exe"
$TVx86U="C:\Program Files (x86)\TeamViewer\Uninstall.exe"
$TVx64U="C:\Program Files\TeamViewer\Uninstall.exe"
##TV INSTALLER LOCATION##
$tvMSI="C:\TV\TeamViewer_Host_Configured.msi"
##TV DOWNLOAD LINK##
#$WebResponse = Invoke-WebRequest "https://www.teamviewer.com/en/download/previous-versions/"
#$tvVERstring = $WebResponse.tostring() -split "[`r`n]" | select-string "<p><strong>Current version:" -list -SimpleMatch | select-object -First 1
$tvVER="14.7.48350"
$tvLink="https://download.teamviewer.com/download/version_14x/$tvVER/TeamViewer_Host.msi"
write-host $tvLink
write-host $tvVER
#TV CONFIG FILE (.TVOPT)#
$conffile=@"
Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\SOFTWARE\TeamViewer]
"Proxy_Type"=dword:00000001
"Proxy_IP"=hex(1):00,00
"ProxyUsername"=hex(1):00,00
"ProxyPassword"=hex(1):00,00
"LanOnly"=dword:00000000
"General_DirectLAN"=dword:00000001
"Wol_Mode"=dword:00000000
"Wol_IP"=hex(1):00,00
"Wol_Port"=dword:00000000
"Wol_Neighbors"=hex(7):00,00
"Wol_ForceUpdate"=dword:00000001
"Security_WinLogin"=dword:00000002
"Security_PasswordStrength"=dword:00000004
"Blacklist"=hex(7):00,00
"Whitelist"=hex(7):00,00
"BlacklistBuddy"=hex(7):00,00
"WhitelistBuddy"=hex(7):00,00
"BlacklistCompany"=hex(7):00,00
"WhitelistCompany"=hex(7):00,00
"BlacklistBuddyAccountID"=hex(3):88,44,d7,0a,b2,96,2a,3d,63,16,3c,ff,e4,15,04,fb
"WhitelistBuddyAccountID"=hex(3):88,44,d7,0a,b2,96,2a,3d,63,16,3c,ff,e4,15,04,fb
"BlacklistCompanyID"=hex(3):47,94,ba,97,5c,d0,a3,35,bf,25,02,fc,2c,83,f1,36,11,e9,bf,94,16,25,5a,39,19,a0,13,0a,8f,fa,8f,5a
"WhitelistCompanyID"=hex(3):c2,fe,5d,47,c7,e7,08,11,3f,24,98,fb,da,7f,68,ee,9d,35,f2,84,0d,54,37,95,df,4a,69,8e,a9,9f,60,4d
"UseWhitelist"=dword:00000000
"RemoteMonitoring_Activated"=dword:00000001
"Security_Disableshutdown"=dword:00000000
"HideOnlineStateOfTV"=dword:00000000
"ACFullAccessOnLoginScreen"=dword:00000001
"AutoUpdateMode"=dword:00000001
"UpdateCheckInterval"=dword:00000000
"UpdateChannel"=dword:00000001
"IsPreviewVersion"=dword:00000000
"ReceiveInsiderBuild"=dword:00000000
"ChatToThisMachine"=dword:00000001
"Logging"=dword:00000001
"LogIncomingConnections"=dword:00000001
"LogOutgoingConnections"=dword:00000001
"Security_AcceptIncoming"=dword:00000001
"Local_BlackScreen"=dword:00000000
"Local_DisableInput"=dword:00000000
"CustomRouter"=hex(1):00,00
"ServerPasswordAES"=hex(3):88,44,d7,0a,b2,96,2a,3d,63,16,3c,ff,e4,15,04,fb
"useUDP"=dword:00000001
"Security_Adminrights"=dword:00000000
"OptionsPasswordHash"=hex:

[HKEY_CURRENT_USER\SOFTWARE\TeamViewer]
"ConferenceSelection"=dword:00000001
"CustomConferenceText"=hex(1):00,00
"SelectedLanguage"=hex(1):00,00
"AutoHideServerControl"=dword:00000001
"DisableCaptureBlt"=dword:00000000
"SessionRecorderDirectory"=hex(1):00,00
"LockRemoteComputer"=dword:00000002
"ClipboardSync"=dword:00000001
"ClipboardSyncExtended"=dword:00000001
"ClipboardSyncPrefill"=dword:00000001
"ChangeDynamicPassword"=dword:00000001
"DeactivatedDynamicPassword"=dword:00000000
"DisableDragAndDrop"=dword:00000000
"DisableDirectXScreenRendering"=dword:00000000

[HKEY_LOCAL_MACHINE\SOFTWARE\TeamViewer\AccessControl]
"AC_Server_AccessControlType"=dword:00000003
"AC_Server_Custom_AllowPartnerViewDesktop"=dword:00000000
"AC_Server_Custom_RemoteControlAccess"=dword:00000000
"AC_Server_Custom_FileTransferAccess"=dword:00000000
"AC_Server_Custom_AllowVPN"=dword:00000002
"AC_Server_Custom_DisableRemoteImput"=dword:00000000
"AC_Server_Custom_ControlRemoteTV"=dword:00000000
"AC_Server_Custom_AllowMeToDownloadFromFileBox"=dword:00000000
"AC_Server_Custom_AllowMeToUploadToFileBox"=dword:00000000
"AC_Server_Custom_AllowToPrintOnMyPrinters"=dword:00000000
"AC_Server_Custom_AllowToPrintOnRemotePrinters"=dword:00000002
"AC_Server_Custom_AllowExecuteScripts"=dword:00000000

[HKEY_CURRENT_USER\SOFTWARE\TeamViewer\AccessControl]
"AC_Client_Custom_ChangeDirAllowed"=dword:00000000
"AC_AllowOutgoingConnections"=dword:00000000
"AC_Client_AccessControlType"=dword:0000000a
"AC_Client_Custom_AllowPartnerViewDesktop"=dword:00000000
"AC_Client_Custom_RemoteControlAccess"=dword:00000000
"AC_Client_Custom_FileTransferAccess"=dword:00000000
"AC_Client_Custom_AllowVPN"=dword:00000000
"AC_Client_Custom_DisableRemoteImput"=dword:00000000
"AC_Client_Custom_ControlRemoteTV"=dword:00000000
"AC_Client_Custom_DisableRemoteInputAtStart"=dword:00000000
"AC_Client_Custom_ShareMyFiles"=dword:00000000
"AC_Client_Custom_ShareFilesWithMe"=dword:00000000
"AC_Client_Custom_AllowToPrintOnMyPrinters"=dword:00000000
"AC_Client_Custom_AllowToPrintOnRemotePrinters"=dword:00000000
"AC_Client_Custom_AllowExecuteScripts"=dword:00000000
"Meeting_AC_AccessControlType"=dword:00000000
"Meeting_AC_Custom_HostAMeetingAccess"=dword:00000000
"Meeting_AC_Custom_JoinAMeetingAccess"=dword:00000000
"Meeting_AC_Custom_ControlRemoteComputersAccess"=dword:00000000
"Meeting_AC_Custom_ControlThisComputersAccess"=dword:00000000
"Meeting_AC_Custom_RecordMeetingAccess"=dword:00000000
"Meeting_AC_Custom_ShareMyFilesAccess"=dword:00000000
"Meeting_AC_Custom_ShareFilesWithMeAccess"=dword:00000000

[HKEY_CURRENT_USER\SOFTWARE\TeamViewer\MsgBoxDontShow]
"PasswordOnSessionEnd"=dword:00000001
"@
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
###CREATING LOCAL VARIBLE TO USE CUSTOM TV ENTRY NAME###
#
#write-host "Building TeamViewer name"
#$hostname=[System.Net.Dns]::GetHostname()
#$currentuser=$env:UserName
#$TVnameToSet="$hostname($currentuser)"
#[System.Environment]::SetEnvironmentVariable('TVNAME', $TVNameToSet,[System.EnvironmentVariableTarget]::Machine)
#Write-Host "TeamViewer name: " $TVnameToSet
#
##sCRIPT##
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
write-host "Detecting TeamViewer instalation file"
If (Test-Path $tvMSI){ 
write-host "TeamViewer installation exist"}
else{
write-host "Downloading install file"
Invoke-WebRequest -Uri $tvLink -OutFile $tvMSI}
write-host "Building TeamViewer config file"
Set-Content TeamViewer_Settings.tvopt $conffil 
Start-Sleep -Seconds 5
write-host "Installing TeamViewer"
Start-Process msiexec.exe -Wait -ArgumentList '/I C:\TV\TeamViewer_Host_Configured.msi /qn  SETTINGSFILE=C:\TV\TeamViewer_Settings.tvopt CUSTOMCONFIGID={{CUSTOMCONFIGID}} APITOKEN={{APITOKEN}} ASSIGNMENTOPTIONS="--reassign --alias %COMPUTERNAME% --group-id {{GROUPID}} --grant-easy-access"'
Start-Sleep -Seconds 10
Stop-Transcript
notepad.exe $logfilePath
