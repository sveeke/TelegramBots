#!/bin/bash

#############################################################################
# Version 0.6.4-ALPHA (04-08-2018)
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
# Please note that you have to set them *all* (even the ones you don't use)
# for them to work.

# TelegramBots
TelegramBotsAutoUpdate='no' # Default 'no'

# TelegramMetricsBot
Install_TelegramMetricsBot='yes' # Default 'yes'
Token_TelegramMetricsBot='token'
Chat_TelegramMetricsBot='id'

# TelegramUpdateBot
Install_TelegramUpdateBot='yes' # Default 'yes'
Token_TelegramUpdateBot='token'
Chat_TelegramUpdateBot='id'

# TelegramLoginBot
Install_TelegramLoginBot='no' # Default 'yes'
Token_TelegramLoginBot='token'
Chat_TelegramLoginBot='id'

# TelegramAlertBot
Install_TelegramAlertBot='yes' # Default 'yes'
Token_TelegramAlertBot='token'
Chat_TelegramAlertBot='id'

# TelegramOutageBot
Install_TelegramOutageBot='no' # Default 'no'
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
echo -n "[1/3] Script is running as root..."
if [ "$EUID" -ne 0 ]; then
    echo -e "\\t\\t\\t\\t[NO]"
    echo
    echo "**********************************"
	echo "This script should be run as root."
	echo "**********************************"
    echo
	exit 1
fi
echo -e "\\t\\t\\t\\t[YES]"

# Checking whether Debian is installed
echo -n "[2/3] Running Debian..."
if [ -f /etc/debian_version ]; then
    echo -e "\\t\\t\\t\\t\\t\\t[YES]"

else
    echo -e "\\t\\t\\t\\t\\t\\t[NO]"
    echo
    echo "*************************************"
    echo "This script will only work on Debian."
    echo "*************************************"
    echo
    exit 1
fi

# Checking internet connection
echo -n "[3/3] Connected to the internet..."
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
    exit 1
fi

#############################################################################
# UPDATE OPERATING SYSTEM
#############################################################################

# Update the package list from the Debian repositories
echo
echo "*** UPDATING OPERATING SYSTEM ***"
echo "[+] Downloading package list from repositories..."
apt-get -qq update

# Upgrade operating system with new package list
echo "[+] Downloading and upgrading packages..."
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
echo "[+] Installing curl and aptitude..."
apt-get -y -qq install curl

if [ "$Install_TelegramUpdateBot" = 'yes' ]; then
    apt-get -y -qq install aptitude
fi

if [ "$Install_TelegramAlertBot" = 'yes' ]; then
    apt-get -y -qq install bc
fi

#############################################################################
# CONFIGURATION
#############################################################################

echo
echo "*** CONFIGURATION ***"

# Check whether TelegramBots.conf exists and act accordingly
if [ ! -f /etc/TelegramBots/TelegramBots.conf ]; then
    echo "[+] No existing configuration found, creating new one..."

#    # Create array with all install variables (work in progress)
#    declare -a ArrayInstallBots=(
#        '$TelegramMetricsBot'
#        '$TelegramUpdateBot'
#        '$TelegramLoginBot'
#        '$TelegramAlertBot'
#        '$TelegramOutageBot'
#        )

#    # Check if all tokens and id's are filled in for all bots that get installed
#    for i in "${ArrayInstallBots[@]}" do
#        if [ "$i" -eq "yes" ]; then
#            if [ "$Token_$i"]
#            echo "$i"
#    done

    # Check whether the variables at the beginning of the script were used
    if [ "$Token_TelegramMetricsBot" != "token" ] && \
    [ "$Chat_TelegramMetricsBot" != "id" ] && \
    [ "$Token_TelegramUpdateBot" != "token" ] && \
    [ "$Chat_TelegramUpdateBot" != "id" ] && \
    [ "$Token_TelegramLoginBot" != "token" ] && \
    [ "$Chat_TelegramLoginBot" != "id" ] && \
    [ "$Token_TelegramAlertBot" != "token" ] && \
    [ "$Chat_TelegramAlertBot" != "id" ] && \
    [ "$Token_TelegramOutageBot" != "token" ] && \
    [ "$Chat_TelegramOutageBot" != "id" ]; then

        echo "[+] Using provided access tokens..."
        echo "[+] Using provided chat IDs"

    else
        # Bot authentication token
        read -r -p "[?] Enter bot token: " ProvidedToken

        # Telegram chat ID
        read -r -p "[?] Enter chat ID:   " ProvidedChatID

        # Use provided token and chat ID in corresponding variables
        Token_TelegramMetricsBot="${ProvidedToken}"
        Chat_TelegramMetricsBot="${ProvidedChatID}"
        Token_TelegramUpdateBot="${ProvidedToken}"
        Chat_TelegramUpdateBot="${ProvidedChatID}"
        Token_TelegramLoginBot="${ProvidedToken}"
        Chat_TelegramLoginBot="${ProvidedChatID}"
        Token_TelegramAlertBot="${ProvidedToken}"
        Chat_TelegramAlertBot="${ProvidedChatID}"
        Token_TelegramOutageBot="${ProvidedToken}"
        Chat_TelegramOutageBot="${ProvidedChatID}"
    fi

    # Add TelegramBots configuration file to /etc/TelegramBots/
    echo "[+] Adding configuration file to system..."
    mkdir -m 755 /etc/TelegramBots
    wget -q https://raw.githubusercontent.com/sveeke/TelegramBots/master/TelegramBots.conf -O /etc/TelegramBots/TelegramBots.conf
    chmod 750 /etc/TelegramBots/TelegramBots.conf
    
    # Add access tokens and chat IDs
    echo "[+] Adding access token and chat ID to bots..."
    sed -i s/'auto_update_here'/"$TelegramBotsAutoUpdate"/g /etc/TelegramBots/TelegramBots.conf
    sed -i s/'metrics_install_here'/"$Install_TelegramMetricsBot"/g /etc/TelegramBots/TelegramBots.conf
    sed -i s/'metrics_token_here'/"$Token_TelegramMetricsBot"/g /etc/TelegramBots/TelegramBots.conf
    sed -i s/'metrics_id_here'/"$Chat_TelegramMetricsBot"/g /etc/TelegramBots/TelegramBots.conf
    sed -i s/'update_install_here'/"$Install_TelegramUpdateBot"/g /etc/TelegramBots/TelegramBots.conf
    sed -i s/'update_token_here'/"$Token_TelegramUpdateBot"/g /etc/TelegramBots/TelegramBots.conf
    sed -i s/'update_id_here'/"$Chat_TelegramUpdateBot"/g /etc/TelegramBots/TelegramBots.conf
    sed -i s/'login_install_here'/"$Install_TelegramLoginBot"/g /etc/TelegramBots/TelegramBots.conf
    sed -i s/'login_token_here'/"$Token_TelegramLoginBot"/g /etc/TelegramBots/TelegramBots.conf
    sed -i s/'login_id_here'/"$Chat_TelegramLoginBot"/g /etc/TelegramBots/TelegramBots.conf
    sed -i s/'alert_install_here'/"$Install_TelegramAlertBot"/g /etc/TelegramBots/TelegramBots.conf
    sed -i s/'alert_token_here'/"$Token_TelegramAlertBot"/g /etc/TelegramBots/TelegramBots.conf
    sed -i s/'alert_id_here'/"$Chat_TelegramAlertBot"/g /etc/TelegramBots/TelegramBots.conf
    sed -i s/'outage_install_here'/"$Install_TelegramOutageBot"/g /etc/TelegramBots/TelegramBots.conf
    sed -i s/'outage_token_here'/"$Token_TelegramOutageBot"/g /etc/TelegramBots/TelegramBots.conf
    sed -i s/'outage_id_here'/"$Chat_TelegramOutageBot"/g /etc/TelegramBots/TelegramBots.conf

else
    # Notify user that all configuration steps will be skipped
    echo "[i] Existing configuration found, skipping creation..."
    echo "[i] Skipping gathering tokens..."
    echo "[i] Skipping gathering chat IDs..."
    echo "[i] Skipping adding configuration file..."
    echo "[i] Skipping adding tokens and IDs to configuration..."
    echo "[i] Skipping adding cronjobs to system..."
fi

#############################################################################
# BOTS INSTALLATION OR UPDATE
#############################################################################

# Source TelegramBots.conf
. /etc/TelegramBots/TelegramBots.conf

echo
echo "*** INSTALLING BOTS & SCRIPTS ***"

# Install newest version of TelegramBotsUpgrade always
echo "[+] Installing TelegramBotsUpgrade"
wget -q https://raw.githubusercontent.com/sveeke/TelegramBots/master/TelegramBotsUpgrade.sh -O /usr/local/bin/TelegramBotsUpgrade
chmod 700 /usr/local/bin/TelegramBotsUpgrade

# Install newest version of TelegramBotsGenerateConfig always
echo "[+] Installing TelegramBotsGenerateConfig"
wget -q https://raw.githubusercontent.com/sveeke/TelegramBots/master/TelegramBotsGenerateConfig.sh -O /usr/local/bin/TelegramBotsGenerateConfig
chmod 700 /usr/local/bin/TelegramBotsGenerateConfig

# Install TelegramMetricsBot when enabled
if [ "$Install_TelegramMetricsBot" = 'yes' ]; then
    echo "[+] Installing TelegramMetricsBot"
    wget -q https://raw.githubusercontent.com/sveeke/TelegramBots/master/TelegramMetricsBot.sh -O /usr/local/bin/TelegramMetricsBot
    chmod 700 /usr/local/bin/TelegramMetricsBot
fi

# Install TelegramUpdateBot when enabled
if [ "$Install_TelegramUpdateBot" = 'yes' ]; then
    echo "[+] Installing TelegramUpdateBot"
    wget -q https://raw.githubusercontent.com/sveeke/TelegramBots/master/TelegramUpdateBot.sh -O /usr/local/bin/TelegramUpdateBot
    chmod 700 /usr/local/bin/TelegramUpdateBot
fi

# Install TelegramLoginBot when enabled
if [ "$Install_TelegramLoginBot" = 'yes' ]; then
    echo "[+] Installing TelegramLoginBot"
    wget -q https://raw.githubusercontent.com/sveeke/TelegramBots/master/TelegramLoginBot.sh -O /usr/local/bin/TelegramLoginBot
    chmod 700 /usr/local/bin/TelegramLoginBot
fi

# Install TelegramAlertBot when enabled
if [ "$Install_TelegramAlertBot" = 'yes' ]; then
    echo "[+] Installing TelegramAlertBot"
    wget -q https://raw.githubusercontent.com/sveeke/TelegramBots/master/TelegramAlertBot.sh -O /usr/local/bin/TelegramAlertBot
    chmod 700 /usr/local/bin/TelegramAlertBot
fi

# Install TelegramOutageBot when enabled
if [ "$Install_TelegramOutageBot" = 'yes' ]; then
    echo "[+] Installing TelegramOutageBot"
    wget -q https://raw.githubusercontent.com/sveeke/TelegramBots/master/TelegramOutageBot.sh -O /usr/local/bin/TelegramOutageBot
    chmod 700 /usr/local/bin/TelegramOutageBot
fi

#############################################################################
# CRON CREATE OR UPDATE
#############################################################################

# Creating or updating cronjobs
/bin/bash /usr/local/bin/TelegramBotsGenerateConfig

#############################################################################
# NOTICE
#############################################################################

echo
echo "#############################################################################"
echo "#                         INSTALLATION COMPLETE                             #"
echo "#############################################################################"
echo "#                                                                           #"
echo "#   Just type 'Telegram' and autocomplete (double tab) the bot or script    #"
echo "#   you want to use. You can change the default bot and script settings in  #"
echo "#   /etc/TelegramBots/TelegramBots.conf. After changing the config, run     #"
echo "#   'TelegramBotsGenerateConfig' to effectuate the changes.                 #"
echo "#                                                                           #"
echo "#############################################################################"
echo
echo

exit 0
