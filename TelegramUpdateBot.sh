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

# General information
TelegramUpdateBotVersion='0.3.0'

# Source variables in TelegramBots.conf
. /etc/TelegramBots/TelegramBots.conf

# Primary function
GatherUpdates () {

# Update repository
apt-get -qq update

# List with available updates to variable $UPDATES
AvailableUpdates="$(aptitude -F "%p" search '~U')"
LengthUpdates="${#AvailableUpdates}"
}

# Enable the use of arguments
case $1 in
    --help|-help|help|--h|-h|help)
        echo
        echo "USAGE: TelegramUpdateBot [OPTION]..."
        echo "Sent package updates to a Telegram bot."
        echo
        echo "OPTIONS:"
        echo "--cli       output metrics to cli and exit"
        echo "--help      display this help and exit"
        echo "--version   display version information and exit"
        echo
        exit 0;;

    --version)
        echo
        echo "TelegramUpdateBot $TelegramUpdateBotVersion"
        echo "Copyright (C) 2018 S. Veeke."
        echo
        echo "License CC Attribution-NonCommercial-ShareAlike 4.0 Int."
        echo
        exit 0;;

    --cli|--command-line|--local)
        GatherUpdates

        # Notify user when there are no updates
        if [ -z "$AvailableUpdates" ]; then
            echo
            echo "TelegramUpdateBot:"
            echo "There are no updates available on $(uname -n)."
            echo
            exit 0
        fi

        # Notify user when there are updates available
        echo
        echo "The following updates are available on $(uname -n):"
        echo
        echo "${AvailableUpdates}"
        echo
        echo "Use 'apt update && apt -y upgrade' to upgrade these packages."
        echo
        exit 0;;
esac

# Run function
GatherUpdates

# Do nothing if there are no updates
if [ -z "$AvailableUpdates" ]; then
    exit 0
fi

# If update list length is less than 4000 characters, then sent update list
if [ "$LengthUpdates" -lt "4000" ]; then
    UpdateMessage="There are updates available on *$(uname -n)*:\n\n${AvailableUpdates}"
fi

# If update list length is greater than 4000 characters, don't sent update list
if [ "$LengthUpdates" -gt "4000" ]; then
    UpdateMessage="There are updates available on *$(uname -n)*. Unfortunately, the list with updates is too large for Telegram. Please update your server as soon as possible."
fi

# Create updates payload to sent to telegram API
UpdatePayload="chat_id=$Chat_TelegramUpdateBot&text=$(echo -e "$UpdateMessage")&parse_mode=Markdown&disable_web_page_preview=true"

# Sent updates payload to Telegram API
curl -s --max-time 10 --retry 5 --retry-delay 2 --retry-max-time 10 -d "$UpdatePayload" $Url_TelegramUpdateBot > /dev/null 2>&1 &

exit
