#!/bin/bash

#############################################################################
# Version 0.4.0-ALPHA (08-07-2018)
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
# Please note that you have to set them *all* eight for them to work.

# TelegramMetricsBot
Token_TelegramMetricsBot='token'
Chat_TelegramMetricsBot='id'

# TelegramUpdateBot
Token_TelegramUpdateBot='token'
Chat_TelegramUpdateBot='id'

# TelegramLoginBot
Token_TelegramLoginBot='token'
Chat_TelegramLoginBot='id'

# TelegramOutageBot
Token_TelegramOutageBot='token'
Chat_TelegramOutageBot='id'

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
echo -n "[1/15] Script is running as root..."
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
echo -n "[2/15] Running Debian..."
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
echo -n "[3/15] Connected to the internet..."
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
echo "[4/15] Downloading package list from repositories..."
apt-get -qq update

# Upgrade operating system with new package list
echo "[5/15] Downloading and upgrading packages..."
apt-get -y -qq upgrade

sleep 1

#############################################################################
# INSTALL NEW SOFTWARE
#############################################################################

# The following packages are needed for the bots to work.
# - curl              Sends the bot content to the API
# - aptitude          Provides the upgradable package list

echo
echo "*** INSTALLING DEPENDENCIES ***"
echo "[6/15] Installing curl and aptitude..."
apt-get -y -qq install curl aptitude

#############################################################################
# BOTS INSTALLATION
#############################################################################

echo
echo "*** INSTALLING BOTS ***"

# Download and save the bot scripts to /usr/local/bin
echo "[7/15] Downloading and saving the bots..."
wget -q https://raw.githubusercontent.com/sveeke/TelegramBots/master/TelegramMetricsBot.sh -O /usr/local/bin/TelegramMetricsBot.sh
wget -q https://raw.githubusercontent.com/sveeke/TelegramBots/master/TelegramUpdateBot.sh -O /usr/local/bin/TelegramUpdateBot.sh

# Give execute privileges to the bot scripts
echo "[8/15] Setting permissions for bots..."
chmod 700 /usr/local/bin/TelegramMetricsBot.sh
chmod 700 /usr/local/bin/TelegramUpdateBot.sh
#chmod 700 /usr/local/bin/TelegramLoginBot.sh
#chmod 700 /usr/local/bin/TelegramOutageBot.sh

#############################################################################
# CONFIGURATION
#############################################################################

echo
echo "*** CONFIGURATION ***"

# Check whether TelegramBots.conf exists and act accordingly
if [ ! -f /etc/TelegramBots/TelegramBots.conf ]; then
    echo "[9/15] No existing configuration found, creating new one..."

    # Check whether the variables at the beginning of the script were used
    if [ "$Token_TelegramMetricsBot" != "token" ] && \
    [ "$Chat_TelegramMetricsBot" != "id" ] && \
    [ "$Token_TelegramUpdateBot" != "token" ] && \
    [ "$Chat_TelegramUpdateBot" != "id" ] && \
    [ "$Token_TelegramLoginBot" != "token" ] && \
    [ "$Chat_TelegramLoginBot" != "id" ] && \
    [ "$Token_TelegramOutageBot" != "token" ] && \
    [ "$Chat_TelegramOutageBot" != "id" ]; then

        echo "[10/15] Using provided access tokens..."
        echo "[11/15] Using provided chat IDs"

    else
        # Bot authentication token
        read -r -p "[10/15] Enter bot token: " ProvidedToken

        # Telegram chat ID
        read -r -p "[11/15] Enter chat ID:   " ProvidedChatID

        # Use provided token and chat ID in corresponding variables
        Token_TelegramMetricsBot="${ProvidedToken}"
        Chat_TelegramMetricsBot="${ProvidedChatID}"
        Token_TelegramUpdateBot="${ProvidedToken}"
        Chat_TelegramUpdateBot="${ProvidedChatID}"
        Token_TelegramLoginBot="${ProvidedToken}"
        Chat_TelegramLoginBot="${ProvidedChatID}"
        Token_TelegramOutageBot="${ProvidedToken}"
        Chat_TelegramOutageBot="${ProvidedChatID}"
    fi
    # Add TelegramBots configuration file to /etc/TelegramBots
    echo "[12/15] Adding configuration file to system..."
    mkdir /etc/TelegramBots
    chmod 755 /etc/TelegramBots
    wget -q https://raw.githubusercontent.com/sveeke/TelegramBots/master/TelegramBots.conf -O /etc/TelegramBots/TelegramBots.conf
    chmod 750 /etc/TelegramBots/TelegramBots.conf
    
    # Add access tokens and chat IDs
    echo "[13/15] Adding access token and chat ID to bots..."
    sed -i s/'metrics_token_here'/"$Token_TelegramMetricsBot"/g /etc/TelegramBots/TelegramBots.conf
    sed -i s/'metrics_id_here'/"$Chat_TelegramMetricsBot"/g /etc/TelegramBots/TelegramBots.conf
    sed -i s/'update_token_here'/"$Token_TelegramUpdateBot"/g /etc/TelegramBots/TelegramBots.conf
    sed -i s/'update_id_here'/"$Chat_TelegramUpdateBot"/g /etc/TelegramBots/TelegramBots.conf
    sed -i s/'login_token_here'/"$Token_TelegramLoginBot"/g /etc/TelegramBots/TelegramBots.conf
    sed -i s/'login_id_here'/"$Chat_TelegramLoginBot"/g /etc/TelegramBots/TelegramBots.conf
    sed -i s/'outage_token_here'/"$Token_TelegramOutageBot"/g /etc/TelegramBots/TelegramBots.conf
    sed -i s/'outage_id_here'/"$Chat_TelegramOutageBot"/g /etc/TelegramBots/TelegramBots.conf

else
    # Notify user that all configuration steps will be skipped
    echo "[9/15] Existing configuration found, skipping creation..."
    echo "[10/15] Skipping gathering tokens..."
    echo "[11/15] Skipping gathering chat IDs..."
    echo "[12/15] Skipping adding configuration file..."
    echo "[13/15] Skipping adding tokens and IDs to configuration..."
fi

#############################################################################
# CRONJOBS
#############################################################################

# Add UpdateCron.sh to /etc/TelegramBots/
echo "[14/15] Adding UpdateCron.sh to system..."
wget -q https://raw.githubusercontent.com/sveeke/TelegramBots/master/UpdateCron.sh -O /etc/TelegramBots/UpdateCron.sh
chmod 750 /etc/TelegramBots/UpdateCron.sh

# Create cronjobs in /etc/cron.d
echo "[15/15] Adding cronjobs for bots..."

# Cronjob for TelegramMetricsBot
cat << EOF > /etc/cron.d/TelegramMetricsBot
# This cronjob activates the TelegramMetricsBot daily at 8:00.
0 8 * * * root /usr/local/bin/TelegramMetricsBot.sh
EOF

# Cronjob for TelegramUpdateBot
cat << EOF > /etc/cron.d/TelegramUpdateBot
# This cronjob activates the TelegramUpdateBot three times during the day.
0 8,15,22 * * * root /usr/local/bin/TelegramUpdateBot.sh
EOF

# Cronjob for TelegramLoginBot
# Will be added later!

# Cronjob for TelegramOutagebot
# Will be added later!

# Restart cron service
systemctl restart cron

#############################################################################
# NOTICE
#############################################################################

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
