# Give Make something to do if called without args
all: all-preset-composes

# The generated compose files are dependent on the Python environment and the scripts that generate them
COMPOSE_PREREQS := Pipfile.lock embedder/compose_generator.py embedder/flow.py

# Look for .yml files first in the user profiles then in default profiles
vpath %.yml embedder/profiles/user
vpath %.yml embedder/profiles

# Our embedder compose file profiles - these are actually built using Make properly!
# i.e. they won't be rebuilt if the prerequisites haven't changed
dev.yml: $(COMPOSE_PREREQS)
	pipenv run python3 embedder/compose_generator.py dev --is-system

dev-gpu.yml: $(COMPOSE_PREREQS)
	pipenv run python3 embedder/compose_generator.py dev-gpu --gpu --is-system

prod.yml: $(COMPOSE_PREREQS)
	pipenv run python3 embedder/compose_generator.py prod --replicas 3 --gpu --is-system

all-preset-composes: dev.yml dev-gpu.yml prod.yml

# Get a list of profiles that actually exist
# This is so custom profiles are selectable too
#   Builds a list of filenames (e.g. embedder-dev.yml, embedder-dev-gpu.yml, etc)
compose_files = $(join $(wildcard embedder/profiles/*.yml), $(wildcard embedder/profiles/user/*.yml))
compose_filenames = $(notdir $(compose_files))
#   Strips out just the profile name (e.g. dev, dev-gpu, etc)
profile_names = $(patsubst -%.yml, %, )
#   If the user overrides one of the default configurations, this list will
#     have duplicates, but that doesn't matter because we `vpath` from profiles/user first.

.PHONY: $(addprefix 'use-', profile_names)
# use-PROFILE is dependent on embedder-PROFILE.yml
# This is resolved to embedder/embedder-PROFILE.yml by the vpath
# - If this is one of our profiles, defined above, Make will build it then run the command
# - If not, Make considers it built already and will just run the command
# - If it doesn't exist, it will fail because Make doesn't know how to build it
use-%: %.yml
	echo $< > .embedder-profile

# ==================
# A horrifying hack to avoid the lengthy docker compose command
# Adapted from https://stackoverflow.com/a/14061796/5257483

PASSTHROUGH_TARGETS := dc
ifneq ($(filter $(firstword $(MAKECMDGOALS)),$(PASSTHROUGH_TARGETS)),)
  RUN_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  $(eval $(RUN_ARGS):;@:)
endif

CHOSEN_COMPOSE := $(shell cat .embedder-profile)
.PHONY: dc
dc: 
	docker compose -f docker-compose.yml -f $(CHOSEN_COMPOSE) $(RUN_ARGS)
# ==================

# Some useful Docker Compose shortcuts
.PHONY: watch-health
watch-health:
	watch make dc ps

.PHONY: logs
watch-logs:
	make -- dc logs --follow --tail 20

.PHONY: lint
lint:
	pipenv run isort **/*.py
	pipenv run black .
	pipenv run flake8 .