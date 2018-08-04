# TelegramBots
TelegramBots is a collection of scripts that work well with a default Telegram bot. As of now, there are four 'bots':

| Bot name | Description | Status |
| --- | --- | --- |
| TelegramMetricsBot | Sents metrics like load, ram and disk | Beta |
| TelegramUpdateBot | Notifies when an update is available | Alpha |
| TelegramAlertBot | Sents alerts with predefined thresholds | Beta |
| TelegramLoginBot | Notifies when someone logs in to the server | Experimental |

The bots are easily configurable from a single config file located in /etc/TelegramBots/TelegramBots.conf.

Some examples of messages:

![Examples](https://raw.githubusercontent.com/sveeke/jumble/master/TelegramBots/TelegramBots.png)

Since I mostly use Debian (with UK/US locale and bash), I created the bots without compatibilty with other operating systems in mind. They should also work on Debian derivatives like Ubuntu though.

# Requirements
* Telegram bot
* Debian with Bash and root access
* Aptitude (TelegramUpdateBot)
* bc (TelegramAlertBot)
* Curl (all bots)

# Installation
Installing the bots is really simple, just follow the below steps:

1. Install Telegram and add https://telegram.me/botfather.
2. Create a new bot with `/newbot` and save the authentication token.
3. Add the bot to the chat you want to use, and retreive the chat id from the [Telegram API](https://api.telegram.org/bot***AUTHENTICATION_TOKEN***/getUpdates).
4. Download and run `InstallTelegramBots.sh` as root and follow the instructions.

Or use this command: `bash <(wget -qO- https://raw.githubusercontent.com/sveeke/TelegramBots/master/InstallTelegramBots.sh)`.

Please note that the token and chat id you supply during the installation will be used for all bots. You can also use multiple Telegram bots and/or chats for these bot scripts, just add them to the top of `InstallTelegramBots.sh` (below `TELEGRAM VARIABLES`) then.

# Updating the bots
Updating is also really simple. Just run the newest `InstallTelegramBots.sh` and everything will be updated. The install script checks if a previous configuration is available and if so, ignores it. You can also enable automatic updates, but this is not recommended for obvious reasons.

# Future plans
I'm working on adding the following:

* TelegramLoginBot that notifies when someone logs in on the server.
* TelegramOutageBot that notifies when servers or websites are down.
* CentOS support.
