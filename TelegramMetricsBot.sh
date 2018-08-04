#!/bin/bash

#############################################################################
# Version 0.4.1-ALPHA (04-08-2018)
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
TelegramMetricsBotVersion='0.4.1'

# Source variables in TelegramBots.conf
. /etc/TelegramBots/TelegramBots.conf

# Primary function
GatherMetrics() {
read -r -d "" MetricsMessage << EOM
*HOST:* $(uname -n)
*UPTIME:* $(uptime -p)

*LOAD:* $(cat /proc/loadavg | awk '{print $1" "$2" "$3}')
*RAM:* $(awk '/^Mem/ {print $3}' <(free -m -h)) / $(awk '/^Mem/ {print $2}' <(free -m -h))
*HDD:* $(df -h / --output=used -x tmpfs -x devtmpfs | tr -dc '1234567890GKMT.') / $(df -h / --output=size -x tmpfs -x devtmpfs | tr -dc '1234567890GKMT.') ($(df / --output=pcent -x tmpfs -x devtmpfs | tr -dc '0-9')%)
EOM
}

# Enable the use of arguments
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

    --version)
        echo
        echo "TelegramMetricsBot $TelegramMetricsBotVersion"
        echo "Copyright (C) 2018 S. Veeke."
        echo
        echo "License CC Attribution-NonCommercial-ShareAlike 4.0 Int."
        echo
        exit 0;;

    --cli|--command-line|--local)
        GatherMetrics
        echo
        echo "TelegramMetricsBot:"
        echo
        echo "${MetricsMessage//'*'}"
        echo
        exit 0;;
esac

# Run function
GatherMetrics

# Create metrics payload to sent to Telegram API
MetricsPayload="chat_id=$Chat_TelegramMetricsBot&text=$MetricsMessage&parse_mode=Markdown&disable_web_page_preview=true"

# Sent metrics payload to Telegram API
curl -s --max-time 10 --retry 5 --retry-delay 2 --retry-max-time 10 -d "$MetricsPayload" $Url_TelegramMetricsBot > /dev/null 2>&1 &
