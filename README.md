# TelegramBots
TelegramBots is a collection of scripts that work well with a default Telegram bot. As of now, there are five 'bots':

| Bot name | Description | Status |
| --- | --- | --- |
| TelegramMetricsBot | Sents metrics like load, ram and disk | Beta |
| TelegramAlertBot | Sents alerts with predefined thresholds | Beta |
| TelegramUpdateBot | Notifies when an update is available | Alpha |
| TelegramLoginBot | Notifies when someone logs in to the server | Experimental |
| TelegramOutageBot | Alerts when something is down | Experimental |

The bots are easily configurable from a single config file located in `/etc/TelegramBots/TelegramBots.conf`. After making changes to this file, simply use `TelegramBotsGenerateConfig` to effectuate the changes. You can use `TelegramBotsUpgrade` to update all bots to the newest version.

# Compatibility
The scripts/bots will at least be made compatible with the following distro's:

* CentOS 7
* Debian 8 Jessie
* Debian 9 Stretch
* Debian 10 Buster
* Ubuntu 14.04 Trusty Tahr
* Ubuntu 16.04 Xenial Xerus
* Ubuntu 18.04 Bionic Beaver
* Ubuntu 18.10 Cosmic Cuttlefish

In the future, more distro's will be supported. As of now the state is as follows:

| Bots | CentOS 7 | Debian 8 | Debian 9 | Debian 10 | Ubuntu |
| --- | --- | --- | --- | --- | --- |
| TelegramMetricsBot | YES | YES | YES | NOT TESTED | NOT TESTED |
| TelegramUpdateBot | NO | YES | YES | NOT TESTED | NOT TESTED |
| TelegramLoginBot | NOT TESTED | NOT TESTED | NOT TESTED | NOT TESTED | NOT TESTED |
| TelegramAlertBot | NOT TESTED | YES | YES | NOT TESTED | NOT TESTED |
| TelegramOutageBot | NOT TESTED | NOT TESTED | NOT TESTED | NOT TESTED | NOT TESTED |

# Dependencies
The scripts/bots mostly use standard stuff like `cat`, `print` and `free`. In addition they also need `bash`, `curl`, `wget`, `bc`.

Some examples of messages:

![Examples](https://raw.githubusercontent.com/sveeke/jumble/master/TelegramBots/TelegramBots.png)

Since I mostly use Debian (with UK/US locale and bash), I created the bots without compatibilty with other operating systems in mind. They should also work on Debian derivatives like Ubuntu though.

# Requirements
* Telegram bot
* Debian with bash and root access
* Aptitude (TelegramUpdateBot)
* bc (TelegramAlertBot)
* curl (all bots)

# Installation
Installing the bots is really simple, just follow the below steps:

1. Install Telegram and add https://telegram.me/botfather.
2. Create a new bot with `/newbot` and save the authentication token.
3. Add the bot to the chat you want to use, and retreive the chat id from the [Telegram API](https://api.telegram.org/bot***AUTHENTICATION_TOKEN***/getUpdates).
4. Download and run `InstallTelegramBots.sh` as root and follow the instructions.

Or use this command: `bash <(wget -qO- https://raw.githubusercontent.com/sveeke/TelegramBots/master/InstallTelegramBots.sh)`.

Please note that the token and chat id you supply during the installation will be used for all bots. You can also use multiple Telegram bots and/or chats for these bot scripts, just add them to the top of `InstallTelegramBots.sh` (below `TELEGRAM VARIABLES`) then.

# Updating the bots
Updating is also really simple. Just run `TelegramBotsUpgrade` or download and run the newest `InstallTelegramBots.sh`. The install script checks if a previous configuration is available and if so, will use that. You can also enable automatic updates, but this is not recommended for obvious reasons.

# Future plans
I'm working on adding the following:

* TelegramLoginBot that notifies when someone logs in on the server.
* TelegramOutageBot that also checks TLS certificates, mailservers and other stuff
* CentOS support.
