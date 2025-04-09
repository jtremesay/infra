include config.mk

all: deploy


########################################################################################
# Generic
########################################################################################

.PHONY: deploy
deploy: \
	deploy-freshrss \
	deploy-games \
    deploy-mattermost \
	deploy-mirrors \
	deploy-nextcloud \
	deploy-rssbridge \
	deploy-swarmpit \
	deploy-traefik \
	deploy-vaultwarden

.PHONY: undeploy
undeploy: \
	undeploy-freshrss \
	undeploy-games \
	undeploy-mattermost \
	undeploy-mirrors \
	undeploy-nextcloud \
	undeploy-rssbridge \
	undeploy-swarmpit \
	undeploy-traefik \
	undeploy-vaultwarden

.PHONY: context
context:
	docker context create --docker "host=ssh://${DOCKER_CONTEXT}.jtremesay.org" ${DOCKER_CONTEXT}

.PHONY: prune
prune:
	DOCKER_CONTEXT=${DOCKER_CONTEXT} docker system prune --all


#########################################################################################
# FreshRSS
#########################################################################################

.PHONY: deploy-freshrss
deploy-freshrss:
	$(MAKE) -C freshrss deploy

.PHONY: undeploy-freshrss
undeploy-freshrss:
	$(MAKE) -C freshrss undeploy


#########################################################################################
# Games
#########################################################################################

.PHONY: deploy-games
deploy-games:
	$(MAKE) -C games deploy

.PHONY: undeploy-games
undeploy-games:
	$(MAKE) -C games undeploy


#########################################################################################
# Mail
#########################################################################################

.PHONY: deploy-mail
deploy-mail:
	$(MAKE) -C mail deploy

.PHONY: undeploy-mail
undeploy-mail:
	$(MAKE) -C mail undeploy


#########################################################################################
# Mattermost
#########################################################################################

.PHONY: deploy-mattermost
deploy-mattermost:
	$(MAKE) -C mattermost deploy

.PHONY: undeploy-mattermost
undeploy-mattermost:
	$(MAKE) -C mattermost undeploy


#########################################################################################
# Mirrors
#########################################################################################

.PHONY: deploy-mirrors
deploy-mirrors:
	$(MAKE) -C mirrors deploy

.PHONY: undeploy-mirrors
undeploy-mirrors:
	$(MAKE) -C mirrors undeploy


#########################################################################################
# Nextcloud
#########################################################################################

.PHONY: deploy-nextcloud
deploy-nextcloud:
	$(MAKE) -C nextcloud deploy

.PHONY: undeploy-nextcloud
undeploy-nextcloud:
	$(MAKE) -C nextcloud undeploy


#########################################################################################
# RSSBridge
#########################################################################################

.PHONY: deploy-rssbridge
deploy-rssbridge:
	$(MAKE) -C rssbridge deploy

.PHONY: undeploy-rssbridge
undeploy-rssbridge:
	$(MAKE) -C rssbridge undeploy


#########################################################################################
# SwarmPit
#########################################################################################

.PHONY: deploy-swarmpit
deploy-swarmpit:
	$(MAKE) -C swarmpit deploy

.PHONY: undeploy-swarmpit
undeploy-swarmpit:
	$(MAKE) -C swarmpit undeploy


#########################################################################################
# Traefik
#########################################################################################

.PHONY: deploy-traefik
deploy-traefik:
	$(MAKE) -C traefik deploy

.PHONY: undeploy-traefik
undeploy-traefik:
	$(MAKE) -C traefik undeploy



#########################################################################################
# VaultWarden
#########################################################################################

.PHONY: deploy-vaultwarden
deploy-vaultwarden:
	$(MAKE) -C vaultwarden deploy

.PHONY: undeploy-vaultwarden
undeploy-vaultwarden:
	$(MAKE) -C vaultwarden undeploy