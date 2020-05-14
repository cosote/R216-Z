# R216-Z
Tools for Vodafone R216-Z (ZTE MF910)

As I couldn't find any usefull information how to fix this Vodafone R216-Z bug, that network connection is not initiated automatically, I've created a small tool to push 2 scripts onto the device to fix that. Now, after reboot or resuming from sleep, internet connection is immediately established. 

Donations are welcome :)<br>
[![Donate](https://www.paypalobjects.com/en_US/i/btn/btn_donate_SM.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=83VK6A6D3MCRS&source=url)

Just USB connect the R216-Z to your Windows computer and launch R216-Z_patch.bat to push the patch to the device.
With R216-Z_patch.bat remove, you can un-install the patch again. Ensure you have setup **admin** as your administrative password of the R216-Z device (that is the default password).

The script runs as a background process on the R216-Z device and checks every 3 Seconds if it was rebootet or resumed from sleep and initiates then CONNECT_NETWORK command if it is disconnected. Please reboot the R216-Z device after you've pushed it.

Required drivers for R216-Z can be found here: [2015010810282162.zip](http://download.pcdcdn.com/download.php?file=f0ccf6b7e75ec4c92e651dfbef4e3951)

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
