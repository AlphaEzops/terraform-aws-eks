variable "network_name" {
  description = "Name of VPC"
  type        = string
  default     = "default"
}

variable "cluster_name" {
  description = "Name of EKS cluster"
  type        = string
  default     = "reveal"
}

variable "stage" {
  description = "Stage of deployment"
  type        = string
  default     = "default"
}
