#!/bin/bash

#############################################################################
# Version 0.1.1-ALPHA (07-07-2018)
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
# TELEGRAM VARIABLES
#############################################################################

# During normal installation, only one pair of token and chat ID will be
# asked and used. If you want to use multiple Telegram Bots for the
# different roles, add the tokens and chat IDs in the below variables. 
# Please note that you have to set them all for it to work.

# TelegramMetricsBot
TOKEN_METRICS_BOT='token'
CHAT_ID_METRICS_BOT='id'

# TelegramUpdateBot
TOKEN_UPDATE_BOT='token'
CHAT_ID_UPDATE_BOT='id'

#############################################################################
# INTRODUCTION
#############################################################################

echo
echo
echo
echo '         _______   _                                ____        _       '
echo '        |__   __| | |     Created by S. Veeke      |  _ \      | |      '
echo '           | | ___| | ___  __ _ _ __ __ _ _ __ ___ | |_) | ___ | |_ ___ '
echo '           | |/ _ \ |/ _ \/ _` | `__/ _` | `_ ` _ \|  _ < / _ \| __/ __|'
echo '           | |  __/ |  __/ (_| | | | (_| | | | | | | |_) | (_) | |_\__ \'
echo '           |_|\___|_|\___|\__, |_|  \__,_|_| |_| |_|____/ \___/ \__|___/'
echo '                           __/ |                                        '
echo '                          |___/                                         '
echo
echo '         This script will install TelegramBots on your server. You need'
echo '         the access token and chat ID during the installation.'
echo
echo '         Press ctrl + c during the installation to abort.'

sleep 3

#############################################################################
# CHECKING REQUIREMENTS
#############################################################################

echo
echo
echo "*** CHECKING REQUIREMENTS ***"

# Checking whether the script runs as root
echo -n "[1/12] Script is running as root..."
    if [ "$EUID" -ne 0 ]; then
        echo -e "\\t\\t\\t\\t[NO]"
        echo
        echo "**********************************"
	    echo "This script should be run as root."
	    echo "**********************************"
        echo
	    exit
    fi
echo -e "\\t\\t\\t\\t[YES]"

# Checking whether Debian is installed
echo -n "[2/12] Running Debian..."
    if [ -f /etc/debian_version ]; then
        echo -e "\\t\\t\\t\\t\\t[YES]"

    else
            echo -e "\\t\\t\\t\\t\\t[NO]"
            echo
            echo "*************************************"
            echo "This script will only work on Debian."
            echo "*************************************"
            echo
            exit 1
    fi

# Checking internet connection
echo -n "[3/12] Connected to the internet..."
wget -q --tries=10 --timeout=20 --spider www.google.com
    if [[ $? -eq 0 ]]; then
        echo -e "\\t\\t\\t\\t[YES]"

    else
        echo -e "\\t\\t\\t\\t[NO]"
        echo
        echo "***********************************"
        echo "Access to the internet is required."
        echo "***********************************"
        echo
        exit
    fi

#############################################################################
# UPDATE OPERATING SYSTEM
#############################################################################

echo
echo

# Update the package list from the Debian repositories
echo "*** UPDATING OPERATING SYSTEM ***"
echo "[4/12] Downloading package list from repositories..."
apt-get -qq update

# Upgrade operating system with new package list
echo "[5/12] Downloading and upgrading packages..."
apt-get -y -qq upgrade

sleep 1

#############################################################################
# INSTALL NEW SOFTWARE
#############################################################################

# The following packages are needed for the bots to work.
# - curl                          Sends the bot content to the API
# - aptitude                      Provides the upgradable package list

echo
echo "*** INSTALLING DEPENDENCIES ***"
echo "[6/12] Installing curl and aptitude..."
apt-get -y -qq install curl aptitude

#############################################################################
# USER INPUT
#############################################################################

echo
echo "*** TELEGRAM VARIABLES ***"

# Check whether the variables at the beginning of the script were used
if [ "$TOKEN_METRICS_BOT" != "token" ] && \
[ "$CHAT_ID_METRICS_BOT" != "id" ] && \
[ "$TOKEN_UPDATE_BOT" != "token" ] && \
[ "$CHAT_ID_UPDATE_BOT" != "id" ]; then

    echo "[7/12] Using provided access tokens..."
    echo "[8/12] Using providet chat IDs"

else

    # Bot access token
    read -r -p "[7/12] Enter bot access token: " TOKEN

    # Chat ID
    read -r -p "[8/12] Enter chat id:          " ID

    # Use provided token and chat ID in corresponding variables
    TOKEN_METRICS_BOT="${TOKEN}"
    CHAT_ID_METRICS_BOT="${ID}"
    TOKEN_UPDATE_BOT="${TOKEN}"
    CHAT_ID_UPDATE_BOT="${ID}"
fi


#############################################################################
# BOTS INSTALLATION
#############################################################################

echo
echo "*** INSTALLING BOTS ***"

# Download and save the bot scripts to /usr/local/bin
echo "[9/12] Downloading and saving the bots..."
wget -q https://raw.githubusercontent.com/sveeke/TelegramBots/master/bots/TelegramMetricsBot.sh -O /usr/local/bin/TelegramMetricsBot.sh
wget -q https://raw.githubusercontent.com/sveeke/TelegramBots/master/bots/TelegramUpdateBot.sh -O /usr/local/bin/TelegramUpdateBot.sh

# Give execute privileges to the bot scripts
echo "[10/12] Setting permissions for bots..."
chmod 700 /usr/local/bin/TelegramMetricsBot.sh
chmod 700 /usr/local/bin/TelegramUpdateBot.sh

# Add access tokens and chat IDs
echo "[11/12] Adding access token and chat ID to bots..."
sed -i s/'ACCESS_TOKEN_HERE'/"$TOKEN_METRICS_BOT"/g /usr/local/bin/TelegramMetricsBot.sh
sed -i s/'CHAT_ID_HERE'/"$CHAT_ID_METRICS_BOT"/g /usr/local/bin/TelegramMetricsBot.sh
sed -i s/'ACCESS_TOKEN_HERE'/"$TOKEN_UPDATE_BOT"/g /usr/local/bin/TelegramUpdateBot.sh
sed -i s/'CHAT_ID_HERE'/"$CHAT_ID_UPDATE_BOT"/g /usr/local/bin/TelegramUpdateBot.sh

# Create cronjobs in /etc/cron.d
echo "[12/12] Making sure the script runs daily..."
cat << EOF > /etc/cron.d/TelegramMetricsBot
# This cronjob activates the TelegramMetricBot daily at 8:00.
0 8 * * * root /usr/local/bin/TelegramMetricsBot.sh
EOF

cat << EOF > /etc/cron.d/TelegramUpdateBot
# This cronjob activates the TelegramUpdateBot three times during the day.
0 8,15,22 * * * root /usr/local/bin/TelegramUpdateBot.sh
EOF

# Final notice
echo
echo
echo "The installation has been completed!"
echo "You will now receive daily updates with some server metrics."
echo "If you want to edit some settings, please look at these locations:"
echo
echo "    /etc/cron.d/TelegramMetricsBot"
echo "    /etc/cron.d/TelegramUpdateBot"
echo "    /etc/cron.d/TelegramLoginBot"
echo "    /usr/local/bin/TelegramMetricsBot.sh"
echo "    /usr/local/bin/TelegramUpdateBot.sh"
echo "    /usr/local/bin/TelegramLoginBot.sh"
echo
echo "To test, just enter the name of the bot in the CLI and press enter."
echo
echo "Good luck!"
echo
echo
exit
