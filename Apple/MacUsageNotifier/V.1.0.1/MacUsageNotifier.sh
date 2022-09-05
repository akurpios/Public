#!/bin/bash

UpTime=$(uptime | tr ' ' '\n' | sed '5,6!d' | tr '\n' ' ')
if [[ "$UpTime" == *"user"* ]]; then
  UpTime=$(uptime | tr ' ' '\n' | sed '3,4!d' | tr '\n' ' ' | tr ',' ' ')
fi
if [[ "$UpTime" == *"mins"* ]]; then
  UpTime=$(uptime | tr ' ' '\n' | sed '3,5!d' | tr '\n' ' ' | tr ',' ' ')
fi

CPUUsage=$(top -l 2 | grep -E "^CPU" | tr ' ' '\n' | sed '3!d')
RAMused=$(top -l 1 | grep PhysMem: | tr ' ' '\n' | sed '2!d')
RAMfree=$(top -l 1 | grep PhysMem: | tr ' ' '\n' | sed '6!d')
SwapUsage=$(sysctl vm.swapusage | tr ' ' '\n' | sed '8!d')

osascript -e 'display notification "'"$UpTime"'" with title "Mac Usage Notifier" subtitle "Device uptime"'
osascript -e 'delay 5'
osascript -e 'display notification "'"$CPUUsage"'" with title "Mac Usage Notifier" subtitle "CPU usage"'
osascript -e 'delay 5'
osascript -e 'display notification "'"$RAMused"'" with title "Mac Usage Notifier" subtitle "RAM used"'
osascript -e 'delay 5'
osascript -e 'display notification "'"$RAMfree"'" with title "Mac Usage Notifier" subtitle "RAM free"'
osascript -e 'delay 5'
osascript -e 'display notification "'"$SwapUsage"'" with title "Mac Usage Notifier" subtitle "Swap Used"'
