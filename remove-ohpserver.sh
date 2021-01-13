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

systemctl stop ohpserver-0*
systemctl disable ohpserver-0*
rm -rf /etc/systemd/system/ohpserver-0*
systemctl daemon-reload
systemctl reset-failed

rm -rf remove-ohpserver.ssh

echo "Done. Reboot is recommended. Type reboot to restart vps."