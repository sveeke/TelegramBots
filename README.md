# TelegramBots
Telegrambot is a multi-function script that work really well together with Telegram bots. As of now, telegrambot is under heavy development and therefore instable. It shouldn't be used for any production system.

There are four different functions:

| Function | Description |
| --- | --- |
| Metrics | Sents metrics like load, ram and disk |
| Alert | Sents alerts after exceeding predefined thresholds |
| Updates | Notifies when a update is available |
| Outage | Alerts when something is down |

telegrambot can be invoked from the command line, or can be configured to use cron. telegrambot and its cron settings are easily configurable from a single config file located in `/etc/telegrambot/telegrambot.conf`. After making changes to this file, simply run `telegrambot --config` to effectuate the changes. You can use `telegrambot --upgrade` to update telegrambot to the newest version.

# How to use?
That's actually quite easy. Just run the telegrambot with the function and the desired method. As of now there are two supported methods: cli and telegram.

Use `telegrambot --help` for some help to get you on your way:
```
root@server:~# telegrambot --help

Usage:
 telegrambot [function/option]... [method]...

Functions:
 -m, --metrics         Show server metrics
 -a, --alert           Show server alert status
 -u, --updates         Show available server updates
 -o, --outage          Check list for outage

Methods:
 -c, --cli             Output [option] to command line
 -t, --telegram        Output [option] to Telegram bot

Options:
 --config     effectuate changes from telegrambot config
 --upgrade    upgrade telegrambot to the newest version
 --help       display this help and exit
 --version    display version information and exit
```

# Examples
## Metrics on CLI
```
root@server:~# telegrambot --metrics --cli

HOST:     server.domain.tld
UPTIME:   up 3 weeks, 1 day, 1 hour, 20 minutes
LOAD:     0.19 0.07 0.03
MEMORY:   130M / 2004M (6%)
DISK:     2.4G / 40G (7%)
```
## Metrics on Telegram
`root@server:~# telegrambot --metrics --telegram`
(screenshot will follow)

## Alert on CLI
```
root@server:~# telegrambot --alert --cli

[i] SERVER LOAD:        A current server load of 23% does not exceed the threshold of 90%.
[!] SERVER MEMORY:      A current memory usage of 93% exceeds the threshold of 90%.
[!] DISK USAGE:         A current disk usage of 89% exceeds the threshold of 80%.
```
## Alert on Telegram
`root@server:~# telegrambot --alert --telegram`
(screenshot will follow)

# Compatibility
telegrambot will at least be tested and compatible with the following distro's:

* CentOS 7
* CentOS 8
* Fedora 27
* Fedora 28
* Fedora 29
* Debian 8 Jessie
* Debian 9 Stretch
* Debian 10 Buster
* Ubuntu 14.04 Trusty Tahr
* Ubuntu 16.04 Xenial Xerus
* Ubuntu 18.04 Bionic Beaver
* Ubuntu 18.10 Cosmic Cuttlefish

CentOS 6/Debian 7/Ubuntu 12.04 and below are not compatible due to their old linux core utilities. In the future, more distro's will probably be supported. As of now the functionality state is as follows:

| Bots | Fedora 27-28 | CentOS 7 | Debian 8-10 | Ubuntu 14.04-18.10 |
| --- | --- | --- | --- | --- |
| Metrics | BETA | BETA | BETA | BETA |
| Alert | ALPHA | ALPHA | BETA | ALPHA |
| Updates | ALPHA | ALPHA | BETA | BETA |
| Outage | ALPHA | ALPHA | ALPHA | ALPHA |

The first stable release (version 1.0) will probably be somewhere in september 2018. [Semantic Versioning 2.0.0](https://semver.org/) is being used for versioning this project.

# Installation
## Dependencies
telegrambot mostly uses standard stuff like `cat`, `print`, `awk` and `free`. In addition it also needs `bash`, `curl`, `wget`, `bc`.

## Downloading and installing
Installing telegrambot is really simple, just follow the below steps:

1. Install Telegram and add https://telegram.me/botfather.
2. Create a new bot with `/newbot` and save the authentication token.
3. Add the bot to the chat you want to use, and retreive the chat id from the [Telegram API](https://api.telegram.org/bot***AUTHENTICATION_TOKEN***/getUpdates).
4. Download and run `install_telegrambot.sh` as root and follow the instructions.

Or use this command: `bash <(wget -qO- https://raw.githubusercontent.com/sveeke/TelegramBots/master/install_telegrambot.sh)`.

Please note that the default setting is that the token and chat id you supply during the installation will be used for all functions. You can also use different tokens and chat id combinations for each individual function. This can be handy if you need a dedicated chat that doesn't get silenced at night for alert emergencies. Just add the individual combinations to the top of `install_telegramBots.sh` (below `TELEGRAM VARIABLES`).

# Upgrading telegrambot
Just run `telegrambot --upgrade` or download and run the newest `install_telegrambot.sh`. The install script checks if a previous configuration is available and if so, will use that. You can also enable automatic updates, but this is not recommended for obvious reasons.

# Future plans
I'm working on adding the following:

* Login function that notifies when someone logs in to the server.
* Adding more functionality to the Outage function so that is also checks TLS certificates, mailservers and other stuff
* Full Fedora, CentOS 7 and Ubuntu support.