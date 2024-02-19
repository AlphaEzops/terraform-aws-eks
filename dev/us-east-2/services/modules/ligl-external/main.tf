data "aws_caller_identity" "this" {}
data "aws_partition" "this" {}
data "aws_eks_cluster" "reveal-cluster" {
  name = "reveal-cluster"
}

locals {
  region = "us-east-2"
}


#==============================================================================================================
# APPLICATION - LIGL-EXTERNAL
#==============================================================================================================


resource "kubectl_manifest" "ligl-ui" {

  yaml_body = <<YAML
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  finalizers:
    - resources-finalizer.argocd.argoproj.io
  labels:
    argocd.argoproj.io/instance: app-of-apps
  name: ligl-ui-development
  namespace: argocd-system
spec:
  destination:
    namespace: ligl-ui
    server: 'https://kubernetes.default.svc'
  project: default
  source:
    helm:
      valueFiles:
        - values.yaml
    path: dev/us-east-2/services/apps/ligl-external
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
  depends_on = [
    aws_iam_role_policy_attachment.eks_ligl_ui_secrets_kms_access_policy
  ]
}
