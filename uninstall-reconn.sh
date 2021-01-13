#!/bin/bash

# Check if root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

echo 'Created by @pigscanfly | Version 0.0.1'

echo "Uninstalling in progress..."
rm -rf /usr/local/bin/reconn
rm -rf /etc/systemd/system/reconn.service
echo "Done"