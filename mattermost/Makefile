include ../config.mk
include config.mk

deploy:
	DOCKER_CONTEXT=${DOCKER_CONTEXT} docker stack deploy --compose-file compose.yml --prune ${STACK_NAME}

undeploy:
	DOCKER_CONTEXT=${DOCKER_CONTEXT} docker stack rm traefik ${STACK_NAME}
