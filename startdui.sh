#!/bin/sh
# Enable mobile connection on device boot or resume from suspension
# Author: 2020-05-02 Jens Bornemann, jbornema@gmail.com

# start script in background to check every 3 Seconds and issue CONNECT_NETWORK
sh /etc/ppp_reconnect.sh &