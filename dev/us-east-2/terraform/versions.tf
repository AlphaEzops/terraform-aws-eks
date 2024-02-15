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
    tls = {
      source = "hashicorp/tls"
      version = "4.0.4"
    }
    github = {
      source = "integrations/github"
      version = "5.33.0"
    }
  }

  backend "s3" {
    bucket  = "reveal-tf-state-975635808270"
    key     = "us-east-2/dev/terraform.tfstate"
    encrypt = true
  }
}
