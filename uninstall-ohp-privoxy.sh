#!/bin/bash

# Check if root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

echo 'Created by @pigscanfly | Version 0.0.1'

echo "Uninstalling in progress..."

DEBIAN_FRONTEND=noninteractive apt purge -y privoxy

rm -rf /usr/local/bin/ohpserver-ssh
rm -rf /etc/systemd/system/ohpserver-ssh.service
rm -rf /etc/privoxy/user.action
rm -rf /etc/privoxy

echo "Done"