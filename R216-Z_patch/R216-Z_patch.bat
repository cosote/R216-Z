@echo off
set device=MF910_ZTED000000
set adb=adb\adb.exe -s %device%
set curl=curl\curl.exe

rem If not starting adb server first, the devices -l command might hang...
%adb% start-server
for /F "delims=" %%i in ('%adb% -s %device% devices -l^|find "%device%"') do goto :device_connected

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
echo.

:device_connected
if "%1" == "remove" goto remove

echo.
set reboot=end
choice /m "Do you want to deploy the re-connect script"
if errorlevel 2 goto :auto_reconnect_patch
goto :patch_start

:patch_start
echo.
echo Push patch to R216-Z...
for /f "tokens=*" %%a in ('%adb% shell mkdir /usr/ui/^|find /i "File exists"') do (
	if not errorlevel 1 goto :already_patched
)
:continue_patch
echo.
%adb% push startdui.sh /usr/ui/
%adb% push ppp_reconnect.sh /etc/
%adb% push sendmail.sh /etc/
%adb% push sms_email_forward.sh /etc/
set reboot=reboot
goto :auto_reconnect_patch

:auto_reconnect_patch
echo.
echo Additional mobile networks, like Telekon, Telefonica, o2 and 1^&1
echo can be added to enable auto-reconnect.
choice /m "Do you want to update the apn_list database"
if errorlevel 2 goto :sms_forward
rem Create backup of database
%adb% shell if ! [ -f "/usr/zte_web/web/auto_apn/auto_apn_backup.db" ]; then cp /usr/zte_web/web/auto_apn/auto_apn.db /usr/zte_web/web/auto_apn/auto_apn_backup.db; fi
echo.
%adb% push apn_list_update.sh /etc/
%adb% shell sh /etc/apn_list_update.sh add
%adb% shell sh /etc/apn_list_update.sh list
set reboot=reboot
goto :sms_forward

:sms_forward
echo.
echo You can forward (and delete) incoming SMS to email.
echo You need to configure the from-email, smtp details and to-email.
choice /m "Do you want to deploy this feature"
if errorlevel 2 goto :%reboot%
set /p "subject_prefix=Email subject prefix (default R216-Z): "
if [%subject_prefix%]==[] set subject_prefix=R216-Z
set /p "email_from=Enter from-email: "
set email_default_smtp_account=%email_from%
for /f "tokens=2 delims=@" %%a in ("%email_from%") do (
  set "email_default_smtp_server=smtp.%%a:587"
)
set /p "email_smtp_account=Enter smtp-account (default %email_default_smtp_account%): "
if [%email_smtp_account%]==[] set email_smtp_account=%email_default_smtp_account%
set /p "email_smtp_password=Enter smtp-passwort: "
set /p "email_smtp_server=Enter smtp server:port (default %email_default_smtp_server%): "
if [%email_smtp_server%]==[] set email_smtp_server=%email_default_smtp_server%
set /p "email_to=Enter to-email (default %email_from%): "
if [%email_to%]==[] set email_to=%email_from%

if not [%email_from%]==[] (
  echo "Creating /etc/sendmail.conf..."
  %adb% shell "echo SUBJECT_PREFIX=%subject_prefix%>/etc/sendmail.conf"
  %adb% shell "echo SMTP_FROM=%email_from%>>/etc/sendmail.conf"
  %adb% shell "echo SMTP_USER=%email_smtp_account%>>/etc/sendmail.conf"
  %adb% shell "echo SMTP_PASS=%email_smtp_password%>>/etc/sendmail.conf"
  %adb% shell "echo SMTP_SERVER=%email_smtp_server%>>/etc/sendmail.conf"
  %adb% shell "echo SMTP_TO=%email_to%>>/etc/sendmail.conf"
)
echo Downloading CA cert...
%curl% -o cacert.pem https://curl.se/ca/cacert.pem
%adb% push cacert.pem /etc/

set reboot=reboot
goto :reboot

:patch_end
:reboot_done
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
%adb% shell if [ -d "/usr/ui/" ]; then rmdir /usr/ui/; fi
%adb% shell if [ -f "/etc/ppp_reconnect.sh" ]; then rm /etc/ppp_reconnect.sh; fi
%adb% shell if [ -f "/etc/sms_email_forward.sh" ]; then rm /etc/sms_email_forward.sh; fi
%adb% shell if [ -f "/etc/sendmail.sh" ]; then rm /etc/sendmail.sh; fi
%adb% shell if [ -f "/etc/sendmail.conf" ]; then rm /etc/sendmail.conf; fi
%adb% shell if [ -f "/etc/apn_list_update.sh" ]; then rm /etc/apn_list_update.sh; fi
%adb% shell if [ -f "/usr/zte_web/web/auto_apn/auto_apn_backup.db" ]; then cp /usr/zte_web/web/auto_apn/auto_apn_backup.db /usr/zte_web/web/auto_apn/auto_apn.db;rm /usr/zte_web/web/auto_apn/auto_apn_backup.db; fi
set reboot=remove
goto :reboot

:reboot
echo.
echo Done. Please reboot R216-Z.
echo.
choice /m "Do you want to reboot the R216-Z"
if errorlevel 2 goto :%reboot%_done
echo Rebooting R216-Z...
%adb% shell reboot
goto :%reboot%_done

:END
:remove_done
echo.
echo Fix route...
route delete 0.0.0.0 192.168.0.1
pause
