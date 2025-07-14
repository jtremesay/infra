include config.mk

all: deploy

.PHONY: context
context:
	docker context create --docker "host=ssh://${DOCKER_CONTEXT}.jtremesay.org" ${DOCKER_CONTEXT}


#########################################################################################
# Services generic
#########################################################################################

.PHONY: deploy
deploy: \
	deploy-games \
	deploy-mattermost \
	deploy-mirrors \
	deploy-nextcloud \
	deploy-openwebui \
	deploy-public_html \
	deploy-swarmpit \
	deploy-traefik \
	deploy-vaultwarden

.PHONY: undeploy
undeploy: \
	undeploy-games \
	undeploy-mattermost \
	undeploy-mirrors \
	undeploy-nextcloud \
	undeploy-openwebui \
	undeploy-public_html \
	undeploy-swarmpit \
	undeploy-traefik \
	undeploy-vaultwarden


#########################################################################################
# games
#########################################################################################

.PHONY: deploy-games
deploy-games:
	$(MAKE) -C games deploy

.PHONY: undeploy-games
undeploy-games:
	$(MAKE) -C games undeploy


#########################################################################################
# mattermost
#########################################################################################

.PHONY: deploy-mattermost
deploy-mattermost:
	$(MAKE) -C mattermost deploy

.PHONY: undeploy-mattermost
undeploy-mattermost:
	$(MAKE) -C mattermost undeploy


#########################################################################################
# mirrors
#########################################################################################

.PHONY: deploy-mirrors
deploy-mirrors:
	$(MAKE) -C mirrors deploy

.PHONY: undeploy-mirrors
undeploy-mirrors:
	$(MAKE) -C mirrors undeploy


#########################################################################################
# nextcloud
#########################################################################################

.PHONY: deploy-nextcloud
deploy-nextcloud:
	$(MAKE) -C nextcloud deploy

.PHONY: undeploy-nextcloud
undeploy-nextcloud:
	$(MAKE) -C nextcloud undeploy


#########################################################################################
# openwebui
#########################################################################################

.PHONY: deploy-openwebui
deploy-openwebui:
	$(MAKE) -C openwebui deploy

.PHONY: undeploy-openwebui
undeploy-openwebui:
	$(MAKE) -C openwebui undeploy


#########################################################################################
# public_html
#########################################################################################

.PHONY: deploy-public_html
deploy-public_html:
	$(MAKE) -C public_html deploy

.PHONY: undeploy-public_html
undeploy-public_html:
	$(MAKE) -C public_html undeploy


#########################################################################################
# swarmpit
#########################################################################################

.PHONY: deploy-swarmpit
deploy-swarmpit:
	$(MAKE) -C swarmpit deploy

.PHONY: undeploy-swarmpit
undeploy-swarmpit:
	$(MAKE) -C swarmpit undeploy


#########################################################################################
# traefik
#########################################################################################

.PHONY: deploy-traefik
deploy-traefik:
	$(MAKE) -C traefik deploy

.PHONY: undeploy-traefik
undeploy-traefik:
	$(MAKE) -C traefik undeploy


#########################################################################################
# vaultwarden
#########################################################################################

.PHONY: deploy-vaultwarden
deploy-vaultwarden:
	$(MAKE) -C vaultwarden deploy

.PHONY: undeploy-vaultwarden
undeploy-vaultwarden:
	$(MAKE) -C vaultwarden undeploy

