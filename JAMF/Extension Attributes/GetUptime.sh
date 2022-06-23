#!/bin/bash
declare -x awk="/usr/bin/awk"
declare -x sysctl="/usr/sbin/sysctl"
declare -x perl="/usr/bin/perl"
declare -xi DAY=86400
declare -xi EPOCH="$($perl -e "print time")"
declare -xi UPTIME="$($sysctl kern.boottime |
                        $awk -F'[= ,]' '/sec/{print $6;exit}')"

declare -xi DIFF="$(($EPOCH - $UPTIME))"

if [ $DIFF -le $DAY ] ; then
        echo "<result>1</result>"
else
        echo "<result>$(($DIFF / $DAY))</result>"
fi