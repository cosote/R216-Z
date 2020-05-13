# R216-Z
Tools for Vodafone R216-Z (ZTE MF910)

As I couldn't find any usefull information how to fix this Vodafone R216-Z bug, that network connection is not initiated automatically, I've created a small tool to push 2 scripts onto the device to fix that. Now, after reboot or resuming from sleep, internet connection is immediately established.

Just USB connect the R216-Z your Windows computer and launch R216-Z_patch.bat to push the patch to the device.
With R216-Z_patch.bat remove, you can un-install the patch again.

The script runs as a background process and checks every 3 Seconds if it was rebootet or resumed from sleep and initiates then CONNECT_NETWORK command if it is disconnected.

Please find here some links about Vodafone R216-Z device:
- https://github.com/kristrev/zte-mf910-scripts
- https://kristrev.github.io/2016/07/21/making-the-zte-mf910-play-nice
- https://wiki.archlinux.org/index.php/ZTE_MF_823_(Megafon_M100-3)_4G_Modem
- https://www.pentestpartners.com/security-blog/zte-mf910-an-end-of-life-router-running-lots-of-vivacious-hidden-code/
- https://github.com/pentestpartners/defcon27-4grouters
- https://www.lteforum.at/mobilfunk/sms-kodierung-bei-zte-usb-modem.5219/
- https://www.rbit.at/wordpress/uncategorized/zte-modem-mf831-telnet-ssh-zugang/
- https://blog.hqcodeshop.fi/archives/255-ZTE-MF910-Wireless-Router-reviewed.html
- https://3ginfo.ru/download116.html
