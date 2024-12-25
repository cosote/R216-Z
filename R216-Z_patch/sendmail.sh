#!/bin/sh

source /etc/sendmail.conf
echo "Sending email to $SMTP_TO, subject='$SUBJECT_PREFIX: $1', body='$2'"
sendmail -f "$SMTP_FROM" -H "exec openssl s_client -quiet -tls1 -starttls smtp -connect $SMTP_SERVER -CAfile /etc/cacert.pem" -au"$SMTP_USER" -ap"$SMTP_PASS" "$SMTP_TO"<<~~!END!~~
Subject: $SUBJECT_PREFIX: $1

$2
~~!END!~~
