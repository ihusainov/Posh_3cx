# Posh_3cx
 
Script in powershell to add ip addresses from 3CX database blacklist table. Then send file to ftp and then received from Mikrotik. 
After that Mikrotik start script "Add3cxBLmikrotik.txt" and add blacklisted ip in his Firewall for block connection.


Add script "Add3cxBLmikrotik.txt" in MikroTik:
Start Winbox - System - Scripts - Add