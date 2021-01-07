# Environment variable definition
ENV_FILE    = .env
ENV_PARAM   = ENV
ENV_OPTIONS = dev dev-debug stage prod

ERR = 0

# Program file definitions
#DOCKER =
DOCKER = $(shell which docker)
#DOCKER_COMPOSE =
DOCKER_COMPOSE = $(shell which docker-compose)

# Get user and group id
UID ?= $(shell id -u)
GID ?= $(shell id -g)


ifndef DOCKER
	ERR_DOCKER_NOT_INSTALLED = 1
	ERR_DOCKER_NOT_RUNNING   = 1
else
	ifdef $(shell $(DOCKER) ps >/dev/null 2>&1)
		ERR_DOCKER_NOT_RUNNING = 1
	endif
endif

ifndef DOCKER_COMPOSE
	ERR_DOCKER_COMPOSE_NOT_INSTALLED = 1
endif




.PHONY: all help prepare check
.DEFAULT_GOAL := help

all:
	@echo Hello World

check:
	@echo Test $(ERR_DOCKER_COMPOSE_NOT_INSTALLED)
	@echo Test $(ERR_DOCKER_NOT_RUNNING)
	@if [ $(ERR_DOCKER_COMPOSE_NOT_INSTALLED) ]; then \
		echo 'docker-compose' not installed; \
	else \
		echo 'docker-compose' installed; \
	fi

	@if [ $(ERR_DOCKER_NOT_RUNNING) ]; then \
		echo 'docker' not running; \
	else \
		echo 'docker' running; \
	fi

help: ## Print this help screen.
	@echo "This Makefile helps you to install and run this application."
	@echo
	@echo "\033[1mUsage:\033[0m"
	@echo "  make <target>"
	@echo
	@echo "\033[1mExamples:\033[0m"
	@echo "  make install ENV=[$(ENV_OPTIONS)]"
	@echo "  make start"
	@echo
	@echo "\033[1mEnvironments:\033[0m"
	@echo "  $(ENV_OPTIONS)"
	@echo
	@echo "\033[1mTargets:\033[0m"
	@echo "$$(grep -hE '^\S+: .*##.*$$' $(MAKEFILE_LIST) | sed -nE 's/^([a-zA-Z0-9_-]+: ).*## (.*)$$/  \1\2/p' | column -t -c2 -s :)"

prepare:
	@echo $(DOCKER_COMPOSE)
	@echo $(UID)
	@echo $(GID)

install: ## Installs the MHS Core API
	@echo install...

start: ## Starts the MHS Core API
	@echo starting...

stop: ## Stops the MHS Core API
	@echo stopping...

restart: stop start ## Restarts the MHS Core API

prerequisite_check: ## Checks if all required applications are installed and running
	@if [ $(ERR_DOCKER_NOT_INSTALLED) ]; then \
	  echo "[\033[31m✗\033[0m] Docker not installed"; \
	else \
	  echo "[\033[32m✔\033[0m] Docker installed -> $(DOCKER)"; \
	fi

	@if [ $(ERR_DOCKER_NOT_RUNNING) ]; then \
	  echo "[\033[31m✗\033[0m] Docker not running"; \
	else \
	  echo "[\033[32m✔\033[0m] Docker running"; \
	fi

	@if [ $(ERR_DOCKER_COMPOSE_NOT_INSTALLED) ]; then \
	  echo "[\033[31m✗\033[0m] Docker-Compose not installed"; \
	else \
	  echo "[\033[32m✔\033[0m] Docker-Compose installed -> $(DOCKER_COMPOSE)"; \
	fi

