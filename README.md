# Deployment of an Application on Azure Kubernetes Service (AKS) with Terraform

Below are the steps I followed to prepare the application image, authenticate to Azure, and deploy the Kubernetes infrastructure using Terraform.

## 1. Transformation to Express.js
We converted the Azure Function into an Express.js application. This was necessary because Azure Functions do not run directly on AKS.

## 2. Creation of package.json
We created the package.json file to include the dependencies required to run the application, in this case **express version 4.18.2**.

## 3. Creation of the Image
When working with Kubernetes, we need a container image of the application to be deployed.  
Therefore, we created a Dockerfile that includes the package.json and the index.js.  
With this, we built the image and pushed it to a public repository—in this case, **Docker Hub**—for use when creating the cluster.

## 4. Creation of main.tf
The **main.tf** file defines all the infrastructure required to deploy an application on Azure Kubernetes Service (AKS) and expose it publicly.  
Below is the role of each section.

### Providers

**a. provider "azurerm"**  
Configures the connection to Microsoft Azure so Terraform can create and manage resources in the specified subscription.

- `features {}`: enables provider features without additional parameters.  
- `subscription_id`: uniquely identifies the Azure subscription where resources will be created.

**b. provider "kubernetes"**  
Allows Terraform to manage objects within the newly created Kubernetes cluster.

- `host` and certificates (`client_certificate`, `client_key`, `cluster_ca_certificate`) are obtained directly from the `azurerm_kubernetes_cluster.aks` resource.

### Resource Group

**resource "azurerm_resource_group" "rg"**  
Creates a Resource Group in Azure that acts as a logical container for all project resources.

- `name` and `location` are provided as variables (`var.resource_group_name` and `var.location`), making the configuration reusable across different regions or environments.

### Kubernetes Cluster

**resource "azurerm_kubernetes_cluster" "aks"**  
Defines the managed Kubernetes cluster in Azure.

Key parameters:

- `name` and `resource_group_name`: identify the cluster and associate it with the previously created resource group.  
- `dns_prefix`: prefix for the cluster’s DNS name.  
- `default_node_pool`: specifies the set of nodes where the containers will run, including the virtual machine size (`vm_size`) and the number of nodes (`node_count`).  
- `identity`: sets up a managed identity for the cluster to integrate with other Azure services without manual credentials.  
- `tags`: adds metadata, in this case to indicate that it is a test environment.

This resource forms the foundation of the infrastructure, providing the runtime environment for the containers.

### Application Deployment

**resource "kubernetes_deployment" "app"**  
Creates a Deployment inside the AKS cluster to run the application.

Highlights:

- `metadata`: defines the deployment name and the label `app = "myapp"`, used to identify and group related resources.  
- `replicas`: number of application instances (1 in this case).  
- `selector` and `template`: define the pod template with the labels needed for the Service to locate them.  
- `container`: specifies the container name, the image hosted on Docker Hub (`juaca2004/myapp:latest`), and the internal port (3000) where the application listens.

This block ensures Kubernetes keeps at least one replica of the application running.

### Exposure Service

**resource "kubernetes_service" "app_svc"**  
Defines a Service of type **LoadBalancer** so the application is accessible from the Internet.

- `metadata`: sets the service name and identification labels.  
- `selector`: links the service to the Deployment’s pods using the label `app = "myapp"`.  
- `port`: exposes port 80 externally and routes traffic to port 3000 in the containers.  
- `type = "LoadBalancer"`: requests Azure to create a load balancer with a public IP address.

Thanks to this resource, the application can receive external traffic automatically and scale as needed.

## 5. Variable Configuration
To enable reuse and allow changes without directly editing the main file, several input variables were defined in a **variables.tf** file.  
Each variable has a type, a default value, and, in some cases, a brief description.

### location
- **Type:** string  
- **Default value:** `"westus3"`  
- **Description:** Specifies the Azure region where all resources will be deployed.  
- **Usage:** Allows changing the deployment region (for example, `"eastus"`) without modifying main.tf.

### resource_group_name
- **Type:** string  
- **Default value:** `"aks-rg"`  
- **Description:** Name of the resource group that will contain the AKS cluster and related objects.  
- **Usage:** Helps identify the environment or project in Azure.

### aks_cluster_name
- **Type:** string  
- **Default value:** `"aks-cluster-2025"`  
- **Description:** Name assigned to the Kubernetes (AKS) cluster.  
- **Usage:** Used to customize the cluster name depending on the environment (development, testing, production).

### node_count
- **Type:** number  
- **Default value:** 1  
- **Description:** Number of nodes in the main pool of the AKS cluster.  
- **Usage:** Adjust the cluster size; for example, increase to handle more load.

### node_vm_size
- **Type:** string  
- **Default value:** `"Standard_B2s"`  
- **Description:** Virtual machine size to be used for the cluster nodes.  
- **Usage:** Allows choosing different hardware specifications (CPU, RAM) based on budget or performance needs.
