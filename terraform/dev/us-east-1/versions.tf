terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.0.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">=2.22.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.10.1"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.10.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.3.2"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.2.3"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.1.1"
    }
  }

  backend "s3" {
    bucket   = "tf-bucket-ecomm-716716811630"
    key      = "us-east-1/terraform.tfstate"
    encrypt  = true
  }
}
