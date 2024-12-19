#!/bin/sh
### BEGIN INIT INFO
# Provides:          ppp_reconnect
# Required-Start:    $remote_fs $all
# Required-Stop: 
# Default-Start:     2 3 4 5
# Default-Stop:
# Short-Description: Connects network at boot for providers other than Vodafone
# Description:       Check connection and connects or reboots device. Uses busybox nc.
### END INIT INFO

# Author: 2020-05-02 cosote@gmail.com
# Update: 2024-12-06 Added smart reboot on internet loss

# Primary check, if internet is accessible
MYIP_SITE=http://icanhazip.com
# Alternative check, if internet is accessible
ALT_SITE=http://www.google.com
# Sleep inside loop
LOOP_SLEEP_SEC=5
# Additional check, that mobile connection is established
CONNECT_CHECK_SEC=120 # 2 Minutes
# Additional check, that internet is accessible
INTERNET_CHECK_SEC=300 # 5 Minutes
INTERNET_LONG_CHECK_SEC=1200 # 20 Minutes
INTERNET_ERROR_REBOOT_AT=3 # Reboot at 3 internet errors
# When device rebooted and cannot connect to internet, it will automatically reboot at
# $INTERNET_CHECK_SEC + $INTERNET_LONG_CHECK_SEC * ($INTERNET_ERROR_REBOOT_AT - 1), so approx. 45 Minutes
# When a internet connection had been established and stopped, it will reboot within 15 Minutes
HAD_ONCE_INTERNET=-1 # -1 for unknown, 0 for never had internet, 1 for internet access existed
HAS_INTERNET=0
CONNECTED=0
# SMS check
SMS_CHECK_SEC=15

NOW=$(date +%s)

LAST_CYCLE=0
LAST_CONNECT_CHECK=0
LAST_INTERNET_CHECK=$NOW
LAST_SMS_CHECK=$NOW
LAST_IP_ADDRESS=
INTERNET_ERROR=0
REBOOT_CHECK_SEC=$(($LOOP_SLEEP_SEC + 1))
SEND_UPDATES=

HOST="127.0.0.1"
H_HOST="Host: $HOST"
H_REFERER="Referer: http://$HOST/home.htm"
H_CONTENTTYPE="Content-Type: application/x-www-form-urlencoded"

check_network_status() {
  RESULT=$( echo -ne "GET /goform/goform_get_cmd_process?cmd=ppp_status HTTP/1.0\n$H_HOST\n$H_REFERER\n$H_CONTENTTYPE\n\n" | nc $HOST 80 | grep -o "{.*}" )
  echo $NOW: $RESULT
  if [[ "$RESULT" = '{"ppp_status":"ppp_disconnected"}' ]]; then
    return 1
  else
    return 0
  fi
}

send_update() {
  if [[ -f /etc/sendmail.sh ]] && [[ -f /etc/sendmail.conf ]]; then
    if [[ $CONNECTED -eq 1 ]]; then
      sh /etc/sendmail.sh "R216-Z: $1"
      if [[ $? -ne 0 ]]; then
        SEND_UPDATES="$SEND_UPDATES|$1"
      fi
    else
      SEND_UPDATES="$SEND_UPDATES|$1"
    fi
  fi
}

msg="$NOW: Running $0"
echo $msg
send_update "$msg"

while [ 1 ]
do
  sleep $LOOP_SLEEP_SEC

  # Check if system was rebooted or resumed from suspension or every 2 Minutes, that connection is established
  NOW=$(date +%s)
  if [[ $(($NOW - $LAST_CYCLE)) -gt $REBOOT_CHECK_SEC ]] || [[ $(($NOW - $LAST_CONNECT_CHECK)) -gt $CONNECT_CHECK_SEC ]]; then
    # Check network
    NOT_CONNECTED_ADJUST_TIME=0
    if ! check_network_status; then
      CONNECTED=0
      # Connect network
      # NOTE: Occasionally it may return "{"result":"success"}" but is not true!
      BODY="goformId=CONNECT_NETWORK"
      RESULT=$( echo -ne "POST /goform/goform_set_cmd_process HTTP/1.0\n$H_HOST\n$H_REFERER\n$H_CONTENTTYPE\nContent-Length: ${#BODY}\n\n${BODY}" | nc $HOST 80 | grep -o "{.*}" )
      msg="$NOW: Connect command result: $RESULT"
      echo $msg
      send_update "$msg"
      # So, Re-check network status
      if check_network_status; then
        CONNECTED=1
      else
        CONNECTED=0
        # check again on next cycle
        NOT_CONNECTED_ADJUST_TIME=$(($CONNECT_CHECK_SEC - 1))
      fi
    else
      CONNECTED=1
    fi
    LAST_CONNECT_CHECK=$(($NOW - $NOT_CONNECTED_ADJUST_TIME))
  fi

  # check internet and reboot if failing multiple times
  if ([[ $(($NOW - $LAST_INTERNET_CHECK)) -gt $INTERNET_CHECK_SEC ]] && [[ $HAD_ONCE_INTERNET -ne 0 ]]) || ([[ $(($NOW - $LAST_INTERNET_CHECK)) -gt $INTERNET_LONG_CHECK_SEC ]] && [[ $HAD_ONCE_INTERNET -eq 0 ]]); then
    HAS_INTERNET=0
    if [[ $HAD_ONCE_INTERNET -lt 0 ]]; then HAD_ONCE_INTERNET=0; fi
    MY_IP=$(wget -q -T 5 -O - $MYIP_SITE 2>/dev/null)
    LAST_INTERNET_CHECK=$NOW
    if [[ ${#MY_IP} -eq 0 ]]; then
      msg="$NOW: My ip address not available using $MYIP_SITE"
      echo $msg
      send_update "$msg"
      # no IP received, check google.com
      TEST_INTERNET=$(wget -q -T 5 -O - $ALT_SITE 2>/dev/null)
      if [[ ${#TEST_INTERNET} -eq 0 ]]; then
        INTERNET_ERROR=$((INTERNET_ERROR + 1))
        echo $NOW: Internet connection error count: $INTERNET_ERROR
      else
        echo $NOW: Internet verified using $ALT_SITE
        INTERNET_ERROR=0
        HAD_ONCE_INTERNET=1
        HAS_INTERNET=1
      fi
    else
      echo $NOW: My ip address: $MY_IP
      INTERNET_ERROR=0
      HAD_ONCE_INTERNET=1
      HAS_INTERNET=1
      if ! [[ "$LAST_IP_ADDRESS" = "$MY_IP" ]]; then
        send_update "$NOW: New IP address assigned: $MY_IP"
      fi
      LAST_IP_ADDRESS=$MY_IP
    fi
    if [[ $INTERNET_ERROR -ge $INTERNET_ERROR_REBOOT_AT ]]; then
      # reboot system
      INTERNET_ERROR=0
      HAS_INTERNET=0
      msg="$NOW: Rebooting system..."
      echo $msg
      send_update "$msg"
      reboot
    fi
  fi
  
  if [[ $HAS_INTERNET -eq 1 ]] && [[ $(($NOW - $LAST_SMS_CHECK)) -gt $SMS_CHECK_SEC ]] && [[ -f /etc/sms_email_forward.sh ]] && [[ -f /etc/sendmail.conf ]]; then
    sh /etc/sms_email_forward.sh
    LAST_SMS_CHECK=$NOW
  fi

  # check sending updates
  updates="$SEND_UPDATES"
  SEND_UPDATES=
  OIFS="$IFS"
  IFS='|'
  for msg in $updates; do
    if ! [[ -z "$msg" ]]; then
      send_update "$msg"
    fi
  done
  IFS="$OFS"
  
  LAST_CYCLE=$NOW

done
