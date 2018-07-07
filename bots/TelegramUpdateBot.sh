#!/bin/bash

#############################################################################
# Version 0.1.2-ALPHA (07-07-2018)
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

# Update repository
apt-get -qq update

# List with available updates to variable $UPDATES
UPDATES="$(aptitude -F "%p" search '~U')"
LENGTH="${#UPDATES}"

# Do nothing if there are no updates
if [ -z "$UPDATES" ]; then
    exit
fi

# If update list length is less than 4000 characters, then sent update list
if [ "$LENGTH" -lt "4000" ]; then
read -r -d "" TEXT_UPDATES << EOM
There are updates available on *$(uname -n)*:

${UPDATES}
EOM
fi

# If update list length is greater than 4000 characters, don't sent update list
if [ "$LENGTH" -gt "4000" ]; then
read -r -d "" TEXT_UPDATES << EOM
There are updates available on *$(uname -n)*. Unfortunately, the list with updates is too large for Telegram. Please update your server as soon as possible.
EOM
fi

# Create updates payload to sent to telegram API
PAYLOAD_UPDATES="chat_id=$TARGET&text=$TEXT_UPDATES&parse_mode=Markdown&disable_web_page_preview=true"

# Sent updates payload to Telegram API
curl -s --max-time 10 --retry 5 --retry-delay 2 --retry-max-time 10 -d "$PAYLOAD_UPDATES" $URL > /dev/null 2>&1 &

exit
