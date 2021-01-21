#!/bin/bash
# OHP+PRIVOXY+SQUID

DISTRO=`awk '/^ID=/' /etc/*-release | awk -F'=' '{ print tolower($2) }'`
#SERVER_IP=`ip -o route get to 8.8.8.8 | sed -n 's/.*src \([0-9.]\+\).*/\1/p'`
SERVER_IP=$(wget -qO- ipv4.icanhazip.com)

# Check if root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Read Input
echo 'OHP For OpenVPN+SSH'
read -e -p 'Input your Server IP: ' -i $SERVER_IP SERVER_IP
read -e -p 'Input SSH Port: ' -i '22' SSH_PORT
read -e -p 'Input OpenVPN TCP Port: ' -i '1194' OPENVPN_PORT
read -e -p 'Input Privoxy Port: ' -i '8118' PRIVOXY_PORT
read -e -p 'Input Squid Port: ' -i '8080' SQUID_PORT
read -e -p 'Input OHP+PRIVOXY+SSH Port: ' -i '9999' OPS_PORT
read -e -p 'Input OHP+PRIVOXY+OPENVPN Port: ' -i '9998' OPO_PORT
read -e -p 'Input OHP+SQUID+SSH Port: ' -i '8888' OSS_PORT
read -e -p 'Input OHP+SQUID+OPENVPN Port: ' -i '8887' OSO_PORT

echo 'Proceeding with the installation of dependencies'

echo 'Installing Dependencies'
DEBIAN_FRONTEND=noninteractive apt install -y privoxy unzip

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

echo 'Installing ohpserver...'
wget https://github.com/lfasmpao/open-http-puncher/releases/download/0.1/ohpserver-linux32.zip
unzip ohpserver-linux32.zip
rm ohpserver-linux32.zip
mv ohpserver /usr/local/bin/ohpserver
chmod +x /usr/local/bin/ohpserver


echo '############################################'
echo '#   			OHP + PRIVOXY + SSH          #'
echo '############################################'
cat <<EOF > /etc/systemd/system/ohpserver001.service
[Unit]
Description=OHP FOR SSH + PRIVOXY
Wants=network.target
After=network.target

[Service]
ExecStart=/usr/local/bin/ohpserver -port $OPS_PORT -proxy 127.0.0.1:$PRIVOXY_PORT -tunnel $SERVER_IP:$SSH_PORT
Restart=always
RestartSec=3
[Install]
WantedBy=multi-user.target
EOF

echo '############################################'
echo '#   		OHP + PRIVOXY + OPENVPN          #'
echo '############################################'
cat <<EOF > /etc/systemd/system/ohpserver002.service
[Unit]
Description=OHP FOR OPENVPN + PRIVOXY
Wants=network.target
After=network.target

[Service]
ExecStart=/usr/local/bin/ohpserver -port $OPO_PORT -proxy 127.0.0.1:$PRIVOXY_PORT -tunnel $SERVER_IP:$OPENVPN_PORT
Restart=always
RestartSec=3
[Install]
WantedBy=multi-user.target
EOF

echo '############################################'
echo '#   			OHP + SQUID + SSH            #'
echo '############################################'
cat <<EOF > /etc/systemd/system/ohpserver003.service
[Unit]
Description=OHP For SSH + SQUID
Wants=network.target
After=network.target

[Service]
ExecStart=/usr/local/bin/ohpserver -port $OSS_PORT -proxy 127.0.0.1:$SQUID_PORT -tunnel $SERVER_IP:$SSH_PORT
Restart=always
RestartSec=3
[Install]
WantedBy=multi-user.target
EOF

echo '############################################'
echo '#   		OHP + SQUID + OPENVPN            #'
echo '############################################'
cat <<EOF > /etc/systemd/system/ohpserver004.service
[Unit]
Description=OHP For OPENVPN + SQUID
Wants=network.target
After=network.target

[Service]
ExecStart=/usr/local/bin/ohpserver -port $OSO_PORT -proxy 127.0.0.1:$SQUID_PORT -tunnel $SERVER_IP:$OPENVPN_PORT
Restart=always
RestartSec=3
[Install]
WantedBy=multi-user.target
EOF

# Enable on boot
echo 'Start services on boot'
systemctl enable privoxy
systemctl start privoxy
systemctl enable ohpserver001.service
systemctl enable ohpserver002.service
systemctl enable ohpserver003.service
systemctl enable ohpserver004.service
systemctl start ohpserver001.service
systemctl start ohpserver002.service
systemctl start ohpserver003.service
systemctl start ohpserver004.service

echo 'Installation Completed!'
echo ''
echo ''
echo '######################################################'
echo ''
echo ''
echo 'SERVER IP: ' $SERVER_IP
echo 'SSH Port: ' $SSH_PORT
echo 'OpenVPN TCP Port: ' $OPENVPN_PORT
echo 'Privoxy Port: ' $PRIVOXY_PORT
echo 'Squid Port: ' $SQUID_PORT
echo 'OHP+PRIVOXY+SSH Port: ' $OPS_PORT
echo 'OHP+PRIVOXY+OPENVPN Port: ' $OPO_PORT
echo 'OHP+SQUID+SSH Port: ' $OSS_PORT
echo 'OHP+SQUID+OPENVPN Port: ' $OSO_PORT
echo ''
echo ''
echo '######################################################'
