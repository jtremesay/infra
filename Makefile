all: infra.mermaid.svg music.mermaid.svg

%.mermaid.svg: %.mermaid
	@echo "Generating $@ from $<"
	@mmdc -i $< -o $@