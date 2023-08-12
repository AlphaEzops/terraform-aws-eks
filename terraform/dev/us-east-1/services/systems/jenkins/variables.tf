variable "create_namespace" {
  type        = bool
  default     = true
  description = "Whether to create Kubernetes namespace with name defined by `namespace`."
}

variable "namespace" {
  type        = string
  default     = "jenkins-system"
  description = "Kubernetes namespace to deploy jenkins Helm chart."
}

variable "enabled" {
  type        = bool
  default     = true
  description = "Variable indicating whether deployment is enabled."
}

variable "node_selector" {
  type = string
  default = "system-services"
  description = "Node selector to use for metric server pods."
}