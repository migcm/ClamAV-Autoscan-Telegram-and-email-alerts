# ClamAV Autoscan (Telegram and email alerts)

Daily virus and malware scan with [ClamAV](https://www.clamav.net/). This script will send notifications by Telegram and / or email when malware is detected. 

This script is designed and tested in Debian 9.

## Installation

* Install ClamAV and all its components:
```
sudo apt-get update && apt-get install clamav clamav-docs clamav-daemon clamav-freshclam
```
* Install different packages so that ClamAV can also analyze the compressed files:
```
sudo apt-get install arc arj bzip2 cabextract lzop nomarch p7zip pax tnef unrar-free unzip zoo
```
* Install the curl packages (to send notifications to Telegram) and cpulimit (so that the scan doesn't consume all the CPU):
```
sudo apt-get install curl cpulimit
```

## ClamAV configuration
* Edit the /etc/clamav/freshclam.conf file and modify the number of daily checks (replace 24 by 1):
```
sudo vi /etc/clamav/freshclam.conf
```
```
...
Checks 1
...
```
* Restart service:
```
sudo service clamav-freshclam restart
```

## Install and configure the script
* Insert the script "clam_scan.sh" in the /root directory.
* Edit the configuration variables (```sudo vi /root/clam_scan.sh```):
  * LOG_FILE: Name for the log files.
  * HOST_NAME: Name of the host.
  * CPU_LIMIT: Maximum percentage of CPU to be consumed by malware scanning.
  * MSG_SUBJECT: Subject of notifications when malware is detected.
  * MSG_INFO: Notification information when malware is detected. Some HTML tags (those allowed by Telegram) can be used.
  * EMAIL: If an email notification should be sent when detecting malware (true) or not (false).
  * EMAIL_FROM: Sender email address.
  * EMAIL_TO: Recipient email address.
  * TELEGRAM: If a malware notification should be sent to Telegram (true) or not (false).
  * TELEGRAM_TOKEN: Token of the Telegram bot to be able to notifications.
  * TELEGRAM_CHATID: Id of the Telegram chat to send the notifications to.
  * DIR_TO_SCAN: Directory/s to scan. Several can be indicated separated by a blank space.
  
* Give script permissions:
```
chmod 0755 /root/clam_scan.sh
```
* Create a cron to run the script at the time you want:
```
crontab -e
```
```
00 03 * * * root /root/clam_scan.sh
```

* To verify that the script works correctly, run:
```
/root/clam_scan.sh

```


## Contribution
Feel free to contribute!
