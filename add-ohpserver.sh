#!/bin/bash

clear

SERVER_IP=`ip -o route get to 8.8.8.8 | sed -n 's/.*src \([0-9.]\+\).*/\1/p'`

# Check if root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Read Input
echo 'Run setup-ohp-ssh.sh before executing this script. [required]'
echo 'This script allows you to use ohp+privoxy to other ssh server.'
echo 'Make sure to add the host and port correctly.'
echo 'It is recommended to increment the service name. e.g ohpserver-001, ohpserver-002'
echo ' '
echo 'Add New Server To OHP (SSH)'
read -e -p 'Input service name: ' -i 'ohpserver-001' SERNAME
read -e -p 'Input your Server IP: ' -i $SERVER_IP SERVER_IP
read -e -p 'Input SSH Port: ' -i '22' SSH_PORT
read -e -p 'Input Privoxy Port: ' -i '8118' PRIVOXY_PORT
read -e -p 'Input ohpserver Port: ' -i '9991' OHP_PORT

FILE=/etc/systemd/system/$SERNAME.service
if test -f "$FILE"; then
    echo "Service Name: $FILE exists."
    echo ""
    exit 1
fi

echo 'Adding server ip to privoxy...'
echo $SERVER_IP >> /etc/privoxy/user.action

echo 'Setting up ohpserver...'
cat <<EOF > /etc/systemd/system/$SERNAME.service
[Unit]
Description=OHP For SSH
Wants=network.target
After=network.target

[Service]
ExecStart=/usr/local/bin/ohpserver-ssh -port $OHP_PORT -proxy 127.0.0.1:$PRIVOXY_PORT -tunnel $SERVER_IP:$SSH_PORT
Restart=always
RestartSec=3
[Install]
WantedBy=multi-user.target
EOF

# Enable on boot
echo 'Start services on boot'
systemctl enable $SERNAME
systemctl start $SERNAME

rm -rf add-ohpserver.sh

echo '##############################' >> ohpserver.logs
echo 'Service Name:' $SERNAME >> ohpserver.logs
echo 'Server IP:' $SERVER_IP >> ohpserver.logs
echo 'SSH Port:' $SSH_PORT >> ohpserver.logs
echo 'HTTP Port:' $PRIVOXY_PORT >> ohpserver.logs
echo 'OHP Port:' $OHP_PORT >> ohpserver.logs
echo '##############################' >> ohpserver.logs

cat ohpserver.logs

echo 'Setup completed!'
echo 'Check ohpserver status by typing systemctl status' $SERNAME