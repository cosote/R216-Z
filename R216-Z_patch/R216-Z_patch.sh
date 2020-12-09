#!/bin/sh
# Conversion of R216-Z_patch BATCH to BASH
# Author: 2020-11-06 umbertofilippo@tiscali.it
export ADB=./adb
export CURL=./curl
export PATH=$ADB:$CURL:$PATH

BASE_DIR="$(cd "$(dirname "$0")" || return; pwd)";

end () {
    printf "\n"
    read -r REPLY
}

patch_end () {
    printf "\n"
    printf "Info:\n"
    printf "Run command: %s remove\n" "$0"
    printf "to remove patch from R216-Z again.\n"
    end
}

continue_patch () {
    adb push "$BASE_DIR"/startdui.sh /usr/ui/
    adb push "$BASE_DIR"/ppp_reconnect.sh /etc/
    printf "\n"
    printf "Done. Please reboot R216-Z.\n"
    printf "Do you want to reboot the R216-Z (y/n)? \n"
    read -r answer
    if [ "$answer" != "${answer#[Yy]}" ]
    then
        printf "Rebooting R216-Z...\n"
        adb shell reboot
    else
        patch_end
    fi
}

cannot_patch () {
    printf "Error: Cannot create directory!\n"
    printf "Patch is already installed or system files exist and might be overwritten.\n"
    printf "Do you want to continue (y/n)? \n"
    read -r answer
    if [ "$answer" != "${answer#[Yy]}" ]
    then
        continue_patch
    else
        end
    fi
}

cannot_connect () {
   printf "Error: Cannot connect to R216-Z!\n"
   end
}

remove () {
    printf "\n"
    printf "Remove patch from R216-Z...\n"
    adb shell rm /usr/ui/startdui.sh
    adb shell rm /etc/ppp_reconnect.sh
    adb shell rmdir /usr/ui/
    adb shell pkill -f "sh /etc/ppp_reconnect.sh"
    printf "\n"
    printf "Done.\n"
    end
}

printf "Verify login with password admin on R216-Z...\n"
curl -e "http://192.168.0.1/home.htm" -d "goformId=LOGIN" -d "password=YWRtaW4=" "http://192.168.0.1/goform/goform_set_cmd_process"
printf "\n"
if [ $? -eq 1 ]
then
    cannot_connect
fi
printf "\n"
printf "Login with password admin on R216-Z...\n"
curl -c cookies.txt -e "http://192.168.0.1/home.htm" -d "goformId=LOGIN_EXCLUSIVE" -d "password=YWRtaW4=" "http://192.168.0.1/goform/goform_set_cmd_process"
printf "\n"
if [ $? -eq 1 ]
then
    cannot_connect
fi
printf "\n"
printf "Enable ADB connection on R216-Z...\n"
curl -b cookies.txt -e "http://192.168.0.1/home.htm" -d "goformId=USB_MODE_SWITCH" -d "usb_mode=6" "http://192.168.0.1/goform/goform_set_cmd_process"
printf "\n"
if [ $? -eq 1 ]
then
    cannot_connect
fi
printf "\n"
printf "Wait for R216-Z...\n"
adb wait-for-device
if [ "$1" = "remove" ]
then
    remove
fi
printf "\n"
printf "Push patch to R216-Z...\n"
# continue from
#for /f "tokens=*" %%a in ('%adb% shell mkdir /usr/ui/^|find /i "File exists"') do (
#	if not errorlevel 1 goto :cannot_patch
#)
if adb shell mkdir /usr/ui/ | grep "File exists"
then
    cannot_patch
else
    continue_patch
fi