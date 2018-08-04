#!/bin/bash

#############################################################################
# Version 0.2.0-ALPHA (04-08-2018)
#############################################################################

#############################################################################
# Copyright 2018 Sebas Veeke. Licenced under a Creative Commons Attribution-
# NonCommercial-ShareAlike 4.0 International License.
#
# See https://creativecommons.org/licenses/by-nc-sa/4.0/
#
# Contact:
# > e-mail      mail@sebasveeke.nl
# > GitHub      sveeke
#############################################################################

# General information
TelegramAlertBotVersion='0.1.0'

# Source variables in TelegramBots.conf
. /etc/TelegramBots/TelegramBots.conf

# Bot variables
LoadThreshold="$(echo "$Threshold_Load_TelegramAlertBot" | tr -d '%')"
DiskThreshold="$(echo "$Threshold_Disk_TelegramAlertBot" | tr -d '%')"
MemoryThreshold="$(echo "$Threshold_Memory_TelegramAlertBot" | tr -d '%')"

# Core and load information
CoreAmount="$(grep 'cpu cores' /proc/cpuinfo | wc -l)"
MaxLoadServer="$CoreAmount.00"
CurrentLoad="$(cat /proc/loadavg | awk '{print $3}')"
CurrentLoadPercentage="$(echo "("$CurrentLoad"/"$MaxLoadServer")*100" | bc -l)"
CurrentLoadPercentageRounded="$(printf "%.0f\n" $(echo "$CurrentLoadPercentage" | tr -d '%'))"

# Disk usage information
CurrentDiskUsage="$(df -h / | grep / | awk {'print $5'} | tr -d '%')"

# Memory usage information
CurrentMemoryUsage="$(free -m | awk '/^Mem/ {print $3}' | tr -d 'GKMT')"
MaxMemoryServer="$(free -m | awk '/^Mem/ {print $2}' | tr -d 'GKMT')"
CurrentMemoryPercentage="$(echo "("$CurrentMemoryUsage"/"$MaxMemoryServer")*100" | bc -l)"
CurrentMemoryPercentageRounded="$(printf "%.0f\n" $(echo "$CurrentMemoryPercentage" | tr -d '%'))"


# Enable the use of arguments
case $1 in
    --help|-help|help|--h|-h|help)
        echo
        echo "USAGE: TelegramAlertBot [OPTION]..."
        echo "Sent alerts about server metrics that exceed the threshold."
        echo
        echo "OPTIONS:"
        echo "--cli       output metrics to cli and exit"
        echo "--help      display this help and exit"
        echo "--version   display version information and exit"
        echo
        exit 0;;

    --version)
        echo
        echo "TelegramAlertBot $TelegramAlertBotVersion"
        echo "Copyright (C) 2018 S. Veeke."
        echo
        echo "License CC Attribution-NonCommercial-ShareAlike 4.0 Int."
        echo
        exit 0;;

    --cli|--command-line|--local)

# Disk usage
if [[ "$CurrentDiskUsage" -ge "$DiskThreshold" ]]; then
    AlertMessage="\xE2\x9A\xA0 *ALERT: FILE SYSTEM*\\n\\nDisk usage ($CurrentDiskUsage%) on *$(uname -n)* exceeds the threshold of $Threshold_Hdd_TelegramAlertBot\\n\\n*Filesystem info:*\\n$(df -h)"
    AlertPayload="chat_id=$Chat_TelegramAlertBot&text=$(echo -e "$AlertMessage")&parse_mode=Markdown&disable_web_page_preview=true"
    curl -s --max-time 10 --retry 5 --retry-delay 2 --retry-max-time 10 -d "$AlertPayload" $Url_TelegramAlertBot > /dev/null 2>&1 &
fi

# Server load
if [[ "$CurrentLoadPercentageRounded" -ge "$LoadThreshold" ]]; then
AlertMessage="\xE2\x9A\xA0 *ALERT: SERVER LOAD*\\n\\nThe server load ($CurrentLoadPercentageRounded%) on *$(uname -n)* exceeds the threshold of $Threshold_Load_TelegramAlertBot\\n\\n*Load average:*\\n$(cat /proc/loadavg | awk '{print $1" "$2" "$3}')"
AlertPayload="chat_id=$Chat_TelegramAlertBot&text=$(echo -e "$AlertMessage")&parse_mode=Markdown&disable_web_page_preview=true"
curl -s --max-time 10 --retry 5 --retry-delay 2 --retry-max-time 10 -d "$AlertPayload" $Url_TelegramAlertBot > /dev/null 2>&1 &
fi

# Server load
if [[ "$CurrentMemoryPercentageRounded" -ge "$MemoryThreshold" ]]; then
AlertMessage="\xE2\x9A\xA0 *ALERT: SERVER MEMORY*\\n\\nMemory usage ($CurrentMemoryPercentageRounded%) on *$(uname -n)* exceeds the threshold of $Threshold_Memory_TelegramAlertBot\\n\\n*Memory usage:*\\n$(free -m -h)"
AlertPayload="chat_id=$Chat_TelegramAlertBot&text=$(echo -e "$AlertMessage")&parse_mode=Markdown&disable_web_page_preview=true"
curl -s --max-time 10 --retry 5 --retry-delay 2 --retry-max-time 10 -d "$AlertPayload" $Url_TelegramAlertBot > /dev/null 2>&1 &
fi

exit