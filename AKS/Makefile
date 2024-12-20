###################################################################
# Nom du Script  : deployment-automation
# Description    : This Makefile automates the deployment of a containerized 
#    application to Azure Kubernetes Service (AKS). It includes steps 
#    for creating and managing Azure resources, building and pushing 
#    Docker images, and deploying applications to AKS. 
#    Additionally, it provides utility commands for debugging 
#    and monitoring the deployment.
# Retour         : Commands executed successfully or errors encountered during execution.
# Arguments      : Environment variables are loaded from the ../.env file.
# Auteur         : Michel Héon PhD
# Institution    : Cotechnoe Inc.
# Droits d'auteur: Copyright (c) 2024
# Date de création : 24-12-19
# Email          : heon@cotechnoe.com
###################################################################
# Quick Start Guide
# 1. Ensure you have created a .env file based on .env-template.
# 2. Run `make azure-login` to authenticate with Azure.
# 3. Use `make resourcegroup-create` to create the Azure Resource Group.
# 4. Build and push your Docker image with `make docker-build` and `make docker-push`.
# 5. Create an Azure Container Registry with `make acr-create`.
# 5. Deploy the application to AKS using `make application-deploy`.
# 6. For local testing of the Kubernetes deployment:
#    a. Run `make kubernetes-test-setup` to deploy the image locally.
#    b. Access the application via the NodePort on port 8080.
#    c. Use `make kubernetes-test-status` to check deployment status.
#    d. Run `make kubernetes-test-cleanup` to remove the local test setup.
###################################################################

SHELL          := /usr/bin/env bash
PWD            := $(shell pwd)
ROOT_DIR       := $(realpath $(PWD)/../)
TEMPLATE_DIR   := $(ROOT_DIR)/templates
AKS_DIR        := $(ROOT_DIR)/AKS

# Check for .env file existence
ifeq ($(wildcard ../.env),)
$(error ".env file not found. Please create a .env file based on .env-template and configure the necessary environment variables.")
endif

# Include environment variables from .env
include ../.env
export

# Variables
ACR_LOGIN_SERVER := $(ACR_NAME).azurecr.io
DOCKER_IMAGE := $(ACR_LOGIN_SERVER)/$(CONTAINER_NAME):$(IMAGE_TAG)
# sku: Basic, Classic, Premium, Standard
ACR_SKU := Basic

.PHONY: variables-dump deployment-generate azure-login resourcegroup-create acr-create acr-delete acr-login docker-build docker-push kubernetes-test-setup kubernetes-test-cleanup kubernetes-test-status containerservice-register aks-create aks-acr-integrate kubectl-install aks-get-credentials application-deploy service-monitor pods-status pods-logs help

# Utility to dump all variables
variables-dump: ## Dump all Makefile variables
	@$(foreach V,$(sort $(.VARIABLES)),\
		$(if $(filter-out environment% default automatic, $(origin $V)),$(info $V=$($V))))

generate-all: deployment-generate shiro-generate config-generate ## Generate all configuration files

# Generate deployment.yaml from deployment-template.yaml
deployment-generate: ## Generate deployment.yaml from deployment-template.yaml
	@echo "Generating deployment.yaml from deployment-template.yaml..."
	@bash -c 'source $(ROOT_DIR)/.env && envsubst < $(TEMPLATE_DIR)/deployment-template.yaml > $(AKS_DIR)/deployment.yaml'
	@echo "deployment.yaml has been generated successfully."
	
shiro-generate: ## Generate a Shiro.ini configuration file
	cd $(ROOT_DIR) && \
	$(MAKE) log42j.properties && \
	$(MAKE) shiro-generate

config-generate: ## Generate a Fuseki configuration file
	cd $(ROOT_DIR) && \
	$(MAKE) config-generate

# Login to Azure
azure-login: ## Authenticate with Azure
	az login

# Create Azure Resource Group
resourcegroup-create: ## Create Azure Resource Group if it does not exist
	@if [ "$$(az group exists --name $(RESOURCE_GROUP))" = false ]; then \
		echo "Resource group $(RESOURCE_GROUP) does not exist. Creating..."; \
		az group create --name $(RESOURCE_GROUP) --location $(RESOURCE_GROUP_LOCATION); \
	else \
		echo "Resource group $(RESOURCE_GROUP) already exists."; \
	fi

# Create Azure Container Registry
# This command creates an Azure Container Registry (ACR) in the specified resource group.
# - `--resource-group $(RESOURCE_GROUP)`: Specifies the resource group where the ACR will be created.
# - `--name $(ACR_NAME)`: Sets the name of the ACR instance.
# - `--sku Standard`: Defines the pricing tier for the ACR (Standard tier supports unlimited images and 10 webhooks).
acr-create: ## Create Azure Container Registry
	az acr create --resource-group $(RESOURCE_GROUP) --name $(ACR_NAME) --sku $(ACR_SKU)

# Delete Azure Container Registry
acr-delete: ## Delete Azure Container Registry
	az acr delete --resource-group $(RESOURCE_GROUP) --name $(ACR_NAME) --yes

# Login to Azure Container Registry
acr-login: ## Login to Azure Container Registry
	az acr login --name $(ACR_NAME)

# Build Docker Image
docker-build: ## Build the Docker image for the application
	cd ../ && \
	docker build -t $(DOCKER_IMAGE) .

# Push Docker Image to ACR
docker-push: acr-login ## Push the Docker image to Azure Container Registry
	cd ../ && \
	docker push $(DOCKER_IMAGE)

kubernetes-test-cleanup: ## Clean up the local Kubernetes test setup
	kubectl delete service $(IMAGE_NAME)
	kubectl delete deployment $(IMAGE_NAME)

kubernetes-test-status: ## Check the status of the local Kubernetes test setup
	kubectl get all -l app=$(IMAGE_NAME)

kubernetes-test-setup: ## Set up a local Kubernetes cluster for testing
	@if ! nslookup $(AKS_CLUSTER_FQDN) > /dev/null 2>&1; then \
		echo "DNS resolution failed for $(AKS_CLUSTER_FQDN). Ensure the AKS cluster exists and is accessible."; \
		exit 1; \
	fi
	kubectl create deployment $(IMAGE_NAME) --image=$(DOCKER_IMAGE)
	kubectl expose deployment $(IMAGE_NAME) --type=NodePort --port=3030

# Register the Microsoft.ContainerService resource provider
containerservice-register: ## Register the Microsoft.ContainerService resource provider
	az provider register --namespace Microsoft.ContainerService --wait

# Create AKS Cluster
aks-create: containerservice-register ## Create Azure Kubernetes Service (AKS) cluster
	az aks create --resource-group $(RESOURCE_GROUP) --name $(AKS_CLUSTER) --node-count 1 --enable-addons monitoring --generate-ssh-keys

# Integrate AKS with ACR
aks-acr-integrate: ## Grant AKS access to pull images from ACR
	az aks update -n $(AKS_CLUSTER) -g $(RESOURCE_GROUP) --attach-acr $(ACR_NAME)

# Install kubectl
kubectl-install: ## Install kubectl command-line tool
	sudo az aks install-cli

# Get AKS Credentials
aks-get-credentials: ## Retrieve AKS cluster credentials for kubectl
	az aks get-credentials --resource-group $(RESOURCE_GROUP) --name $(AKS_CLUSTER)

.PHONY: aks-validate
aks-validate: ## Validate the existence of the AKS cluster
	@if ! az aks show --resource-group $(RESOURCE_GROUP) --name $(AKS_CLUSTER) > /dev/null 2>&1; then \
		echo "AKS cluster $(AKS_CLUSTER) in resource group $(RESOURCE_GROUP) not found."; \
		exit 1; \
	fi
	
# Deploy Application to AKS
application-deploy: aks-get-credentials ## Deploy the application to AKS
	kubectl apply -f $(DEPLOYMENT_FILE)

application-delete: ## Delete the application from AKS:
	@echo "Deleting application..."
	@kubectl delete deployment cotechnoe-jena-fuseki-deployment || true
	@kubectl delete service cotechnoe-jena-fuseki-service || true
	@echo "Deleting complete."
	
# Monitor the service for external IP
service-monitor: ## Monitor the service to obtain the external IP address
	kubectl get service $(K8S_IMAGE_NAME)-service --watch

service-url-fetch: ## Fetch the application URL
	@echo "Fetching application URL..."
	@kubectl get svc $(K8S_IMAGE_NAME)-service -o json | jq -r '"http://" + .status.loadBalancer.ingress[0].ip + ":3030"'

service-list: ## List exposed services
	@echo "Listing exposed services..."
	@kubectl get svc --output=wide

service-browser: ## Open the application in the browser:
	@echo "Opening application in the browser..."
	@URL=$$(kubectl get svc $(K8S_IMAGE_NAME)-service -o json | jq -r '"http://" + .status.loadBalancer.ingress[0].ip + ":3030"'); \
	if [ "$$URL" = "http://null:3030" ]; then \
		echo "Service is not yet ready. No IP assigned."; \
	else \
		echo "Launching browser at $$URL"; \
		xdg-open $$URL || open $$URL; \
	fi

# Get Pod Status
pods-status: ## Get the status of the pods
	kubectl get pods -n default -l app=$(K8S_IMAGE_NAME)

# Get Pod Logs
pods-logs: ## Get the logs of the pods
	kubectl logs -n default -l app=$(K8S_IMAGE_NAME)


# Display help message
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
