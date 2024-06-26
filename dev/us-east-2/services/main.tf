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

  set {
    name = "global.nodeSelector.kubernetes\\.io/os"
    value = "linux"
  }
}

# #==============================================================================================================
# # SYSTEM APPLICATIONS - ARGO CD
# #==============================================================================================================

# resource "kubectl_manifest" "cert_manager_system" {
#   yaml_body = <<YAML
# apiVersion: argoproj.io/v1alpha1
# kind: Application
# metadata:
#   finalizers:
#     - resources-finalizer.argocd.argoproj.io
#   labels:
#     argocd.argoproj.io/instance: app-of-apps
#   name: cert-manager-development
#   namespace: argocd-system
# spec:
#   destination:
#     namespace: cert-manager
#     server: 'https://kubernetes.default.svc'
#   project: default
#   source:
#     helm:
#       valueFiles:
#         - values.yaml
#       parameters:
#         - name: "nodeSelector.kubernetes\\.io/os"
#           value: "linux"
#     path: dev/us-east-2/services/system/cert-manager
#     repoURL: 'git@github.com:AlphaEzops/reveal-eks.git'
#     targetRevision: HEAD
#   syncPolicy:
#     automated:
#       allowEmpty: false
#       prune: false
#       selfHeal: true
#     retry:
#       backoff:
#         duration: 5s
#         factor: 2
#         maxDuration: 3m0s
#       limit: 5
#     syncOptions:
#       - CreateNamespace=true
#       - PruneLast=true
# YAML
#   depends_on = [
#     helm_release.argocd_helm_release
#   ]
# }

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
      parameters:
        - name: "controller.nodeSelector.kubernetes\\.io/os"
          value: "linux"
    chart: ingress-nginx
    repoURL: https://kubernetes.github.io/ingress-nginx
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

# resource "kubectl_manifest" "metrics_server" {

#   yaml_body = <<YAML
# apiVersion: argoproj.io/v1alpha1
# kind: Application
# metadata:
#   finalizers:
#     - resources-finalizer.argocd.argoproj.io
#   labels:
#     argocd.argoproj.io/instance: app-of-apps
#   name: metrics-server-development
#   namespace: argocd-system
# spec:
#   destination:
#     namespace: metrics-server
#     server: 'https://kubernetes.default.svc'
#   project: default
#   source:
#     helm:
#       valueFiles:
#         - values.yaml
#     path: dev/us-east-2/services/system/metrics-server
#     repoURL: git@github.com:AlphaEzops/reveal-eks.git
#     targetRevision: HEAD
#   syncPolicy:
#     automated:
#       allowEmpty: false
#       prune: false
#       selfHeal: true
#     retry:
#       backoff:
#         duration: 5s
#         factor: 2
#         maxDuration: 3m0s
#       limit: 5
#     syncOptions:
#       - CreateNamespace=true
#       - PruneLast=true
# YAML
#   depends_on = [
#     helm_release.argocd_helm_release
#   ]
# }

# resource "kubectl_manifest" "external_secrets" {

#   yaml_body = <<YAML
# apiVersion: argoproj.io/v1alpha1
# kind: Application
# metadata:
#   finalizers:
#     - resources-finalizer.argocd.argoproj.io
#   labels:
#     argocd.argoproj.io/instance: app-of-apps
#   name: external-secret-development
#   namespace: argocd-system
# spec:
#   destination:
#     namespace: external-secrets
#     server: 'https://kubernetes.default.svc'
#   project: default
#   source:
#     helm:
#       valueFiles:
#         - values.yaml
#       parameters:
#         - name: "nodeSelector.kubernetes\\.io/os"
#           value: "linux"
#         - name: "webhook.nodeSelector.kubernetes\\.io/os"
#           value: "linux"
#         - name: "certController.nodeSelector.kubernetes\\.io/os"
#           value: "linux"
#     chart: external-secrets
#     repoURL: https://charts.external-secrets.io
#     targetRevision: 0.9.5
#   syncPolicy:
#     automated:
#       allowEmpty: false
#       prune: false
#       selfHeal: true
#     retry:
#       backoff:
#         duration: 5s
#         factor: 2
#         maxDuration: 3m0s
#       limit: 5
#     syncOptions:
#       - CreateNamespace=true
#       - PruneLast=true
# YAML
#   depends_on = [
#     helm_release.argocd_helm_release
#   ]
# }

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
      secret_name = "reveal-ops"
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

module "applications" {
  depends_on = [helm_release.argocd_helm_release]
  source = "./modules/applications"
}

# module "ligl-ui" {
#   depends_on = [helm_release.argocd_helm_release]
#   source = "./modules/ligl-ui"
#   application_namespace = "ligl-ui"
# }

# module "ligl-external" {
#   depends_on = [helm_release.argocd_helm_release]
#   source = "./modules/ligl-external"
#   application_namespace = "ligl-external"
# }

# module "authentication-service" {
#   depends_on = [module.ligl-external]
#   source = "./modules/authentication-service"
#   application_namespace = "authentication-service"
# }

# module "taxonomy-service" {
#   depends_on = [helm_release.argocd_helm_release]
#   source = "./modules/taxonomy-service"
#   application_namespace = "taxonomy-service"
# }

# module "monolith-service" {
#   depends_on = [helm_release.argocd_helm_release]
#   source = "./modules/monolith-service"
#   application_namespace = "monolith-service"
# }

# module "hosting-service" {
#   depends_on = [helm_release.argocd_helm_release]
#   source = "./modules/hosting-service"
#   application_namespace = "hosting-service"
# }

# module "sql-server-backup" {
#   depends_on = [module.hosting-service]
#   source = "./modules/sql-server-backup"
#   application_namespace = "sql-server-backup"
# }

# module "reports-service" {
#   depends_on = [module.sql-server-backup]
#   source = "./modules/reports-service"
#   application_namespace = "reports-service"
# }

# module "notification-service" {
#   depends_on = [module.reports-service]
#   source = "./modules/notification-service"
#   application_namespace = "notification-service"
# }

# module "process-service" {
#   depends_on = [module.notification-service]
#   source = "./modules/process-service"
#   application_namespace = "process-service"
# }

# module "request-tracker-service" {
#   depends_on = [module.notification-service]
#   source = "./modules/request-tracker-service"
#   application_namespace = "request-tracker-service"
# }

# module "metadata-process-service" {
#   depends_on = [module.notification-service]
#   source = "./modules/metadata-process-service"
#   application_namespace = "metadata-process-service"
# }