terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.33.0"
    }
  }
}

provider "azurerm" {
  # Configuration options
features {}
subscription_id = "b8776852-28a5-47be-853f-d7d0876c9353"
}

module "resource-group" {
    source = "./modules/general/resourcegroup"
    resource_group_name = var.resource_group_name
    location = var.location
}   

module "network" {
   source="./modules/networking/vnet"
   resource_group_name = var.resource_group_name
   location = var.location
   vnet_name = var.vnet_name
   vnet_address_prefix = var.vnet_address_prefix
   vnet_subnet_count = var.vnet_subnet_count
   public_ip_address_count = var.public_ip_address_count
   network_interfaces_count = var.network_interfaces_count
   network_security_group_rules = var.network_security_group_rules   
   depends_on = [ module.resource-group ]
}

module "machines" {
    source = "./modules/compute/virtualMachines"
    resource_group_name = var.resource_group_name
    location = var.location
    virtual_machine_count = var.virtual_machine_count
    virtual_network_interface_ids = module.network.virtual_network_interfaces_ids
}