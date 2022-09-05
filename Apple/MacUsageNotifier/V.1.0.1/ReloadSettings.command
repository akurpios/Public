#!/bin/bash

launchctl stop ~/Library/LaunchAgents/com.kurpios.MacUsageNotifier.Schedule.plist
launchctl unload -w ~/Library/LaunchAgents/com.kurpios.MacUsageNotifier.Schedule.plist

launchctl load -w ~/Library/LaunchAgents/com.kurpios.MacUsageNotifier.Schedule.plist
launchctl start ~/Library/LaunchAgents/com.kurpios.MacUsageNotifier.Schedule.plist
