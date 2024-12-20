# Apache Jena Fuseki Deployment on Azure Kubernetes Service (AKS)

This guide provides detailed steps to deploy your application on Azure Kubernetes Service (AKS) using the provided `Makefile`, `.env` configuration file, and deployment templates.

## Prerequisites

Ensure you have the following tools installed:

- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
- [Docker](https://docs.docker.com/get-docker/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [envsubst](https://www.gnu.org/software/gettext/manual/html_node/envsubst-Invocation.html) (included in GNU `gettext`)

## Naming Convention

Microsoft recommends adopting consistent naming conventions for Azure resources to enhance management and identification.

## Quick Start

To streamline the deployment of your application on Azure Kubernetes Service (AKS), follow these quick start steps:

1. **Clone the Repository**:

    ```bash
    git clone https://github.com/michel-heon/jena-fuseki-docker.git
    cd jena-fuseki-docker/AKS
    ```

2. **Set Up Environment Variables**:

    - Duplicate the `.env-template` file and rename it to `.env`:

        ```bash
        cp .env-template .env
        ```

    - Edit the `.env` file to reflect your specific configuration:

        ```dotenv
        RESOURCE_GROUP=your_resource_group_name
        RESOURCE_GROUP_LOCATION=your_resource_group_location
        ACR_NAME=your_acr_name
        AKS_CLUSTER=your_aks_cluster_name
        IMAGE_NAME=your_image_name
        IMAGE_TAG=your_image_tag
        DEPLOYMENT_FILE=deployment.yaml
        ```

3. **Generate the Deployment File**:

    ```bash
    make deployment-generate
    ```

4. **Authenticate with Azure**:

    ```bash
    make azure-login
    ```

5. **Create Azure Resources**:

    - Create the Resource Group:

        ```bash
        make resourcegroup-create
        ```

    - Create the Azure Container Registry (ACR):

        ```bash
        make acr-create
        ```

6. **Build and Deploy the Application**:

    - Log in to ACR:

        ```bash
        make acr-login
        ```

    - Build the Docker Image:

        ```bash
        make docker-build
        ```

    - Push the Docker Image to ACR:

        ```bash
        make docker-push
        ```

    - Integrate AKS with ACR:

        ```bash
        make aks-acr-integrate
        ```

    - Retrieve AKS Cluster Credentials:

        ```bash
        make aks-get-credentials
        ```

    - Deploy the Application to AKS:

        ```bash
        make application-deploy
        ```

7. **Monitor the Deployment**:

    ```bash
    make service-monitor
    ```

For detailed explanations and additional options, refer to the [Azure Kubernetes Service Documentation](https://learn.microsoft.com/en-us/azure/aks/).

## Additional Information

- **Makefile Targets**:

    - `azure-login`: Authenticate with Azure.
    - `resourcegroup-create`: Create the Azure Resource Group if necessary.
    - `acr-create`: Create an Azure Container Registry.
    - `acr-login`: Log in to Azure Container Registry.
    - `docker-build`: Build the application's Docker image.
    - `docker-push`: Push the Docker image to Azure Container Registry.
    - `aks-create`: Create an Azure Kubernetes Service (AKS) cluster.
    - `aks-acr-integrate`: Grant AKS access to pull images from ACR.
    - `kubectl-install`: Install the `kubectl` command-line tool.
    - `aks-get-credentials`: Retrieve AKS cluster credentials for `kubectl`.
    - `application-deploy`: Deploy the application to AKS.
    - `service-monitor`: Monitor the service to obtain the external IP address.
    - `deployment-generate`: Generate `deployment.yaml` from `deployment-template.yaml`.

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

---

This revision integrates the relevant information and steps from the `Makefile` into the `README.md` to ensure clarity and ease of use.