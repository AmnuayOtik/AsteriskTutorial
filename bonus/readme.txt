1. Install from image step 1 - 34
2. Login user / pass (otikadmin/otiknetwork)
3. Change user to root (su -) and enter your root password (see on installation step 11-12)
4. Run command "apt install git -y" (Install git hub for download resources)
5. Run command "cd /tmp"
6. Download Code "git clone https://github.com/AmnuayOtik/AsteriskTutorial.git"
7. Run command "cd AsteriskTutorial" (check path by command pwd it will show "/tmp/AsteriskTutorial")
8. Run command "chmod 777 asterisk21.sh"
9. Run command "./asterisk21.sh"
10. If the system show "Asterisk installation completed..." finished installation. and reboot system one time.
11. Check services run this command with root "systemctl status asterisk" the systemshow active (running) and check version "asterisk -V" it will show Asterisk 21.4.2
12. Run this command for debug Asterisk "asterisk -rvvvvvv" (v = debug level message)
13. Run this command for show all endpoints "pjsip show endpoints" (don' forget add 's' in the endpoints)
14. Exit from Asterisk by run command "exit"