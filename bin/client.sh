#!/usr/bin/env bash

set -e

# shellcheck source=./common.sh
. "${BASH_SOURCE%/*}/common.sh"

printf "Username: "
read -r USERNAME

CONFIG_DIR="./vclient/config"
CONFIG_PATH="${CONFIG_DIR}/${USERNAME}".ovpn

if [ "$USERNAME" = "" ]; then
    echo "Username was empty"
    exit 1
fi

mkdir -p $CONFIG_DIR

function create_user {
    info "+ Start user generation..."
    docker-compose -f docker-compose-server.yml run --rm openvpn easyrsa build-client-full "$USERNAME" nopass
    success "+ User generation complet"
}

function download_user {
    info "+ Downloading user client..."
    docker-compose -f docker-compose-server.yml run --rm openvpn ovpn_getclient "$USERNAME" > "$CONFIG_PATH"
    sed -i "s/^remote .*\r$/remote mystunnel 41194 tcp\r/g" "$CONFIG_PATH"
    success "+ User profile downloaded at $CONFIG_PATH, copy it in proxy sClient.ovpn file"
}

case $1 in
    "get")
        download_user
        ;;
    *)
        create_user
        download_user
        ;;
esac
