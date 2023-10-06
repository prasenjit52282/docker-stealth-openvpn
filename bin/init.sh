#!/usr/bin/env bash
STUNNEL_PORT=$1 #should be passed from the makescript
set -e

# shellcheck source=./common.sh
. "${BASH_SOURCE%/*}/common.sh"

OVPN_CONF_DIR="./ovpn-data-store"
OVPN_CONF_PATH="${OVPN_CONF_DIR}/openvpn.conf"

info "+ Initializing OpenVPN config..."

PUBLIC_IP=$(curl -s https://ipinfo.io/ip)
printf "This server's public address [%s]: " "$PUBLIC_IP"
read -r ADDRESS
ADDRESS=${ADDRESS:-$PUBLIC_IP}

docker-compose -f docker-compose-server.yml run --rm openvpn ovpn_genconfig  -C "AES-256-CBC" -a "SHA384" -u "tcp://$ADDRESS:$STUNNEL_PORT"
docker-compose -f docker-compose-server.yml run --rm openvpn ovpn_initpki

cat >> "$OVPN_CONF_PATH" <<EOF
push "verb 3"
push "route ${ADDRESS} 255.255.255.255 net_gateway"
EOF

success "+ OpenVPN configuration succeeded"

info "+ Initilizing certificates for clients..."
openssl genrsa -out ./tunnel/stunnel.key 2048
openssl req -new -x509 -key ./tunnel/stunnel.key -out ./tunnel/stunnel.pem -days 3650

success "+ New stunnel.key and stunnel.pem file is available in tunnel folder, copy them in the proxy"
