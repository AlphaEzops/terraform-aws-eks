variable "enable_network" {
  description = "Enable Network"
  type        = bool
  default     = true
}

variable "enable_cluster" {
  description = "Enable Cluster"
  type        = bool
  default     = true
}

variable "enable_services" {
  description = "Enable Services"
  type        = bool
  default     = true
}

#variable "enable_dns" {
#  description = "Enable DNS"
#  type        = bool
#  default     = true
#}

variable "project" {
  description = "(required) Project name"
  type        = string
  default     = "reveal"
}

variable "stage" {
  description = "(required) Environment stage"
  type        = string
  default     = "default"
}

#===============================================================================
# NETWORK
#===============================================================================
variable "network_name" {
  description = "Network name"
  type        = string
  default     = "reveal-network"
}
#===============================================================================
# EKS CLUSTER
#===============================================================================
variable "cluster_name" {
  description = "Cluster name"
  type        = string
  default     = "reveal-cluster"
}

variable "cluster_version" {
  description = "Cluster version"
  type        = string
  default     = "1.27"
}

variable "instance_type" {
  description = "Instance type"
  type        = string
  default     = "t3.micro"
}

variable "addons" {
  description = "EKS addons"
  type = list(object({
    name    = string
    version = string
  }))
  default = [
    {
      name    = "coredns"
      version = "v1.10.1-eksbuild.1"
    },
    # {
    #   name    = "kube-proxy"
    #   version = "v1.23.8-eksbuild.2"
    # },
    # {
    #   name    = "vpc-cni"
    #   version = "v1.11.4-eksbuild.1"
    # },
    # {
    #   name = "aws-ebs-csi-driver"
    #   version = "v1.17.0-eksbuild.1"
    # }

  ]
}

variable "aws_auth_users" {
  description = "aws_auth_users"
  type = list(object({
    username = string
    groups   = list(string)
  }))
  default = [
    {
      username = "arthur-santos"
      groups   = ["system:masters"]
    }
  ]
}
