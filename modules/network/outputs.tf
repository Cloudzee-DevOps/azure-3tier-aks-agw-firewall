output "hub_vnet_id" { value = azurerm_virtual_network.hub.id }
output "hub_vnet_name" { value = azurerm_virtual_network.hub.name }
output "spoke_vnet_id" { value = azurerm_virtual_network.spoke.id }
output "spoke_vnet_name" { value = azurerm_virtual_network.spoke.name }


output "subnets" {
    value = {
    appgw = azurerm_subnet.appgw
    aks = azurerm_subnet.aks
  }
}
