variable "resource_group_location" {
  type        = string
  //default     = "westeurope"
  default     = "eastus"
  description = "Location of the resource group."
}

variable "resource_group_name" {
  type        = string
  default     = "rg-sample-nodejs-tf"
  description = "Resource group for the Web App."
}

variable "appservice_plan_name" {
  type        = string
  default     = "sample-nodejs-service-plan-tf"
  description = "Service plan name."
}

variable "webapp_name" {
  type        = string
  default     = "szt-sample-nodejs-tf"
  description = "Web App name."
}

variable "subscription_id" {
  description = "Azure Subscription ID"
}

variable "tenant_id" {
  description = "Azure Tenant ID"
}

variable "client_id" {
  description = "Azure Client ID"
}

variable "client_secret" {
  description = "Azure Client Secret"
}

variable "github_token" {
  description = "Token for GitHub connection"
}

variable "github_org" {
  description = "GitHub org name"
}

variable "github_branch" {
  description = "GitHub branch"
}

variable "github_repository" {
  description = "GitHub repository name"
}