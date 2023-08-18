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

variable "project_name" {
    default = "my-project"
    description = "The name of the project"
    type = string
}