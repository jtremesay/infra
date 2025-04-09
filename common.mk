# Raise error if the stack name is not set
ifndef STACK_NAME
$(error STACK_NAME is not set)
endif

include ../config.mk

all: deploy

.PHONY: deploy
deploy:
	DOCKER_CONTEXT=${DOCKER_CONTEXT} docker stack deploy --detach=true --compose-file compose.yml --prune ${STACK_NAME}

.PHONY: undeploy
undeploy:
	DOCKER_CONTEXT=${DOCKER_CONTEXT} docker stack rm ${STACK_NAME}
