<#
.SYNOPSIS
  Name: Update-CyberChef.ps1
  Download the most recent releast of CyberChef from Github
  
.DESCRIPTION
  Basic function will download the latest ZIP release from Github to hardcoded location. Unzip into a Tools folder and then create a shortcut file on the Desktop.

.NOTES
  Release Date: 2019-11-21
  Author: @mattnotmax

.EXAMPLE
  ./Update-CyberChef.ps1 or in a Scheduled Task
#>

# Only run script if running as admin, this is required to make the shortcut so could be removed if that part not needed
$CheckAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-Not $CheckAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)){
    Write-Host "Requires Administrator."
	exit
}

# Establish variables. Change for own location
$Download_Location = "C:\Tools\"
$Download_File = "CyberChef_latest.zip"
$Install_Location = "C:\Tools\CyberChef\"
$CyberChef_Github = "https://api.github.com/repos/gchq/CyberChef/releases/latest"
$ShortcutLocation = "$env:USERPROFILE\Desktop\CyberChef.lnk"

# Check for previous download & shortcut
if (Test-Path -Path "C:\tools\CyberChef_latest.zip") {
    Remove-Item C:\Tools\CyberChef_latest.zip -Force
}
if (Test-Path -Path $ShortcutLocation){
    Remove-Item $ShortcutLocation -Force
}

# Download ZIP from Github
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 
$ZIP_File = (Invoke-WebRequest $CyberChef_Github | ConvertFrom-Json | ForEach-Object {$_.assets} | Select-Object -ExpandProperty browser_download_url | Select-String "\.zip" | Out-String)
Invoke-WebRequest $ZIP_File -OutFile "$Download_Location\$Download_File"

# Remove and Install previous version
Remove-Item -Path $Install_Location -Force -Recurse
New-Item -ItemType Directory $Install_Location | Out-Null
Expand-Archive -Path "$Download_Location\$Download_File" -DestinationPath $Install_Location

# Rename .html to generic to keep other links
$CyberChef = Get-ChildItem "$Install_Location\*.html" | Select-Object -ExpandProperty Name
Rename-Item $Install_Location$CyberChef "CyberChef.html"

# Create Shortcut on Desktop
$CyberChef = Get-ChildItem "$Install_Location\*.html" | Select-Object -ExpandProperty Name
$Shell = New-Object -ComObject ("WScript.Shell")
$ShortCut = $Shell.CreateShortcut($ShortcutLocation)
$ShortCut.TargetPath = "$Install_Location\$CyberChef"
$ShortCut.Save()

# Remove ZIP file
Remove-Item -Path $Download_Location$Download_File -Force -Recurse
