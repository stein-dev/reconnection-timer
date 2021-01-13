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
echo 'Removing files...'

DEBIAN_FRONTEND=noninteractive apt purge -y privoxy

systemctl stop ohpserver-ssh.service
systemctl disable ohpserver-ssh.service
rm -rf /etc/systemd/system/ohpserver-ssh.service
rm -rf /usr/local/bin/ohpserver-ssh
systemctl daemon-reload
systemctl reset-failed

rm -rf /etc/privoxy/user.action
rm -rf /etc/privoxy

echo "Done. Reboot is recommended. Type reboot to restart vps."