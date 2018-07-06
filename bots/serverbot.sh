#!/bin/bash

#############################################################################
# Version 0.1.0-ALPHA (06-07-2018)
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

# List with available updates to variable $UPDATES
UPDATES="$(aptitude -F "%p" search '~U')"

# Output with metrics to variable $TEXT
read -r -d "" TEXT << EOM
*HOST:* $(uname -n)
*UPTIME:* $(uptime -p)

*LOAD:* $(uptime  | grep -oP '(?<=average:).*')
*RAM:* $(awk '/^Mem/ {print $3}' <(free -m -h)) / $(awk '/^Mem/ {print $2}' <(free -m -h))
*HDD:* $(df -h --output=used -x tmpfs -x devtmpfs | tr -dc '1234567890GMT.') / $(df -h --output=size -x tmpfs -x devtmpfs | tr -dc '1234567890GMT.') ($(df --output=pcent -x tmpfs -x devtmpfs | tr -dc '0-9')%)

*UPDATES:* ${UPDATES}
EOM

# Payload to sent to Telegram API
PAYLOAD="chat_id=$TARGET&text=$TEXT&parse_mode=Markdown&disable_web_page_preview=true"

# Sent payload to Telegram API
curl -s --max-time 10 --retry 5 --retry-delay 2 --retry-max-time 10 -d "$PAYLOAD" $URL > /dev/null 2>&1 &
