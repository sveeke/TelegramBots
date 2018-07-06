#!/bin/bash

#############################################################################
# Version 0.1.1-ALPHA (06-07-2018)
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

# Variables
TOKEN='ACCESS_TOKEN_HERE'
URL="https://api.telegram.org/bot$TOKEN/sendMessage"
TARGET='CHAT_ID_HERE'

#############################################################################
# METRICS
#############################################################################

# Output metrics to variable $TEXT_METRICS
read -r -d "" TEXT_METRICS << EOM
*HOST:* $(uname -n)
*UPTIME:* $(uptime -p)

*LOAD:* $(uptime | grep -oP '(?<=average:).*')
*RAM:* $(awk '/^Mem/ {print $3}' <(free -m -h)) / $(awk '/^Mem/ {print $2}' <(free -m -h))
*HDD:* $(df -h --output=used -x tmpfs -x devtmpfs | tr -dc '1234567890GMT.') / $(df -h --output=size -x tmpfs -x devtmpfs | tr -dc '1234567890GMT.') ($(df --output=pcent -x tmpfs -x devtmpfs | tr -dc '0-9')%)
EOM

# Create metrics payload to sent to Telegram API
PAYLOAD_METRICS="chat_id=$TARGET&text=$TEXT_METRICS&parse_mode=Markdown&disable_web_page_preview=true"

# Sent metrics payload to Telegram API
curl -s --max-time 10 --retry 5 --retry-delay 2 --retry-max-time 10 -d "$PAYLOAD_METRICS" $URL > /dev/null 2>&1 &

#############################################################################
# UPDATES
#############################################################################

# List with available updates to variable $UPDATES
UPDATES="$(aptitude -F "%p" search '~U')"
LENGTH="${#UPDATES}"

if [ -z "$UPDATES" ]; then
    exit
fi

if [ "$LENGTH" -lt "2000" ]; then
read -r -d "" TEXT_UPDATES << EOM
*UPDATES:*
${UPDATES}
EOM
fi

if [ "$LENGTH" -gt "2000" ]; then
read -r -d "" TEXT_UPDATES << EOM
*UPDATES:*
The list with updates is too large for Telegram. Please update your server as soon as possible.
EOM
fi

# Create updates payload to sent to telegram API
PAYLOAD_UPDATES="chat_id=$TARGET&text=$TEXT_UPDATES&parse_mode=Markdown&disable_web_page_preview=true"

# Sent updates payload to Telegram API
curl -s --max-time 10 --retry 5 --retry-delay 2 --retry-max-time 10 -d "$PAYLOAD_UPDATES" $URL > /dev/null 2>&1 &

exit
