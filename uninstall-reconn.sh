#!/bin/bash

clear

# Check if root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

echo ' '
echo 'Created by @pigscanfly | Version 0.0.1'
echo ' '
echo "Removing files..."

systemctl stop reconn.service
systemctl disable reconn.service
rm -rf /etc/systemd/system/reconn.service
rm -rf /usr/local/bin/reconn
systemctl daemon-reload
systemctl reset-failed

rm -rf uninstall-reconn.ssh

echo "Done. Reboot is recommended. Type reboot to restart vps."