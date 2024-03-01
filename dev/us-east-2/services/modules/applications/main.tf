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

# Database decode from AWS Secret Manager
locals {
  DB_HOST = jsondecode(data.aws_secretsmanager_secret_version.secret_reveal.secret_string)["DB_HOST"]
  DB_PORT = jsondecode(data.aws_secretsmanager_secret_version.secret_reveal.secret_string)["DB_PORT"]
  DB_VMDB_NAME = jsondecode(data.aws_secretsmanager_secret_version.secret_reveal.secret_string)["DB_VMDB_NAME"]
  DB_VEDB_NAME = jsondecode(data.aws_secretsmanager_secret_version.secret_reveal.secret_string)["DB_VEDB_NAME"]
  DB_VSDB_NAME = jsondecode(data.aws_secretsmanager_secret_version.secret_reveal.secret_string)["DB_VSDB_NAME"]
  DB_VRDB_NAME = jsondecode(data.aws_secretsmanager_secret_version.secret_reveal.secret_string)["DB_VRDB_NAME"]
  DB_USERNAME = jsondecode(data.aws_secretsmanager_secret_version.secret_reveal.secret_string)["DB_USERNAME"]
  DB_PASSWORD = jsondecode(data.aws_secretsmanager_secret_version.secret_reveal.secret_string)["DB_PASSWORD"]
}

locals {
  region = "us-east-2"
  hostname = "ligl-ui.dev.ezops.com.br"
  mssql_password = "password123@"
  mssql_size = "6Gi"
}
locals {
  ligl_ui_image = "975635808270.dkr.ecr.us-east-2.amazonaws.com/reveal"
  ligl_ui_image_tag = "new-tag"
  ligl_ui_namespace = "ligl-ui"

  authentication_image = "975635808270.dkr.ecr.us-east-2.amazonaws.com/reveal"
  authentication_image_tag = "authentication-service-01-03"
  authentication_namespace = "authentication-service"

  monolith_image = "975635808270.dkr.ecr.us-east-2.amazonaws.com/reveal"
  monolith_image_tag = "monolith-service-master"
  monolith_namespace = "monolith-service"

  taxonomy_image = "975635808270.dkr.ecr.us-east-2.amazonaws.com/reveal"
  taxonomy_image_tag = "taxonomy-service"
  taxonomy_namespace = "taxonomy-service"

  ligl_external_image = "975635808270.dkr.ecr.us-east-2.amazonaws.com/reveal"
  ligl_external_image_tag = "ligl-external"
  ligl_external_namespace = "ligl-external"

  metadata_image = "975635808270.dkr.ecr.us-east-2.amazonaws.com/reveal"
  metadata_image_tag = "metadata-processing-service"
  metadata_namespace = "metadata-service"

  hosting_image = "975635808270.dkr.ecr.us-east-2.amazonaws.com/reveal"
  hosting_image_tag = "hosting-service"
  hosting_namespace = "hosting-service"

  process_image = "975635808270.dkr.ecr.us-east-2.amazonaws.com/reveal"
  process_image_tag = "process-service"
  process_namespace = "process-service"

  reports_image = "975635808270.dkr.ecr.us-east-2.amazonaws.com/reveal"
  reports_image_tag = "report-service"
  reports_namespace = "reports-service"

  requests_image = "975635808270.dkr.ecr.us-east-2.amazonaws.com/reveal"
  requests_image_tag = "request-tracker-service"
  requests_namespace = "requests-service"

  notification_image = "975635808270.dkr.ecr.us-east-2.amazonaws.com/reveal"
  notification_image_tag = "notification-service"
  notification_namespace = "notification-service"

  mssql_image = "975635808270.dkr.ecr.us-east-2.amazonaws.com/reveal"
  mssql_image_tag = "sql-server-backup"
  mssql_namespace = "mssql-service"
}






locals {
  authentication_settings_json = jsonencode(<<EOT
    {
      "ConnectionStrings": {
         "VMDB": "Data Source=${local.DB_HOST},${local.DB_PORT};Initial Catalog=${local.DB_VMDB_NAME};Persist Security Info=True;User ID=${local.DB_USERNAME};Password=${local.DB_PASSWORD};Encrypt=false"
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
            "path": "/logs/AuthenticationCore/log-.txt",
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
      "AccessTokenExpiryInMinutes": 480,
      "RefreshTokenExpiryInMinutes": 480
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
      "Title": "Authentication Service"
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
    "Origion": "*", 
    "Service": "AuthenticationService",
    "NonLegalUserCreatedBy" :  "NonLegalUser"
    }
  EOT  
  )
  taxonomy_setting_json = jsonencode(<<EOT
      {
        "ConnectionStrings": {
          "VMDB": "Data Source=${local.DB_HOST},${local.DB_PORT};Initial Catalog=${local.DB_VMDB_NAME};Persist Security Info=True;User ID=${local.DB_USERNAME};Password=${local.DB_PASSWORD};Encrypt=false"
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
                "path": "/logs/Taxonomycore/log-.txt",
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
          "Audience": "Everyone"
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
        "redis": {
          "host": "127.0.0.1",
          "name": "localhost",
          "port": 6379,
          "expiry": 24 
        },
        "Environment": "dev",
        "Origion": "*",
        "Service": "TaxonomyService"
      }
  EOT  
  )
  metadata_setting_json = jsonencode(<<EOT
    {
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
      "ConnectionStrings": {
          "VMDB": "${local.DB_HOST},${local.DB_PORT};Database=${local.DB_VMDB_NAME};User Id=${local.DB_USERNAME};Password=${local.DB_PASSWORD};Encrypt=false"
      },
      "Hosting": {
          "address": "http://*:50001"
      },
      "Origion": "http://10.1.0.13:8081",
      "Service": "NUIXMicroservice"
    }
  EOT  
  )

  notification_setting_json = jsonencode(<<EOT
    {
      "ConnectionStrings": {
          "VMDB": "Data Source=${local.DB_HOST},${local.DB_PORT};Initial Catalog=${local.DB_VMDB_NAME};Persist Security Info=True;User ID=${local.DB_USERNAME};Password=${local.DB_PASSWORD};Encrypt=false"
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
          "Title": "Notification Service"
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
      "Service": "NotificationService"
    }
  EOT 
  )

  hosting_setting_json = jsonencode(<<EOT
    {
      "ConnectionStrings": {
        "VMDB": "Server=${local.DB_HOST},${local.DB_PORT};Database=${local.DB_VMDB_NAME};integrated security=True;Encrypt=false"
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
      "Origion": "*",
      "Service": "TaxonomyService"
    }
  EOT  
  )
  process_setting_json = jsonencode(<<EOT
    {
      "ConnectionStrings": {
        "VMDB": "Server=${local.DB_HOST},${local.DB_PORT};Database=${local.DB_VMDB_NAME};integrated security=True;Encrypt=false"
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

  reports_setting_json = jsonencode(<<EOT
    {
      "ConnectionStrings": {
        "VMDB": "Server=${local.DB_HOST},${local.DB_PORT};Database=${local.DB_VMDB_NAME};integrated security=True;Encrypt=false",
        "VRDB": "Server=${local.DB_HOST},${local.DB_PORT};Database=${local.DB_VRDB_NAME};integrated security=True;Encrypt=false"
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

  request_tracker_setting_json = jsonencode(<<EOT
    {
      "ConnectionStrings": {
        "VMDB": "Data Source=${local.DB_HOST},${local.DB_PORT};Initial Catalog=${local.DB_VMDB_NAME};Persist Security Info=True;User ID=${local.DB_USERNAME};Password=${local.DB_PASSWORD};Encrypt=false"
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
      "ligil": {
        "url": "http://10.0.1.8:8021/Ligl/#/login/"
      },
      "redis": {
        "host": "127.0.0.1",
        "name": "localhost",
        "port": 6379,
        "expiry": 24 
      },
      "Environment": "dev",
      "Origion": "http://10.1.0.13:8081",
      "Service": "RequestTrackerService"
    }
  EOT  
  )
}

#==============================================================================================================
# CERT MANAGER APPLICATION - ARGO CD - USED TO CERTIFICATE HOSTNAMES
#==============================================================================================================

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
      parameters:
        - name: "nodeSelector.kubernetes\\.io/os"
          value: "linux"
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
}


#==============================================================================================================
# APPLICATIONS - DEPLOY APPLICATIONS
#==============================================================================================================


resource "kubectl_manifest" "application" {
  yaml_body = <<YAML
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  finalizers:
    - resources-finalizer.argocd.argoproj.io
  labels:
    argocd.argoproj.io/instance: app-of-apps
  name: applications-development
  namespace: argocd-system
spec:
  destination:
    server: 'https://kubernetes.default.svc'
  project: default
  sources:

    - repoURL: 'git@github.com:AlphaEzops/reveal-eks.git'
      path: dev/us-east-2/services/apps/ligl-ui
      targetRevision: HEAD
      helm:
        valueFiles:
          - values.yaml
        parameters:
          - name: "global.namespace"
            value: ${local.ligl_ui_namespace}
          - name: "application.image"
            value: ${local.ligl_ui_image}
          - name: "application.tag"
            value: ${local.ligl_ui_image_tag}
          - name: "application.resources.requests.cpu"
            value: "100m"
          - name: "application.resources.requests.memory"
            value: "100m"
          - name: "configMap.name"
            value: "ligl-ui-config"
          - name: "configMap.serviceIp"
            value: ${local.hostname}
          - name: "configMap.webSocketUrl"
            value: "ws://10.0.0.10:8092/"
          - name: "configMap.loginUrl"
            value: "/Token"
          - name: "configMap.getUserUrl"
            value: "/api/user"
          - name: "configMap.oData"
            value: "/odata/"
          - name: "configMap.moduleLookupUrl"
            value: "/odata/Modules"
          - name: "configMap.appSettingUrl"
            value: "/odata/AppSettings"
          - name: "configMap.oDataTaxonomyUrl"
            value: "/odata/TaxonomyService/"
          - name: "configMap.userPermissions"
            value: "/odata/UserPermissions"
          - name: "configMap.logoutUrl"
            value: "/api/ApplicationLogout"
          - name: "configMap.telerikReportServerUrl"
            value: "http://localhost:17080"
          - name: "configMap.apiPrefixURL"
            value: "/api/"
          - name: "configMap.defaultLanguage"
            value: "en-us"
          - name: "configMap.IsNuixEnvironment"
            value: "false"
          - name: "configMap.isCommonSpiritInstance"
            value: "true"
          - name: "configMap.isLocalization"
            value: "true"
          - name: "configMap.ClientName"
            value: "Reveal-Brainspace"
          - name: "configMap.AuthenticationProviderType"
            value: "BasicAuthentication"
          - name: "configMap.IsSSOSPInitiatedEnabled"
            value: "true"
          - name: "configMap.IsMearsk"
            value: "true"
          - name: "configMap.ssoSPInitiatedUrl"
            value: "https://myapps.microsoft.com/signin/SSOTEST/c901be31-6b06-400f-befd-c1e4fc855a43?tenantId=0b72188d-58bf-4491-880a-49e3f402721d"
          - name: "configMap.ApproversCount"
            value: "2"
          - name: "configMap.DocumentHelpUrl"
            value: "https://unec.edu.az/application/uploads/2014/12/pdf-sample.pdf"
          - name: "configMap.telerikReportServerUrlNew"
            value: "https://in-opt-sit-01.in.vertical.com:44399/"
          - name: "configMap.reviewUrl"
            value: "https://landing.revealdata.com/"
          - name: "configMap.scheduledtasksUrl"
            value: "https://telerik.myligl.io/api/reportserver/v2/scheduledtasks"
          - name: "configMap.reportParameters"
            value: "https://telerik.myligl.io/api/reportserver/v2/reports/{reportID}/parameters"
          - name: "configMap.clientID"
            value: "https://telerik.myligl.io/api/reports/clients"
          - name: "configMap.reportParametersByClientID"
            value: "https://telerik.myligl.io/api/reports/clients/{clientId}/parameters"
          - name: "configMap.telerikToken"
            value: "https://telerik.myligl.io/token"
          - name: "configMap.childParameters"
            value: "https://telerik.myligl.io/api/reports/clients/{clientId}/parameters"
          - name: "configMap.getScheduledTask"
            value: "https://telerik.myligl.io/api/reportserver/v2/scheduledtasks"

    
    - repoURL: 'git@github.com:AlphaEzops/reveal-eks.git'
      path: dev/us-east-2/services/apps/authentication-service
      helm:
        valueFiles:
          - values.yaml
        parameters:
          - name: "global.namespace"
            value: ${local.authentication_namespace}
          - name: "application.image"
            value: ${local.authentication_image}
          - name: "application.tag"
            value: ${local.authentication_image_tag}
          - name: "application.resources.requests.cpu"
            value: "100m"
          - name: "application.resources.requests.memory"
            value: "100m"
          - name: "configMap.configuration"
            value: ${local.authentication_settings_json}
          - name: "ingress.hostname"
            value: ${local.hostname}

    
    - repoURL: 'git@github.com:AlphaEzops/reveal-eks.git'
      path: dev/us-east-2/services/apps/monolith-service
      targetRevision: HEAD
      helm:
        valueFiles:
          - values.yaml
        parameters:
          - name: "global.namespace"
            value: ${local.monolith_namespace}
          - name: "application.image"
            value: ${local.monolith_image}
          - name: "application.tag"
            value: ${local.monolith_image_tag}
          - name: "ingress.hostname"
            value: ${local.hostname}
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

    
    - repoURL: 'git@github.com:AlphaEzops/reveal-eks.git'
      path: dev/us-east-2/services/apps/taxonomy-service
      targetRevision: HEAD
      helm:
        valueFiles:
          - values.yaml
        parameters:
          - name: "global.namespace"
            value: ${local.taxonomy_namespace}
          - name: "application.image"
            value: ${local.taxonomy_image}
          - name: "application.tag"
            value: ${local.taxonomy_image_tag}
          - name: "application.resources.requests.cpu"
            value: "100m"
          - name: "application.resources.requests.memory"
            value: "100m"
          - name: "ingress.hostname"
            value: ${local.hostname}
          - name: "configMap.configuration"
            value: ${local.taxonomy_setting_json}
     

    - repoURL: 'git@github.com:AlphaEzops/reveal-eks.git'
      path: dev/us-east-2/services/apps/ligl-external
      targetRevision: HEAD
      helm:
        valueFiles:
          - values.yaml
        parameters:
          - name: "global.namespace"
            value: ${local.ligl_external_namespace}
          - name: "application.image"
            value: ${local.ligl_external_image}
          - name: "application.tag"
            value: ${local.ligl_external_image_tag}
          - name: "ingress.hostname"
            value: ${local.hostname}
          - name: "application.resources.requests.cpu"
            value: "100m"
          - name: "application.resources.requests.memory"
            value: "100m"
        

    - repoURL: 'git@github.com:AlphaEzops/reveal-eks.git'
      path: dev/us-east-2/services/apps/metadata-processing-service
      targetRevision: HEAD   
      helm:
        valueFiles:
          - values.yaml
        parameters:
          - name: "global.namespace"
            value: ${local.metadata_namespace}
          - name: "application.image"
            value: ${local.metadata_image}
          - name: "application.tag"
            value: ${local.metadata_image_tag}
          - name: "application.resources.requests.cpu"
            value: "100m"
          - name: "application.resources.requests.memory"
            value: "100m"
          - name: "ingress.hostname"
            value: ${local.hostname}
          - name: "configMap.configuration"
            value: ${local.metadata_setting_json}
    

    - repoURL: 'git@github.com:AlphaEzops/reveal-eks.git'
      path: dev/us-east-2/services/apps/hosting-service
      targetRevision: HEAD
      helm:
        valueFiles:
          - values.yaml
        parameters:
          - name: "global.namespace"
            value: ${local.hosting_namespace}
          - name: "application.image"
            value: ${local.hosting_image}
          - name: "application.tag"
            value: ${local.hosting_image_tag}
          - name: "application.resources.requests.cpu"
            value: "100m"
          - name: "application.resources.requests.memory"
            value: "100m"
          - name: "ingress.hostname"
            value: ${local.hostname}
          - name: "configMap.configuration"
            value: ${local.hosting_setting_json}
    
    
    - repoURL: 'git@github.com:AlphaEzops/reveal-eks.git'
      path: dev/us-east-2/services/apps/process-service
      targetRevision: HEAD
      helm:
        valueFiles:
          - values.yaml
        parameters:
          - name: "global.namespace"
            value: ${local.process_namespace}
          - name: "application.image"
            value: ${local.process_image}
          - name: "application.tag"
            value: ${local.process_image_tag}
          - name: "application.resources.requests.cpu"
            value: "100m"
          - name: "application.resources.requests.memory"
            value: "100m"
          - name: "ingress.hostname"
            value: ${local.hostname}
          - name: "configMap.configuration"
            value: ${local.process_setting_json}
    

    - repoURL: 'git@github.com:AlphaEzops/reveal-eks.git'
      path: dev/us-east-2/services/apps/reports-service
      targetRevision: HEAD
      helm:
        valueFiles:
          - values.yaml
        parameters:
          - name: "global.namespace"
            value: ${local.reports_namespace}
          - name: "application.image"
            value: ${local.reports_image}
          - name: "application.tag"
            value: ${local.reports_image_tag}
          - name: "application.resources.requests.cpu"
            value: "100m"
          - name: "application.resources.requests.memory"
            value: "100m"
          - name: "ingress.hostname"
            value: ${local.hostname}
          - name: "configMap.configuration"
            value: ${local.reports_setting_json}
      
    
    - repoURL: 'git@github.com:AlphaEzops/reveal-eks.git'
      path: dev/us-east-2/services/apps/request-tracker-service
      targetRevision: HEAD
      helm:
        valueFiles:
          - values.yaml
        parameters:
          - name: "global.namespace"
            value: ${local.requests_namespace}
          - name: "application.image"
            value: ${local.requests_image}
          - name: "application.tag"
            value: ${local.requests_image_tag}
          - name: "application.resources.requests.cpu"
            value: "100m"
          - name: "application.resources.requests.memory"
            value: "100m"
          - name: "ingress.hostname"
            value: ${local.hostname}
          - name: "configMap.configuration"
            value: ${local.request_tracker_setting_json}
    
    
    - repoURL: 'git@github.com:AlphaEzops/reveal-eks.git'
      path: dev/us-east-2/services/apps/notification-service
      targetRevision: HEAD
      helm:
        valueFiles:
          - values.yaml
        parameters:
          - name: "global.namespace"
            value: ${local.notification_namespace}
          - name: "application.image"
            value: ${local.notification_image}
          - name: "application.tag"
            value: ${local.notification_image_tag}
          - name: "application.resources.requests.cpu"
            value: "100m"
          - name: "application.resources.requests.memory"
            value: "100m"
          - name: "ingress.hostname"
            value: ${local.hostname}
          - name: "configMap.configuration"
            value: ${local.notification_setting_json}
   
  
    - repoURL: 'git@github.com:AlphaEzops/reveal-eks.git'
      path: dev/us-east-2/services/apps/sql-server-backup
      targetRevision: HEAD
      helm:
        valueFiles:
          - values.yaml
        parameters:
          - name: "global.namespace"
            value: ${local.mssql_namespace}
          - name: "image.repository"
            value: ${local.mssql_image}
          - name: "image.tag"
            value: ${local.mssql_image_tag}
          - name: "sapassword"
            value: ${local.mssql_password}
          - name: "acceptEula.value"
            value: "Y"
          - name: "nodeSelector.kubernetes\\.io/os"
            value: "linux"
          - name: "persistence.dataSize"
            value: ${local.mssql_size}

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
    kubectl_manifest.cert_manager_system
  ]
}
