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

locals {
  DB_HOST = jsondecode(data.aws_secretsmanager_secret_version.secret_reveal.secret_string)["DB_HOST"]
  DB_PORT = jsondecode(data.aws_secretsmanager_secret_version.secret_reveal.secret_string)["DB_PORT"]
  DB_VMDB_NAME = jsondecode(data.aws_secretsmanager_secret_version.secret_reveal.secret_string)["DB_VMDB_NAME"]
  DB_VEDB_NAME = jsondecode(data.aws_secretsmanager_secret_version.secret_reveal.secret_string)["DB_VEDB_NAME"]
  DB_VSDB_NAME = jsondecode(data.aws_secretsmanager_secret_version.secret_reveal.secret_string)["DB_VSDB_NAME"]
  DB_USERNAME = jsondecode(data.aws_secretsmanager_secret_version.secret_reveal.secret_string)["DB_USERNAME"]
  DB_PASSWORD = jsondecode(data.aws_secretsmanager_secret_version.secret_reveal.secret_string)["DB_PASSWORD"]
}


# module "custom_external_secret_monolith_service" {
#   source = "../../system/external-secrets-role"
#   application_namespace = local.application_namespace
#   service_account_name = local.service_account_name
# }


#==============================================================================================================
# APPLICATION - AUTHENTICATION SERVICE
#==============================================================================================================


resource "kubectl_manifest" "monolith_service" {

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
        - name: "configMap.DefaultConnectionString"
          value: "data source=${local.DB_HOST},${local.DB_PORT};initial catalog=${local.DB_VEDB_NAME};user id=${local.DB_USERNAME};pwd=${local.DB_PASSWORD};MultipleActiveResultSets=True;Enlist=false;App=EntityFramework"
        - name: "configMap.CaseCustodianDataSourceContextConnectionString" 
          value: "data source=${local.DB_HOST},${local.DB_PORT};initial catalog=${local.DB_VEDB_NAME};user id=${local.DB_USERNAME};pwd=${local.DB_PASSWORD};multipleactiveresultsets=True;application name=EntityFramework"
        - name: "configMap.MasterEntitiesConnectionString"
          value: "metadata=res://*/Master.Master.csdl|res://*/Master.Master.ssdl|res://*/Master.Master.msl;provider=System.Data.SqlClient;provider connection string=&quot;data source=${local.DB_HOST},${local.DB_PORT};initial catalog=${local.DB_VMDB_NAME};user id=${local.DB_USERNAME};pwd=${local.DB_PASSWORD};MultipleActiveResultSets=True;Enlist=false;App=EntityFramework&quot;"
        - name: "configMap.ProcessingEngineEntitiesConnectionString"
          value: "metadata=res://*/ProcessingEngineManagement.ProcessingEngine.csdl|res://*/ProcessingEngineManagement.ProcessingEngine.ssdl|res://*/ProcessingEngineManagement.ProcessingEngine.msl;provider=System.Data.SqlClient;provider connection string=&quot;data source=source=${local.DB_HOST},${local.DB_PORT};initial catalog=${local.DB_VMDB_NAME};user id=${local.DB_USERNAME};pwd=${local.DB_PASSWORD};MultipleActiveResultSets=True;Enlist=false;App=EntityFramework&quot;"
        - name: "configMap.ReportManagementEntitiesConnectionString"
          value: "metadata=res://*/ReportManagement.ReportManagement.csdl|res://*/ReportManagement.ReportManagement.ssdl|res://*/ReportManagement.ReportManagement.msl;provider=System.Data.SqlClient;provider connection string=&quot;data source=${local.DB_HOST},${local.DB_PORT};initial catalog=${local.DB_VMDB_NAME};user id=${local.DB_USERNAME};pwd=${local.DB_PASSWORD};MultipleActiveResultSets=True;Enlist=false;App=EntityFramework&quot;"
        - name: "configMap.EntityDbConnectionString"
          value: "metadata={0};provider=System.Data.SqlClient;provider connection string=&quot;data source={1};initial catalog={2};{3};MultipleActiveResultSets=True;Enlist={4};App=EntityFramework&quot;"
        - name: "configMap.StagingEntitiesConnectionString"
          value: "metadata=res://*/Staging.Staging.csdl|res://*/Staging.Staging.ssdl|res://*/Staging.Staging.msl;provider=System.Data.SqlClient;provider connection string=&quot;data source=source=${local.DB_HOST},${local.DB_PORT};initial catalog=${local.DB_VSDB_NAME};user id=${local.DB_USERNAME};pwd=${local.DB_PASSWORD};MultipleActiveResultSets=True;App=EntityFramework&quot;"
    path: dev/us-east-2/services/apps/monolith-service
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
