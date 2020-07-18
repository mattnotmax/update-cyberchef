<#
.SYNOPSIS
  Name: Update-CyberChef.ps1
  Download the most recent releast of CyberChef from Github
  
.DESCRIPTION
  Basic function will download the latest ZIP release from Github to hardcoded location. Unzip into a Tools folder and then create a shortcut file on the Desktop.

.NOTES
  Release Date: 2019-11-21
  Last Update: 2020-07-18
  Author: @mattnotmax

.EXAMPLE
  ./Update-CyberChef.ps1
#>

# Establish variables. Change for own location
$Download_Location = "C:\Tools"
$Download_File = "CyberChef_latest.zip"
$Install_Location = "C:\Tools\CyberChef"
$ShortcutLocation = "$env:USERPROFILE\Desktop\CyberChef.lnk"

# Only run script if running as admin, this is required to make the shortcut so could be removed if that part not needed
$CheckAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-Not $CheckAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
  Write-Host "Requires Administrator."
	Exit
}
if (-not (Test-Path -Path $Download_Location)) {
  Write-Host "[+] Creating Download folder: $Download_Location" -ForegroundColor Yellow
  New-Item -ItemType Directory $Download_Location | Out-Null
}
if (-not (Test-Path -Path $Install_Location)) {
  Write-Host "[+] Creating Installation folder: $Install_Location" -ForegroundColor Yellow
  New-Item -ItemType Directory $Install_Location  | Out-Null
}

# Check if version.txt is present and read contents
if (Test-Path -Path "$Install_Location\version.txt") {
  Write-Host "[+] Reading currently installed version." -ForegroundColor Yellow
  $Installed_Version = Get-Content "$Install_Location\version.txt"
}
else {
  $Installed_Version = $null
}

# Get Version from Github API and compare
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$Release =  Invoke-WebRequest "https://api.github.com/repos/gchq/CyberChef/releases/latest"
$Release = $Release | ConvertFrom-Json | Select-Object -ExpandProperty tag_name 
if ($Installed_Version -eq $Release) {
  Write-Host "[+] CyberChef is current at $Release." -ForegroundColor Yellow
  Exit
}

if (Test-Path -Path "C:\tools\CyberChef_latest.zip") {
  Write-Host "[+] Removing old installation ZIP file." -ForegroundColor Yellow  
  Remove-Item C:\Tools\CyberChef_latest.zip -Force
}

# Download ZIP from Github & Install
Write-Host "[+] Downloading CyberChef from Github." -ForegroundColor Yellow
Invoke-WebRequest "https://github.com/gchq/CyberChef/releases/download/$Release/CyberChef_$Release.zip" -OutFile "$Download_Location\$Download_File"
Get-ChildItem -Path $Install_Location -Exclude "$Install_Location\version.txt" | ForEach-Object { Remove-Item $_ -Recurse }
Write-Host "[+] Expanding ZIP to $Install_Location." -ForegroundColor Yellow
Expand-Archive -Path "$Download_Location\$Download_File" -DestinationPath $Install_Location
Write-Host "[+] Cleaning up." -ForegroundColor Yellow
$CyberChef = Get-ChildItem "$Install_Location\*.html" | Select-Object -ExpandProperty Name
Rename-Item $Install_Location\$CyberChef "CyberChef.html"
$Release | Out-File -FilePath "$Install_Location\version.txt"
Remove-Item -Path $Download_Location\$Download_File -Force -Recurse

# Install Shortcut if necessary
if (Test-Path -Path $ShortcutLocation) {
  Write-Host "[+] Skipping shortcut creation. Already exists." -ForegroundColor Yellow
}
else {
  Write-Host "[+] Creating shortcut $ShortcutLocation." -ForegroundColor Yellow
  $CyberChef = Get-ChildItem "$Install_Location\*.html" | Select-Object -ExpandProperty Name
  $ShortCut = (New-Object -ComObject ("WScript.Shell")).CreateShortcut($ShortcutLocation)
  $ShortCut.TargetPath = "$Install_Location\$CyberChef"
  $ShortCut.Save()
}
Write-Host "[+] Installation Complete." -ForegroundColor Yellow