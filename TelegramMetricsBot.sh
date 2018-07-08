#!/bin/bash

#############################################################################
# Version 0.3.2-ALPHA (08-07-2018)
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

# Source TelegramBots.conf
. /etc/TelegramBots/TelegramBots.conf

# Output metrics to variable $TEXT_METRICS
read -r -d "" Message_Metrics << EOM
*HOST:* $(uname -n)
*UPTIME:* $(uptime -p)

*LOAD:* $(uptime | grep -oP '(?<=average:).*')
*RAM:* $(awk '/^Mem/ {print $3}' <(free -m -h)) / $(awk '/^Mem/ {print $2}' <(free -m -h))
*HDD:* $(df -h / --output=used -x tmpfs -x devtmpfs | tr -dc '1234567890GMT.') / $(df -h / --output=size -x tmpfs -x devtmpfs | tr -dc '1234567890GMT.') ($(df / --output=pcent -x tmpfs -x devtmpfs | tr -dc '0-9')%)
EOM

# Create metrics payload to sent to Telegram API
Payload_Metrics="chat_id=$Chat_TelegramMetricsBot&text=$Message_Metrics&parse_mode=Markdown&disable_web_page_preview=true"

# Sent metrics payload to Telegram API
curl -s --max-time 10 --retry 5 --retry-delay 2 --retry-max-time 10 -d "$Payload_Metrics" $Url_TelegramMetricsBot > /dev/null 2>&1 &
