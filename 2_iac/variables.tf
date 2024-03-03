variable "resource_group_location" {
  type        = string
  default     = "westeurope"
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
  description = "Resource group for the Web App."
}