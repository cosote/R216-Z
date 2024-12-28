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
WAS_CONNECTED=0
# SMS check
SMS_CHECK_SEC=15

NOW=$(date +%s)

LAST_CYCLE=0
LAST_CONNECT_CHECK=0
NOT_CONNECTED_ADJUST_TIME=0
LAST_INTERNET_CHECK=$NOW
LAST_SMS_CHECK=$NOW
LAST_IP_ADDRESS=
INTERNET_ERROR=0
RESUME_CHECK_SEC=$(($LOOP_SLEEP_SEC + 60))
SEND_UPDATES=
IPTABLES=0 # Enable local SSH at 3rd cycle, set to 3 to disable SSH enablement

HOST="127.0.0.1"
H_HOST="Host: $HOST"
H_REFERER="Referer: http://$HOST/home.htm"
H_CONTENTTYPE="Content-Type: application/x-www-form-urlencoded"

queue_send_update() {
  SEND_UPDATES="$SEND_UPDATES|$1"
}

send_update() {
  if [[ -f /etc/sendmail.sh ]] && [[ -f /etc/sendmail.conf ]]; then
    if [[ $HAS_INTERNET -eq 1 ]]; then
      sh /etc/sendmail.sh "$1" "$2"
      return $?
    else
      return 1
    fi
  fi
}

check_network_status() {
  RESULT=$( echo -ne "GET /goform/goform_get_cmd_process?cmd=ppp_status HTTP/1.0\n$H_HOST\n$H_REFERER\n$H_CONTENTTYPE\n\n" | nc $HOST 80 | grep -o "{.*}" )
  echo "$RESULT" | sed -n 's/{"ppp_status":"ppp_\(.*\)"}/\1/p'
  #msg="$NOW: $RESULT"
  #echo $msg
  #if [[ $(echo "$RESULT" | grep '{"ppp_status":".*_connected"}') ]]; then
  #  return 0
  #else
  #  return 1
  #fi
}

msg="$(date +%s): Running $0"
echo $msg
queue_send_update "$msg"

while [ 1 ]
do
  sleep $LOOP_SLEEP_SEC

  # Check if system was rebooted or resumed from sleep or every 2 Minutes, that connection is established
  NOW=$(date +%s)
  if [[ $(($NOW - $LAST_CYCLE)) -gt $RESUME_CHECK_SEC ]] || [[ $(($NOW - $LAST_CONNECT_CHECK)) -gt $CONNECT_CHECK_SEC ]]; then
    if [[ $(($NOW - $LAST_CYCLE)) -gt $RESUME_CHECK_SEC ]] && [[ $LAST_CYCLE -gt 0 ]]; then
      # device was resumed, adjust some variables for early notifications
      msg="$(date +%s): Device resumed"
      echo $msg
      queue_send_update "$msg"
      CONNECTED=0
      LAST_INTERNET_CHECK=$NOW
    fi
    # Check network
    NOT_CONNECTED_ADJUST_TIME=0
    WAS_CONNECTED=$CONNECTED
    PPP_STATUS=$(check_network_status)
    if [[ "$PPP_STATUS" != "connected" ]]; then
      CONNECTED=0
      # Connect network
      # NOTE: Occasionally it may return "{"result":"success"}" but is not true!
      BODY="goformId=CONNECT_NETWORK"
      RESULT=$( echo -ne "POST /goform/goform_set_cmd_process HTTP/1.0\n$H_HOST\n$H_REFERER\n$H_CONTENTTYPE\nContent-Length: ${#BODY}\n\n${BODY}" | nc $HOST 80 | grep -o "{.*}" )
      msg="$(date +%s): PPP status is $PPP_STATUS, reconnecting..."
      echo $msg
      queue_send_update "$msg"
      sleep 3
      # So, Re-check network status
      PPP_STATUS=$(check_network_status)
      if [[ "$PPP_STATUS" == "connected" ]]; then
        CONNECTED=1
      else
        CONNECTED=0
        # check again on next cycle
        NOT_CONNECTED_ADJUST_TIME=$(($CONNECT_CHECK_SEC - 1))
      fi
      msg="$(date +%s): PPP status is $PPP_STATUS"
      echo $msg
      queue_send_update "$msg"
    else
      CONNECTED=1
    fi
    LAST_CONNECT_CHECK=1
  fi

  # check internet and reboot if failing multiple times
  NOW=$(date +%s)
  if [[ $CONNECTED -gt $WAS_CONNECTED ]] || ([[ $(($NOW - $LAST_INTERNET_CHECK)) -gt $INTERNET_CHECK_SEC ]] && [[ $HAD_ONCE_INTERNET -ne 0 ]]) || ([[ $(($NOW - $LAST_INTERNET_CHECK)) -gt $INTERNET_LONG_CHECK_SEC ]] && [[ $HAD_ONCE_INTERNET -eq 0 ]]); then
    WAS_CONNECTED=$CONNECTED
    HAS_INTERNET=0
    if [[ $HAD_ONCE_INTERNET -lt 0 ]]; then HAD_ONCE_INTERNET=0; fi
    MY_IP=$(wget -q -T 5 -O - $MYIP_SITE 2>/dev/null)
    LAST_INTERNET_CHECK=1
    if [[ ${#MY_IP} -eq 0 ]]; then
      msg="$(date +%s): My ip address not available using $MYIP_SITE"
      echo $msg
      queue_send_update "$msg"
      # no IP received, check google.com
      TEST_INTERNET=$(wget -q -T 5 -O - $ALT_SITE 2>/dev/null)
      if [[ ${#TEST_INTERNET} -eq 0 ]]; then
        INTERNET_ERROR=$((INTERNET_ERROR + 1))
        echo "$(date +%s): Internet connection error count: $INTERNET_ERROR"
      else
        echo "$(date +%s): Internet verified using $ALT_SITE"
        MY_IP=$(wget -q -T 5 -O - $MYIP_SITE 2>/dev/null)
        INTERNET_ERROR=0
        HAD_ONCE_INTERNET=1
        HAS_INTERNET=1
      fi
    fi
    if [[ ${#MY_IP} -gt 0 ]]; then
      echo "$(date +%s): My ip address: $MY_IP"
      INTERNET_ERROR=0
      HAD_ONCE_INTERNET=1
      HAS_INTERNET=1
      if ! [[ "$LAST_IP_ADDRESS" = "$MY_IP" ]]; then
        queue_send_update "$(date +%s): New IP address assigned: $MY_IP"
      fi
      LAST_IP_ADDRESS=$MY_IP
    fi
    if [[ $INTERNET_ERROR -ge $INTERNET_ERROR_REBOOT_AT ]]; then
      # reboot system
      INTERNET_ERROR=0
      HAS_INTERNET=0
      msg="$(date +%s): Rebooting system..."
      echo $msg
      reboot
      exit
    fi
  fi
  
  NOW=$(date +%s)
  if [[ $HAS_INTERNET -eq 1 ]] && [[ $(($NOW - $LAST_SMS_CHECK)) -gt $SMS_CHECK_SEC ]] && [[ -f /etc/sms_email_forward.sh ]] && [[ -f /etc/sendmail.conf ]]; then
    sh /etc/sms_email_forward.sh
    LAST_SMS_CHECK=1
  fi

  # check sending updates
  updates="$SEND_UPDATES"
  SEND_UPDATES=
  OIFS="$IFS"
  IFS='|'
  BODY=
  I=0
  for msg in $updates; do
    if ! [[ -z "$msg" ]]; then
      I=$((I + 1))
      if [[ $I -gt 1 ]]; then
        BODY="$BODY"$'\n'"$msg"
        LAST_MSG="$msg"
      else
        BODY="$msg"
      fi
    fi
  done
  if [[ $I -gt 0 ]]; then
    if [[ $I -eq 1 ]]; then
      if ! send_update "$BODY" "$BODY"; then
        SEND_UPDATES="$updates"
      fi
    else
      if ! send_update "$LAST_MSG" "$BODY"; then
        SEND_UPDATES="$updates"
      fi
    fi
  fi
  IFS="$OFS"

  if [[ $IPTABLES -lt 3 ]]; then
    IPTABLES=$(($IPTABLES + 1))
    if [[ $IPTABLES -ge 3 ]]; then
      iptables -D INPUT -p tcp --dport 22 -j DROP
      iptables -D INPUT -p udp --dport 22 -j DROP
    fi
  fi
  
  # handle timeouts
  NOW=$(date +%s)
  if [[ $LAST_CONNECT_CHECK -eq 1 ]]; then
    LAST_CONNECT_CHECK=$(($NOW - $NOT_CONNECTED_ADJUST_TIME))
  fi
  if [[ $LAST_INTERNET_CHECK -eq 1 ]]; then
    LAST_INTERNET_CHECK=$NOW
  fi
  if [[ $LAST_SMS_CHECK -eq 1 ]]; then
    LAST_SMS_CHECK=$NOW
  fi
  LAST_CYCLE=$NOW

done
