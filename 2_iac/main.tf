resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = var.resource_group_name
}

resource "azurerm_service_plan" "app_service_plan" {
  name                = var.appservice_plan_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "B1"
}

resource "azurerm_linux_web_app" "web_app" {
  name                = var.webapp_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.app_service_plan.id
  site_config {
    application_stack {
      node_version = "20-lts"
    }
  }
}

data "local_file" "input" {
  filename = "contrib/workflow.yml"
}

resource "github_repository_file" "add_workflow" {
  repository          = var.github_repository
  branch              = var.github_branch
  file                = ".github/workflows/workflow.yml"
  content             = data.local_file.input.content
  commit_message      = "Managed by Terraform"
  commit_author       = "Terraform User"
  commit_email        = "terraform@example.com"
  overwrite_on_create = true
}
