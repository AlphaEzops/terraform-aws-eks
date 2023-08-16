data "aws_region" "current" {}

#==============================================================================================================
# KUBERNETES RESOURCES - NAMESPACE
#==============================================================================================================
resource "kubernetes_namespace" "ingress_nginx" {
  count      = (var.enabled && var.create_namespace && var.namespace != "kube-system") ? 1 : 0

  metadata {
    name = var.namespace
  }
}
#==============================================================================================================
# HELM CHART - INGRESS NGINX
#==============================================================================================================
resource "helm_release" "ingress_nginx" {
  depends_on   = [kubernetes_namespace.ingress_nginx]

  name         = "ingress-nginx"
  repository   = "https://kubernetes.github.io/ingress-nginx"
  chart        = "ingress-nginx"
  version      = "4.4.2"
  force_update = false
  namespace    = var.create_namespace ? var.namespace : "ingress-nginx"

  set {
    name  = "controller.service.targetPorts.http"
    value = "http"
  }

  set {
    name  = "controller.service.targetPorts.https"
    value = "https"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-backend-protocol"
    value = "TCP"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-ssl-ports"
    value = "TCP"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-connection-idle-timeout"
    value = "60"
  }
  set {
    name  = "controller.service.internal.enabled"
    value = "false"
  }

  set {
    name  = "controller.service.internal.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-internal"
    value = "false"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
    value = "alb"
  }

  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }

  # set {
  #   name  = "controller.nodeSelector.kube/nodetype"
  #   value = var.node_selector
  # }

  set {
    name  = "defaultBackend.nodeSelector.kube/nodetype"
    value = var.node_selector
  }
}

data "kubernetes_service_v1" "ingress_nginx_service" {
  depends_on = [
    helm_release.ingress_nginx
  ]

  metadata {
    name      = "ingress-nginx-controller"
    namespace = var.namespace
  }
}

data "aws_elb_hosted_zone_id" "ingress_nginx_zone_id" {
  region = data.aws_region.current.name
}

