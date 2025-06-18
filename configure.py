#!/usr/bin/env python3
from argparse import ArgumentParser
from pathlib import Path

from jinja2 import Template

services = {
    "freshrss": True,
    "games": True,
    "mattermost": True,
    "mirrors": True,
    "nextcloud": True,
    "openwebui": True,
    "rssbridge": True,
    "swarmpit": True,
    "traefik": True,
    "vaultwarden": True,
}

template = Template(
    """\
include config.mk

all: deploy

.PHONY: context
context:
\tdocker context create --docker "host=ssh://${DOCKER_CONTEXT}.jtremesay.org" ${DOCKER_CONTEXT}


#########################################################################################
# Services generic
#########################################################################################

.PHONY: deploy
deploy:{% for service in services %} \\
\tdeploy-{{ service }}{% endfor %}

.PHONY: undeploy
undeploy:{% for service in services %} \\
\tundeploy-{{ service }}{% endfor %}

{% for service in services %}
#########################################################################################
# {{ service }}
#########################################################################################

.PHONY: deploy-{{ service }}
deploy-{{ service }}:
\t$(MAKE) -C {{ service }} deploy

.PHONY: undeploy-{{ service }}
undeploy-{{ service }}:
\t$(MAKE) -C {{ service }} undeploy

{% endfor %}
"""
)


def main():
    parser = ArgumentParser()
    for service, is_enabled in services.items():
        parser.add_argument(
            f"--enable-{service}",
            action="store_true",
            dest=service,
            default=is_enabled,
            help="default" if is_enabled else "",
        )
        parser.add_argument(
            f"--disable-{service}",
            action="store_false",
            dest=service,
            default=not is_enabled,
            help="default" if not is_enabled else "",
        )
    args = parser.parse_args()

    enabled_services = []
    for service in services:
        is_enabled = getattr(args, service)
        if is_enabled:
            enabled_services.append(service)

    result = template.render(services=enabled_services)
    Path("Makefile").write_text(result)


if __name__ == "__main__":
    main()
