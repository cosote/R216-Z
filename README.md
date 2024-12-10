# R216-Z
Reconnect for Vodafone R216-Z (ZTE MF910)

As I couldn't find any usefull information how to fix this Vodafone R216-Z bug, that network connection is not initiated automatically, I've created a small tool to push 2 scripts onto the device to fix that. Now, after reboot or resuming from sleep, internet connection is immediately established. 
Thx @umbe1987, the linux script is great - I just need to merge the recent changes into it:
I've updated the script to also reboot the device, if no internet connection is available for longer period (~45 Minutes after reboot or ~15 Minutes if it had once internet) - thx @fazio91 for that fix on a related matter.
I had another issue that internet after 2-3 days of constant use stopped working: mobile connect was established (LED on), WiFi also, IP all good, but internet was not accessible - only rebooting device fixed the issue...
Thx to @1ras, I've also added the update of apn_list database with Telekom, Telefonica, o2 and 1&1. This should make the original re-connect script opsolete, you can choose.

Donations are welcome :)<br>
[![Donate](https://www.paypalobjects.com/en_US/i/btn/btn_donate_SM.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=83VK6A6D3MCRS&source=url)

Just USB connect the R216-Z to your Windows computer, connect to it's WLAN and launch R216-Z_patch.bat (<a href="https://github.com/cosote/R216-Z/releases/download/R216-Z_patch_v0.1/R216-Z_patch_v0.1.zip"><img valign="bottom" src="https://img.shields.io/github/downloads/cosote/R216-Z/latest/total"></a>) to push the patch to the device.
With R216-Z_patch.bat remove, you can un-install the patch again. Ensure you have setup **admin** as your administrative password of the R216-Z device (that is the default password).

The script runs as a background process on the R216-Z device and checks every 5 Seconds if it was rebootet or resumed from sleep and initiates then CONNECT_NETWORK command if it is disconnected. Please reboot the R216-Z device after you've pushed it.
It also checks every 2 Minutes for network connection and initiates a connect, if not connected. If internet becomes unavailable for 15 Minutes, the device reboots (or every 45 Minutes, when it never internet since boot).

Drivers for R216-Z can be found here: [2015010810282162.zip](http://download.pcdcdn.com/download.php?file=f0ccf6b7e75ec4c92e651dfbef4e3951) but should not be required for the patch tool.

I've not updated my Vodafone Verion 4.0 devices (QPEST tool should work, or adb reboot bootloader, but didn't get any further... any additional detailed information would be helpful), but please find here some links about Vodafone R216-Z device:
- Firmware 4.1 from vodafone.nl (couldn't install though, but thx @1ras for your comments and the super cool DB patch, I've added that to this tool)
  - https://www.vodafone.nl/content/dam/vodafone/downloads/software/r216_z_mobilewifi_firmware_v4.1.exe
- Debranding firmware (unverified!) or updating/reverting to Version 4.2, 4.0...
  - Flash tool: https://3ginfo.ru/downloads1739.html, https://forum.gsmhosting.com/vbb/f844/zte-mf910-firmware-flasher-2156390/
  - Firmware 4.0 with instructions: https://drive.google.com/file/d/1HUKdVe7-za2PC2JwXXMAwDCBq1cGPQYF, https://firmwarefile.com/zte-r216-z
  - https://3ginfo.ru/download116.html
  - https://forum.gsmhosting.com/vbb/f695/answered-cannot-find-r216-mf910-debranding-fw-2275125/#post13694461
  - https://firmware.gem-flash.com/index.php?a=downloads&b=folder&id=19223
  - https://firmwarefile.com/zte-r216-z
  - https://firmwaredrive.com/index.php?a=downloads&b=folder&id=25798
  - https://firmwaredrive.com/index.php?a=downloads&b=folder&id=36785
- Device source code
  - http://download.ztedevices.com/device/global/support/opensource/7/109/Vodafone_R216-Z_opensource_code.tar.gz
  - http://download.ztedevices.com/device/global/support/opensource/7/20170415_01/Vodafone_R216-ZV4.3_opensource_code.tar.gz
  - http://download.ztedevices.com/device/global/support/opensource/7/20181025_01/Vodafone_R216-ZV4.4_opensource_code.tar
- https://github.com/kristrev/zte-mf910-scripts
- https://kristrev.github.io/2016/07/21/making-the-zte-mf910-play-nice
- https://wiki.archlinux.org/index.php/ZTE_MF_823_(Megafon_M100-3)_4G_Modem
- https://www.pentestpartners.com/security-blog/zte-mf910-an-end-of-life-router-running-lots-of-vivacious-hidden-code/
- https://github.com/pentestpartners/defcon27-4grouters
- https://www.lteforum.at/mobilfunk/sms-kodierung-bei-zte-usb-modem.5219/
- https://www.rbit.at/wordpress/uncategorized/zte-modem-mf831-telnet-ssh-zugang/
- https://blog.hqcodeshop.fi/archives/255-ZTE-MF910-Wireless-Router-reviewed.html
- https://4pda.to/forum/index.php?showtopic=665736