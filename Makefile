# Image and container names
IMAGE_NAME = jena-fuseki:5.2.0
CONTAINER_NAME = jena-fuseki

# Data file path
DATA_FILE = ./data/paul-family.ttl

# SPARQL query file
QUERY_FILE = ./query.rq

# Fuseki dataset and endpoint
FUSEKI_DATASET = dataset
FUSEKI_UPDATE_URL = http://localhost:3030/$(FUSEKI_DATASET)/data?default
FUSEKI_QUERY_URL = http://localhost:3030/$(FUSEKI_DATASET)/sparql

.PHONY: build run run-tdb2 load wait-for-fuseki stop clean

# Build the Docker image
build:
	docker build -t $(IMAGE_NAME) .

# Run Fuseki with an in-memory dataset
run: stop
	docker run -d --rm -p 3030:3030 --name $(CONTAINER_NAME) $(IMAGE_NAME)

# Run Fuseki with a TDB2 dataset using the provided configuration
run-tdb2: stop
	docker run -d --rm -p 3030:3030 --name $(CONTAINER_NAME) $(IMAGE_NAME) --conf /fuseki/config-tdb2.ttl

# Load data into the Fuseki dataset
load: wait-for-fuseki
	@echo "Loading data from $(DATA_FILE) into Fuseki dataset $(FUSEKI_DATASET)..."
	curl -X POST -H "Content-Type: text/turtle" --data-binary @$(DATA_FILE) $(FUSEKI_UPDATE_URL)
	@echo "\nData loading completed."

query: wait-for-fuseki
	@echo "Sending SPARQL query from $(QUERY_FILE) to Fuseki dataset $(FUSEKI_DATASET)..."
	curl -X POST -H "Content-Type: application/sparql-query" -H "Accept: text/turtle" --data-binary @$(QUERY_FILE) $(FUSEKI_QUERY_URL)
	@echo "\nQuery execution completed."

# Wait for Fuseki to be ready
wait-for-fuseki:
	@echo "Waiting for Fuseki to start..."
	@until curl -s http://localhost:3030/ >/dev/null; do \
		echo "Fuseki is not available yet..."; \
		sleep 2; \
	done
	@echo "Fuseki is up and running."

# Stop the running Fuseki container
stop:
	@docker stop $(CONTAINER_NAME) || true

# Clean up Docker resources
clean: stop
	docker rmi $(IMAGE_NAME) || true
