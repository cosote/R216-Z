#!/bin/sh
### BEGIN INIT INFO
# Provides:          ppp_reconnect
# Required-Start:    $remote_fs $all
# Required-Stop: 
# Default-Start:     2 3 4 5
# Default-Stop:
# Short-Description: Connects network at boot for providers other than Vodafone
# Description:       Checks every 3 seconds on disconnected status and issues connect. Uses busybox nc.
### END INIT INFO

# Author: 2020-05-02 cosote@gmail.com

check_network_status() {
  RESULT=$(echo -ne "GET /goform/goform_get_cmd_process?cmd=ppp_status HTTP/1.0\r\nHost: 127.0.0.1\r\nReferer: http://127.0.0.1/home.htm\r\nContent-Type: application/x-www-form-urlencoded\r\n\r\n" | nc 127.0.0.1 80 | grep "ppp_disconnected")
  if [[ "$RESULT" = '{"ppp_status":"ppp_disconnected"}' ]]; then
    return 1
  else
    return 0
  fi
}

EPOCH=0

while [ 1 ]
do
   sleep 3
   
   # Check if system was rebooted or resumed from suspension
   if [[ $(($(date +%s) - $EPOCH)) -gt 5 ]]; then

      check_network_status
      if [[ $? -eq 1 ]]; then

         # Connect network
         # NOTE: Occasionally it may return "{"result":"success"}" but is not true!
         echo "Connecting..."
         BODY="goformId=CONNECT_NETWORK"
         RESULT=$(echo -ne "POST /goform/goform_set_cmd_process HTTP/1.0\r\nHost: 127.0.0.1\r\nReferer: http://127.0.0.1/home.htm\r\nContent-Type: application/x-www-form-urlencoded\r\nContent-Length: $(echo -n ${BODY} | wc -c)\r\n\r\n${BODY}" | nc 127.0.0.1 80)

         # So, Re-check network status
         check_network_status
         if [[ $? -eq 1 ]]; then
            EPOCH=0
            continue
         fi
     fi

   fi
   
   EPOCH=$(date +%s)
   
done
