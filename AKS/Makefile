# Check for .env file existence
ifeq ($(wildcard .env),)
$(error ".env file not found. Please create a .env file based on .env-template and configure the necessary environment variables.")
endif

# Include environment variables from .env
include .env
export

# Variables
ACR_LOGIN_SERVER := $(ACR_NAME).azurecr.io
DOCKER_IMAGE := $(ACR_LOGIN_SERVER)/$(IMAGE_NAME):$(IMAGE_TAG)

# Generate deployment.yaml from deployment-template.yaml
.PHONY: generate-deployment
generate-deployment: ## Generate deployment.yaml from deployment-template.yaml
	@echo "Generating deployment.yaml from deployment-template.yaml..."
	@bash -c 'source .env && envsubst < deployment-template.yaml > deployment.yaml'
	@echo "deployment.yaml has been generated successfully."

# Login to Azure
.PHONY: azure-login
azure-login: ## Authenticate with Azure
	az login

# Create Azure Container Registry
.PHONY: create-acr
create-acr: ## Create Azure Container Registry
	az acr create --resource-group $(RESOURCE_GROUP) --name $(ACR_NAME) --sku Standard

# Login to Azure Container Registry
.PHONY: acr-login
acr-login: ## Login to Azure Container Registry
	az acr login --name $(ACR_NAME)

# Create Azure Resource Group
.PHONY: create-resource-group
create-resource-group: ## Create Azure Resource Group if it does not exist
	@if [ "$$(az group exists --name $(RESOURCE_GROUP))" = false ]; then \
		echo "Resource group $(RESOURCE_GROUP) does not exist. Creating..."; \
		az group create --name $(RESOURCE_GROUP) --location $(RESOURCE_GROUP_LOCATION); \
	else \
		echo "Resource group $(RESOURCE_GROUP) already exists."; \
	fi

# Build Docker Image
.PHONY: docker-build
docker-build: ## Build the Docker image for the application
	cd ../ && \
	docker build -t $(DOCKER_IMAGE) .

# Push Docker Image to ACR
.PHONY: docker-push
docker-push: acr-login ## Push the Docker image to Azure Container Registry
	cd ../ && \
	docker push $(DOCKER_IMAGE)

# Create AKS Cluster
.PHONY: create-aks
create-aks: ## Create Azure Kubernetes Service (AKS) cluster
	az aks create --resource-group $(RESOURCE_GROUP) --name $(AKS_CLUSTER) --node-count 1 --enable-addons monitoring --generate-ssh-keys

# Integrate AKS with ACR
.PHONY: aks-acr-integration
aks-acr-integration: ## Grant AKS access to pull images from ACR
	az aks update -n $(AKS_CLUSTER) -g $(RESOURCE_GROUP) --attach-acr $(ACR_NAME)

# Install kubectl
.PHONY: install-kubectl
install-kubectl: ## Install kubectl command-line tool
	az aks install-cli

# Get AKS Credentials
.PHONY: get-credentials
get-credentials: ## Retrieve AKS cluster credentials for kubectl
	az aks get-credentials --resource-group $(RESOURCE_GROUP) --name $(AKS_CLUSTER)

# Deploy Application to AKS
.PHONY: deploy
deploy: get-credentials ## Deploy the application to AKS
	kubectl apply -f $(DEPLOYMENT_FILE)

# Watch Service for External IP
.PHONY: watch-service
watch-service: ## Monitor the service to obtain the external IP address
	kubectl get service jena-fuseki-service --watch

# Display help message
.PHONY: help
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
