#!/bin/bash

#############################################################################
# Version 0.1.0-ALPHA (04-08-2018)
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
TelegramOutageBotVersion='0.1.0'

# Script variables
TelegramOutageBotWebsites='/etc/TelegramBots/TelegramOutageBotWebsites.list'

# Colours
red='\e[31m'    # Red
green='\e[32m'  # Green
nc='\e[0m'      # No colour

# Source variables in TelegramBots.conf
. /etc/TelegramBots/TelegramBots.conf

#############################################################################
# FUNCTIONS
#############################################################################

# Function to check TelegramOutageBotWebsites.list and output to cli
function CheckWebsitesCli {
    WebsiteStatus="$(curl -sL -w "%{http_code}\n" "$1" -o /dev/null)"
    if [ "$WebsiteStatus" -eq 200 ]; then
        echo -e "$1 ${green}[OK]${nc}"
    else
        echo -e "$1 ${red}[DOWN]${nc}"
    fi
}

# Function to check TelegramOutageBotWebsites.list and output to Telegram
function CheckWebsites {
    WebsiteStatus="$(curl -sL -w "%{http_code}\n" "$1" -o /dev/null)"
    if [ "$WebsiteStatus" -ne 200 ]; then
        OutageMessage="\xF0\x9F\x94\xA5 *ALERT: $1 is down*"
        OutagePayload="chat_id=$Chat_TelegramOutageBot&text=$(echo -e "$OutageMessage")&parse_mode=Markdown&disable_web_page_preview=true"
        curl -s --max-time 10 --retry 5 --retry-delay 2 --retry-max-time 10 -d "$OutagePayload" $Url_TelegramOutageBot > /dev/null 2>&1 &
    fi
}

#############################################################################
# ARGUMENTS
#############################################################################

# Enable help, version and a cli option
case $1 in
    --help|-help|help|--h|-h)
        echo
        echo "USAGE: TelegramOutageBot [OPTION]..."
        echo "Sent alerts when servers or websites are unavailable."
        echo
        echo "OPTIONS:"
        echo "--cli       output alerts to cli and exit"
        echo "--help      display this help and exit"
        echo "--version   display version information and exit"
        echo
        exit 0;;

    --version|-version|version|--v|-v)
        echo
        echo "TelegramOutageBot $TelegramOutageBotVersion"
        echo "Copyright (C) 2018 S. Veeke."
        echo
        echo "License CC Attribution-NonCommercial-ShareAlike 4.0 Int."
        echo
        exit 0;;

    --cli|-cli|cli|--dry-run|-dry-run|--dry|-dry-run|dry)
        echo
        echo "CHECKING WEBSITES"
        while read i; do
            CheckWebsitesCli $i
        done < "$TelegramOutageBotWebsites"
        # also option for custom domain to check?
        echo
        exit 0;;
esac


while read i; do
    CheckWebsites $i
done < "$TelegramOutageBotWebsites"

exit 0