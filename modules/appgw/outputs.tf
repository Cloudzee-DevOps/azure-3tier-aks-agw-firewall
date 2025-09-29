output "id" { value = azurerm_application_gateway.agw.id }
output "private_ip" { value = azurerm_application_gateway.agw.frontend_ip_configuration[0].private_ip_address }
