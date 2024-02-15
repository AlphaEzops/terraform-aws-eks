data "aws_eks_cluster" "cluster_info" {
  name = var.eks_cluster_name
}

data "aws_eks_cluster_auth" "cluster_auth" {
  name = data.aws_eks_cluster.cluster_info.id
}
#==============================================================================================================
# KUBERNETES RESOURCES - NAMESPACE
#==============================================================================================================
resource "kubernetes_namespace_v1" "argo_cd_namespace" {
  count = (var.enabled && var.create_namespace && var.namespace != "default") ? 1 : 0

  metadata {
    name = var.namespace
  }
}
#==============================================================================================================
# HELM RELEASE - ARGO CD
#==============================================================================================================
resource "helm_release" "argocd_helm_release" {
  depends_on = [kubernetes_namespace_v1.argo_cd_namespace]
  name             = format("argo-cd-%s", var.stage)
  repository       = var.argo_repository
  version          = var.argo_version
  chart            = var.argo_chart
  namespace        = var.create_namespace ? var.namespace : "kube-system"
  wait             = false
  cleanup_on_fail  = true

  dynamic "set" {
    for_each = try(var.values, {})
    content {
      name  = set.value.name
      value = set.value.value
    }
  }
}

#==============================================================================================================
# SYSTEM APPLICATIONS - ARGO CD
#==============================================================================================================
#data "aws_ssm_parameter" "ssh_key" {
#name = "/DEV/REVEAL/PRIVATEKEY"
#}

resource "kubectl_manifest" "cert_manager_system" {
  yaml_body = <<YAML
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  finalizers:
    - resources-finalizer.argocd.argoproj.io
  labels:
    argocd.argoproj.io/instance: app-of-apps
  name: cert-manager-development
  namespace: argocd-system
spec:
  destination:
    namespace: cert-manager
    server: 'https://kubernetes.default.svc'
  project: default
  source:
    helm:
      valueFiles:
        - values.yaml
    path: dev/us-east-2/services/system/cert-manager
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
    helm_release.argocd_helm_release
  ]
}


resource "kubectl_manifest" "nginx_system" {

  yaml_body = <<YAML
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  finalizers:
    - resources-finalizer.argocd.argoproj.io
  labels:
    argocd.argoproj.io/instance: app-of-apps
  name: ingress-nginx-development
  namespace: argocd-system
spec:
  destination:
    namespace: ingress-nginx
    server: 'https://kubernetes.default.svc'
  project: default
  source:
    helm:
      valueFiles:
        - values.yaml
    path: null
    repoURL: 'https://kubernetes.github.io/ingress-nginx'
    targetRevision: 4.8.0
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
    helm_release.argocd_helm_release
  ]
}

#resource "kubectl_manifest" "argo_cd_application" {
##  for_each = try({ for k, v in var.applications : k => v if v != null }, {})
#
#  yaml_body = <<YAML
#apiVersion: argoproj.io/v1alpha1
#kind: Application
#metadata:
#  name: app-of-apps
#  namespace: argocd-system
#  finalizers:
#    - resources-finalizer.argocd.argoproj.io
#spec:
#  destination:
#    namespace: app-of-apps
#    server: "https://kubernetes.default.svc"
#  source:
#    path: "dev/us-east-2/services/app-of-apps/system/apps"
#    repoURL: "git@github.com:AlphaEzops/reveal-eks.git"
#    targetRevision: "HEAD"
#    helm:
#      valueFiles:
#        - "values.yaml"
#  project: "default"
#  syncPolicy:
#    managedNamespaceMetadata:
#      labels:
#        managed: "argo-cd"
#    automated:
#      prune: true
#      selfHeal: true
#    syncOptions:
#      - CreateNamespace=true
#      - PruneLast=true
#    retry:
#      limit: 5
#      backoff:
#        duration: 5s
#        maxDuration: 3m0s
#        factor: 2
#YAML
#  depends_on = [
#    helm_release.argocd_helm_release
#  ]
#}

#==============================================================================================================
# INGRESS - ARGO CD
#==============================================================================================================
resource "kubernetes_ingress_v1" "argo_cd_ingress" {
  depends_on = [helm_release.argocd_helm_release]

  metadata {
    name      = "argocd"
    namespace = var.create_namespace ? var.namespace : "argocd-system"
    annotations = {
      "cert-manager.io/cluster-issuer" = "letsencrypt-staging"
      "nginx.ingress.kubernetes.io/backend-protocol" =  "HTTPS"
      "nginx.ingress.kubernetes.io/proxy-connect-timeout" = "300"
      "nginx.ingress.kubernetes.io/proxy-read-timeout" = "300"
      "nginx.ingress.kubernetes.io/proxy-send-timeout" = "300"
      "ingress.kubernetes.io/force-ssl-redirect" =  "true"
      "nginx.ingress.kubernetes.io/ssl-passthrough" = "true"
    }
  }

  spec {
    tls {
      hosts = ["argocd.dev.ezops.com.br"]
      secret_name = "reveal-ops" #"santos-ops"
    }
    ingress_class_name = "nginx"
    rule {
      host = "argocd.dev.ezops.com.br"
      http {
        path {
          path_type = "Prefix"
          path = "/"
          backend {
            service {
              name = "argo-cd-dev-argocd-server"
              port {
                 name = "http"
              }
            }
          }
        }
      }
    }
  }
}

