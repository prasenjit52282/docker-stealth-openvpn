##
# Docker Stealth OpenVPN
#
# @file
# @version 0.1
COLOUR_GREEN=\033[0;32m
COLOUR_RED=\033[0;31m
COLOUR_BLUE=\033[0;34m
END_COLOR=\033[0m

all:
	@echo "$(COLOUR_RED)deploy:$(END_COLOR) deploy the stunnel and open-vpn stack"
	@echo "$(COLOUR_RED)init:$(END_COLOR) initialize the certificates and configs"
	@echo "$(COLOUR_RED)up:$(END_COLOR) run the vpn service"
	@echo "$(COLOUR_RED)ps:$(END_COLOR) list running containers"
	@echo "$(COLOUR_RED)clean:$(END_COLOR) stop and remove the containers"
	@echo "$(COLOUR_RED)restart:$(END_COLOR)restart the service"
	@echo "$(COLOUR_RED)add_user:$(END_COLOR) add user"
	@echo "$(COLOUR_RED)rm_user:$(END_COLOR) remove user"

init:
	bin/init.sh

up:
	docker-compose up -d

ps:
	docker ps

clean:
	docker-compose down --rmi all

restart:
	docker ps -aq | xargs sudo docker restart

add_user:
	bin/client.sh

rm_user:
	bin/revoke.sh
	docker-compose restart openvpn

config_ufw_firewall:
	ufw allow ssh
	ufw allow 443
	ufw enable
	ufw status

deploy:
	$(MAKE) init
	$(MAKE) up
	$(MAKE) config_ufw_firewall

# end
