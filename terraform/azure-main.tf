# ----------------------------------------------------------------------
# Provider Configuration
# ----------------------------------------------------------------------

provider "azurerm" {
  subscription_id = var.azure_subscription_id
  client_id       = var.azure_client_id
  client_secret   = var.azure_client_secret
  tenant_id       = var.azure_tenant_id

  features {

  }
}

# ----------------------------------------------------------------------
# Resource Group Configuration
# ----------------------------------------------------------------------

resource "azurerm_resource_group" "atlas-tf" {
  name     = "atlas-tf"
  location = "East US"
}

# ----------------------------------------------------------------------
# Log Analytics Workspace Configuration
# ----------------------------------------------------------------------

resource "azurerm_log_analytics_workspace" "atlas-tf" {
  name                = "atlas-tf-law"
  location            = "East US"
  resource_group_name = azurerm_resource_group.atlas-tf.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}


# ----------------------------------------------------------------------
# Managed Identity Configuration
# ----------------------------------------------------------------------

resource "azurerm_user_assigned_identity" "atlas-tf" {
  name                = "atlas-tf-web"
  resource_group_name = azurerm_resource_group.atlas-tf.name
  location            = azurerm_resource_group.atlas-tf.location
}

# ----------------------------------------------------------------------
# Azure Monitor Configuration
# ----------------------------------------------------------------------

resource "azurerm_monitor_diagnostic_setting" "atlas-tf" {
  name                       = "atlas-tf-diag"
  target_resource_id         = azurerm_user_assigned_identity.atlas-tf.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.atlas-tf.id

  metric {
    category = "AllMetrics"
  }
}