#!/bin/bash

#############################################################################
# Version 0.1.4-BETA (05-08-2018)
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
TelegramMetricsBotVersion='0.1.4'

# Source variables in TelegramBots.conf
. /etc/TelegramBots/TelegramBots.conf

# Gather OS version
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OperatingSystem="$NAME"
    OperatingSystemVersion="$VERSION_ID"
fi

# Use older format in free when Debian 8 is used
if [ "$OperatingSystem" == "Debian GNU/Linux" ] && [ "$OperatingSystemVersion" -eq "8" ]; then
    TotalMemory="$(free -m | awk '/^Mem/ {print $2}')"
    FreeMemory="$(free -m | awk '/^Mem/ {print $4}')"
    BuffersMemory="$(free -m | awk '/^Mem/ {print $6}')"
    CachedMemory="$(free -m | awk '/^Mem/ {print $7}')"
    UsedMemory="$(echo "("$TotalMemory"-"$FreeMemory"-"$BuffersMemory"-"$CachedMemory")" | bc -l)"
fi

# Use newer format in free when Debian 9 is used
if [ "$OperatingSystem" == "Debian GNU/Linux" ] && [ "$OperatingSystemVersion" -eq "9" ]; then
    TotalMemory="$(free -m | awk '/^Mem/ {print $2}')"
    FreeMemory="$(free -m | awk '/^Mem/ {print $4}')"
    BuffersCachedMemory="$(free -m | awk '/^Mem/ {print $6}')"
    UsedMemory="$(echo "("$TotalMemory"-"$FreeMemory"-"$BuffersCachedMemory")" | bc -l)"
fi

# Use newer format in free when CentOS 7 is used
if [ "$OperatingSystem" == "CentOS Linux" ] && [ "$OperatingSystemVersion" -eq "7" ]; then
    TotalMemory="$(free -m | awk '/^Mem/ {print $2}')"
    FreeMemory="$(free -m | awk '/^Mem/ {print $4}')"
    BuffersCachedMemory="$(free -m | awk '/^Mem/ {print $6}')"
    UsedMemory="$(echo "("$TotalMemory"-"$FreeMemory"-"$BuffersCachedMemory")" | bc -l)"
fi

#############################################################################
# FUNCTIONS
#############################################################################

# Gather all metrics in variable MetricsMessage
GatherMetrics() {
read -r -d "" MetricsMessage << EOM
*HOST:* $(uname -n)
*UPTIME:* $(uptime -p)

*LOAD:* $(cat /proc/loadavg | awk '{print $1" "$2" "$3}')
*RAM:* $UsedMemory M / $TotalMemory M
*HDD:* $(df -h / --output=used -x tmpfs -x devtmpfs | tr -dc '1234567890GKMT.') / $(df -h / --output=size -x tmpfs -x devtmpfs | tr -dc '1234567890GKMT.') ($(df / --output=pcent -x tmpfs -x devtmpfs | tr -dc '0-9')%)
EOM
}

#############################################################################
# ARGUMENTS
#############################################################################

# Enable help, version and a cli option
case $1 in
    --help|-help|help|--h|-h|help)
        echo
        echo "USAGE: TelegramMetricsBot [OPTION]..."
        echo "Sent server metrics to a Telegram bot."
        echo
        echo "OPTIONS:"
        echo "--cli       output metrics to cli and exit"
        echo "--help      display this help and exit"
        echo "--version   display version information and exit"
        echo
        exit 0;;

    --version|-version|version|--v|-v)
        echo
        echo "TelegramMetricsBot $TelegramMetricsBotVersion"
        echo "Copyright (C) 2018 S. Veeke."
        echo
        echo "License CC Attribution-NonCommercial-ShareAlike 4.0 Int."
        echo
        exit 0;;

    --cli|-cli|cli|--dry-run|-dry-run|--dry|-dry-run|dry)
        GatherMetrics
        echo
        echo "${MetricsMessage//'*'}"
        echo
        exit 0;;
esac

#############################################################################
# SENT METRICS
#############################################################################

# Run function
GatherMetrics

# Create metrics payload to sent to Telegram API
MetricsPayload="chat_id=$Chat_TelegramMetricsBot&text=$MetricsMessage&parse_mode=Markdown&disable_web_page_preview=true"

# Sent metrics payload to Telegram API
curl -s --max-time 10 --retry 5 --retry-delay 2 --retry-max-time 10 -d "$MetricsPayload" $Url_TelegramMetricsBot > /dev/null 2>&1 &

exit 0
