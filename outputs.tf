output "firewall_public_ip" { value = module.firewall.public_ip }
output "appgw_private_ip" { value = module.appgw.private_ip }
output "aks_name" { value = module.aks.name }
output "aks_rg" { value = module.aks.node_rg }
output "kubeconfig" { value = module.aks.kubeconfig sensitive = true }
output "dns_host" { value = var.dns_host }
