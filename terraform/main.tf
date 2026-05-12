terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90"
    }
  }
  backend "azurerm" {
    resource_group_name  = "rg-althea-tfstate"
    storage_account_name = "stalteatfstatefrc"
    container_name       = "tfstate"
    key                  = "althea.terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

resource "azurerm_resource_group" "main" {
  name     = "rg-althea-${var.environment}-frc"
  location = "France Central"
  tags = {
    project     = "Althea Systems"
    environment = var.environment
    managed_by  = "Terraform"
  }
}

resource "azurerm_container_registry" "acr" {
  name                = "acrwebprdfrc"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "Standard"
  admin_enabled       = true
  tags = {
    project    = "Althea Systems"
    managed_by = "Terraform"
  }
}

resource "azurerm_virtual_network" "main" {
  name                = "vnet-althea-${var.environment}-frc"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  address_space       = ["10.10.0.0/16"]
}

resource "azurerm_subnet" "aks" {
  name                 = "snet-aks-${var.environment}"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.10.1.0/24"]
}

resource "azurerm_key_vault" "main" {
  name                = "kv-althea-${var.environment}-frc"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  tenant_id           = var.tenant_id
  sku_name            = "standard"
  tags = {
    project    = "Althea Systems"
    managed_by = "Terraform"
  }
}

resource "azurerm_log_analytics_workspace" "sentinel" {
  name                = "law-althea-sentinel-frc"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_sentinel_log_analytics_workspace_onboarding" "sentinel" {
  workspace_id = azurerm_log_analytics_workspace.sentinel.id
}

output "acr_login_server" {
  value = azurerm_container_registry.acr.login_server
}

output "resource_group_name" {
  value = azurerm_resource_group.main.name
}

