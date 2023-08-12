terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=4.67.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.10.1"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">=2.22.0"
    }
  }
}
