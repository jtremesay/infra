all: infra.svg music.svg

%.svg: %.d2
	@echo "Generating $@ from $<"
	@d2 --layout=elk $< $@