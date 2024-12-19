#!/bin/sh

source /etc/sendmail.conf
sendmail -f "$SMTP_FROM" -H "exec openssl s_client -quiet -tls1 -starttls smtp -connect $SMTP_SERVER -CAfile /etc/cacert.pem" -au"$SMTP_USER" -ap"$SMTP_PASS" "$RECIPIENT"<<EOF
Subject: $1

$2
EOF