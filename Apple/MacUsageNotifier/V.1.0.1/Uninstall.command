#!/bin/bash

#Load Scheduler
launchctl stop ~/Library/LaunchAgents/com.kurpios.MacUsageNotifier.Schedule.plist
launchctl unload -w ~/Library/LaunchAgents/com.kurpios.MacUsageNotifier.Schedule.plist

#Uninstall files
rm /Users/Shared/Scripts/Kurpios/MacUsageNotifier/MacUsageNotifier.sh
rm -r /Users/Shared/Scripts/Kurpios/MacUsageNotifier
rm ~/Library/LaunchAgents/com.kurpios.MacUsageNotifier.Schedule.plist

