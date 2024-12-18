# Project Deployment Guide

This guide provides detailed steps to deploy your application on Azure Kubernetes Service (AKS) using the provided `Makefile`, `.env` configuration file, and deployment templates.

## Prerequisites

Ensure you have the following tools installed:

- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
- [Docker](https://docs.docker.com/get-docker/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [envsubst](https://www.gnu.org/software/gettext/manual/html_node/envsubst-Invocation.html) (included in GNU `gettext`)

## Naming convention

Microsoft recommends adopting consistent naming conventions for Azure resources to enhance management and identification. Key guidelines include:

- **Allowed Characters**: Resource names can include alphanumeric characters (`a-z`, `A-Z`, `0-9`). Some resource types also permit hyphens (`-`) and underscores (`_`); however, specific restrictions vary by resource type. 

- **Length Constraints**: The permissible length for resource names depends on the resource type. For instance, a resource group name can range from 1 to 90 characters, while a storage account name must be between 3 and 24 characters. 

- **Uniqueness**: Certain resources require globally unique names, especially services with public endpoints. For example, Azure Storage account names must be unique across all of Azure. 

An effective naming convention may include elements such as resource type, business unit, application name, environment, region, and instance identifier. For example, a virtual machine used by the marketing department for the "Navigator" application in the production environment, deployed in the West Europe region, could be named:

```
vm-mktg-navigator-prod-weu-01
```

Where:

- `vm`: Resource Type (Virtual Machine)
- `mktg`: Business Unit (Marketing)
- `navigator`: Application Name
- `prod`: Environment (Production)
- `weu`: Region (West Europe)
- `01`: Instance

For more detailed guidelines and specific recommendations, refer to Microsoft's official documentation on naming conventions and resource tagging.  

## Setup Instructions

1. **Clone the Repository**:

   ```bash
   git clone https://github.com/your_username/your_repository.git
   cd your_repository
   ```

2. **Configure Environment Variables**:

   - Duplicate the `.env-template` file and rename it to `.env`:

     ```bash
     cp .env-template .env
     ```

   - Open the `.env` file and replace the default values with those corresponding to your specific configuration. For example:

     ```dotenv
     RESOURCE_GROUP=your_resource_group_name
     RESOURCE_GROUP_LOCATION=your_resource_group_location
     ACR_NAME=your_acr_name
     AKS_CLUSTER=your_aks_cluster_name
     IMAGE_NAME=your_image_name
     IMAGE_TAG=your_image_tag
     DEPLOYMENT_FILE=deployment.yaml
     ```

   **Note**: Ensure that the `.env` file is included in your `.gitignore` to prevent sensitive information from being tracked in version control.

3. **Generate the `deployment.yaml` File**:

   - Use the following command to create the `deployment.yaml` file from the template:

     ```bash
     make generate-deployment
     ```

   This command uses `envsubst` to replace environment variables in `deployment-template.yaml` and generates the `deployment.yaml` file.

## Deployment Steps

1. **Authenticate with Azure**:

   ```bash
   make azure-login
   ```

2. **Create the Azure Resource Group**:

   ```bash
   make create-resource-group
   ```

   This command checks if the specified resource group exists and creates it if it does not.

3. **Create an Azure Container Registry (ACR)**:

   ```bash
   make create-acr
   ```

4. **Log in to Azure Container Registry**:

   ```bash
   make acr-login
   ```

5. **Build and Push the Docker Image**:

   - Build the Docker image:

     ```bash
     make docker-build
     ```

   - Push the Docker image to ACR:

     ```bash
     make docker-push
     ```

6. **Create an Azure Kubernetes Service (AKS) Cluster**:

   ```bash
   make create-aks
   ```

7. **Integrate AKS with ACR**:

   ```bash
   make aks-acr-integration
   ```

8. **Install `kubectl`** (if not already installed):

   ```bash
   make install-kubectl
   ```

9. **Retrieve AKS Cluster Credentials**:

   ```bash
   make get-credentials
   ```

10. **Deploy the Application to AKS**:

    ```bash
    make deploy
    ```

11. **Monitor the Service to Obtain the External IP Address**:

    ```bash
    make watch-service
    ```

    This command monitors the service until an external IP address is assigned.

## Additional Information

- **Makefile Targets**:

  - `azure-login`: Authenticate with Azure.
  - `create-resource-group`: Create the Azure Resource Group if necessary.
  - `create-acr`: Create an Azure Container Registry.
  - `acr-login`: Log in to Azure Container Registry.
  - `docker-build`: Build the application's Docker image.
  - `docker-push`: Push the Docker image to Azure Container Registry.
  - `create-aks`: Create an Azure Kubernetes Service (AKS) cluster.
  - `aks-acr-integration`: Grant AKS access to pull images from ACR.
  - `install-kubectl`: Install the `kubectl` command-line tool.
  - `get-credentials`: Retrieve AKS cluster credentials for `kubectl`.
  - `deploy`: Deploy the application to AKS.
  - `watch-service`: Monitor the service to obtain the external IP address.
  - `generate-deployment`: Generate `deployment.yaml` from `deployment-template.yaml`.

- **Error Handling**:

  - The `Makefile` checks for the existence of the `.env` file. If it is missing, an error message is displayed:

    ```
    .env file not found. Please create a .env file based on .env-template and configure the necessary environment variables.
    ```

  - Ensure that all required environment variables are correctly defined in the `.env` file to avoid issues during deployment.

## References

- [Azure Kubernetes Service Documentation](https://learn.microsoft.com/en-us/azure/aks/)
- [Docker Documentation](https://docs.docker.com/)
- [Kubernetes Documentation](https://kubernetes.io/docs/home/)

By following these instructions, you can deploy your application on Azure Kubernetes Service using the provided `Makefile` and configuration templates. 