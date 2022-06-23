#!/bin/sh
hwIdentifier=$(sysctl -n hw.model)
VAR_SERIAL="$(ioreg -l | grep IOPlatformSerialNumber | sed -e 's/.*\"\(.*\)\"/\1/')"
VAR_USERNAME="$(stat -f%Su /dev/console)"
VAR_REALNAME="$(dscl . -read /Users/$VAR_USERNAME RealName | cut -d: -f2 | sed -e 's/^[ \t]*//' | grep -v "^$" | sed -e 's/$/ /' -e 's/\([^ ]\)[^ ]* /\1/g' -e 's/^ *//')"
VAR_COMPANY="COMPANYNAME"
VAR_MODEL="notChosen"
	if [[ $hwIdentifier =~ "MacBookPro" ]] ; then
		VAR_MODEL="MBP"
	elif [[ $hwIdentifier =~ "MacBookAir" ]] ; then
		VAR_MODEL="MBA"
	elif [[ $hwIdentifier =~ "iMac" ]] ; then
		VAR_MODEL="IMAC"
	elif [[ $hwIdentifier =~ "MacBook" ]] ; then
		VAR_MODEL="MB"
	elif [[ $hwIdentifier =~ "Macmini" ]] ; then
		VAR_MODEL="MM"
	elif [[ $hwIdentifier =~ "MacPro" ]] ; then
		VAR_MODEL="MP"
	else
    	echo "Model not found"
    fi
VAR_HOSTNAME="$VAR_MODEL-$VAR_COMPANY-$VAR_SERIAL"
scutil --set ComputerName "$VAR_HOSTNAME"
scutil --set LocalHostName "$VAR_HOSTNAME"
scutil --set HostName "$VAR_HOSTNAME"
