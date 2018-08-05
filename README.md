# TelegramBots
TelegramBots is a collection of scripts that work well with a default Telegram bot. As of now, there are four bots:

| Bot name | Description | Status |
| --- | --- | --- |
| TelegramMetricsBot | Sents metrics like load, ram and disk | Beta |
| TelegramAlertBot | Sents alerts with predefined thresholds | Beta |
| TelegramUpdateBot | Notifies when an update is available | Alpha |
| TelegramOutageBot | Alerts when something is down | Experimental |

The bots are easily configurable from a single config file located in `/etc/TelegramBots/TelegramBots.conf`. After making changes to this file, simply use `TelegramBotsGenerateConfig` to effectuate the changes. You can use `TelegramBotsUpgrade` to update all bots to the newest version.

# Compatibility
The scripts/bots will at least be tested and compatible with the following distro's:

* CentOS 7
* Fedora 27
* Fedora 28
* Debian 8 Jessie
* Debian 9 Stretch
* Debian 10 Buster
* Ubuntu 14.04 Trusty Tahr
* Ubuntu 16.04 Xenial Xerus
* Ubuntu 18.04 Bionic Beaver
* Ubuntu 18.10 Cosmic Cuttlefish

CentOS 6/Debian 7/Ubuntu 12.04 and below are not compatible due to their old linux core utilities. In the future, more distro's will probably be supported. As of now the state is as follows:

| Bots | Fedora 27-28 | CentOS 7 | Debian 8-10 | Ubuntu 14.04-18.10 |
| --- | --- | --- | --- | --- |
| TelegramMetricsBot | YES | YES | YES | YES |
| TelegramUpdateBot | YES | YES | YES | YES |
| TelegramAlertBot | YES | YES | YES | YES |
| TelegramOutageBot | YES | YES | YES | YES |

# Dependencies
The scripts/bots mostly use standard stuff like `cat`, `print` and `free`. In addition they also need `bash`, `curl`, `wget`, `bc`.

# Examples
Some examples of messages:

![Examples](https://raw.githubusercontent.com/sveeke/jumble/master/TelegramBots/TelegramBots.png)

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
* Full Fedora, CentOS 7 and Ubuntu support.
* Also show the percentage of memory usage in the TelegramMetricsBot.
* Maybe merge the bots in to one? Would be less clear for people that want to read the code, but can be more user friendly (less different bots, more arguments to one bot).
* 