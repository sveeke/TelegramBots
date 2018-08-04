#!/bin/bash

#############################################################################
# Version 0.1.0-BETA (04-08-2018)
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

#############################################################################
# VARIABLES
#############################################################################

# Bot version
TelegramAlertBotVersion='0.1.0'

# Source variables in TelegramBots.conf
. /etc/TelegramBots/TelegramBots.conf

# Strip '%' of TelegramAlertBot thresholds in TelegramBot.conf
LoadThreshold="$(echo "$Threshold_Load_TelegramAlertBot" | tr -d '%')"
DiskThreshold="$(echo "$Threshold_Disk_TelegramAlertBot" | tr -d '%')"
MemoryThreshold="$(echo "$Threshold_Memory_TelegramAlertBot" | tr -d '%')"

# Gather server core count and calculate current server load
CoreAmount="$(grep 'cpu cores' /proc/cpuinfo | wc -l)"
MaxLoadServer="$CoreAmount.00"
CurrentLoad="$(cat /proc/loadavg | awk '{print $3}')"
CurrentLoadPercentage="$(echo "("$CurrentLoad"/"$MaxLoadServer")*100" | bc -l)"
CurrentLoadPercentageRounded="$(printf "%.0f\n" $(echo "$CurrentLoadPercentage" | tr -d '%'))"

# Gather current server memory usage
CurrentMemoryUsage="$(free -m | awk '/^Mem/ {print $3}' | tr -d 'GKMT')"
MaxMemoryServer="$(free -m | awk '/^Mem/ {print $2}' | tr -d 'GKMT')"
CurrentMemoryPercentage="$(echo "("$CurrentMemoryUsage"/"$MaxMemoryServer")*100" | bc -l)"
CurrentMemoryPercentageRounded="$(printf "%.0f\n" $(echo "$CurrentMemoryPercentage" | tr -d '%'))"

# Gather current disk usage of /
CurrentDiskUsage="$(df -h / | grep / | awk {'print $5'} | tr -d '%')"

#############################################################################
# ARGUMENTS
#############################################################################

# Enable help, version and a cli option
case $1 in
    --help|-help|help|--h|-h)
        echo
        echo "USAGE: TelegramAlertBot [OPTION]..."
        echo "Sent alerts about server metrics that exceed the threshold."
        echo
        echo "OPTIONS:"
        echo "--cli       output alerts to cli and exit"
        echo "--help      display this help and exit"
        echo "--version   display version information and exit"
        echo
        exit 0;;

    --version|-version|version|--v|-v)
        echo
        echo "TelegramAlertBot $TelegramAlertBotVersion"
        echo "Copyright (C) 2018 S. Veeke."
        echo
        echo "License CC Attribution-NonCommercial-ShareAlike 4.0 Int."
        echo
        exit 0;;

    --cli|-cli|cli|--dry-run|-dry-run|--dry|-dry-run|dry)
        echo
        if [[ "$CurrentLoadPercentageRounded" -ge "$LoadThreshold" ]]; then
            echo -e "[!] SERVER LOAD:\\tA current server load of $CurrentLoadPercentageRounded% exceeds the threshold of $Threshold_Load_TelegramAlertBot."
        else
            echo -e "[i] SERVER LOAD:\\tA current server load of $CurrentLoadPercentageRounded% does not exceed the threshold of $Threshold_Load_TelegramAlertBot."
        fi

        if [[ "$CurrentMemoryPercentageRounded" -ge "$MemoryThreshold" ]]; then
            echo -e "[!] SERVER MEMORY:\\tA current memory usage of $CurrentMemoryPercentageRounded% exceeds the threshold of $Threshold_Memory_TelegramAlertBot."
        else
            echo -e "[i] SERVER MEMORY:\\tA current memory usage of $CurrentMemoryPercentageRounded% does not exceed the threshold of $Threshold_Memory_TelegramAlertBot."
        fi

        if [[ "$CurrentDiskUsage" -ge "$DiskThreshold" ]]; then
            echo -e "[!] DISK USAGE:\\t\\tA current disk usage of $CurrentDiskUsage% exceeds the threshold of $Threshold_Disk_TelegramAlertBot."
        else
            echo -e "[i] DISK USAGE:\\t\\tA current disk usage of $CurrentDiskUsage% does not exceed the threshold of $Threshold_Disk_TelegramAlertBot."
        fi
        echo
        exit 0;;
esac

#############################################################################
# SENT ALERT IF THRESHOLD IS EXCEEDED
#############################################################################

# Check whether the current server load exceeds the threshold and alert if true
if [[ "$CurrentLoadPercentageRounded" -ge "$LoadThreshold" ]]; then
    AlertMessageLoad="\xE2\x9A\xA0 *ALERT: SERVER LOAD*\\n\\nThe server load ($CurrentLoadPercentageRounded%) on *$(uname -n)* exceeds the threshold of $Threshold_Load_TelegramAlertBot\\n\\n*Load average:*\\n$(cat /proc/loadavg | awk '{print $1" "$2" "$3}')"
    AlertPayloadLoad="chat_id=$Chat_TelegramAlertBot&text=$(echo -e "$AlertMessageLoad")&parse_mode=Markdown&disable_web_page_preview=true"
    curl -s --max-time 10 --retry 5 --retry-delay 2 --retry-max-time 10 -d "$AlertPayloadLoad" $Url_TelegramAlertBot > /dev/null 2>&1 &
fi

# Check whether the current server memory usage exceeds the threshold and alert if true
if [[ "$CurrentMemoryPercentageRounded" -ge "$MemoryThreshold" ]]; then
    AlertMessageMemory="\xE2\x9A\xA0 *ALERT: SERVER MEMORY*\\n\\nMemory usage ($CurrentMemoryPercentageRounded%) on *$(uname -n)* exceeds the threshold of $Threshold_Memory_TelegramAlertBot\\n\\n*Memory usage:*\\n$(free -m -h)"
    AlertPayloadMemory="chat_id=$Chat_TelegramAlertBot&text=$(echo -e "$AlertMessageMemory")&parse_mode=Markdown&disable_web_page_preview=true"
    curl -s --max-time 10 --retry 5 --retry-delay 2 --retry-max-time 10 -d "$AlertPayloadMemory" $Url_TelegramAlertBot > /dev/null 2>&1 &
fi

# Check whether the current disk usaged exceeds the threshold and alert if true
if [[ "$CurrentDiskUsage" -ge "$DiskThreshold" ]]; then
    AlertMessageDisk="\xE2\x9A\xA0 *ALERT: FILE SYSTEM*\\n\\nDisk usage ($CurrentDiskUsage%) on *$(uname -n)* exceeds the threshold of $Threshold_Disk_TelegramAlertBot\\n\\n*Filesystem info:*\\n$(df -h)"
    AlertPayloadDisk="chat_id=$Chat_TelegramAlertBot&text=$(echo -e "$AlertMessageDisk")&parse_mode=Markdown&disable_web_page_preview=true"
    curl -s --max-time 10 --retry 5 --retry-delay 2 --retry-max-time 10 -d "$AlertPayloadDisk" $Url_TelegramAlertBot > /dev/null 2>&1 &
fi

exit 0;;