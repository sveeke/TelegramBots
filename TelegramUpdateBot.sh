#!/bin/bash

#############################################################################
# Version 0.2.1-ALPHA (08-07-2018)
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

# Update repository
apt-get -qq update

# List with available updates to variable $UPDATES
AvailableUpdates="$(aptitude -F "%p" search '~U')"
LengthUpdates="${#AvailableUpdates}"

# Do nothing if there are no updates
if [ -z "$AvailableUpdates" ]; then
    exit
fi

# If update list length is less than 4000 characters, then sent update list
if [ "$LengthUpdates" -lt "4000" ]; then
read -r -d "" Message_Update << EOM
There are updates available on *$(uname -n)*:

${UPDATES}
EOM
fi

# If update list length is greater than 4000 characters, don't sent update list
if [ "$LengthUpdates" -gt "4000" ]; then
read -r -d "" Message_Update << EOM
There are updates available on *$(uname -n)*. Unfortunately, the list with updates is too large for Telegram. Please update your server as soon as possible.
EOM
fi

# Create updates payload to sent to telegram API
Payload_Updates="chat_id=$Chat_TelegramUpdateBot&text=$Message_Update&parse_mode=Markdown&disable_web_page_preview=true"

# Sent updates payload to Telegram API
curl -s --max-time 10 --retry 5 --retry-delay 2 --retry-max-time 10 -d "$Payload_Updates" $Url_TelegramUpdateBot > /dev/null 2>&1 &

exit
