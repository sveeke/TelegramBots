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
TelegramBotsUpgrade='0.1.0'

#############################################################################
# UPDATE TELEGRAMBOTS
#############################################################################

# Get most recent install script
wget -q https://raw.githubusercontent.com/sveeke/TelegramBots/master/InstallTelegramBots.sh -O /etc/TelegramBots/InstallTelegramBots.sh

# Set permissions on install script
chmod 700 /etc/TelegramBots/InstallTelegramBots.sh

# Execute install script
/bin/bash /etc/TelegramBots/InstallTelegramBots.sh