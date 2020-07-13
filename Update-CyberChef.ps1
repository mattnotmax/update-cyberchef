<#
.SYNOPSIS
  Name: Update-CyberChef.ps1
  Download the most recent releast of CyberChef from Github
  
.DESCRIPTION
  Basic function will download the latest ZIP release from Github to hardcoded location. Unzip into a Tools folder and then create a shortcut file on the Desktop.

.NOTES
  Release Date: 2019-11-21
  Last Update: 2020-07-13
  Author: @mattnotmax

.EXAMPLE
  ./Update-CyberChef.ps1
#>

# Establish variables. Change for own location
$Download_Location = "C:\Tools\"
$Download_File = "CyberChef_latest.zip"
$Install_Location = "C:\Tools\CyberChef\"
$CyberChef_Github = "https://api.github.com/repos/gchq/CyberChef/releases/latest"
$ShortcutLocation = "$env:USERPROFILE\Desktop\CyberChef.lnk"

# Only run script if running as admin, this is required to make the shortcut so could be removed if that part not needed
$CheckAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-Not $CheckAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
  Write-Host "Requires Administrator."
	Exit
}

# Check if version.txt is present and read contents
if (Test-Path -Path "$Install_Location\version.txt") {
  $Installed_Version = Get-Content "$Install_Location\version.txt"
}
else {
  $Installed_Version = $null
}

# Get Version from Github API and compare
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 
$ZIP_File = (Invoke-WebRequest $CyberChef_Github | ConvertFrom-Json | ForEach-Object {$_.assets} | Select-Object -ExpandProperty browser_download_url | Select-String "\.zip" | Out-String)
$Github_Version = ($ZIP_File -split "(?<=_)(.*?)(?=\.zip)")[1]
if ($Installed_Version -eq $Github_Version) {
  Write-Host "CyberChef is current"
  Exit
}

if (Test-Path -Path "C:\tools\CyberChef_latest.zip") {
    Remove-Item C:\Tools\CyberChef_latest.zip -Force
}

# Download ZIP from Github & Install
Invoke-WebRequest $ZIP_File -OutFile "$Download_Location\$Download_File"
Get-ChildItem -Path $Install_Location -Exclude "$Install_Location\version.txt" | ForEach-Object { Remove-Item $_ -Recurse }
Expand-Archive -Path "$Download_Location\$Download_File" -DestinationPath $Install_Location
$CyberChef = Get-ChildItem "$Install_Location\*.html" | Select-Object -ExpandProperty Name
Rename-Item $Install_Location$CyberChef "CyberChef.html"
$Github_Version | Out-File -FilePath "$Install_Location\version.txt"
Remove-Item -Path $Download_Location$Download_File -Force -Recurse

# Install Shortcut if necessary
if (Test-Path -Path $ShortcutLocation) {
  Write-Host "Skipping Shortcut. Already Exists"
}
else {
  $CyberChef = Get-ChildItem "$Install_Location\*.html" | Select-Object -ExpandProperty Name
  $Shell = New-Object -ComObject ("WScript.Shell")
  $ShortCut = $Shell.CreateShortcut($ShortcutLocation)
  $ShortCut.TargetPath = "$Install_Location\$CyberChef"
  $ShortCut.Save()
}