resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = var.resource_group_name
}

resource "azurerm_app_service_plan" "app_service_plan" {
  name                = var.appservice_plan_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  kind                = "Linux"
  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "web_app" {
  name                = var.webapp_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.app_service_plan.name

  site_config {
    linux_fx_version = "NODE|20-lts"
  }
}