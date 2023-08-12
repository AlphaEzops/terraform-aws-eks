variable "cluster_name" {
  default = "my-cluster"
  description = "The name of the cluster"
  type = string
}

variable "node_selector" {
    default = "system-services"
    description = "The node selector for the cluster"
    type = string
}