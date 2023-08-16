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

resource "kubectl_manifest" "argo_cd_project" {
  for_each = try({ for k, v in var.project : k => v if v != null }, {})

  yaml_body = templatefile("${path.module}/templates/project/project.yaml.tpl", {
    PROJECT_NAME        = try(each.value.project_name, "default")
    ARGO_NAMESPACE      = var.namespace
    PROJECT_DESCRIPTION = each.value.project_description
  })

  depends_on = [
    helm_release.argocd_helm_release
  ]
}

#==============================================================================================================
# PRIVATE REPOSITORY CONFIGURATION
#==============================================================================================================
data "aws_ssm_parameter" "ssh_key" {
  name = "/DEV/PRIVATEKEY"
}

resource "kubernetes_secret_v1" "argo_cd_private_repo" {
  for_each = try({ for k, v in var.private_repo : k => v if v != null }, {})

  metadata {
    name      = each.value.app_name
    namespace = var.create_namespace ? var.namespace : "kube-system"
    labels = {
      "argocd.argoproj.io/secret-type" =  "repository"
    }
  }

  data = {
    url = each.value.private_repo_url
    sshPrivateKey = data.aws_ssm_parameter.ssh_key.value
#    insecure =  "true"
#    enableLfs = "true"
  }
}
#==============================================================================================================
# PUBLIC REPOSITORY CONFIGURATION
#==============================================================================================================
resource "kubectl_manifest" "argo_cd_public_repo" {
  for_each = try({ for k, v in var.public_repo : k => v if v != null }, {})

  yaml_body = templatefile("${path.module}/templates/repositories/Public-repository.yaml.tpl", {
    APP_NAME        = each.value.app_name
    ARGO_NAMESPACE  = var.namespace
    PUBLIC_REPO_URL = each.value.public_repo_url
  })
  depends_on = [
    helm_release.argocd_helm_release
  ]
}

#==============================================================================================================
# APPLICATION CONFIGURATION
#==============================================================================================================
resource "kubectl_manifest" "argo_cd_application" {
  for_each = try({ for k, v in var.applications : k => v if v != null }, {})

  yaml_body = templatefile("${path.module}/templates/applications/Application.yaml.tpl", {
    APP_NAME              = each.value.app_name
    ARGO_NAMESPACE        = var.namespace
    APP_NAMESPACE         = each.value.app_namespace
    APP_PATH              = each.value.app_path
    APP_REPO_URL          = each.value.app_repo_url
    APP_TARGET_REVISION   = each.value.app_target_revision
    APP_DIRECTORY_RECURSE = each.value.app_directory_recurse
    APP_PROJECT           = try(each.value.app_project, "default")


  })
  depends_on = [
    helm_release.argocd_helm_release
  ]
}
#==============================================================================================================
# APPLICATION  CERT-MANAGER
#==============================================================================================================
resource "kubectl_manifest" "cert_manager" {
  yaml_body = <<YAML
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: cert-manager
  namespace: argocd-system
spec:
  destination:
    namespace: "cert-manager-system"
    server: "https://kubernetes.default.svc"
  source:
    path: "dev/us-east-1/services/system/cert-manager"
    repoURL: "git@github.com:ArthurMaverick/devops_project.git"
    targetRevision: "HEAD"
    helm:
      valueFiles:
        - "values.yaml"
  project: "devops"
  syncPolicy:
    managedNamespaceMetadata:
      labels:
        managed: "argo-cd"
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
YAML
}
#==============================================================================================================
# APPLICATION JENKINS
#==============================================================================================================
resource "kubectl_manifest" "jenkins" {
  yaml_body = <<YAML
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: jenkins
  namespace: argocd-system
spec:
  destination:
    namespace: "jenkins-system"
    server: "https://kubernetes.default.svc"
  source:
    path: "dev/us-east-1/services/system/jenkins"
    repoURL: "git@github.com:ArthurMaverick/devops_project.git"
    targetRevision: "HEAD"
    helm:
      valueFiles:
        - "values.yaml"
  project: "devops"
  syncPolicy:
    managedNamespaceMetadata:
      labels:
        managed: "argo-cd"
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
YAML
}
#==============================================================================================================
# APPLICATION GRAFANA
#==============================================================================================================
resource "kubectl_manifest" "grafana" {
  yaml_body = <<YAML
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: grafana
  namespace: argocd-system
spec:
  destination:
    namespace: "grafana-system"
    server: "https://kubernetes.default.svc"
  source:
    path: "dev/us-east-1/services/system/grafana"
    repoURL: "git@github.com:ArthurMaverick/devops_project.git"
    targetRevision: "HEAD"
    helm:
      valueFiles:
        - "values.yaml"
  project: "devops"
  syncPolicy:
    managedNamespaceMetadata:
      labels:
        managed: "argo-cd"
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
YAML
}
#==============================================================================================================
# APPLICATION PROMETHEUS
#==============================================================================================================
resource "kubectl_manifest" "prometheus" {
  yaml_body = <<YAML
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: prometheus
  namespace: argocd-system
spec:
  destination:
    namespace: "prometheus-system"
    server: "https://kubernetes.default.svc"
  source:
    path: "dev/us-east-1/services/system/prometheus"
    repoURL: "git@github.com:ArthurMaverick/devops_project.git"
    targetRevision: "HEAD"
    helm:
      valueFiles:
        - "values.yaml"
  project: "devops"
  syncPolicy:
    managedNamespaceMetadata:
      labels:
        managed: "argo-cd"
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
YAML
}
#==============================================================================================================
# APPLICATION INGRESS NGINX
#==============================================================================================================
resource "kubectl_manifest" "ingress_nginx" {
  yaml_body = <<YAML
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: ingress-nginx
  namespace: argocd-system
spec:
  destination:
    namespace: "ingress-nginx-system"
    server: "https://kubernetes.default.svc"
  source:
    path: "dev/us-east-1/services/system/ingress-nginx"
    repoURL: "git@github.com:ArthurMaverick/devops_project.git"
    targetRevision: "HEAD"
    helm:
      valueFiles:
        - "values.yaml"
  project: "devops"
  syncPolicy:
    managedNamespaceMetadata:
      labels:
        managed: "argo-cd"
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
YAML
}
#==============================================================================================================
# APPLICATION  METRICS SERVER
#==============================================================================================================
resource "kubectl_manifest" "metric-server" {
  yaml_body = <<YAML
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: metrics-server
  namespace: argocd-system
spec:
  destination:
    namespace: "metrics-server-system"
    server: "https://kubernetes.default.svc"
  source:
    path: "dev/us-east-1/services/system/metrics-server"
    repoURL: "git@github.com:ArthurMaverick/devops_project.git"
    targetRevision: "HEAD"
    helm:
      valueFiles:
        - "values.yaml"
  project: "devops"
  syncPolicy:
    managedNamespaceMetadata:
      labels:
        managed: "argo-cd"
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
YAML
}
#==============================================================================================================
# INGRESS - ARGO CD
#==============================================================================================================
resource "kubernetes_ingress_v1" "argo_cd_ingress" {
  depends_on = [helm_release.argocd_helm_release]

  metadata {
    name      = "argocd"
    namespace = var.create_namespace ? var.namespace : "argocd-system"
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
      "nginx.ingress.kubernetes.io/rewrite-target" = "/"
      "cert-manager.io/cluster-issuer" = "letsencrypt-staging"
      "nginx.ingress.kubernetes.io/backend-protocol" = "HTTP"
      "ingress.kubernetes.io/force-ssl-redirect" =  "true"
    }
  }

  spec {
    tls {
      hosts = ["argocd.santosops.com"]
      secret_name = "santos-ops"
    }
    ingress_class_name = "nginx"
    rule {
      host = "argocd.santosops.com"
      http {
        path {
          path_type = "Prefix"
          path = "/"
          backend {
            service {
              name = "argo-cd-dev-argocd-server"
              port {
                number = 8080
              }
            }
          }
        }
      }
    }
  }
}

#==============================================================================================================
# NOTIFICATION CONFIGURATION
#==============================================================================================================
#resource "kubectl_manifest" "argo_cd_notification" {
#  for_each = try({ for k, v in var.notification : k => v if v != null }, {})
#
#  yaml_body = templatefile("${path.module}/templates/notifications/application-notification.yaml.tpl", {
#    ARGO_NAMESPACE      = var.namespace
#    OAUTH_SLACK_TOKEN   = each.value.oauth_slack_token
#    SLACK_CHANNELS_LIST = each.value.slack_channels_list
#  })
#
#  depends_on = [
#    helm_release.argo_cd_install
#  ]
#  sensitive_fields = [
#    "data.oauth-slack-token"
#  ]
#}
