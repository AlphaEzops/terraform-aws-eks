# Reveal Guide

![](docs/assets/macro-system.gif)

# Strucutre of folder
![](docs/assets/structure-folder.png)

## 1. Services

### PROVISION SERVICES 

The application provisions services by creating Helm applications in Argocd for each service via Terraform. An Argocd application needs to retrieve information and have access to the repository where the Helm charts are located. In this application, the service is located in the same repository as the project, in the **dev/us-east-2/services/apps/** folder, where all the Helm charts of the applications are found.
There are services created to enable features in applications by extending the Kubernetes API, such as:
- [External-Secrets](https://artifacthub.io/packages/helm/external-secrets-operator/external-secrets), which allows obtaining sensitive data from external sources, in this case, AWS Secrets Manager.
- [Nginx Ingress Controller](https://artifacthub.io/packages/helm/ingress-nginx/ingress-nginx), which acts as a load balancer, managing HTTP and HTTPS traffic being executed within the Kubernetes application.
- [Cert-Manager](https://artifacthub.io/packages/helm/cert-manager/cert-manager), which is a tool used to manage TLS certificates, responsible for ensuring security and communication within the environment.
- [ArgoCD](https://artifacthub.io/packages/helm/argo/argo-cd) is a tool that enables continuous deployment of applications in Kubernetes environments.

Terraform applications involve deploying Helm services in Argocd, the Terraform application modules are created in dev/us-east-2/modules. Each folder corresponds to a service, an ArgoCD [application has its own Kubernetes template](https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/#applications) structure and is being deployed via Kubectl.
An example of a created ArgoCD application is:

![](docs/assets/argocd_application.png)

This application deploys the monolith service, in the folder **dev/us-east-2/services/apps/monolith-service**.
