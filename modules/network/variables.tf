variable "rg_name" { type = string }
variable "location" { type = string }
variable "prefix" { type = string }
variable "address_spaces" {
    type = object({ hub = string, spoke = string })
}
