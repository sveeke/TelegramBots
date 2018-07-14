#!/bin/bash

#############################################################################
# Version 0.3.0-ALPHA (14-07-2018)
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
TelegramBotsGenerateConfigVersion='0.3.0'

echo
echo
echo "*** TelegramBots cron jobs will be updated from TelegramBots.conf ***"
echo

# Source TelegramBots.conf
echo "[1/4] Reading TelegramBots.conf..."
. /etc/TelegramBots/TelegramBots.conf

# Enable the use of arguments
case $1 in
    --help|-help|help|--h|-h|help)
        echo
        echo "USAGE: TelegramBotsGenerateConfig [OPTION]..."
        echo "Execute changes in TelegramBots configuration file on system."
        echo
        echo "OPTIONS:"
        echo "--help      display this help and exit"
        echo "--version   display version information and exit"
        echo
        exit 0;;

    --version)
        echo
        echo "TelegramBotsGenerateConfig $TelegramBotsGenerateConfigVersion"
        echo "Copyright (C) 2018 S. Veeke."
        echo
        echo "License CC Attribution-NonCommercial-ShareAlike 4.0 Int."
        echo
        exit 0;;
esac

# Generate config function (work in progress)
#GenerateConfig() {
#    if [ "$1" = 'yes' ]; then
#        echo "Updating cronjob for $1"
#        echo -e "# This cronjob activates the "$1" on the chosen schedule\n\nCron_"$1" root /usr/local/bin/TelegramMetricsBot" > /etc/cron.d/"$1"
#        chmod 750 /etc/cron.d/TelegramMetricsBot
#    fi
#}

# Automatic update of TelegramBots
if [ "$TelegramBotsAutoUpdate" = 'yes' ]; then
    echo "Updating cronjob for TelegramBotsAutoUpdate"
    echo -e "# This cronjob activates the TelegramBotsAutoUpdate on the chosen schedule\n\n$Cron_TelegramBotsAutoUpdate root /usr/local/bin/TelegramBotsAutoUpdate" > /etc/cron.d/TelegramBotsAutoUpdate
fi

# TelegramMetricsBot
if [ "$Install_TelegramMetricsBot" = 'yes' ] &&
[ -f /usr/local/bin/TelegramMetricsBot ]; then
    echo "Updating cronjob for TelegramMetricsBot"
    echo -e "# This cronjob activates the TelegramMetricsBot on the chosen schedule\n\n$Cron_TelegramMetricsBot root /usr/local/bin/TelegramMetricsBot" > /etc/cron.d/TelegramMetricsBot
    chmod 750 /etc/cron.d/TelegramMetricsBot
fi

# TelegramUpdateBot
if [ "$Install_TelegramUpdateBot" = 'yes' ] &&
[ -f /usr/local/bin/TelegramUpdateBot ]; then
    echo "Updating cronjob for TelegramUpdateBot"
    echo -e "# This cronjob activates the TelegramUpdateBot on the chosen schedule\n\n$Cron_TelegramUpdateBot root /usr/local/bin/TelegramUpdateBot" > /etc/cron.d/TelegramUpdateBot
    chmod 750 /etc/cron.d/TelegramUpdateBot
fi

# TelegramLoginBot
if [ "$Install_TelegramLoginBot" = 'yes' ] &&
[ -f /usr/local/bin/TelegramLoginBot ]; then
    echo "Updating cronjob for TelegramLoginBot"
    echo -e "# This cronjob activates the TelegramLoginBot on the chosen schedule\n\n$Cron_TelegramLoginBot root /usr/local/bin/TelegramLoginBot" > /etc/cron.d/TelegramLoginBot
    chmod 750 /etc/cron.d/TelegramLoginBot
fi

# TelegramAlertBot
if [ "$Install_TelegramAlertBot" = 'yes' ] &&
[ -f /usr/local/bin/TelegramAlertBot ]; then
    echo "Updating cronjob for TelegramAlertBot"
    echo -e "# This cronjob activates the TelegramAlertBot on the chosen schedule\n\n$Cron_TelegramAlertBot root /usr/local/bin/TelegramAlertBot" > /etc/cron.d/TelegramAlertBot
    chmod 750 /etc/cron.d/TelegramAlertBot
fi

# TelegramOutageBot
if [ "$Install_TelegramOutageBot" = 'yes' ] &&
[ -f /usr/local/bin/TelegramOutageBot ]; then
    echo "Updating cronjob for TelegramOutageBot"
    echo -e "# This cronjob activates the TelegramOutageBot on the chosen schedule\n\n$Cron_TelegramOutageBot root /usr/local/bin/TelegramOutageBot" > /etc/cron.d/TelegramOutageBot
    chmod 750 /etc/cron.d/TelegramOutageBot
fi

# Restart cron
echo "Restarting the cron service..."
systemctl restart cron
echo
echo "All done!"
echo
echo
exit
