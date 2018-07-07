# TelegramBots
TelegramBots is a collection of scripts that work well with a default Telegram bot. As of now, there are three 'bots':

| Bot name | Description | Status |
| --- | --- | --- |
| TelegramMetricsBot | Sents daily metrics like load, ram and disk | Beta |
| TelegramUpdateBot | Notifies when an update is available | Experimental |
| TelegramLoginBot | Notifies when someone logs in to the server | Experimental |

Since I mostly use Debian (with UK/US locale and bash), I created the bots without compatibilty with other operating systems in mind. They should also work on Debian derivatives like Ubuntu.

# Requirements
* Telegram bot
* Debian with root access
* Aptitude
* Curl

# Installation
Installing the bots is really simple, just run `install_telegrambots.sh` as root.

