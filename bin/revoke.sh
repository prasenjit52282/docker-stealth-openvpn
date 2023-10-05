#!/usr/bin/env bash

set -e

CLIENTS_DIR="./vclient/config"
printf "Username: "
read -r USERNAME

if [ "$USERNAME" = "" ]; then
    echo "Username was empty"
    exit 1
fi

docker-compose -f docker-compose-server.yml run --rm openvpn easyrsa revoke ${USERNAME}
docker-compose -f docker-compose-server.yml run --rm openvpn easyrsa gen-crl
rm -rfv "$CLIENTS_DIR/$USERNAME".ovpn
