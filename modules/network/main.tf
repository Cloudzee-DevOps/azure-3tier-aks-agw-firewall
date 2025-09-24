resource "azurerm_virtual_network" "hub" {
    name = "${var.prefix}-hub-vnet"
    address_space = [var.address_spaces.hub]
    location = var.location
    resource_group_name = var.rg_name
}

resource "azurerm_subnet" "firewall" {
    name = "AzureFirewallSubnet"
    resource_group_name = var.rg_name
    virtual_network_name = azurerm_virtual_network.hub.name
    address_prefixes = [cidrsubnet(var.address_spaces.hub, 8, 0)]
}


resource "azurerm_virtual_network" "spoke" {
    name = "${var.prefix}-spoke-vnet"
    address_space = [var.address_spaces.spoke]
    location = var.location
    resource_group_name = var.rg_name
}

resource "azurerm_subnet" "appgw" {
    name = "appgw-subnet"
    resource_group_name = var.rg_name
    virtual_network_name = azurerm_virtual_network.spoke.name
    address_prefixes = [cidrsubnet(var.address_spaces.spoke, 8, 0)]
}


resource "azurerm_subnet" "aks" {
    name = "aks-subnet"
    resource_group_name = var.rg_name
    virtual_network_name = azurerm_virtual_network.spoke.name
    address_prefixes = [cidrsubnet(var.address_spaces.spoke, 8, 1)]
}
