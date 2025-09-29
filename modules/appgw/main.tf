resource "azurerm_application_gateway" "agw" {
    name = "${var.prefix}-agw"
    resource_group_name = var.rg_name
    location = var.location
    sku {
        name = "WAF_v2"
        tier = "WAF_v2"
        capacity = 1
    }


    gateway_ip_configuration {
        name = "ipconfig"
        subnet_id = var.appgw_subnet_id
    }


    frontend_port { name = "port80" port = 80 }
    frontend_port { name = "port443" port = 443 }
    
    
    frontend_ip_configuration {
        name = "frontend-private"
        private_ip_address_allocation = "Dynamic"
        subnet_id = var.appgw_subnet_id
    }


# Minimal listener/rule; AGIC will manage actual routing from Ingress
    http_listener {
        name = "listener80"
        frontend_ip_configuration_name = "frontend-private"
        frontend_port_name = "port80"
        protocol = "Http"
    }


    request_routing_rule {
        name = "dummy"
        rule_type = "Basic"
        http_listener_name = "listener80"
        backend_address_pool_name = "dummy-pool"
        backend_http_settings_name = "dummy-setting"
    }


    backend_address_pool { name = "dummy-pool" }


    backend_http_settings {
        name = "dummy-setting"
        cookie_based_affinity = "Disabled"
        port = 80
        protocol = "Http"
        request_timeout = 30
    }
}
