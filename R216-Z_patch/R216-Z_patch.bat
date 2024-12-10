@echo off
set adb=adb\adb.exe
set curl=curl\curl.exe

echo Verify login with password admin on R216-Z...
%curl% -e "http://192.168.0.1/home.htm" -d "goformId=LOGIN" -d "password=YWRtaW4=" "http://192.168.0.1/goform/goform_set_cmd_process"
if errorlevel 1 goto :cannot_connect

echo.
echo Login with password admin on R216-Z...
%curl% -c cookies.txt -e "http://192.168.0.1/home.htm" -d "goformId=LOGIN_EXCLUSIVE" -d "password=YWRtaW4=" "http://192.168.0.1/goform/goform_set_cmd_process"
if errorlevel 1 goto :cannot_connect

echo.
echo Enable ADB connection on R216-Z...
%curl% -b cookies.txt -e "http://192.168.0.1/home.htm" -d "goformId=USB_MODE_SWITCH" -d "usb_mode=6" "http://192.168.0.1/goform/goform_set_cmd_process"
if errorlevel 1 goto :cannot_connect

echo.
echo Wait for R216-Z...
%adb% wait-for-device
echo Logoff admin on R216-Z...
%curl% -e "http://192.168.0.1/home.htm" -d "goformId=LOGOUT" "http://192.168.0.1/goform/goform_set_cmd_process"
if "%1" == "remove" goto remove

echo.
set reboot=patch_end
choice /m "Do you want to deploy the re-connect script"
if errorlevel 2 goto :auto_reconnect_patch
goto :patch_start

:patch_start
set end=patch_end
echo.
echo Push patch to R216-Z...
for /f "tokens=*" %%a in ('%adb% shell mkdir /usr/ui/^|find /i "File exists"') do (
	if not errorlevel 1 goto :already_patched
)
:continue_patch
echo.
%adb% push startdui.sh /usr/ui/
%adb% push ppp_reconnect.sh /etc/
set reboot=reboot
goto :auto_reconnect_patch

:auto_reconnect_patch
echo.
echo Additional mobile networks, like Telekon, Telefonica, o2 and 1^&1
echo can be added to enable auto-reconnect.
choice /m "Do you want to update the apn_list database"
if errorlevel 2 goto :%reboot%
rem Create backup of database
%adb% shell if ! [ -f "/usr/zte_web/web/auto_apn/auto_apn_backup.db" ]; then cp /usr/zte_web/web/auto_apn/auto_apn.db /usr/zte_web/web/auto_apn/auto_apn_backup.db; fi
echo.
%adb% push apn_list_update.sh /etc/
%adb% shell sh /etc/apn_list_update.sh add
%adb% shell sh /etc/apn_list_update.sh list
goto :reboot

:patch_end
echo.
echo Info:
echo Run command: %0 remove
echo to remove patch from R216-Z again.
goto :END

:already_patched
echo.
echo Patch is already installed or system files exist and might be overwritten.
choice /m "Do you want to continue"
if errorlevel 2 goto :END
goto :continue_patch

:cannot_connect
echo.
echo Error: Cannot connect to R216-Z! Please ensure you're connected to its WLAN!
goto :END

:remove
echo.
echo Remove patch from R216-Z...
%adb% shell pkill -f "sh /etc/ppp_reconnect.sh"
%adb% shell if [ -f "/usr/ui/startdui.sh" ]; then rm /usr/ui/startdui.sh; fi
%adb% shell if [ -f "/etc/ppp_reconnect.sh" ]; then rm /etc/ppp_reconnect.sh; fi
%adb% shell if [ -d "/usr/ui/" ]; then rmdir /usr/ui/; fi
%adb% shell if [ -f "/etc/apn_list_update.sh" ]; then rm /etc/apn_list_update.sh; fi
%adb% shell if [ -f "/usr/zte_web/web/auto_apn/auto_apn_backup.db" ]; then cp /usr/zte_web/web/auto_apn/auto_apn_backup.db /usr/zte_web/web/auto_apn/auto_apn.db;rm /usr/zte_web/web/auto_apn/auto_apn_backup.db; fi
set end=END
goto :reboot

:reboot
echo.
echo Done. Please reboot R216-Z.
echo.
choice /m "Do you want to reboot the R216-Z"
if errorlevel 2 goto :%end%
echo Rebooting R216-Z...
%adb% shell reboot

:END
echo.
pause
