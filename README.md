## CyberChef Update Script: `Update-CyberChef.ps1`

PowerShell script to update to the latest version of CyberChef.  

*Usage:* `PS C:\> .\Update-CyberChef.ps1`  

*Requirements:* Admin privs (to make the shortcut). If you are on a restricted endpoint without admin then remove that section.   

Currently has hardcoded saving location 'C:\Tools' for ZIP download and 'C:\Tools\CyberChef\' for app. Change as you see fit.  

Will create a `version.txt` file in the install location from which it subsequently reads the installed version against the latest release. If there is an update it will download to the nominated location.  
