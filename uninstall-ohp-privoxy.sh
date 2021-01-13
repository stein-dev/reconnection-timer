#!/bin/bash

clear

# Check if root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

echo 'Created by @pigscanfly | Version 0.0.1'

echo "Removing files..."

DEBIAN_FRONTEND=noninteractive apt purge -y privoxy

systemctl disable ohpserver-ssh

rm -rf /usr/local/bin/ohpserver-ssh
rm -rf /etc/systemd/system/ohpserver-ssh.service
rm -rf /etc/privoxy/user.action
rm -rf /etc/privoxy

systemctl daemon-reload

echo "Done. Reboot is recommended. Type reboot to restart vps."