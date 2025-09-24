locals {
    rg_name = "${var.prefix}-rg"
}


resource "azurerm_resource_group" "rg" {
    name = local.rg_name
    location = var.location
}

module "network" {
    source = "./modules/network"
    rg_name = azurerm_resource_group.rg.name
    location = var.location
    prefix = var.prefix
    address_spaces = var.address_spaces
}

module "firewall" {
    source = "./modules/firewall"
    rg_name = azurerm_resource_group.rg.name
    location = var.location
    prefix = var.prefix
    hub_vnet_id = module.network.hub_vnet_id
    appgw_priv_ip = module.appgw.private_ip
}

module "appgw" {
    source = "./modules/appgw"
    rg_name = azurerm_resource_group.rg.name
    location = var.location
    prefix = var.prefix
    spoke_vnet_id = module.network.spoke_vnet_id
    appgw_subnet_id = module.network.subnets["appgw"].id
}

module "aks" {
    source = "./modules/aks"
    rg_name = azurerm_resource_group.rg.name
    location = var.location
    prefix = var.prefix
    aks_subnet_id = module.network.subnets["aks"].id
    appgw_id = module.appgw.id
}

# Peering Hub <-> Spoke
resource "azurerm_virtual_network_peering" "hub_to_spoke" {
    name = "${var.prefix}-hub-to-spoke"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = module.network.hub_vnet_name
    remote_virtual_network_id = module.network.spoke_vnet_id
    allow_forwarded_traffic = true
    allow_gateway_transit = false
}

resource "azurerm_virtual_network_peering" "spoke_to_hub" {
    name = "${var.prefix}-spoke-to-hub"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = module.network.spoke_vnet_name
    remote_virtual_network_id = module.network.hub_vnet_id
    allow_forwarded_traffic = true
    use_remote_gateways = false
}

# Export kubeconfig to file for Ansible
resource "local_file" "kubeconfig" {
    filename = "${path.module}/../ansible/kubeconfig"
    content = module.aks.kubeconfig
}
