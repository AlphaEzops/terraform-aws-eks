#==============================================================================================================
# KUBERNETES RESOURCES - NAMESPACE
#==============================================================================================================
resource "kubernetes_namespace" "jenkins" {
  count      = (var.enabled && var.create_namespace && var.namespace != "kube-system") ? 1 : 0

  metadata {
    name = var.namespace
  }
}
#==============================================================================================================
# HELM CHART - JENKINS
#==============================================================================================================
locals {
  default_set_values = {
#    "nodeSelector.kube/nodetype" = var.node_selector
  }
}

resource "helm_release" "jenkins" {
  depends_on = [kubernetes_namespace.jenkins]
  name             = "jenkins"
  chart            = "jenkins"
  repository       = "https://charts.bitnami.com/bitnami"
  version          = "12.2.7"
  namespace        = var.create_namespace ? var.namespace : "jenkins-system"
  timeout          = 260

  dynamic "set" {
    for_each = try({ for key, value in local.default_set_values : key => value }, {})
    content {
      name  = set.key
      value = set.value
    }
  }

  values = [
    file("${path.module}/manifests/jenkins-bitnami.yaml")
  ]
}
#==============================================================================================================
# INGRESS - JENKINS
#==============================================================================================================
resource "kubernetes_ingress_v1" "jenkins" {
  depends_on = [helm_release.jenkins]
#  count      = var.enabled && var.create_ingress ? 1 : 0

  metadata {
    name      = "jenkins"
    namespace = var.create_namespace ? var.namespace : "jenkins-system"
    annotations = {
#      "kubernetes.io/ingress.class" = "nginx"
#      "nginx.ingress.kubernetes.io/rewrite-target" = "/"
      "cert-manager.io/cluster-issuer" = "letsencrypt-staging"
      "nginx.ingress.kubernetes.io/backend-protocol" = "HTTP"
      "ingress.kubernetes.io/force-ssl-redirect" =  "true"
    }
  }

  spec {
    tls {
      hosts = ["jenkins.santosops.com"]
      secret_name = "santos-ops"
    }
    ingress_class_name = "nginx"
    rule {
      host = "jenkins.santosops.com"
      http {
        path {
          path_type = "Prefix"
          path = "/"
          backend {
            service {
              name = "jenkins"
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
#==============================================================================================================
# CONFIGMAP - JENKINS SED JOB
#==============================================================================================================
#resource "kubernetes_config_map" "jcasc_jobs" {
#  metadata {
#    name = "jcasc-jobs"
#    labels = {
#      jenkins-jenkins-config = "true"
#    }
#    namespace = var.namespace
#  }
#
#  data = {
#    "jcasc-jobs.yaml" = file("${path.module}/manifests/seed-job.yaml")
#  }
#}