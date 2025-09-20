
provider "azurerm" {
  features {}
  subscription_id = "8cb53e20-cd47-46be-94b9-4ef15fa36ea9"
}

provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.aks.kube_config.0.host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate)
}


resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_cluster_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = replace(lower(var.aks_cluster_name), "_", "-")

  default_node_pool {
    name       = "default"
    node_count = var.node_count
    vm_size    = var.node_vm_size
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Prueba"
  }
}


resource "kubernetes_deployment" "app" {
  metadata {
    name      = "myapp-deployment"
    labels = {
      app = "myapp"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "myapp"
      }
    }

    template {
      metadata {
        labels = {
          app = "myapp"
        }
      }

      spec {
        container {
          name  = "myapp"
          image = "juaca2004/myapp:latest"
          port {
            container_port = 3000
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "app_svc" {
  metadata {
    name = "myapp-service"
    labels = {
      app = "myapp"
    }
  }

  spec {
    selector = {
      app = kubernetes_deployment.app.spec[0].template[0].metadata[0].labels.app
    }
    port {
      port        = 80
      target_port = 3000
    }
    type = "LoadBalancer"
  }
}


