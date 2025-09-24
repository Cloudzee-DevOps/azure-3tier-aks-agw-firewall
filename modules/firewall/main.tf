resource "azurerm_public_ip" "fw" {
    name = "${var.prefix}-fw-pip"
    location = var.location
    resource_group_name = var.rg_name
    allocation_method = "Static"
    sku = "Standard"
}


resource "azurerm_firewall" "fw" {
    name = "${var.prefix}-firewall"
    location = var.location
    resource_group_name = var.rg_name
    sku_name = "AZFW_VNet"
    sku_tier = "Standard"
    ip_configuration {
        name = "configuration"
        subnet_id = replace(var.hub_vnet_id, "/virtualNetworks", "/virtualNetworks/${var.prefix}-hub-vnet/subnets/AzureFirewallSubnet")
        public_ip_address_id = azurerm_public_ip.fw.id
    }
}


# DNAT rules: 80/443 → AppGW private IP
resource "azurerm_firewall_policy" "pol" {
    name = "${var.prefix}-fw-policy"
    resource_group_name = var.rg_name
    location = var.location
}

resource "azurerm_firewall_policy_rule_collection_group" "dnat" {
    name = "${var.prefix}-dnat"
    firewall_policy_id = azurerm_firewall_policy.pol.id
    priority = 100
    
    
    nat_rule_collection {
        name = "dnat-web"
        priority = 100
        action = "Dnat"

        rule {
            name = "http"
            source_addresses = ["*"]
            destination_addresses = [azurerm_public_ip.fw.ip_address]
            destination_ports = ["80"]
            ip_protocols = ["TCP"]
            translated_address = var.appgw_priv_ip
            translated_port = "80"
        }
        
        
        rule {
            name = "https"
            source_addresses = ["*"]
            destination_addresses = [azurerm_public_ip.fw.ip_address]
            destination_ports = ["443"]
            ip_protocols = ["TCP"]
            translated_address = var.appgw_priv_ip
            translated_port = "443"
            }
      }
}

resource "azurerm_firewall_policy_rule_collection_group" "network" {
    name = "${var.prefix}-net"
    firewall_policy_id = azurerm_firewall_policy.pol.id
    priority = 200
    
    
    network_rule_collection {
        name = "allow-aks-essentials"
        priority = 200
        action = "Allow"
    
    
        rule {
            name = "aks-out"
            source_addresses = ["10.20.0.0/16"]
            destination_fqdns = ["*"]
            destination_ports = ["80","443"]
            ip_protocols = ["TCP"]
        }
    }
}

resource "azurerm_firewall_policy_rule_collection_group" "app" {
    name = "${var.prefix}-app"
    firewall_policy_id = azurerm_firewall_policy.pol.id
    priority = 300
    
    
    application_rule_collection {
        name = "allow-http-https"
        priority = 300
        action = "Allow"
        
        
        rule {
            name = "web"
            source_addresses = ["10.20.0.0/16"]
            protocol {
            type = "Http"
            port = 80
            }
            protocol {
            type = "Https"
            port = 443
            }
            destination_fqdns = ["*"]
        }
    }
}

resource "azurerm_firewall_policy_assignment" "assign" {
    firewall_policy_id = azurerm_firewall_policy.pol.id
    firewall_id = azurerm_firewall.fw.id
}
        
