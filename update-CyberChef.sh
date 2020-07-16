#!/bin/bash 
INSTALL_LOC=/home/$(whoami)/bin/CyberChef
echo "[+] Checking for previous installation directoy"
if [[ ! -d $INSTALL_LOC ]]
then
	echo "[+] Directory not found, creating."
	mkdir -p $INSTALL_LOC
fi

RELEASE=$(curl -s https://api.github.com/repos/gchq/CyberChef/releases/latest | grep tag_name | cut -d '"' -f 4)

if [[ -f $INSTALL_LOC/version.txt ]]
then
	if [[ $(cat $INSTALL_LOC/version.txt) == $RELEASE ]]
	then
		echo "[+] CyberChef is up-to-date at $RELEASE"
		exit 0
	fi
fi
echo "[+] New version $RELEASE located"
find $INSTALL_LOC -type f -not -name version.txt -delete
ZIP=https://github.com/gchq/CyberChef/releases/download/$RELEASE/CyberChef_$RELEASE.zip
echo "[+] Downloading CyberChef_$RELEASE.zip from Github"
curl -Ls $ZIP --output $INSTALL_LOC/CyberChef_$RELEASE.zip
echo "[+] Extracting ZIP to $INSTALL_LOC"
unzip -q $INSTALL_LOC/CyberChef_$RELEASE.zip -d $INSTALL_LOC
echo "[+] Cleaning up..."
rm $INSTALL_LOC/CyberChef_$RELEASE.zip
echo $RELEASE > $INSTALL_LOC/version.txt
echo "[+] Complete."
