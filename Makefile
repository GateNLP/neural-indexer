# Give Make something to do if called without args
all: all-profile-composes

# The generated compose files are dependent on the Python environment and the scripts that generate them
COMPOSE_PREREQS := Pipfile.lock embedder/compose_generator.py embedder/flow.py

# Resolve yml files to the embedder/profiles dir
vpath %.yml embedder/profiles

# Build our system compose files using the script
# This actually uses make properly, so won't run if prerequisites haven't changed
dev.yml: $(COMPOSE_PREREQS)
	pipenv run python3 embedder/compose_generator.py dev --is-system

dev-gpu.yml: $(COMPOSE_PREREQS)
	pipenv run python3 embedder/compose_generator.py dev-gpu --gpu --is-system

prod.yml: $(COMPOSE_PREREQS)
	pipenv run python3 embedder/compose_generator.py prod --replicas 3 --gpu --is-system

.PHONY: all-profile-composes
all-profile-composes: dev.yml dev-gpu.yml prod.yml

.PHONY: lint
lint:
	pipenv run isort **/*.py
	pipenv run black .
	pipenv run flake8 .