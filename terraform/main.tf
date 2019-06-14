resource "azurerm_resource_group" "cluster_resource_group" {
  name     = "${var.resource_group_name}"
  location = "${var.azure_region}"
}

# Find the available kubernetes version(s)
data "azurerm_kubernetes_service_versions" "current" {
  location = "${var.azure_region}"
  version_prefix = "${lower(var.kube_version) != "latest" ? var.kube_version : ""}"
}


resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = "${var.cluster_name}"
  location            = "${azurerm_resource_group.cluster_resource_group.location}"
  resource_group_name = "${azurerm_resource_group.cluster_resource_group.name}"
  dns_prefix          = "${var.dns_prefix}"
  kubernetes_version  = "${var.kube_version}"

  linux_profile {
    admin_username = "${var.username}"

    ssh_key {
      key_data = "${var.ssh_public_key}"
    }
  }

  agent_pool_profile {
    name            = "default"
    count           = "${var.worker_count}"
    vm_size         = "${var.worker_vm_size}"
    os_type         = "Linux"
    os_disk_size_gb = 30
  }

  service_principal {
    client_id     = "${var.principal_id}"
    client_secret = "${var.principal_password}"
  }
}
