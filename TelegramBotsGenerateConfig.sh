#!/bin/bash

#############################################################################
# Version 0.1.1-BETA (04-08-2018)
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

# Script version
TelegramBotsGenerateConfigVersion='0.1.0'

#############################################################################
# ARGUMENTS
#############################################################################

# Enable help and version
case $1 in
    --help|-help|help|--h|-h)
        echo
        echo "USAGE: TelegramBotsGenerateConfig [OPTION]..."
        echo "Execute changes in TelegramBots configuration file on system."
        echo
        echo "OPTIONS:"
        echo "--help      display this help and exit"
        echo "--version   display version information and exit"
        echo
        exit 0;;

    --version|-version|version|--v|-v)
        echo
        echo "TelegramBotsGenerateConfig $TelegramBotsGenerateConfigVersion"
        echo "Copyright (C) 2018 S. Veeke."
        echo
        echo "License CC Attribution-NonCommercial-ShareAlike 4.0 Int."
        echo
        exit 0;;
esac

#############################################################################
# UPDATE CRONJOBS
#############################################################################

echo
echo "*** UPDATING CRONJOBS ***"
echo

# Source TelegramBots.conf
echo "[+] Reading TelegramBots.conf..."
. /etc/TelegramBots/TelegramBots.conf

# Update cronjob for TelegramBotsAutoUpdate
if [ "$TelegramBotsAutoUpdate" = 'yes' ]; then
    echo "[+] Updating cronjob for TelegramBotsAutoUpdate"
    echo -e "# This cronjob activates TelegramBotsUpgrade on the chosen schedule\n\n$Cron_TelegramBotsAutoUpdate root /usr/local/bin/TelegramBotsUpgrade" > /etc/cron.d/TelegramBotsAutoUpdate
fi

# Update cronjob for TelegramMetricsBot
if [ "$Install_TelegramMetricsBot" = 'yes' ] &&
[ -f /usr/local/bin/TelegramMetricsBot ]; then
    echo "[+] Updating cronjob for TelegramMetricsBot"
    echo -e "# This cronjob activates the TelegramMetricsBot on the chosen schedule\n\n$Cron_TelegramMetricsBot root /usr/local/bin/TelegramMetricsBot" > /etc/cron.d/TelegramMetricsBot
    chmod 750 /etc/cron.d/TelegramMetricsBot
fi

# Update cronjob for TelegramUpdateBot
if [ "$Install_TelegramUpdateBot" = 'yes' ] &&
[ -f /usr/local/bin/TelegramUpdateBot ]; then
    echo "[+] Updating cronjob for TelegramUpdateBot"
    echo -e "# This cronjob activates the TelegramUpdateBot on the chosen schedule\n\n$Cron_TelegramUpdateBot root /usr/local/bin/TelegramUpdateBot" > /etc/cron.d/TelegramUpdateBot
    chmod 750 /etc/cron.d/TelegramUpdateBot
fi

# Update cronjob for TelegramLoginBot
if [ "$Install_TelegramLoginBot" = 'yes' ] &&
[ -f /usr/local/bin/TelegramLoginBot ]; then
    echo "[+] Updating cronjob for TelegramLoginBot"
    echo -e "# This cronjob activates the TelegramLoginBot on the chosen schedule\n\n$Cron_TelegramLoginBot root /usr/local/bin/TelegramLoginBot" > /etc/cron.d/TelegramLoginBot
    chmod 750 /etc/cron.d/TelegramLoginBot
fi

# Update cronjob for TelegramAlertBot
if [ "$Install_TelegramAlertBot" = 'yes' ] &&
[ -f /usr/local/bin/TelegramAlertBot ]; then
    echo "[+] Updating cronjob for TelegramAlertBot"
    echo -e "# This cronjob activates the TelegramAlertBot on the chosen schedule\n\n$Cron_TelegramAlertBot root /usr/local/bin/TelegramAlertBot" > /etc/cron.d/TelegramAlertBot
    chmod 750 /etc/cron.d/TelegramAlertBot
fi

# Update cronjob for TelegramOutageBot
if [ "$Install_TelegramOutageBot" = 'yes' ] &&
[ -f /usr/local/bin/TelegramOutageBot ]; then
    echo "[+] Updating cronjob for TelegramOutageBot"
    echo -e "# This cronjob activates the TelegramOutageBot on the chosen schedule\n\n$Cron_TelegramOutageBot root /usr/local/bin/TelegramOutageBot" > /etc/cron.d/TelegramOutageBot
    chmod 750 /etc/cron.d/TelegramOutageBot
fi

# Restart cron
echo
echo "[+] Restarting the cron service..."
systemctl restart cron

echo
exit 0
