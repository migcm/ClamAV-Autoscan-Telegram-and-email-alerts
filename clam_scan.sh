#!/bin/bash

LOG_FILE="/var/log/clamav/clamav-$(date +'%Y-%m-%d').log";

HOST_NAME="host1"
CPU_LIMIT=10

MSG_SUBJECT="** PROBLEM - Malware found on --HOST-- **"
MSG_INFO="<b>The daily scan on --HOST-- has detected malware. Please check the attached log snippet.</b>"

EMAIL="true"
EMAIL_FROM="daily@clamav.com";
EMAIL_TO="me@clamav.com";

TELEGRAM="false"
TELEGRAM_TOKEN="xxxx"
TELEGRAM_CHATID="xxxx"


DIR_TO_SCAN="/";


REQUIRED_PACKAGES='clamav clamav-docs clamav-daemon clamav-freshclam arc arj bzip2 cabextract lzop nomarch p7zip pax tnef unrar-free unzip zoo curl sendmail cpulimit'             
if ! dpkg -s $REQUIRED_PACKAGES >/dev/null 2>&1; then
        echo "Before running this script, install the following packages: $REQUIRED_PACKAGES"
        exit 0
fi


for S in ${DIR_TO_SCAN}; do
 	DIRSIZE=$(du -sh "$S" 2>/dev/null | cut -f1);

 	echo "Starting a daily scan of "$S" directory. Amount of data to be scanned is "$DIRSIZE".";

 	cpulimit -z --exe clamscan -l "$CPU_LIMIT" & clamscan -ri --exclude-dir="^/sys" "$S" >> "$LOG_FILE";

 	# get the value of "Infected lines"
 	MALWARE=$(tail "$LOG_FILE"|grep Infected|cut -d" " -f3);

 	# if the value is not equal to zero, send an telegram message with the log file attached
 	if [ "$MALWARE" != "0" ];then


		MSG_SUBJECT=$(echo "${MSG_SUBJECT/--HOST--/$HOST_NAME}")
        MSG_INFO_ORIGINAL=$(echo "${MSG_INFO/--HOST--/$HOST_NAME}")

        if [ "$TELEGRAM" == "true" ]; then

			MSG_INFO="$MSG_INFO_ORIGINAL%0a%0a<code>$(tail $LOG_FILE)</code>"
            CURL=`curl -s -X POST https://api.telegram.org/bot"$TELEGRAM_TOKEN"/sendMessage -d chat_id="$TELEGRAM_CHATID" -d parse_mode=HTML -d text="$MSG_INFO"`

		fi

		if [ "$EMAIL" == "true" ]; then

			MSG_INFO="$MSG_INFO_ORIGINAL<br><br><code>$(tail $LOG_FILE | sed 's/$/<br>/')</code>"
            echo "$MSG_INFO" | mail -a "Content-type: text/html;" -s "$MSG_SUBJECT" -r "$EMAIL_FROM" "$EMAIL_TO"

        fi

	fi
done


exit 0
