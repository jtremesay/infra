include config.mk

all: deploy


########################################################################################
# Generic
########################################################################################

.PHONY: deploy
deploy: \
    deploy-mattermost \
	deploy-nextcloud \
	deploy-rssbridge \
	deploy-traefik

.PHONY: undeploy
undeploy: \
	undeploy-mattermost \
	undeploy-nextcloud \
	undeploy-rssbridge \
	undeploy-traefik

.PHONY: context
context:
	docker context create --docker "host=ssh://${DOCKER_CONTEXT}.jtremesay.org" ${DOCKER_CONTEXT}


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
# Traefik
#########################################################################################

.PHONY: deploy-traefik
deploy-traefik:
	$(MAKE) -C traefik deploy

.PHONY: undeploy-traefik
undeploy-traefik:
	$(MAKE) -C traefik undeploy

