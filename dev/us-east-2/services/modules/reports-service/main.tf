data "aws_caller_identity" "this" {}
data "aws_partition" "this" {}
data "aws_eks_cluster" "reveal-cluster" {
  name = "reveal-cluster"
}

# data "aws_secretsmanager_secret" "secret_reveal" {
#  name = "prod/reveal/reports-service"
# }

# data "aws_secretsmanager_secret_version" "secret_reveal" {
#  secret_id = data.aws_secretsmanager_secret.secret_reveal.id
# }


# SINGLE QUOTE ON CONNECTIONSTRINGS.VMDB TO ESCAPE STRINGS AUTOMATICALLY 
locals {
  region = "us-east-2"
  application_namespace = var.application_namespace
  service_account_name = var.service_account_name
  setting_json = jsonencode(<<EOT
     {
      "ConnectionStrings": {
        "VMDB": "Server=IN-DEMO-DB-01\\VDSQL,60444;Database=OPTIMUM_DIT_MASTER;integrated security=True;Encrypt=false",
        "VRDB": "Server=IN-DEMO-DB-01\\VDSQL,60444;Database=OPTIMUM_DIT_REPORTS;integrated security=True;Encrypt=false"
      },
      "Logging": {
        "LogLevel": {
          "Default": "Information",
          "Microsoft.AspNetCore": "Warning"
        }
      },
      "AllowedHosts": "*",
      "Serilog": {
        "Using": [ "Serilog.Sinks.File", "Serilog.Sinks.Console" ],
        "MinimumLevel": {
          "Default": "Information",
          "Override": {
            "Microsoft": "Warning",
            "System": "Warning"
          }
        },
        "WriteTo": [
          {
            "Name": "Console"
          },
          {
            "Name": "File",
            "Args": {
              "path": "/logs/core/log-.txt",
              "rollOnFileSizeLimit": true,
              "formatter": "Serilog.Formatting.Compact.CompactJsonFormatter,Serilog.Formatting.Compact",
              "rollingInterval": "Day"
            }
          }
        ],
        "Enrich": [ "FromLogContext", "WithThreadId", "WithMachineName" ]
      },
      "Tokens": {
        "Key": "IxrAjDoa2FqEl3RIhrSrUJELhUckePEPVpaePlS_Poa",
        "Issuer": "VerticalAuthority",
        "Audience": "Everyone",
        "AccessTokenExpiry": 10,
        "RefreshTokenExpiry": 60
      },
      "SecurityKeys": {
        "EncyKey": "VDev@2016",
        "DefaultPasswordKey": "VerticalPassword#123"
      },
      "WebSocketSetting": {
        "KeepAliveInterval": 120,
        "BufferSize": 4,
        "DefaultBuffer": 1024,
        "TimeOut": 3600000
      },
      "SwaggerSettings": {
        "Version": "V1",
        "Title": "Taxonomy Service"
      },
      "ConnectionStringSettings": {
        "MaxTryCount": 10,
        "MaxDelayTryInSeconds": 30
      },
      "redis": {
        "host": "127.0.0.1",
        "name": "localhost",
        "port": 6379,
        "expiry": 24 
      },
      "Environment": "dev",
      "Origion": "http://10.1.0.13:8081", 
      "Service": "TaxonomyService"
    }
EOT  
)
}
module "custom_external_secret_reports_service" {
  source = "../../system/external-secrets-role"
  application_namespace = local.application_namespace
  service_account_name = local.service_account_name
}


#==============================================================================================================
# APPLICATION - REPORTS SERVICE
#==============================================================================================================


resource "kubectl_manifest" "reports_service" {

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
        - name: "secrets.externalSecrets.serviceAccount.name"
          value: ${local.service_account_name}
        - name: "secrets.externalSecrets.serviceAccount.arn"
          value: ${module.custom_external_secret_reports_service.service_account_role_arn}
        - name: "global.namespace"
          value: ${local.application_namespace}
        - name: "application.resources.requests.cpu"
          value: "100m"
        - name: "application.resources.requests.memory"
          value: "100m"
        - name: "configMap.configuration"
          value: ${local.setting_json}
    path: dev/us-east-2/services/apps/reports-service
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
