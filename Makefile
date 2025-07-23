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
	deploy-mattermost \
	deploy-public_html \
	deploy-swarmpit \
	deploy-traefik

.PHONY: undeploy
undeploy: \
	undeploy-mattermost \
	undeploy-public_html \
	undeploy-swarmpit \
	undeploy-traefik


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

