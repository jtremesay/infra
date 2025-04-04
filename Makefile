include config.mk

all: deploy


########################################################################################
# Generic
########################################################################################

.PHONY: deploy
deploy: deploy-traefik

.PHONY: undeploy
undeploy: undeploy-traefik

.PHONY: context
context:
	docker context create --docker "host=ssh://${DOCKER_CONTEXT}.jtremesay.org" ${DOCKER_CONTEXT}


#########################################################################################
# Traefik
#########################################################################################

.PHONY: deploy-traefik
deploy-traefik:
	$(MAKE) -C traefik deploy

.PHONY: undeploy-traefik
undeploy-traefik:
	$(MAKE) -C traefik undeploy

