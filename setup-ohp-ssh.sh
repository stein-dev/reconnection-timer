#!/bin/bash
# file: setup-ohp-ssh.sh

DISTRO=`awk '/^ID=/' /etc/*-release | awk -F'=' '{ print tolower($2) }'`
SERVER_IP=`ip -o route get to 8.8.8.8 | sed -n 's/.*src \([0-9.]\+\).*/\1/p'`


# Check if root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Read Input
echo 'OHP For SSH'
read -e -p 'Input your Server IP: ' -i $SERVER_IP SERVER_IP
read -e -p 'Input SSH Port: ' -i '22' SSH_PORT
read -e -p 'Input Privoxy Port: ' -i '8118' PRIVOXY_PORT
read -e -p 'Input ohpserver Port: ' -i '9999' OHP_PORT

# Install Dependencies
echo 'Installing Dependencies'
DEBIAN_FRONTEND=noninteractive apt install -y privoxy 
echo 'Dependencies Installed!' 

echo 'Installing ohpserver'
wget https://raw.githubusercontent.com/stein-dev/reconnection-timer/main/ohpserver
mv ohpserver /usr/local/bin/ohpserver-ssh
chmod 755 /usr/local/bin/ohpserver-ssh

# Setup Privoxy
echo 'Setting up Privoxy'
mkdir /etc/privoxy/
cat <<EOF > /etc/privoxy/config
user-manual /usr/share/doc/privoxy/user-manual
confdir /etc/privoxy
logdir /var/log/privoxy
actionsfile match-all.action
actionsfile default.action
actionsfile user.action
filterfile default.filter
filterfile user.filter
logfile logfile
listen-address  :$PRIVOXY_PORT
toggle 1
enable-remote-toggle  0
enable-remote-http-toggle  0
enable-edit-actions 0
enforce-blocks 0
buffer-limit 4096
enable-proxy-authentication-forwarding 0
forwarded-connect-retries  0
accept-intercepted-requests 0
allow-cgi-request-crunching 0
split-large-forms 0
keep-alive-timeout 5
tolerate-pipelining 1
socket-timeout 300
EOF

cat <<EOF > /etc/privoxy/user.action
{ +block }
/

{ -block }
*.tcat.me
127.0.0.1
$SERVER_IP
EOF

# Setup ohpserver
echo 'Setup ohpserver'
cat <<EOF > /etc/systemd/system/ohpserver-ssh.service
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
systemctl enable privoxy
systemctl start privoxy
systemctl enable ohpserver-ssh
systemctl start ohpserver-ssh

# Installation Completed
echo 'Installation Completed!'
echo ''
echo ''
echo 'Installation Information'
echo '##############################'
echo 'Server IP:' $SERVER_IP
echo 'SSH Port:' $SSH_PORT
echo 'HTTP Port:' $PRIVOXY_PORT
echo 'OHP Port:' $OHP_PORT
