variable "appId" {}
variable "password" {}

resource "azurerm_resource_group" "aksrg" {
  name     = "AKSDemoRG"
  location = "Canada Central"
}

resource "azurerm_network_security_group" "aksnsg" {
  name                = "AKSDemovNetNSG"
  location            = azurerm_resource_group.aksrg.location
  resource_group_name = azurerm_resource_group.aksrg.name
}

resource "azurerm_virtual_network" "aksvnet" {
  name                = "AKSDemovNet"
  location            = azurerm_resource_group.aksrg.location
  resource_group_name = azurerm_resource_group.aksrg.name
  address_space       = ["10.0.0.0/16"]

  subnet {
    name           = "AKSDemoSubnet"
    address_prefix = "10.0.1.0/24"
    security_group = azurerm_network_security_group.aksnsg.id
  }
}





resource "azurerm_kubernetes_cluster" "akscluster" {
  name                = "AKSDemoCluster"
  location            = azurerm_resource_group.aksrg.location
  resource_group_name = azurerm_resource_group.aksrg.name
  dns_prefix          = "aksdemo"

  default_node_pool {
    name       = "aksdemopool"
    node_count = 3
    vm_size    = "Standard_B2s"
  }


  service_principal {
    client_id     = var.appId
    client_secret = var.password
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "basic"
  }

  tags = {
    Environment = "Demo"
  }
}


resource "azurerm_container_registry" "aksacr" {
  name                = "GhaiderAKSDemoRegistry"
  resource_group_name = azurerm_resource_group.aksrg.name
  location            = azurerm_resource_group.aksrg.location
  sku                 = "Basic"
  admin_enabled       = false
}




output "client_certificate" {
  value = azurerm_kubernetes_cluster.akscluster.kube_config.0.client_certificate
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.akscluster.kube_config_raw
}
