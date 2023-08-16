#===============================================================================
# REQUIRED
#===============================================================================
variable "project" {
  description = "(required) Project name"
  type        = string
}

variable "vpc_id" {
  description = "(required) VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "(required) Private subnet IDs"
  type        = list(string)
}

/* variable "public_subnet_ids" {
  description = "(required) Public subnet IDs"
  type        = list(string)
} */

variable "stage" {
  description = "(required) Environment stage"
  type        = string
}

#===============================================================================
# OPTIONAL
#===============================================================================
variable "cluster_name" {
  description = "Cluster name"
  type        = string
  default     = "cluster"
}

variable "tags" {
  description = "All Tags"
  type = object({
    eks       = map(any)
    eks_addon = map(any)
    iam_role  = map(any)

  })
  default = {
    eks       = {}
    eks_addon = {}
    iam_role  = {}
  }
}
variable "cluster_version" {
  description = "Cluster version"
  type        = string
  default     = "1.27"
}

variable "instance_type" {
  description = "Instance type"
  type        = string
  default     = "t3.medium"
}

#variable "addons" {
#  description = "EKS addons"
#  type = list(object({
#    name    = string
#    version = string
#  }))
#  default = [
#    {
#      name    = "coredns"
#      version = "v1.10.1-eksbuild.2"
#    },
#    # {
#    #   name    = "kube-proxy"
#    #   version = "v1.23.8-eksbuild.2"
#    # },
#    # {
#    #   name    = "vpc-cni"
#    #   version = "v1.11.4-eksbuild.1"
#    # },
##     {
##       name = "aws-ebs-csi-driver"
##       version = "v1.21.0-eksbuild.1"
##     }
#
#  ]
#}

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
