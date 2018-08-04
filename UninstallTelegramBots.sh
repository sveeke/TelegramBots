#!/bin/bash

#############################################################################
# Version 0.1.3-ALPHA (04-08-2018)
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

rm -rf /etc/TelegramBots
rm /usr/local/bin/TelegramMetricsBot*
rm /usr/local/bin/TelegramUpdateBot*
rm /usr/local/bin/TelegramAlertBot*
rm /usr/local/bin/TelegramLoginBot*
rm /usr/local/bin/TelegramOutageBot*
rm /usr/local/bin/TelegramBotsGenerateConfig*
rm /usr/local/bin/TelegramCronUpdate*
rm /etc/cron.d/TelegramMetricsBot
rm /etc/cron.d/TelegramUpdateBot
rm /etc/cron.d/TelegramAlertBot
rm /etc/cron.d/TelegramLoginBot
rm /etc/cron.d/TelegramOutageBot
