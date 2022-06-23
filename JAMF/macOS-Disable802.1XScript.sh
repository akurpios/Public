#!/bin/bash
currentuser=$(/bin/ls -la /dev/console | /usr/bin/cut -d ' ' -f 4)
su -l $currentuser -c "defaults -currentHost write com.apple.network.eapolcontrol EthernetAutoConnect -bool false"