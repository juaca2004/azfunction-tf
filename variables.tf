variable "location" {
  type        = string
  default     = "westus3"
  description = "Azure region"
}

variable "resource_group_name" {
  type    = string
  default = "aks-rg"
}


variable "aks_cluster_name" {
  type    = string
  default = "aks-cluster-2025"
}

variable "node_count" {
  type    = number
  default = 1
}

variable "node_vm_size" {
  type    = string
  default = "Standard_B2s"
}
