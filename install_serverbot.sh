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

#############################################################################
# CHECKING REQUIREMENTS
#############################################################################

echo
echo "This script will install ServerBot on your machine. You need the"
echo "access token and chat ID during the installation."
echo
echo "Press ctrl + c during the installation to abort."

sleep 3

echo
echo
echo "CHECKING REQUIREMENTS"

# Checking whether the script runs as root
echo -n "Script is running as root..."
    if [ "$EUID" -ne 0 ]; then
        echo -e "\\t\\t\\t\\t\\t[NO]"
        echo
        echo "************************************************************************"
	    echo "This script should be run as root. Use su root and run the script again."
	    echo "************************************************************************"
        echo
	    exit
    fi
echo -e "\\t\\t\\t\\t\\t[YES]"

# Checking Debian version
echo -n "Running Debian..."
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
echo -n "Connected to the internet..."
wget -q --tries=10 --timeout=20 --spider www.google.com
    if [[ $? -eq 0 ]]; then
        echo -e "\\t\\t\\t\\t\\t[YES]"
    else
        echo -e "\\t\\t\\t\\t\\t[NO]"
        echo
        echo "***********************************"
        echo "Access to the internet is required."
        echo "***********************************"
        echo
        exit
    fi

#############################################################################
# USER INPUT
#############################################################################

echo
echo
echo "USER INPUT"

# Bot access token
read -r -p "Enter bot access token: " TOKEN

# Chat ID
read -r -p "Enter chat id:          " ID


#############################################################################
# BOT INSTALLATION
#############################################################################

echo
echo
echo "INSTALLATION"

# Download and save the bot script to /usr/local/bin
echo "1. Downloading and saving the bot..."

wget -q https://raw.githubusercontent.com/sveeke/TelegramBots/master/bots/serverbot.sh -O /usr/local/bin/serverbot.sh

# Give execute privileges to the bot script
echo "2. Setting permissions for bot..."

chmod 700 /usr/local/bin/serverbot.sh

# Add access token and chat ID
echo "3. Adding access token and chat ID to bot..."

sed -i s/'ACCESS_TOKEN_HERE'/"$TOKEN"/g /usr/local/bin/serverbot.sh
sed -i s/'CHAT_ID_HERE'/"$ID"/g /usr/local/bin/serverbot.sh

# Create cronjob in /etc/cron.d
echo "4. Making sure the script runs daily..."

cat << EOF > /etc/cron.d/serverbot
# This cronjob activates the serverbot daily at 8:00.
0 8 * * * root /usr/local/bin/serverbot.sh
EOF

# Final notice
echo
echo
echo "The installation has been completed. You will now receive daily"
echo "updates with some server metrics. If you want to edit some"
echo "settings, please look at these locations:"
echo
echo "/etc/cron.d/serverbot"
echo "/usr/local/bin/serverbot.sh"
echo
echo "Good luck!"
echo
echo
exit
