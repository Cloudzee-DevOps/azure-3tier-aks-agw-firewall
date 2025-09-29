resource "azurerm_user_assigned_identity" "agic" {
    name = "${var.prefix}-agic-mi"
    resource_group_name = var.rg_name
    location = var.location
}


resource "azurerm_kubernetes_cluster" "aks" {
    name = "${var.prefix}-aks"
    location = var.location
    resource_group_name = var.rg_name
    dns_prefix = "${var.prefix}-dns"


    default_node_pool {
        name = "nodepool1"
        vm_size = "Standard_DS2_v2"
        node_count = 2
        vnet_subnet_id = var.aks_subnet_id
    }


    identity { type = "SystemAssigned" }


    network_profile {
        network_plugin = "azure"
        network_policy = "azure"
        load_balancer_sku = "standard"
    }


    addon_profile {
        ingress_application_gateway {
            enabled = true
            gateway_id = var.appgw_id
            identity {
            user_assigned_identity_id = azurerm_user_assigned_identity.agic.id
            }
        }
    }
}


# Grant AGIC identity required access to App Gateway
resource "azurerm_role_assignment" "agic_contrib" {
    scope = var.appgw_id
    role_definition_name = "Contributor"
    principal_id = azurerm_user_assigned_identity.agic.principal_id
}


# Kubeconfig out
data "azurerm_kubernetes_cluster" "this" {
    name = azurerm_kubernetes_cluster.aks.name
    resource_group_name = var.rg_name
}


output "kubeconfig" {
    value = data.azurerm_kubernetes_cluster.this.kube_config_raw
    sensitive = true
}
