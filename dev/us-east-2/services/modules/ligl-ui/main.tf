data "aws_caller_identity" "this" {}
data "aws_partition" "this" {}
data "aws_eks_cluster" "reveal-cluster" {
  name = "reveal-cluster"
}
data "aws_secretsmanager_secret" "secret_reveal" {
 name = "prod/reveal"
}

data "aws_secretsmanager_secret_version" "secret_reveal" {
 secret_id = data.aws_secretsmanager_secret.secret_reveal.id
}
locals {
  region = "us-east-2"
  application_namespace = var.application_namespace
  service_account_name = var.service_account_name
}

#==============================================================================================================
# APPLICATION - LIGL-UI
#==============================================================================================================

# resource "helm_release" "ligl_ui" {
#   name         = "ligl-ui"
#   chart        = "${path.module}/../../apps/argocd-application"
#   namespace    = "argocd-system"
#   description  = "ArgoCD for Authentication Service"
#   reset_values = true
#   max_history  = 5

#   values = [
#     # Add values
#     templatefile("${path.module}/../00_helm_values/ligl-ui_values.yml", {
#       "helm_repoUrl" = "git@github.com:AlphaEzops/reveal-eks.git"
#       "helm_path"   = "dev/us-east-2/services/apps/ligl-ui-secrets"
#       "helm_version" = "HEAD"

#       "image_repo"        = "975635808270.dkr.ecr.us-east-2.amazonaws.com/reveal"
#       "image_tag"         = "new-tag"
#       "application_name"  = "ligl-ui"
#       "ligl_ui_hostname"  = "ligl-ui.dev.ezops.com.br"
#       "secrets_enabled"   = false
#       "configmap_serviceip" = "ligl-ui.dev.ezops.com.br/"
#       "configmap_websocketurl" = "ws://10.0.0.10:8092/"
#       "configmap_loginurl" = "/Token"
#       "configmap_getuserurl" = "/api/user"
#       "configmap_odata" = "/odata/"
#       "configmap_modulelookupurl" = "/odata/Modules"
#       "configmap_appsettingurl" = "/odata/AppSettings"
#       "configmap_odatataxonomyurl" = "/odata/TaxonomyService/"
#       "configmap_userpermissions" = "/odata/UserPermissions"
#       "configmap_logouturl" = "/api/ApplicationLogout"
#       "configmap_telerikreportserverurl" = "http://localhost:17080"
#       "configmap_apiprefixurl" = "/api/"
#       "configmap_defaultlanguage" = "en-us"
#       "configmap_isnuixenvironment" = false
#       "configmap_iscommonspiritinstance" = true
#       "configmap_islocalization" = true
#       "configmap_clientname" = "Reveal-Brainspace"
#       "configmap_authenticationprovidertype" = "BasicAuthentication"
#       "configmap_isssospinitiatedenabled" = true
#       "configmap_ismearsk" = true
#       "configmap_ssospinitiatedurl" = "https://myapps.microsoft.com/signin/SSOTEST/c901be31-6b06-400f-befd-c1e4fc855a43?tenantId=0b72188d-58bf-4491-880a-49e3f402721d"
#       "configmap_approverscount" = 2
#       "configmap_documenthelpurl" = "https://unec.edu.az/application/uploads/2014/12/pdf-sample.pdf"
#       "configmap_telerikreportserverurlnew" = "https://in-opt-sit-01.in.vertical.com:44399/"
#       "configmap_reviewurl" = "https://landing.revealdata.com/"
#       "configmap_scheduledtasksurl" = "https://telerik.myligl.io/api/reportserver/v2/scheduledtasks"
#       "configmap_reportparameters" = "https://telerik.myligl.io/api/reportserver/v2/reports/{reportID}/parameters"
#       "configmap_clientid" = "https://telerik.myligl.io/api/reports/clients"
#       "configmap_reportparametersbyclientid" = "https://telerik.myligl.io/api/reports/clients/{clientId}/parameters"
#       "configmap_teleriktoken" = "https://telerik.myligl.io/token"
#       "configmap_childparameters" = "https://telerik.myligl.io/api/reports/clients/{clientId}/parameters"
#       "configmap_getscheduledtask" = "https://telerik.myligl.io/api/reportserver/v2/scheduledtasks"
#     })
#   ]
# }


resource "kubectl_manifest" "ligl-ui" {

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
        - name: "global.namespace"
          value: ${local.application_namespace}
        - name: "application.resources.requests.cpu"
          value: "100m"
        - name: "application.resources.requests.memory"
          value: "100m"
    path: dev/us-east-2/services/apps/ligl-ui-secrets
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
