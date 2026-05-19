resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.name
  location            = var.location
  resource_group_name = var.rg_name
  dns_prefix          = "aks-prod"

  private_cluster_enabled = true

  default_node_pool {
    name                = "systemnp"
    vm_size             = "Standard_DS3_v2"
    node_count          = 2
    vnet_subnet_id      = var.subnet_id
    enable_auto_scaling = true
    min_count           = 2
    max_count           = 5
    os_disk_size_gb     = 128
  }

  identity {
    type = "SystemAssigned"
  }

  azure_active_directory_role_based_access_control {
    managed = true
    azure_rbac_enabled = true
  }

  network_profile {
    network_plugin    = "azure"   # Azure CNI
    network_policy    = "azure"
    load_balancer_sku = "standard"
  }

  oms_agent {
    log_analytics_workspace_id = var.law_id
  }

  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  tags = {
    env = "prod"
  }

resource "azurerm_kubernetes_cluster_node_pool" "usernp" {
  name                  = "usernp"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = "Standard_DS3_v2"
  vnet_subnet_id        = var.subnet_id

  enable_auto_scaling = true
  min_count           = 2
  max_count           = 10

  mode = "User"
}
}
