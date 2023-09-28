#!/usr/bin/env bash

set -e

# shellcheck source=./common.sh
. "${BASH_SOURCE%/*}/common.sh"

OVPN_CONF_DIR="./ovpn-data-store"
OVPN_CONF_PATH="${OVPN_CONF_DIR}/openvpn.conf"

STUNNEL_CERT_PATH="./cert.pem"
STUNNEL_CONF_PATH="./stunnel.conf"
info "+ Initializing OpenVPN config..."

PUBLIC_IP=$(curl -s https://ipinfo.io/ip)
printf "This server's public address [%s]: " "$PUBLIC_IP"
read -r ADDRESS
ADDRESS=${ADDRESS:-$PUBLIC_IP}

docker-compose run --rm openvpn ovpn_genconfig  -C "AES-256-CBC" -a "SHA384" -u "tcp://$ADDRESS:443"
docker-compose run --rm openvpn ovpn_initpki

cat >> "$OVPN_CONF_PATH" <<EOF
push "verb 3"
push "route ${ADDRESS} 255.255.255.255 net_gateway"
EOF

success "+ OpenVPN configuration succeeded"

info "+ Initilizing cert.pem for clients..."
#openssl req -new -newkey rsa:2048 -days 3650 -nodes -x509 -sha256 -subj '/CN=127.0.0.1/O=localhost/C=US' -keyout "$STUNNEL_CERT_PATH" -out "$STUNNEL_CERT_PATH"
openssl genrsa -out ./auth/stunnel.key 2048
openssl req -new -x509 -key ./auth/stunnel.key -out ./auth/stunnel.pem -days 3650
cat ./auth/stunnel.key ./auth/stunnel.pem >> "$STUNNEL_CERT_PATH"

info "+ Initializing stunnel.conf for clients..."

cat > "$STUNNEL_CONF_PATH" << EOF
cert = cert.pem
#debug = 7
foreground = yes
client = yes

[stunnel.nl]
accept = 127.0.0.1:41194
connect = ${ADDRESS}:443
EOF

success "+ Stunnel config is available at ${STUNNEL_CONF_PATH}"
success "+ Stunnel cert file is available at ${STUNNEL_CERT_PATH}"
