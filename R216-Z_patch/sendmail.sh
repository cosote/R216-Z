#!/bin/sh

source /etc/sendmail.conf
sendmail -f "$SMTP_FROM" -H "exec openssl s_client -quiet -tls1 -starttls smtp -connect $SMTP_SERVER -CAfile /etc/cacert.pem" -au"$SMTP_USER" -ap"$SMTP_PASS" "$SMTP_TO"<<~~!END!~~
Subject: $SUBJECT_PREFIX: $1

$2
~~!END!~~
