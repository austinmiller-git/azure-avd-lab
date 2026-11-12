locals {
  prefix = "${var.workload}-${var.environment}"

  tags = {
    workload    = var.workload
    environment = var.environment
    managed_by  = "terraform"
    repo        = "azure-avd-lab"
  }
}

resource "azurerm_resource_group" "avd" {
  name     = "rg-${local.prefix}"
  location = var.location
  tags     = local.tags
}
