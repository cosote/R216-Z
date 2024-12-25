#!/bin/sh
# Enable mobile connection on device boot or resume from suspension
# Author: 2020-05-02 cosote@gmail.com

# start script in background to check on CONNECT_NETWORK
sh /etc/ppp_reconnect.sh &
#sh /etc/ppp_reconnect.sh >> /var/log/ppp_reconnect.log 2>&1 &