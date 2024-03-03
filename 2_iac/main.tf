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

resource "github_repository_file" "add_workflow" {
  depends_on = [azurerm_linux_web_app.web_app]

  repository          = var.github_repository
  branch              = var.github_branch
  file                = ".github/workflows/workflow.yml"
  content             =  <<-EOT
on:
  push:
    branches:
      - ${var.github_branch}

env:
  AZURE_WEBAPP_NAME: ${var.webapp_name}
  AZURE_WEBAPP_PACKAGE_PATH: '.'
  NODE_VERSION: '20.x'

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4

    - name: Set up Node.js
      uses: actions/setup-node@v4
      with:
        node-version: $${{ env.NODE_VERSION }}
        cache: 'npm'

    - name: npm install, build, and test
      run: |
        npm install
        npm run build --if-present
        npm run test --if-present
    - name: Upload artifact for deployment job
      uses: actions/upload-artifact@v4
      with:
        name: node-app
        path: .

  deploy:
    runs-on: ubuntu-latest
    needs: build
    environment:
      name: 'production'
      url: $${{ steps.deploy-to-webapp.outputs.webapp-url }}

    steps:
    - name: Azure Login
      uses: azure/login@v1
      with:
        creds: $${{ secrets.AZURE_CREDENTIALS }}

    - name: Get Publish Profile
      run: |
        echo "::set-output name=PUBLISH_PROFILE::$(az webapp deployment list-publishing-profiles -g 'rg-sample-nodejs-tf' -n 'szt-sample-nodejs-tf' --xml)"
      id: getPublishProfile

    - name: Download artifact from build job
      uses: actions/download-artifact@v4
      with:
        name: node-app

    - name: 'Deploy to Azure WebApp'
      id: deploy-to-webapp
      uses: azure/webapps-deploy@85270a1854658d167ab239bce43949edb336fa7c
      with:
        app-name: $${{ env.AZURE_WEBAPP_NAME }}
        publish-profile: $${{ steps.getPublishProfile.outputs.PUBLISH_PROFILE }}
        package: $${{ env.AZURE_WEBAPP_PACKAGE_PATH }}
  EOT
  commit_message      = "Managed by Terraform"
  commit_author       = "Terraform User"
  commit_email        = "terraform@example.com"
  overwrite_on_create = true
}