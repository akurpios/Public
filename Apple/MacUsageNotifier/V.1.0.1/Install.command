#!/bin/bash

#Go To Downloads locaiton
cd ~/Downloads/MacUserNotifier

#Check if ~/Scripts exist
if [ ! -d "/Users/Shared/Scripts/Kurpios/MacUsageNotifier" ] 
then
    echo "/Users/Shared/Scripts/Kurpios DOES NOT exists. Creating" 
    mkdir /Users/Shared/Scripts
    mkdir /Users/Shared/Scripts/Kurpios
    mkdir /Users/Shared/Scripts/Kurpios/MacUsageNotifier
fi

#Install files
cp ./MacUsageNotifier.sh /Users/Shared/Scripts/Kurpios/MacUsageNotifier/MacUsageNotifier.sh
cp ./Uninstall.command /Users/Shared/Scripts/Kurpios/MacUsageNotifier/Uninstall.command
cp ./ReloadSettings.command /Users/Shared/Scripts/Kurpios/MacUsageNotifier/ReloadSettings.command
cp ./com.kurpios.MacUsageNotifier.Schedule.plist ~/Library/LaunchAgents/com.kurpios.MacUsageNotifier.Schedule.plist


chmod +x /Users/Shared/Scripts/Kurpios/MacUsageNotifier/MacUsageNotifier.sh
chmod +x /Users/Shared/Scripts/Kurpios/MacUsageNotifier/Uninstall.command
chmod +x /Users/Shared/Scripts/Kurpios/MacUsageNotifier/ReloadSettings.command
chmod +x ~/Library/LaunchAgents/com.kurpios.MacUsageNotifier.Schedule.plist


#Load Scheduler
launchctl load -w ~/Library/LaunchAgents/com.kurpios.MacUsageNotifier.Schedule.plist
launchctl start ~/Library/LaunchAgents/com.kurpios.MacUsageNotifier.Schedule.plist

#Thank you
osascript <<'END'
    set theAlertText to "Thank you :)"
    set theAlertMessage to "Thank you for installing Mac Usage Notifier. \nI would be happy if you would fill the survey about my scipt."
    display alert theAlertText message theAlertMessage as critical buttons {"Cancel", "Open survey"} default button "Open survey" cancel button "Cancel" giving up after 60
    set the button_pressed to the button returned of the result
    if the button_pressed is "Open survey" then
        open location "https://forms.office.com/r/84PH80r5TU"
    end if
END