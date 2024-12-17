# Image and container names
IMAGE_NAME = jena-fuseki:5.2.0
CONTAINER_NAME = jena-fuseki

# Data file path
DATA_FILE = ./data/paul-family.ttl

# SPARQL query file
QUERY_FILE = ./query.rq

# Fuseki dataset and endpoints
FUSEKI_DATASET = dataset
FUSEKI_UPDATE_URL = http://localhost:3030/$(FUSEKI_DATASET)/data?default
FUSEKI_QUERY_URL = http://localhost:3030/$(FUSEKI_DATASET)/sparql

.PHONY: build run run-tdb2 load query wait-for-fuseki stop clean logs help

build: ## Build the Docker image
	docker build -t $(IMAGE_NAME) .

run: stop ## Start Fuseki with an in-memory dataset
	docker run -d --rm -p 3030:3030 -e FUSEKI_DATASET=$(FUSEKI_DATASET) --name $(CONTAINER_NAME) $(IMAGE_NAME)

run-tdb2: stop ## Start Fuseki with a TDB2 dataset using the provided configuration
	docker run -d --rm -p 3030:3030 -e FUSEKI_DATASET=$(FUSEKI_DATASET) --name $(CONTAINER_NAME) $(IMAGE_NAME) --conf /fuseki/config-tdb2.ttl

load: wait-for-fuseki ## Load data into the Fuseki dataset
	@echo "Loading data from $(DATA_FILE) into Fuseki dataset $(FUSEKI_DATASET)..."
	curl -X POST -H "Content-Type: text/turtle" --data-binary @$(DATA_FILE) $(FUSEKI_UPDATE_URL)
	@echo "\nData loading completed."

query: wait-for-fuseki ## Send a SPARQL query to the Fuseki dataset
	@echo "Sending SPARQL query from $(QUERY_FILE) to Fuseki dataset $(FUSEKI_DATASET)..."
	curl -X POST -H "Content-Type: application/sparql-query" -H "Accept: text/turtle" --data-binary @$(QUERY_FILE) $(FUSEKI_QUERY_URL)
	@echo "\nQuery execution completed."

wait-for-fuseki: ## Wait for Fuseki to be ready
	@echo "Waiting for Fuseki to start..."
	@until curl -s http://localhost:3030/ >/dev/null; do \
		echo "Fuseki is not available yet..."; \
		sleep 2; \
	done
	@echo "Fuseki is up and running."

stop: ## Stop the running Fuseki container
	@docker stop $(CONTAINER_NAME) || true

clean: stop ## Clean up Docker resources
	docker rmi $(IMAGE_NAME) || true

logs: ## Display the logs of the running Fuseki container
	@docker logs -f $(CONTAINER_NAME)

help: ## Display this help message
	@echo "Available targets:"
	@awk '/^[a-zA-Z0-9_-]+:/ { \
		split($$0, a, ":"); \
		helpMsg = match($$0, /## (.*)/); \
		target = a[1]; \
		if (helpMsg) { \
			comment = substr($$0, RSTART + 3); \
			printf "  %-20s : %s\n", target, comment; \
		} \
	}' $(MAKEFILE_LIST)
