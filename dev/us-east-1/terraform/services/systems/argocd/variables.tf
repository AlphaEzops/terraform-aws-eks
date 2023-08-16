variable "enabled" {
  type        = bool
  default     = true
  description = "Whether to install enable."
}

variable "create_namespace" {
  type        = bool
  default     = true
  description = "Whether to create the namespace or not"
}

variable "namespace" {
  type        = string
  description = "Namespace to deploy ArgoCD"
  default     = "argocd-system"
}

#------------------------------------------------------------------------------
# ARGO HELM CONFIG
#------------------------------------------------------------------------------
variable "stage" {
  type        = string
  description = "Stage to deploy ArgoCD"
  default     = "dev"
}



variable "argo_version" {
  type        = string
  description = "ArgoCD version"
  default     = "5.27.1"
}

variable "argo_chart" {
  type        = string
  description = "ArgoCD chart"
  default     = "argo-cd"
}

variable "argo_repository" {
  type        = string
  description = "ArgoCD repository"
  default     = "https://argoproj.github.io/argo-helm"
}

variable "values" {
  description = "ArgoCD values"
  type = list(object({
    name  = string
    value = string
  }))
  default = [
    {
      name  = "configs.cm.timeout.reconciliation"
      value = "40s"
    },
    {
      name  = "configs.cm.params.applicationsetcontroller.enable.progressive.syncs"
      value = true
    },
    {
      name  = "crds.install"
      value = true
    }
  ]
}


#------------------------------------------------------------------------------
# ARGO CD PROJECTS CONFIG
#------------------------------------------------------------------------------
variable "project" {
  type        = any
  description = "Project Setup"
  default = {
    devops = {
      project_name        = "devops"
      project_description = "Devops Project"
    }
  }
}

variable "private_repo" {
  type        = any
  description = "Private repository"
  default     = {
    ezops = {
      app_name         = "devops-project"
      argo_namespace   = "argocd-system"
      private_repo_url = "git@github.com:ArthurMaverick/devops_project.git"
    }
  }
}

variable "public_repo" {
  type        = any
  description = "Private repository"
  default = {}
}

variable "applications" {
  type        = any
  description = "Application Setup"
  default     = {}
}

variable "notification" {
  type        = any
  description = "Notification Setup"
  default     = {}
}