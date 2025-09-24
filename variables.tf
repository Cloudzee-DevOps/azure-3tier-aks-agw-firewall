variable "subscription_id" { type = string }
variable "tenant_id" { type = string }
variable "location" { type = string default = "eastus" }
variable "prefix" { type = string default = "cz3tier" }


variable "address_spaces" {
    description = "CIDRs for hub/spoke"
    type = object({
        hub = string
        spoke = string
    })
    default = {
        hub = "10.10.0.0/16"
        spoke = "10.20.0.0/16"
    }
}


variable "dns_host" {
    description = "Hostname used on Ingress (configure your DNS A record to Firewall public IP)"
    type = string
    default = "app.cloudzee.local"
}
