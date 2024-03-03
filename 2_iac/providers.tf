terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }
}

provider "azurerm" {
  features {}

  subscription_id   = "defd2967-afdd-4091-8b77-dec4f7e880c9"
  tenant_id         = "a1fa26d7-43d0-4c83-9f20-a7a7d3aed0e1"
  client_id         = "78c757dc-3502-4742-afbd-affec5b96fec"
  client_secret     = "DKa8Q~gqqD.1LThwe_GGhjazBVPnfqgk5~drGdde"
}
