include .$(PWD)/.env
##installation scripts

#----------Common-------------------#
all:
	@echo "see the make file to get all options"

ps:
	@sudo docker ps

restart:
	@sudo docker ps -aq | xargs sudo docker restart


#----------Server-------------------#
install_deps:
	@sudo bin/installdocker.sh

init_server:
	@sudo bin/init.sh $(STUNNEL_PORT)

up_server:
	@sudo docker-compose -f docker-compose-server.yml --env-file .env up -d

rebuild_server:
	@sudo docker-compose -f docker-compose-server.yml --env-file .env up -d --build

clean_server: #to clear server just run this
	@sudo docker-compose -f docker-compose-server.yml down --rmi all
	@sudo rm -rf ovpn-data-store

prune_server:
	$(MAKE) clean_server
	@sudo docker system prune -a

add_user:
	@sudo bin/client.sh

rm_user:
	@sudo bin/revoke.sh
	@sudo docker-compose -f docker-compose-server.yml restart openvpn

config_ufw_firewall:
	@sudo ufw allow ssh
	@sudo ufw allow $(STUNNEL_PORT)
	@sudo ufw enable
	@sudo ufw status

deploy_server: #to deploy server just run this
	$(MAKE) init_server
	$(MAKE) up_server
	$(MAKE) config_ufw_firewall
	$(MAKE) add_user




#----------------Proxy--------------------#
up_proxy:
	@sudo docker-compose -f docker-compose-proxy.yml --env-file .env up -d

rebuild_proxy:
	@sudo docker-compose -f docker-compose-proxy.yml --env-file .env up -d --build

clean_proxy:
	@sudo docker-compose -f docker-compose-proxy.yml down --rmi all

prune_proxy:
	$(MAKE) clean_proxy
	@sudo docker system prune -a

deploy_proxy: #copy the stunnel.key, stunnel.pem, and sClient.ovpn[content from username.ovpn] file from server and run this to deploy proxy
	$(MAKE) up_proxy