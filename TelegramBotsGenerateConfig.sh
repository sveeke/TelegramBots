#!/bin/bash

#############################################################################
# Version 0.2.0-ALPHA (08-07-2018)
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

echo
echo
echo "*** TelegramBots cron jobs will be updated from TelegramBots.conf ***"
echo

# Source TelegramBots.conf
echo "[1/4] Reading TelegramBots.conf..."
. /etc/TelegramBots/TelegramBots.conf

# Cronjob for TelegramMetricsBot
echo "[2/4] Updating cronjob for TelegramMetricsBot"
cat << EOF > /etc/cron.d/TelegramMetricsBot
# This cronjob activates the TelegramMetricsBot daily at 8:00.
$Cron_TelegramMetricsBot root /usr/local/bin/TelegramMetricsBot.sh
EOF

# Cronjob for TelegramUpdateBot
echo "[3/4] Updating cronjob for TelegramUpdateBot"
cat << EOF > /etc/cron.d/TelegramUpdateBot
# This cronjob activates the TelegramUpdateBot three times during the day.
$Cron_TelegramUpdateBot root /usr/local/bin/TelegramUpdateBot.sh
EOF

# Restart cron
echo "[4/4] Restarting the cron service..."
echo
echo "All done!"
echo
echo
exit
