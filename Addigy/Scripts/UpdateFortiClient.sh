# Determine Current User
currentUser=$( scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ && ! /loginwindow/ { print $3 }' )
echo "currentUser: " $currentUser

# Determine Current User ID
currentUserUID=`id -u "$currentUser"`
echo "currentUserUID: " $currentUserUID

#Export VPN configs
/bin/launchctl asuser "$currentUserUID" "/Library/Application Support/Fortinet/FortiClient/bin/fcconfig" -m vpn -f "/Library/Addigy/ansible/packages/Update FortiClient VPN (7.2)/FortiClientConfig_Backup.xml" -o export -p "5up3rP@55w0rd"
echo "config exported"

#UninstallOldForti
sudo /usr/bin/chflags -R noschg /Applications/FortiClient.app
echo "flag removed @ forti app"
sudo /usr/bin/chflags -R noschg /Applications/FortiClientUninstaller.app
echo "flag removed @ forti uninstaller app"
sudo rm -Rfv /Applications/FortiClient.app
echo "forti app removed"
sudo rm -Rfv /Applications/FortiClientUninstaller.app
echo "forti uninstaller app removed"

#InstallNewForti
hdiutil attach -nobrowse "/Library/Addigy/ansible/packages/Update FortiClient VPN (7.2)/FortiClient_OfflineInstaller_7.2.dmg"
/usr/sbin/installer -pkg "/Volumes/FortiClient/Install.mpkg" -target /
sudo hdiutil detach /Volumes/FortiClient/

#Import VPN Configs
/bin/launchctl asuser "$currentUserUID" "/Library/Application Support/Fortinet/FortiClient/bin/fcconfig" -m vpn -f "/Library/Addigy/ansible/packages/Update FortiClient VPN (7.2)/FortiClientConfig_Backup.xml" -o import -p "5up3rP@55w0rd"
