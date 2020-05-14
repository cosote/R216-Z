@echo off
set adb=adb\adb.exe
set curl=curl\curl.exe

echo Verify login with password admin on R216-Z...
%curl% -e "http://192.168.0.1/home.htm" -d "goformId=LOGIN" -d "password=YWRtaW4=" "http://192.168.0.1/goform/goform_set_cmd_process"
echo.
if errorlevel 1 goto :cannot_connect
echo.
echo Login with password admin on R216-Z...
%curl% -c cookies.txt -e "http://192.168.0.1/home.htm" -d "goformId=LOGIN_EXCLUSIVE" -d "password=YWRtaW4=" "http://192.168.0.1/goform/goform_set_cmd_process"
echo.
if errorlevel 1 goto :cannot_connect
echo.
echo Enable ADB connection on R216-Z...
%curl% -b cookies.txt -e "http://192.168.0.1/home.htm" -d "goformId=USB_MODE_SWITCH" -d "usb_mode=6" "http://192.168.0.1/goform/goform_set_cmd_process"
echo.
if errorlevel 1 goto :cannot_connect
echo.
echo Wait for R216-Z...
%adb% wait-for-device
if "%1" == "remove" goto remove
echo.
echo Push patch to R216-Z...
for /f "tokens=*" %%a in ('%adb% shell mkdir /usr/ui/^|find /i "File exists"') do (
	if not errorlevel 1 goto :cannot_patch
)
:continue_patch
%adb% push startdui.sh /usr/ui/
%adb% push ppp_reconnect.sh /etc/
echo.
echo Done. Please reboot R216-Z.
echo.
choice /m "Do you want to reboot the R216-Z"
if errorlevel 2 goto :patch_end
echo Rebooting R216-Z...
%adb% shell reboot
:patch_end
echo.
echo Info:
echo Run command: %0 remove
echo to remove patch from R216-Z again.
goto :END

:cannot_patch
echo Error: Cannot create directory!
echo Patch is already installed or system files exist and might be overwritten.
choice /m "Do you want to continue"
if errorlevel 2 goto :END
goto :continue_patch

:cannot_connect
echo Error: Cannot connect to R216-Z!
goto :END

:remove
echo.
echo Remove patch from R216-Z...
%adb% shell rm /usr/ui/startdui.sh 
%adb% shell rm /etc/ppp_reconnect.sh 
%adb% shell rmdir /usr/ui/
%adb% shell pkill -f "sh /etc/ppp_reconnect.sh"
echo.
echo Done.
goto :END

:END
echo.
pause
