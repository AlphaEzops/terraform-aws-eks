variable "enabled" {
  type        = bool
  default     = true
  description = "Whether to install enable."
}

variable "cluster_name" {
  type        = string
  description = "The name of the cluster name"
}

variable "service_account_name" {
  type        = string
  default     = "ebs-csi-controller-sa"
  description = "External Secrets service account name"
}

#==============================================================================================================
# HELM CHART - EBS CSI DRIVER
#==============================================================================================================
variable "helm_chart_name" {
  type        = string
  default     = "aws-ebs-csi-driver"
  description = "Helm chart name"
}

variable "helm_chart_version" {
  type        = string
  default     = "2.21.0"
  description = "Helm chart version"
}

variable "helm_chart_repo" {
  type        = string
  default     = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
  description = "Helm chart repository"
}

variable "create_namespace" {
  type        = bool
  default     = false
  description = "Whether to create the namespace or not"
}

variable "namespace" {
  type        = string
  default     = "kube-system"
  description = "Namespace to install the Helm chart into"
}
