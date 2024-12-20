###################################################################
# Nom du Script  : manage-fuseki
# Description    : This Makefile is designed to manage a Jena Fuseki 
#    containerized environment, allowing for actions such as building 
#    Docker images, running Fuseki instances (both in-memory and TDB2-based), l
#    oading data, querying datasets, and generating configuration files. 
#    It simplifies workflows related to Jena Fuseki by providing a set of 
#    predefined commands for container lifecycle management, data 
#    interaction, and configuration generation. This script is 
#    essential for developers and administrators working with 
#    RDF datasets and SPARQL endpoints.
# Retour         : Outputs of various commands, such as logs, 
#    success or error messages from Docker and Fuseki interactions.
# Arguments      : No direct arguments. Targets may depend on 
#    external files such as `.env`, `shiro-template.ini`, 
#    `config-template.ttl`, `data/paul-family.ttl`, 
#    and `query.rq`.
# Auteur         : Michel Héon PhD
# Institution    : Cotechnoe Inc.
# Droits d'auteur: Copyright (c) 2024
# Date de création : 2024-12-19
# Email          : heon@cotechnoe.com
# Quick Start    :
#  1. Build the Docker image: make image-build
#  2. Start Fuseki container: make container-start
#  3. Load data into Fuseki:  make data-load
#  4. Query the dataset:      make data-query
###################################################################

SHELL          := /usr/bin/env bash
PWD            := $(shell pwd)
ROOT_DIR       := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
TEMPLATE_DIR   := $(ROOT_DIR)/templates
# Check for .env file existence
ifeq ($(wildcard .env),)
$(error ".env file not found. Please create a .env file based on .env-template and configure the necessary environment variables.")
endif

# Include environment variables from .env
include .env
export

# Data file path
DATA_FILE = ./data/paul-family.ttl

# SPARQL query file
QUERY_FILE = ./query.rq

# Fuseki dataset and endpoints
FUSEKI_DATASET = dataset
FUSEKI_UPDATE_URL = http://localhost:3030/$(FUSEKI_DATASET)/data?default
FUSEKI_QUERY_URL = http://localhost:3030/$(FUSEKI_DATASET)/sparql

.PHONY: image-build container-start container-start-tdb2 data-load data-query fuseki-wait container-stop docker-clean logs-show help shiro-generate config-generate

dump-variables: ## Dump all Makefile variables
	@$(foreach V,$(sort $(.VARIABLES)),\
		$(if $(filter-out environment% default automatic, $(origin $V)),$(info $V=$($V))))

image-build: shiro-generate config-generate log42j.properties ## Build the Docker image
	docker build -t $(IMAGE_NAME) .

log42j.properties: $(TEMPLATE_DIR)/log42j.properties
	cp $(TEMPLATE_DIR)/log42j.properties log42j.properties

shiro-generate: ## Generate a Shiro.ini configuration file
	@echo "Generating shiro.ini from shiro-template.ini..."
	@bash -c 'source $(ROOT_DIR)/.env && envsubst < $(TEMPLATE_DIR)/shiro-template.ini > $(ROOT_DIR)/shiro.ini'
	@echo "shiro.ini has been generated successfully."

config-generate: ## Generate a Fuseki configuration file
	@echo "Generating configuration file from config-template.ttl..."
	@bash -c 'source $(ROOT_DIR)/.env && envsubst < $(TEMPLATE_DIR)/config-template.ttl > $(ROOT_DIR)/config.ttl'
	@echo "config.ttl has been generated successfully."

container-run: container-stop ## Start Fuseki container with TDB2 dataset
	docker run -d --rm -p 3030:3030 -e FUSEKI_DATASET=$(FUSEKI_DATASET) --name $(CONTAINER_NAME) $(IMAGE_NAME)

container-run-persistent: container-stop ## Start Fuseki with persistent data storage
	docker run -d -p 3030:3030 -v $(ROOT_DIR)/data:/data -e FUSEKI_DATASET=$(FUSEKI_DATASET) --name $(CONTAINER_NAME) $(IMAGE_NAME)

container-remove: ## Remove existing container with the same name
	@docker ps -aq -f name=$(CONTAINER_NAME) | xargs -r docker rm -f

container-restart-persistent: ## Restart or start the Fuseki container with persistent data
	@docker ps -a -q -f name=$(CONTAINER_NAME) | grep -q . && \
		docker start $(CONTAINER_NAME) || \
		docker run -d -p 3030:3030 -v $(ROOT_DIR)/data:/data -e FUSEKI_DATASET=$(FUSEKI_DATASET) --name $(CONTAINER_NAME) $(IMAGE_NAME)

data-load: fuseki-wait ## Load RDF data into the Fuseki dataset
	@echo "Loading data from $(DATA_FILE) into Fuseki dataset $(FUSEKI_DATASET)..."
	curl -X POST -H "Content-Type: text/turtle" --data-binary @$(DATA_FILE) $(FUSEKI_UPDATE_URL)
	@echo "\nData loading completed."

data-query: fuseki-wait ## Execute a SPARQL query on the Fuseki dataset
	@echo "Executing SPARQL query from $(QUERY_FILE) on Fuseki dataset $(FUSEKI_DATASET)..."
	curl -X POST -H "Content-Type: application/sparql-query" -H "Accept: text/turtle" --data-binary @$(QUERY_FILE) $(FUSEKI_QUERY_URL)
	@echo "\nQuery execution completed."

fuseki-wait: ## Wait until Fuseki is ready to accept requests
	@echo "Waiting for Fuseki to start..."
	@until curl -s http://localhost:3030/ >/dev/null; do \
		echo "Fuseki is not available yet..."; \
		sleep 2; \
	done
	@echo "Fuseki is up and running."

container-stop: ## Stop the running Fuseki container
	@docker stop $(CONTAINER_NAME) || true

logs-show: ## Display logs of the running Fuseki container
	@docker logs -f $(CONTAINER_NAME)

docker-clean: container-stop ## Clean up Docker resources
	docker rmi $(IMAGE_NAME) || true

help: ## Display the list of available targets and their descriptions
	@echo "Available targets:"
	@awk '/^[a-zA-Z0-9_-]+:/ { \
		split($$0, a, ":"); \
		helpMsg = match($$0, /## (.*)/); \
		target = a[1]; \
		if (helpMsg) { \
			comment = substr($$0, RSTART + 3); \
			printf "  %-25s : %s\n", target, comment; \
		} \
	}' $(MAKEFILE_LIST)
