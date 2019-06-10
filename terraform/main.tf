# Use regular expression to validate format of given kubernetes version
resource "null_resource" "validate-kube-version" {
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command = <<EOT
regex="^latest|(([0-9]+\\.?){0,2}([0-9]+))$"
if [[ ! ${lower(var.kube_version)} =~ $$regex ]]; then
    echo "Invalid kubernetes version"
    exit 1
fi
EOT
  }
}


resource "azurerm_resource_group" "cluster_resource_group" {
  depends_on = ["null_resource.validate-kube-version"]
  name     = "${var.resource_group_name}"
  location = "${var.azure_region}"
}

# Find the available kubernetes version(s)
data "azurerm_kubernetes_service_versions" "current" {
  location = "${var.azure_region}"
  version_prefix = "${lower(var.kube_version) != "latest" ? var.kube_version : ""}"
}

locals {
  # Supported versions ordered earliest to latest
  supported_versions = "${data.azurerm_kubernetes_service_versions.current.versions}"
  version_count      = "${length(local.supported_versions)}"
  requested_version  = "${local.version_count > 0 ?
                          local.supported_versions[local.version_count - 1] :
                          data.azurerm_kubernetes_service_versions.current.latest_version}"
}

resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = "${var.cluster_name}"
  location            = "${azurerm_resource_group.cluster_resource_group.location}"
  resource_group_name = "${azurerm_resource_group.cluster_resource_group.name}"
  dns_prefix          = "${var.dns_prefix}"
  kubernetes_version  = "${local.requested_version}"

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
