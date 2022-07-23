#!/bin/bash

system_name="$SYSTEM_NAME"
mail_recipient="$MAIL_RECIPIENTS"
scan_dir="/source/"
scan_result="/tmp/scan-result.log"
config_file="$CONFIG_FILE"

echo "TCPSocket $REMOTE_PORT
TCPAddr $REMOTE_ADDRESS" > /tmp/clamd.remote.conf

notify_admins() {
    recipients="$1"
    subject="$2"
    body="$3"
    echo "sending mail to $recipients"
    echo "subject: $subject"
    echo "body: $body"

    if [ -z "$MAILGUN_DOMAIN" ]
    then
        echo "no mailgun config set! no email notification sent"
    else
        /usr/bin/curl -v -s --user "api:$MAILGUN_API_KEY" \
        "https://api.mailgun.net/v3/$MAILGUN_DOMAIN/messages" \
        -F from="malware-scanner+$SYSTEM_NAME@$MAILGUN_DOMAIN" \
        -F to="$recipients" \
        -F subject="$subject" \
        -F text="$body"
    fi
}

echo "starting scan..."

if [ -s "$config_file" ]
then
    /usr/bin/clamdscan -c /tmp/clamd.remote.conf -i -r "$scan_dir" --config-file="$config_file" | grep 'FOUND' > "$scan_result"
else
    /usr/bin/clamdscan -c /tmp/clamd.remote.conf -i -r "$scan_dir" | grep 'FOUND' > "$scan_result"
fi

if [ -s "$scan_result" ]
then
   echo "Malware Found!"

   scan_result_string=`cat "$scan_result"`

   notify_admins "$mail_recipient" "[$system_name] Malware found. Please take action immediately" "$scan_result_string"

   cat "$scan_result"
fi

echo "Done"