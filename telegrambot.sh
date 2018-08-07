#!/bin/bash

#############################################################################
# Version 0.1.0-ALPHA (07-08-2018)
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
# NOTICE FOR READERS
#############################################################################

# How nice of you that you look in the source code of this bot.
# bla bla
# bla bla

#############################################################################
# VARIABLES
#############################################################################

# Bot version
TelegrambotVersion='0.1.0'

# Source variables in telegrambot.conf
. /etc/telegrambot/telegrambot.conf

#############################################################################
# ARGUMENTS
#############################################################################

# Enable help, version and a cli option
while test -n "$1"; do
    case "$1" in
        --version|-version|version|--v|-v)
            echo
            echo "TelegramAlertBot $TelegrambotVersion"
            echo "Copyright (C) 2018 Nozel."
            echo
            echo "License CC Attribution-NonCommercial-ShareAlike 4.0 Int."
            echo
            echo "Written by Sebas Veeke"
            shift
            ;;

        --help|-help|help|--h|-h)
            echo
            echo "Usage:"
            echo " telegrambot [function/option]... [method]..."
            echo
            echo "Functions:"
            echo " -m, --metrics         Show server metrics"
            echo " -a, --alert           Show server alert status"
            echo " -u, --updates         Show available server updates"
            echo " -o, --outage          Check list for outage"
            echo
            echo "Methods:"
            echo " -c, --cli             Output [option] to command line"
            echo " -t, --telegram        Output [option] to Telegram bot"
            echo
            echo "Options:"
            echo " --config     effectuate changes from telegrambot config"
            echo " --upgrade    upgrade telegrambot to the newest version"
            echo " --help       display this help and exit"
            echo " --version    display version information and exit"
            echo
            shift
            ;;

        --config|--configuration|-config|-configuration|config|configuration)
            ArgumentConfiguration="1"
            shift
            ;;

        --upgrade|-upgrade|upgrade)
            ArgumentUpgrade="1"
            shift
            ;;

        --metrics|-metrics|metrics|--m|-m)
            ArgumentMetrics="1"
            shift
            ;;

        --alert|-alert|alert|--a|-a)
            ArgumentAlert="1"
            shift
            ;;

        --updates|-updates|updates|--u|-u)
            ArgumentUpdates="1"
            shift
            ;;

        --outage|-outage|outage|--o|-o)
            ArgumentOutage="1"
            shift
            ;;

        --cli|-cli|cli|--c|-c)
            ArgumentCli="1"
            shift
            ;;

        --telegram|-telegram|telegram|--t|-t)
            ArgumentTelegram="1"
            shift
            ;;
    esac
done

#############################################################################
# MANAGEMENT FUNCTIONS
#############################################################################

function ManagementConfiguration {

    echo
    echo "*** UPDATING CRONJOBS ***"
    echo

    # Source telegrambot.conf
    echo "[+] Reading telegrambot.conf..."
    . /etc/telegrambot/telegrambot.conf

    # Update cronjob for AutoUpgrade if activated
    if [ "$AutoUpgrade" = 'yes' ]; then
        echo "[+] Updating cronjob for automatic upgrade"
        echo -e "# This cronjob activates automatic upgrade of Telegrambot on the chosen schedule\n\n${AutoUpgradeCron} root /usr/local/bin/telegrambot --upgrade" > /etc/cron.d/telegrambot_auto_upgrade
    fi

    # Update metrics cronjob if activated
    if [ "$MetricsActivate" = 'yes' ]; then
        echo "[+] Updating metrics cronjob"
        echo -e "# This cronjob activates the metrics on Telegram on the chosen schedule\n\n${MetricsCron} root /usr/local/bin/telegrambot --metrics --telegram" > /etc/cron.d/telegrambot_metrics
    fi

    # Update alert cronjob if activated
    if [ "$AlertActivate" = 'yes' ]; then
        echo "[+] Updating alert cronjob"
        echo -e "# This cronjob activates alerts on Telegram on the chosen schedule\n\n${AlertCron} root /usr/local/bin/telegrambot --alert --telegram" > /etc/cron.d/telegrambot_alert
    fi

    # Update updates cronjob if activated
    if [ "$UpdatesActivate" = 'yes' ]; then
        echo "[+] Updating updates cronjob"
        echo -e "# This cronjob activates updates messages on Telegram on the the chosen schedule\n\n${UpdatesCron} root /usr/local/bin/telegrambot --updates --telegram" > /etc/cron.d/telegrambot_updates
    fi

    # A cronjob for the login function is probably not relevant. Can be removed after the login functionality has been thought out.
    # Update login cronjob if activated
    #if [ "$LoginActivated" = 'yes' ]; then
    #    echo "[+] Updating login cronjob"
    #    echo -e "# This cronjob activates login notices on telegram on the chosen schedule\n\n${LoginCron} root /usr/local/bin/telegrambot --login --telegram" > /etc/cron.d/telegrambot_login
    #fi

    # Update outage cronjob if activated
    if [ "$OutageActivate" = 'yes' ]; then
        echo "[+] Updating outage cronjob"
        echo -e "# This cronjob activates the outage warnings on Telegram on the chosen schedule\n\n${OutageCron} root /usr/local/bin/telegrambot --outage --telegram" > /etc/cron.d/telegrambot_outage
    fi

    # Restart cron
    echo
    echo "[+] Restarting the cron service..."
    systemctl restart cron

    echo
    exit 0
}

function ManagementUpgrade {

    # Get most recent install script
    wget -q https://raw.githubusercontent.com/sveeke/TelegramBots/master/install_telegrambot.sh -O /etc/telegrambot/install_telegrambot.sh

    # Set permissions on install script
    chmod 700 /etc/telegrambot/install_telegrambot.sh

    # Execute install script
    /bin/bash /etc/telegrambot/install_telegrambot.sh
}

#############################################################################
# GATHER FUNCTIONS
#############################################################################

function GatherServerInformation {

    # Server information
    Hostname="$(uname -n)"
    Uptime="$(uptime -p)"
}

function GatherMetrics {

    # Strip '%' of thresholds in Telegrambot.conf
    ThresholdLoadNumber="$(echo "$ThresholdLoad" | tr -d '%')"
    ThresholdMemoryNumber="$(echo "$ThresholdMemory" | tr -d '%')"
    ThresholdDiskNumber="$(echo "$ThresholdDisk" | tr -d '%')"


    # CPU and load metrics
    CoreAmount="$(grep 'cpu cores' /proc/cpuinfo | wc -l)"
    MaxLoadServer="$CoreAmount.00"
    CompleteLoad="$(cat /proc/loadavg | awk '{print $1" "$2" "$3}')"
    CurrentLoad="$(cat /proc/loadavg | awk '{print $3}')"
    CurrentLoadPercentage="$(echo "("$CurrentLoad"/"$MaxLoadServer")*100" | bc -l)"
    CurrentLoadPercentageRounded="$(printf "%.0f\n" $(echo "$CurrentLoadPercentage" | tr -d '%'))"

    # Memory metrics
    # Use older format in free when Debian 8 or Ubuntu 14.04 is used
    if [ "$OperatingSystem $OperatingSystemVersion" == "Debian GNU/Linux 8" ] || \
    [ "$OperatingSystem $OperatingSystemVersion" == "Ubuntu 14.04" ]; then
        TotalMemory="$(free -m | awk '/^Mem/ {print $2}')"
        FreeMemory="$(free -m | awk '/^Mem/ {print $4}')"
        BuffersMemory="$(free -m | awk '/^Mem/ {print $6}')"
        CachedMemory="$(free -m | awk '/^Mem/ {print $7}')"
        UsedMemory="$(echo "("$TotalMemory"-"$FreeMemory"-"$BuffersMemory"-"$CachedMemory")" | bc -l)"
        CurrentMemoryPercentage="$(echo "("$UsedMemory"/"$TotalMemory")*100" | bc -l)"
        CurrentMemoryPercentageRounded="$(printf "%.0f\n" $(echo "$CurrentMemoryPercentage" | tr -d '%'))"
    fi

    # Use newer format in free when CentOS 7+, Debian 9+ or Ubuntu 16.04+ is used
    if [ "$OperatingSystem $OperatingSystemVersion" == "CentOS Linux 7" ] || \
    [ "$OperatingSystem $OperatingSystemVersion" == "CentOS Linux 8" ] || \
    [ "$OperatingSystem $OperatingSystemVersion" == "Fedora 27" ] || \
    [ "$OperatingSystem $OperatingSystemVersion" == "Fedora 28" ] || \
    [ "$OperatingSystem $OperatingSystemVersion" == "Debian GNU/Linux 9" ] || \
    [ "$OperatingSystem $OperatingSystemVersion" == "Debian GNU/Linux 10" ] || \
    [ "$OperatingSystem $OperatingSystemVersion" == "Ubuntu 16.04" ] || \
    [ "$OperatingSystem $OperatingSystemVersion" == "Ubuntu 18.04" ] || \
    [ "$OperatingSystem $OperatingSystemVersion" == "Ubuntu 18.10" ]; then
        TotalMemory="$(free -m | awk '/^Mem/ {print $2}')"
        FreeMemory="$(free -m | awk '/^Mem/ {print $4}')"
        BuffersCachedMemory="$(free -m | awk '/^Mem/ {print $6}')"
        UsedMemory="$(echo "("$TotalMemory"-"$FreeMemory"-"$BuffersCachedMemory")" | bc -l)"
        CurrentMemoryPercentage="$(echo "("$UsedMemory"/"$TotalMemory")*100" | bc -l)"
        CurrentMemoryPercentageRounded="$(printf "%.0f\n" $(echo "$CurrentMemoryPercentage" | tr -d '%'))"
    fi

    # File system metrics
    TotalDiskSize="$(df -h / --output=size -x tmpfs -x devtmpfs | tr -dc '1234567890GKMT.')"
    CurrentDiskUsage="$(df -h / --output=used -x tmpfs -x devtmpfs | tr -dc '1234567890GKMT.')"
    CurrentDiskPercentage="$(df / --output=pcent -x tmpfs -x devtmpfs | tr -dc '0-9')"
}

function GatherUpdates {

    if [ "$OperatingSystem $OperatingSystemVersion" == "CentOS Linux 7" ]; then
        # List with available updates to variable AvailableUpdates
        AvailableUpdates="$(yum check-update | grep -v plugins | awk '(NR >=1) {print $1;}' | grep '^[[:alpha:]]' | sed 's/\<Loading\>//g')"
        # Outputs the character length of AvailableUpdates in LengthUpdates
        LengthUpdates="${#AvailableUpdates}"
    fi

    if [ "$OperatingSystem $OperatingSystemVersion" == "CentOS Linux 8" ] || \
    [ "$OperatingSystem $OperatingSystemVersion" == "Fedora 27" ] || \
    [ "$OperatingSystem $OperatingSystemVersion" == "Fedora 28" ]; then
        # List with available updates to variable AvailableUpdates
        AvailableUpdates="$(dnf check-update | grep -v plugins | awk '(NR >=1) {print $1;}' | grep '^[[:alpha:]]' | sed 's/\<Loading\>//g')"
        # Outputs the character length of AvailableUpdates in LengthUpdates
        LengthUpdates="${#AvailableUpdates}"
    fi

    if [ "$OperatingSystem $OperatingSystemVersion" == "Debian GNU/Linux 8" ] || \
    [ "$OperatingSystem $OperatingSystemVersion" == "Debian GNU/Linux 9" ] || \
    [ "$OperatingSystem $OperatingSystemVersion" == "Debian GNU/Linux 10" ] || \
    [ "$OperatingSystem $OperatingSystemVersion" == "Ubuntu 14.04" ] || \
    [ "$OperatingSystem $OperatingSystemVersion" == "Ubuntu 16.04" ] || \
    [ "$OperatingSystem $OperatingSystemVersion" == "Ubuntu 18.04" ] || \
    [ "$OperatingSystem $OperatingSystemVersion" == "Ubuntu 18.10" ]; then
        # Update repository
        apt-get -qq update
        # List with available updates to variable AvailableUpdates
        AvailableUpdates="$(aptitude -F "%p" search '~U')"
        # Outputs the character length of AvailableUpdates in LengthUpdates
        LengthUpdates="${#AvailableUpdates}"
    fi
}

#############################################################################
# Update config
#############################################################################

if [ "$ArgumentConfiguration" == "1" ]; then
    # Effectuate changes in telegrambot.conf to system
    ManagementConfiguration
fi

#############################################################################
# Upgrade telegrambot
#############################################################################

if [ "$ArgumentUpgrade" == "1" ]; then
    # Upgrade telegrambot to the newest version
    ManagementUpgrade
fi

#############################################################################
# Metrics bot
#############################################################################

# Method CLI
if [ "$ArgumentMetrics" == "1" ] && [ "$ArgumentCli" == "1" ]; then

    # Gather required server information and metrics
    GatherServerInformation
    GatherMetrics

    # Output server metrics to shell and exit
    echo
    echo "HOST:     ${Hostname}"
    echo "UPTIME:   ${Uptime}"
    echo "LOAD:     ${CompleteLoad}"
    echo "MEMORY:   ${UsedMemory}M / ${TotalMemory}M (${CurrentMemoryPercentageRounded}%)"
    echo "DISK:     ${CurrentDiskUsage} / ${TotalDiskSize} (${CurrentDiskPercentage}%)"
    exit 0
fi

# Method Telegram
if [ "$ArgumentMetrics" == "1" ] && [ "$ArgumentTelegram" == "1" ]; then

    # Gather required server information and metrics
    GatherServerInformation
    GatherMetrics

    # Create message for Telegram
    MetricsMessage="$(echo -e "*Host*:        ${Hostname}\\n*Uptime*:  ${Uptime}\\n\\n*Load*:         ${CompleteLoad}\\n*Memory*:  ${UsedMemory} M / ${TotalMemory} M (${CurrentMemoryPercentageRounded}%)\\n*Disk*:          ${CurrentDiskUsage} / ${TotalDiskSize} (${CurrentDiskPercentage}%)")"

    # Create payload for curl
    MetricsPayload="chat_id=${MetricsChat}&text=${MetricsMessage}&parse_mode=Markdown&disable_web_page_preview=true"

    # Sent payload to Telegram and exit
    curl -s --max-time 10 --retry 5 --retry-delay 2 --retry-max-time 10 -d "${MetricsPayload}" ${MetricsUrl} > /dev/null 2>&1 &
    exit 0
fi

#############################################################################
# Alert bot
#############################################################################

# Method CLI
if [ "$ArgumentAlert" == "1" ] && [ "$ArgumentCli" == "1" ]; then

    # Gather required server information and metrics
    GatherServerInformation
    GatherMetrics

    # Check whether the current server load exceeds the threshold and alert if true
    # and output server alert status to shell
    echo
    if [ "$CurrentLoadPercentageRounded" -ge "$ThresholdLoadNumber" ]; then
        echo -e "[!] SERVER LOAD:\\tA current server load of ${CurrentLoadPercentageRounded}% exceeds the threshold of ${ThresholdLoad}."
    else
        echo -e "[i] SERVER LOAD:\\tA current server load of ${CurrentLoadPercentageRounded}% does not exceed the threshold of ${ThresholdLoad}."
    fi

    if [ "$CurrentMemoryPercentageRounded" -ge "$ThresholdMemoryNumber" ]; then
        echo -e "[!] SERVER MEMORY:\\tA current memory usage of ${CurrentMemoryPercentageRounded}% exceeds the threshold of ${ThresholdMemory}."
    else
        echo -e "[i] SERVER MEMORY:\\tA current memory usage of ${CurrentMemoryPercentageRounded}% does not exceed the threshold of ${ThresholdMemory}."
    fi

    if [ "$CurrentDiskPercentage" -ge "$ThresholdDiskNumber" ]; then
        echo -e "[!] DISK USAGE:\\t\\tA current disk usage of ${CurrentDiskPercentage}% exceeds the threshold of ${ThresholdDisk}."
    else
        echo -e "[i] DISK USAGE:\\t\\tA current disk usage of ${CurrentDiskPercentage}% does not exceed the threshold of ${ThresholdDisk}."
    fi
    # Exit when done
    exit 0
fi

# Method Telegram
if [ "$ArgumentAlert" == "1" ] && [ "$ArgumentTelegram" == "1" ]; then

    # Gather required server information and metrics
    GatherServerInformation
    GatherMetrics

    # Check whether the current server load exceeds the threshold and alert if true
    if [ "$CurrentLoadPercentageRounded" -ge "$ThresholdLoadNumber" ]; then

        # Create message for Telegram
        AlertMessageLoad="\xE2\x9A\xA0 *ALERT: SERVER LOAD*\\n\\nThe server load (${CurrentLoadPercentageRounded}%) on *${Hostname}* exceeds the threshold of ${ThresholdLoad}\\n\\n*Load average:*\\n${CompleteLoad}"

        # Create payload for curl
        AlertPayloadLoad="chat_id=${AlertChat}&text=$(echo -e "${AlertMessageLoad}")&parse_mode=Markdown&disable_web_page_preview=true"

        # Sent payload to Telegram
        curl -s --max-time 10 --retry 5 --retry-delay 2 --retry-max-time 10 -d "${AlertPayloadLoad}" ${AlertUrl} > /dev/null 2>&1 &
    fi

    # Check whether the current server memory usage exceeds the threshold and alert if true
    if [ "$CurrentMemoryPercentageRounded" -ge "$ThresholdMemoryNumber" ]; then

        # Create message for Telegram
        AlertMessageMemory="\xE2\x9A\xA0 *ALERT: SERVER MEMORY*\\n\\nMemory usage (${CurrentMemoryPercentageRounded}%) on *${Hostname}* exceeds the threshold of ${ThresholdMemory}\\n\\n*Memory usage:*\\n$(free -m -h)"

        # Create payload for curl
        AlertPayloadMemory="chat_id=${AlertChat}&text=$(echo -e "${AlertMessageMemory}")&parse_mode=Markdown&disable_web_page_preview=true"

        # Sent payload to Telegram
        curl -s --max-time 10 --retry 5 --retry-delay 2 --retry-max-time 10 -d "${AlertPayloadMemory}" ${AlertUrl} > /dev/null 2>&1 &
    fi

    # Check whether the current disk usaged exceeds the threshold and alert if true
    if [ "$CurrentDiskPercentage" -ge "$ThresholdDiskNumber" ]; then

        # Create message for Telegram
        AlertMessageDisk="\xE2\x9A\xA0 *ALERT: FILE SYSTEM*\\n\\nDisk usage (${CurrentDiskPercentage}%) on *${Hostname}* exceeds the threshold of ${ThresholdDisk}\\n\\n*Filesystem info:*\\n$(df -h)"

        # Create payload for curl
        AlertPayloadDisk="chat_id=${AlertChat}&text=$(echo -e "${AlertMessageDisk}")&parse_mode=Markdown&disable_web_page_preview=true"

        # Sent payload to Telegram
        curl -s --max-time 10 --retry 5 --retry-delay 2 --retry-max-time 10 -d "${AlertPayloadDisk}" ${AlertUrl} > /dev/null 2>&1 &
    fi
    exit 0
fi

#############################################################################
# Updates bot
#############################################################################

# Method CLI
if [ "$ArgumentUpdates" == "1" ] && [ "$ArgumentCli" == "1" ]; then

    # Gather required information about updates
    GatherUpdates

    # Notify user when there are no updates
    if [ -z "$AvailableUpdates" ]; then
        echo
        echo "There are no updates available."
        echo
        exit 0
    fi

    # Notify user when there are updates available
    echo
    echo "The following updates are available:"
    echo
    echo "${AvailableUpdates}"
    echo
    exit 0
fi

# Method Telegram
if [ "$ArgumentUpdates" == "1" ] && [ "$ArgumentTelegram" == "1" ]; then

    # Gather required information about updates and server
    GatherServerInformation
    GatherUpdates

            UpdatesMessage="hoi"        
        # Create updates payload to sent to telegram API
        UpdatesPayload="chat_id=${UpdatesChat}&text=$(echo -e "${UpdatesMessage}")&parse_mode=Markdown&disable_web_page_preview=true"

        # Sent updates payload to Telegram API
        curl -s --max-time 10 --retry 5 --retry-delay 2 --retry-max-time 10 -d "${UpdatesPayload}" ${UpdatesUrl} > /dev/null 2>&1 &

    # Do nothing if there are no updates
    if [ -z "$AvailableUpdates" ]; then
        exit 0
    else
        # If update list length is less than 4000 characters, then sent update list
        if [ "$LengthUpdates" -lt "4000" ]; then
            UpdatesMessage="There are updates available on *${Hostname}*:\n\n${AvailableUpdates}"
        fi

        # If update list length is greater than 4000 characters, don't sent update list
        if [ "$LengthUpdates" -gt "4000" ]; then
            UpdatesMessage="There are updates available on *${Hostname}*. Unfortunately, the list with updates is too large for Telegram. Please update your server as soon as possible."
        fi

        UpdatesMessage="hoi"        
        # Create updates payload to sent to telegram API
        UpdatesPayload="chat_id=${UpdatesChat}&text=$(echo -e "${UpdatesMessage}")&parse_mode=Markdown&disable_web_page_preview=true"

        # Sent updates payload to Telegram API
        curl -s --max-time 10 --retry 5 --retry-delay 2 --retry-max-time 10 -d "${UpdatesPayload}" ${UpdatesUrl} > /dev/null 2>&1 &
    fi
exit 0
fi