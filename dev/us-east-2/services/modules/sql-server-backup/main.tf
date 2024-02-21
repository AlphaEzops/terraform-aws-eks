data "aws_caller_identity" "this" {}
data "aws_partition" "this" {}
data "aws_eks_cluster" "reveal-cluster" {
  name = "reveal-cluster"
}

# data "aws_secretsmanager_secret" "secret_reveal" {
#  name = "prod/reveal/taxonomy-service"
# }

# data "aws_secretsmanager_secret_version" "secret_reveal" {
#  secret_id = data.aws_secretsmanager_secret.secret_reveal.id
# }


# SINGLE QUOTE ON CONNECTIONSTRINGS.VMDB TO ESCAPE STRINGS AUTOMATICALLY 
locals {
  region = "us-east-2"
  application_namespace = var.application_namespace
  database_password = "password123@"
}


#==============================================================================================================
# APPLICATION - TAXONOMY SERVICE
#==============================================================================================================


resource "kubectl_manifest" "sql-server-backup" {

  yaml_body = <<YAML
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  finalizers:
    - resources-finalizer.argocd.argoproj.io
  labels:
    argocd.argoproj.io/instance: app-of-apps
  name: ${local.application_namespace}-development
  namespace: argocd-system
spec:
  destination:
    namespace: ${local.application_namespace}
    server: 'https://kubernetes.default.svc'
  project: default
  source:
    helm:
      valueFiles:
        - values.yaml
      parameters:
        - name: "sapassword"
          value: ${local.database_password}
        - name: "acceptEula.value"
          value: "Y"
    path: dev/us-east-2/services/apps/sql-server-backup
    repoURL: 'git@github.com:AlphaEzops/reveal-eks.git'
    targetRevision: HEAD
  syncPolicy:
    automated:
      allowEmpty: false
      prune: false
      selfHeal: true
    retry:
      backoff:
        duration: 5s
        factor: 2
        maxDuration: 3m0s
      limit: 5
    syncOptions:
      - CreateNamespace=true
      - PruneLast=true
YAML
}
