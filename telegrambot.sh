#!/bin/bash

#############################################################################
# Version 0.1.4-ALPHA (24-11-2018)
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

# telegrambot version
VERSION='0.1.4'

# source variables in telegrambot.conf
source /etc/telegrambot/telegrambot.conf

#############################################################################
# ARGUMENTS
#############################################################################

# enable help, version and a cli option
while test -n "$1"; do
    case "$1" in
        --version|-version|version|--v|-v)
            echo "TelegramAlertBot ${VERSION}"
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
            ARGUMENT_CONFIGURATION="1"
            shift
            ;;

        --upgrade|-upgrade|upgrade)
            ARGUMENT_UPGRADE="1"
            shift
            ;;

        --metrics|-metrics|metrics|--m|-m)
            ARGUMENT_METRICS="1"
            shift
            ;;

        --alert|-alert|alert|--a|-a)
            ARGUMENT_ALERT="1"
            shift
            ;;

        --updates|-updates|updates|--u|-u)
            ARGUMENT_UPDATES="1"
            shift
            ;;

        --outage|-outage|outage|--o|-o)
            ARGUMENT_OUTAGE="1"
            shift
            ;;

        --cli|-cli|cli|--c|-c)
            ARGUMENT_CLI="1"
            shift
            ;;

        --telegram|-telegram|telegram|--t|-t)
            ARGUMENT_TELEGRAM="1"
            shift
            ;;
    esac
done

#############################################################################
# MANAGEMENT FUNCTIONS
#############################################################################

function management_configuration {

    echo
    echo "*** UPDATING CRONJOBS ***"
    echo

    # source telegrambot.conf
    echo "[+] Reading telegrambot.conf..."
    source /etc/telegrambot/telegrambot.conf

    # update cronjob for AutoUpgrade if activated
    if [ "$AUTO_UPGRADE" = 'yes' ]; then
        echo "[+] Updating cronjob for automatic upgrade"
        echo -e "# This cronjob activates automatic upgrade of Telegrambot on the chosen schedule\n\n${AUTO_UPGRADE_CRON} root /usr/local/bin/telegrambot --upgrade" > /etc/cron.d/telegrambot_auto_upgrade
    fi

    # update metrics cronjob if activated
    if [ "$METRICS_ENABLED" = 'yes' ]; then
        echo "[+] Updating metrics cronjob"
        echo -e "# This cronjob activates the metrics on Telegram on the chosen schedule\n\n${METRICS_CRON} root /usr/local/bin/telegrambot --metrics --telegram" > /etc/cron.d/telegrambot_metrics
    fi

    # update alert cronjob if activated
    if [ "$ALERT_ENABLED" = 'yes' ]; then
        echo "[+] Updating alert cronjob"
        echo -e "# This cronjob activates alerts on Telegram on the chosen schedule\n\n${ALERT_CRON} root /usr/local/bin/telegrambot --alert --telegram" > /etc/cron.d/telegrambot_alert
    fi

    # update updates cronjob if activated
    if [ "$UPDATES_ENABLED" = 'yes' ]; then
        echo "[+] Updating updates cronjob"
        echo -e "# This cronjob activates updates messages on Telegram on the the chosen schedule\n\n${UPDATES_CRON} root /usr/local/bin/telegrambot --updates --telegram" > /etc/cron.d/telegrambot_updates
    fi

    # work in progress
    # a cronjob for the login function is probably not relevant. can be removed after the login functionality has been thought out.
    # update login cronjob if activated
    #if [ "$LOGIN_ENABLED" = 'yes' ]; then
    #    echo "[+] Updating login cronjob"
    #    echo -e "# This cronjob activates login notices on telegram on the chosen schedule\n\n${LOGIN_CRON} root /usr/local/bin/telegrambot --login --telegram" > /etc/cron.d/telegrambot_login
    #fi

    # update outage cronjob if activated
    if [ "$OUTAGE_ENABLED" = 'yes' ]; then
        echo "[+] Updating outage cronjob"
        echo -e "# This cronjob activates the outage warnings on Telegram on the chosen schedule\n\n${OUTAGE_CRON} root /usr/local/bin/telegrambot --outage --telegram" > /etc/cron.d/telegrambot_outage
    fi

    # restart cron
    echo
    echo "[+] Restarting the cron service..."
    systemctl restart cron

    echo
    exit 0
}

function management_upgrade {

    # get most recent install script
    wget -q https://raw.githubusercontent.com/sveeke/TelegramBots/master/install_telegrambot.sh -O /etc/telegrambot/install_telegrambot.sh

    # set permissions on install script
    chmod 700 /etc/telegrambot/install_telegrambot.sh

    # execute install script
    /bin/bash /etc/telegrambot/install_telegrambot.sh
}

#############################################################################
# GATHER FUNCTIONS
#############################################################################

function gather_server_information {

    # server information
    HOSTNAME="$(uname -n)"
    UPTIME="$(uptime -p)"
}

function gather_metrics {

    # strip '%' of thresholds in Telegrambot.conf
    THRESHOLD_LOAD_NUMBER="$(echo "${THRESHOLD_LOAD}" | tr -d '%')"
    THRESHOLD_MEMORY_NUMBER="$(echo "${THRESHOLD_MEMORY}" | tr -d '%')"
    THRESHOLD_DISK_NUMBER="$(echo "${THRESHOLD_DISK}" | tr -d '%')"

    # cpu and load metrics
    CORE_AMOUNT="$(grep -c 'cpu cores' /proc/cpuinfo)"
    MAX_LOAD_SERVER="${CORE_AMOUNT}.00"
    COMPLETE_LOAD="$(< /proc/loadavg awk '{print $1" "$2" "$3}')"
    CURRENT_LOAD="$(< /proc/loadavg awk '{print $3}')"
    CURRENT_LOAD_PERCENTAGE="$(echo "(${CURRENT_LOAD}/${MAX_LOAD_SERVER})*100" | bc -l)"
    CURRENT_LOAD_PERCENTAGE_ROUNDED="$(printf "%.0f\n" $(echo "${CURRENT_LOAD_PERCENTAGE}" | tr -d '%'))"

    # memory metrics
    # use older format in free when Debian 8 or Ubuntu 14.04 is used
    if [ "${OPERATING_SYSTEM} ${OPERATING_SYSTEM_VERSION}" == "Debian GNU/Linux 8" ] || \
    [ "${OPERATING_SYSTEM} ${OPERATING_SYSTEM_VERSION}" == "Ubuntu 14.04" ]; then
        TOTAL_MEMORY="$(free -m | awk '/^Mem/ {print $2}')"
        FREE_MEMORY="$(free -m | awk '/^Mem/ {print $4}')"
        BUFFERS_MEMORY="$(free -m | awk '/^Mem/ {print $6}')"
        CACHED_MEMORY="$(free -m | awk '/^Mem/ {print $7}')"
        USED_MEMORY="$(echo "(${TOTAL_MEMORY}-${FREE_MEMORY}-${BUFFERS_MEMORY}-${CACHED_MEMORY})" | bc -l)"
        CURRENT_MEMORY_PERCENTAGE="$(echo "(${USED_MEMORY}/${TOTAL_MEMORY})*100" | bc -l)"
        CURRENT_MEMORY_PERCENTAGE_ROUNDED="$(printf "%.0f\n" $(echo "${CURRENT_MEMORY_PERCENTAGE}" | tr -d '%'))"
    fi

    # use newer format in free when CentOS 7+, Debian 9+ or Ubuntu 16.04+ is used
    if [ "$OPERATING_SYSTEM $OPERATING_SYSTEM_VERSION" == "CentOS Linux 7" ] || \
    [ "$OPERATING_SYSTEM $OPERATING_SYSTEM_VERSION" == "CentOS Linux 8" ] || \
    [ "$OPERATING_SYSTEM $OPERATING_SYSTEM_VERSION" == "Fedora 27" ] || \
    [ "$OPERATING_SYSTEM $OPERATING_SYSTEM_VERSION" == "Fedora 28" ] || \
    [ "$OPERATING_SYSTEM $OPERATING_SYSTEM_VERSION" == "Fedora 29" ] || \
    [ "$OPERATING_SYSTEM $OPERATING_SYSTEM_VERSION" == "Debian GNU/Linux 9" ] || \
    [ "$OPERATING_SYSTEM $OPERATING_SYSTEM_VERSION" == "Debian GNU/Linux 10" ] || \
    [ "$OPERATING_SYSTEM $OPERATING_SYSTEM_VERSION" == "Ubuntu 16.04" ] || \
    [ "$OPERATING_SYSTEM $OPERATING_SYSTEM_VERSION" == "Ubuntu 18.04" ] || \
    [ "$OPERATING_SYSTEM $OPERATING_SYSTEM_VERSION" == "Ubuntu 18.10" ]; then
        TOTAL_MEMORY="$(free -m | awk '/^Mem/ {print $2}')"
        FREE_MEMORY="$(free -m | awk '/^Mem/ {print $4}')"
        BUFFERS_CACHED_MEMORY="$(free -m | awk '/^Mem/ {print $6}')"
        USED_MEMORY="$(echo "(${TOTAL_MEMORY}-${FREE_MEMORY}-${BUFFERS_CACHED_MEMORY})" | bc -l)"
        CURRENT_MEMORY_PERCENTAGE="$(echo "(${USED_MEMORY}/${TOTAL_MEMORY})*100" | bc -l)"
        CURRENT_MEMORY_PERCENTAGE_ROUNDED="$(printf "%.0f\n" $(echo "${CURRENT_MEMORY_PERCENTAGE}" | tr -d '%'))"
    fi

    # file system metrics
    TOTAL_DISK_SIZE="$(df -h / --output=size -x tmpfs -x devtmpfs | tr -dc '1234567890GKMT.')"
    CURRENT_DISK_USAGE="$(df -h / --output=used -x tmpfs -x devtmpfs | tr -dc '1234567890GKMT.')"
    CURRENT_DISK_PERCENTAGE="$(df / --output=pcent -x tmpfs -x devtmpfs | tr -dc '0-9')"
}

function gather_updates {

    if [ "$OPERATING_SYSTEM $OPERATING_SYSTEM_VERSION" == "CentOS Linux 7" ]; then
        # list with available updates to variable AVAILABLE_UPDATES
        AVAILABLE_UPDATES="$(yum check-update | grep -v plugins | awk '(NR >=1) {print $1;}' | grep '^[[:alpha:]]' | sed 's/\<Loading\>//g')"
        # outputs the character length of AVAILABLE_UPDATES in LENGTH_UPDATES
        LENGTH_UPDATES="${#AVAILABLE_UPDATES}"
    fi

    if [ "$OPERATING_SYSTEM $OPERATING_SYSTEM_VERSION" == "CentOS Linux 8" ] || \
    [ "$OPERATING_SYSTEM $OPERATING_SYSTEM_VERSION" == "Fedora 27" ] || \
    [ "$OPERATING_SYSTEM $OPERATING_SYSTEM_VERSION" == "Fedora 28" ] || \
    [ "$OPERATING_SYSTEM $OPERATING_SYSTEM_VERSION" == "Fedora 29" ]; then

        # list with available updates to variable AVAILABLE_UPDATES
        AVAILABLE_UPDATES="$(dnf check-update | grep -v plugins | awk '(NR >=1) {print $1;}' | grep '^[[:alpha:]]' | sed 's/\<Loading\>//g')"
        # outputs the character length of AVAILABLE_UPDATES in LENGTH_UPDATES
        LENGTH_UPDATES="${#AVAILABLE_UPDATES}"
    fi

    if [ "$OPERATING_SYSTEM $OPERATING_SYSTEM_VERSION" == "Debian GNU/Linux 8" ] || \
    [ "$OPERATING_SYSTEM $OPERATING_SYSTEM_VERSION" == "Debian GNU/Linux 9" ] || \
    [ "$OPERATING_SYSTEM $OPERATING_SYSTEM_VERSION" == "Debian GNU/Linux 10" ] || \
    [ "$OPERATING_SYSTEM $OPERATING_SYSTEM_VERSION" == "Ubuntu 14.04" ] || \
    [ "$OPERATING_SYSTEM $OPERATING_SYSTEM_VERSION" == "Ubuntu 16.04" ] || \
    [ "$OPERATING_SYSTEM $OPERATING_SYSTEM_VERSION" == "Ubuntu 18.04" ] || \
    [ "$OPERATING_SYSTEM $OPERATING_SYSTEM_VERSION" == "Ubuntu 18.10" ]; then
        # update repository
        apt-get -qq update
        # list with available updates to variable AVAILABLE_UPDATES
        AVAILABLE_UPDATES="$(aptitude -F "%p" search '~U')"
        # outputs the character length of AVAILABLE_UPDATES in LENGTH_UPDATES
        LENGTH_UPDATES="${#AVAILABLE_UPDATES}"
    fi
}

#############################################################################
# UPDATE CONFIG
#############################################################################

if [ "$ARGUMENT_CONFIGURATION" == "1" ]; then
    # effectuate changes in telegrambot.conf to system
    management_configuration
fi

#############################################################################
# UPGRADE TELEGRAMBOT
#############################################################################

if [ "$ARGUMENT_UPGRADE" == "1" ]; then
    # upgrade telegrambot to the newest version
    management_upgrade
fi

#############################################################################
# FUNCTION METRICS
#############################################################################

# method CLI
if [ "$ARGUMENT_METRICS" == "1" ] && [ "$ARGUMENT_CLI" == "1" ]; then

    # gather required server information and metrics
    gather_server_information
    gather_metrics

    # output server metrics to shell and exit
    echo
    echo "HOST:     ${HOSTNAME}"
    echo "UPTIME:   ${UPTIME}"
    echo "LOAD:     ${COMPLETE_LOAD}"
    echo "MEMORY:   ${USED_MEMORY}M / ${TOTAL_MEMORY}M (${CURRENT_MEMORY_PERCENTAGE_ROUNDED}%)"
    echo "DISK:     ${CURRENT_DISK_USAGE} / ${TOTAL_DISK_SIZE} (${CURRENT_DISK_PERCENTAGE}%)"
    exit 0
fi

# method Telegram
if [ "$ARGUMENT_METRICS" == "1" ] && [ "$ARGUMENT_TELEGRAM" == "1" ]; then

    # gather required server information and metrics
    gather_server_information
    gather_metrics

    # create message for Telegram
    METRICS_MESSAGE="$(echo -e "*Host*:        ${HOSTNAME}\\n*UPTIME*:  ${UPTIME}\\n\\n*Load*:         ${COMPLETE_LOAD}\\n*Memory*:  ${USED_MEMORY} M / ${TOTAL_MEMORY} M (${CURRENT_MEMORY_PERCENTAGE_ROUNDED}%)\\n*Disk*:          ${CURRENT_DISK_USAGE} / ${TOTAL_DISK_SIZE} (${CURRENT_DISK_PERCENTAGE}%)")"

    # create payload for curl
    METRICS_PAYLOAD="chat_id=${METRICS_CHAT}&text=${METRICS_MESSAGE}&parse_mode=Markdown&disable_web_page_preview=true"

    # sent payload to Telegram and exit
    curl -s --max-time 10 --retry 5 --retry-delay 2 --retry-max-time 10 -d "${METRICS_PAYLOAD}" "${METRICS_URL}" > /dev/null 2>&1 &
    exit 0
fi

#############################################################################
# FUNCTION ALERT
#############################################################################

# method CLI
if [ "$ARGUMENT_ALERT" == "1" ] && [ "$ARGUMENT_CLI" == "1" ]; then

    # gather required server information and metrics
    gather_server_information
    gather_metrics

    # check whether the current server load exceeds the threshold and alert if true
    # and output server alert status to shell
    echo
    if [ "$CURRENT_LOAD_PERCENTAGE_ROUNDED" -ge "$THRESHOLD_LOAD_NUMBER" ]; then
        echo -e "[!] SERVER LOAD:\\tA current server load of ${CURRENT_LOAD_PERCENTAGE_ROUNDED}% exceeds the threshold of ${THRESHOLD_LOAD}."
    else
        echo -e "[i] SERVER LOAD:\\tA current server load of ${CURRENT_LOAD_PERCENTAGE_ROUNDED}% does not exceed the threshold of ${THRESHOLD_LOAD}."
    fi

    if [ "$CURRENT_MEMORY_PERCENTAGE_ROUNDED" -ge "$THRESHOLD_MEMORY_NUMBER" ]; then
        echo -e "[!] SERVER MEMORY:\\tA current memory usage of ${CURRENT_MEMORY_PERCENTAGE_ROUNDED}% exceeds the threshold of ${THRESHOLD_MEMORY}."
    else
        echo -e "[i] SERVER MEMORY:\\tA current memory usage of ${CURRENT_MEMORY_PERCENTAGE_ROUNDED}% does not exceed the threshold of ${THRESHOLD_MEMORY}."
    fi

    if [ "$CURRENT_DISK_PERCENTAGE" -ge "$THRESHOLD_DISK_NUMBER" ]; then
        echo -e "[!] DISK USAGE:\\t\\tA current disk usage of ${CURRENT_DISK_PERCENTAGE}% exceeds the threshold of ${THRESHOLD_DISK}."
    else
        echo -e "[i] DISK USAGE:\\t\\tA current disk usage of ${CURRENT_DISK_PERCENTAGE}% does not exceed the threshold of ${THRESHOLD_DISK}."
    fi
    # exit when done
    exit 0
fi

# Method Telegram
if [ "$ARGUMENT_ALERT" == "1" ] && [ "$ARGUMENT_TELEGRAM" == "1" ]; then

    # gather required server information and metrics
    gather_server_information
    gather_metrics

    # check whether the current server load exceeds the threshold and alert if true
    if [ "$CURRENT_LOAD_PERCENTAGE_ROUNDED" -ge "$THRESHOLD_LOAD_NUMBER" ]; then

        # create message for Telegram
        ALERT_MESSAGE_LOAD="\xE2\x9A\xA0 *ALERT: SERVER LOAD*\\n\\nThe server load (${CURRENT_LOAD_PERCENTAGE_ROUNDED}%) on *${HOSTNAME}* exceeds the threshold of ${THRESHOLD_LOAD}\\n\\n*Load average:*\\n${COMPLETE_LOAD}"

        # create payload for curl
        ALERT_PAYLOAD_LOAD="chat_id=${ALERT_CHAT}&text=$(echo -e "${ALERT_MESSAGE_LOAD}")&parse_mode=Markdown&disable_web_page_preview=true"

        # sent payload to Telegram
        curl -s --max-time 10 --retry 5 --retry-delay 2 --retry-max-time 10 -d "${ALERT_PAYLOAD_LOAD}" "${ALERT_URL}" > /dev/null 2>&1 &
    fi

    # check whether the current server memory usage exceeds the threshold and alert if true
    if [ "$CURRENT_MEMORY_PERCENTAGE_ROUNDED" -ge "$THRESHOLD_MEMORY_NUMBER" ]; then

        # create message for Telegram
        ALERT_MESSAGE_MEMORY="\xE2\x9A\xA0 *ALERT: SERVER MEMORY*\\n\\nMemory usage (${CURRENT_MEMORY_PERCENTAGE_ROUNDED}%) on *${HOSTNAME}* exceeds the threshold of ${THRESHOLD_MEMORY}\\n\\n*Memory usage:*\\n$(free -m -h)"

        # create payload for curl
        ALERT_PAYLOAD_MEMORY="chat_id=${ALERT_CHAT}&text=$(echo -e "${ALERT_MESSAGE_MEMORY}")&parse_mode=Markdown&disable_web_page_preview=true"

        # sent payload to Telegram
        curl -s --max-time 10 --retry 5 --retry-delay 2 --retry-max-time 10 -d "${ALERT_PAYLOAD_MEMORY}" "${ALERT_URL}" > /dev/null 2>&1 &
    fi

    # check whether the current disk usaged exceeds the threshold and alert if true
    if [ "$CURRENT_DISK_PERCENTAGE" -ge "$THRESHOLD_DISK_NUMBER" ]; then

        # create message for Telegram
        ALERT_MESSAGE_DISK="\xE2\x9A\xA0 *ALERT: FILE SYSTEM*\\n\\nDisk usage (${CURRENT_DISK_PERCENTAGE}%) on *${HOSTNAME}* exceeds the threshold of ${THRESHOLD_DISK}\\n\\n*Filesystem info:*\\n$(df -h)"

        # create payload for curl
        ALERT_PAYLOAD_DISK="chat_id=${ALERT_CHAT}&text=$(echo -e "${ALERT_MESSAGE_DISK}")&parse_mode=Markdown&disable_web_page_preview=true"

        # sent payload to Telegram
        curl -s --max-time 10 --retry 5 --retry-delay 2 --retry-max-time 10 -d "${ALERT_PAYLOAD_DISK}" "${ALERT_URL}" > /dev/null 2>&1 &
    fi
    exit 0
fi

#############################################################################
# FUNCTION UPDATES
#############################################################################

# method CLI
if [ "$ARGUMENT_UPDATES" == "1" ] && [ "$ARGUMENT_CLI" == "1" ]; then

    # gather required information about updates
    gather_updates

    # notify user when there are no updates
    if [ -z "$AVAILABLE_UPDATES" ]; then
        echo
        echo "There are no updates available."
        echo
        exit 0
    fi

    # notify user when there are updates available
    echo
    echo "The following updates are available:"
    echo
    echo "${AVAILABLE_UPDATES}"
    echo
    exit 0
fi

# method Telegram
if [ "$ARGUMENT_UPDATES" == "1" ] && [ "$ARGUMENT_TELEGRAM" == "1" ]; then

    # gather required information about updates and server
    gather_server_information
    gather_updates

    # create updates payload to sent to telegram API
    UPDATES_PAYLOAD="chat_id=${UPDATES_CHAT}&text=$(echo -e "${UPDATES_MESSAGE}")&parse_mode=Markdown&disable_web_page_preview=true"

    # sent updates payload to Telegram API
    curl -s --max-time 10 --retry 5 --retry-delay 2 --retry-max-time 10 -d "${UPDATES_PAYLOAD}" "${UPDATES_URL}" > /dev/null 2>&1 &

    # do nothing if there are no updates
    if [ -z "$AVAILABLE_UPDATES" ]; then
        exit 0
    else
        # if update list length is less than 4000 characters, then sent update list
        if [ "$LENGTH_UPDATES" -lt "4000" ]; then
            UPDATES_MESSAGE="There are updates available on *${HOSTNAME}*:\n\n${AVAILABLE_UPDATES}"
        fi

        # if update list length is greater than 4000 characters, don't sent update list
        if [ "$LENGTH_UPDATES" -gt "4000" ]; then
            UPDATES_MESSAGE="There are updates available on *${HOSTNAME}*. Unfortunately, the list with updates is too large for Telegram. Please update your server as soon as possible."
        fi

        # create updates payload to sent to telegram API
        UPDATES_PAYLOAD="chat_id=${UPDATES_CHAT}&text=$(echo -e "${UPDATES_MESSAGE}")&parse_mode=Markdown&disable_web_page_preview=true"

        # sent updates payload to Telegram API
        curl -s --max-time 10 --retry 5 --retry-delay 2 --retry-max-time 10 -d "${UPDATES_PAYLOAD}" "${UPDATES_URL}" > /dev/null 2>&1 &
    fi
    exit 0
fi

#############################################################################
# FUNCTION LOGIN
#############################################################################

# method CLI
if [ "$ARGUMENT_LOGIN" == "1" ] && [ "$ARGUMENT_CLI" == "1" ]; then
    echo "Oops! This function has not been implemented yet!"
    exit 0
fi

if [ "$ARGUMENT_LOGIN" == "1" ] && [ "$ARGUMENT_TELEGRAM" == "1" ]; then
    echo "Oops! This function has not been implemented yet!"
    exit 0
fi

#############################################################################
# FUNCTION OUTAGE
#############################################################################

# method CLI
if [ "$ARGUMENT_OUTAGE" == "1" ] && [ "$ARGUMENT_CLI" == "1" ]; then
    echo "Oops! This function has not been implemented yet!"
    exit 0
fi

if [ "$ARGUMENT_OUTAGE" == "1" ] && [ "$ARGUMENT_TELEGRAM" == "1" ]; then
    echo "Oops! This function has not been implemented yet!"
    exit 0
fi


