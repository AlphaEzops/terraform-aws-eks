# DevOps Toolchain Installation and Usage Guide

![](https://github.com/ArthurMaverick/devops_project/blob/main/docs/diagram.gif)

---

This comprehensive guide will walk you through the process of installing and using various tools commonly used in the DevOps workflow. From infrastructure provisioning to configuration management, automation, and container orchestration, this guide will cover everything you need to get started.
# Devops Project

## Table of Contents
1. [Requirements](#1-requirements)
2. [Deploy Infrastructure](#2-deploy-infrastructure)
3. [Network Overview](#3-network)
4. [EKS Cluster](#4-eks-cluster)
5. [Pipeline](#5-pipeline)
6. [Conclusion](#6-conclusion)


## 1. Requirements
1. you need install all the tools below:
- [terraform](./docs/terraform.md) - tools for provisioning and managing cloud infrastructure **required**
- [kubectl](./docs/kubectl.md) - command-line tool for Kubernetes **required**
- [ansible](./docs/ansible.md) - configuration management and automation tool **optional**
- [aws cli](./docs/aws-cli.md) - command-line tool for AWS **required**
- [tfenv](./docs/tfenv.md) - terraform version manager **optional**
- [aws vault](./docs/aws-vault.md) - tool for securely storing and accessing AWS credentials in development environments **optional**

## 2. Deploy Infrastructure

### Environments 

[DEV GUIA](https://github.com/ArthurMaverick/devops_project/tree/main/dev) | [STAGE GUIA](https://github.com/ArthurMaverick/devops_project/tree/main/stage) | [PROD GUIA](https://github.com/ArthurMaverick/devops_project/tree/main/prod)
**Folder structure**
![](https://github.com/ArthurMaverick/devops_project/blob/main/docs/repo-structure-folder.gif)
_somente o ambiente de dev foi criado para fins de demonstraçao entao siga com a doc do [DEV GUIA](https://github.com/ArthurMaverick/devops_project/tree/main/dev)_

## 3. Network
Overview of the infrastructure created by terraform

- Foi criado uma rede com 6 subnetes (3 publicas e 3 privadas) em 3 zonas de disponibilidade diferentes.
- O trafego da rede privada é feito por um nat gateway.
- O trafego da rede publica é feito por um internet gateway.
- Security groups foram criados para permitir o trafego entre as subnets e para permitir o trafego de entrada e saida da rede.

![](https://github.com/ArthurMaverick/devops_project/blob/main/docs/network.gif)

## 4. EKS Cluster
- Foi criado um cluster kubernetes com 4 nodes divididos em 2 node groups.
- Cada node groups esta em uma zona de disponibilidade diferente, garantindo alta disponibilidade.
- Servicos foram criados pensando em alta disponibilidade.
- Nginx ingress controller foi instalado para gerenciar o trafego de entrada.
- Prometheus foi instalado para coletar metricas do cluster.
- Grafana foi instalado para visualizar as metricas coletadas pelo prometheus.
- ArgoCD foi instalado para gerenciar os deployments do cluster.

![](https://github.com/ArthurMaverick/devops_project/blob/main/docs/cluster.gif)

## 5. Pipeline
- Foi criado um pipeline para automatizar o deploy da aplicacao.
- A pipeline foi criada usando Jenkins job e Codebuild.
- A pipeline é trigada por um webhook do github.
- A pipeline faz o build e o da imagem docker da aplicacao e faz o deploy no cluster kubernetes.
- A pipeline faz o deploy da aplicacao em um namespace especifico.

![](https://github.com/ArthurMaverick/devops_project/blob/main/docs/pipeline.gif)

## 6. Conclusion

Congratulations! You've successfully installed and set up a suite of powerful tools commonly used in DevOps workflows. With AWS CLI, Terraform, kubectl, and Ansible at your disposal, you can manage infrastructure, provision resources, orchestrate containers, and automate configurations effectively.

Remember to refer to the official documentation and guides for each tool to learn more about their features, usage, and best practices:

- AWS CLI Documentation: https://aws.amazon.com/cli/
- Terraform Documentation: https://www.terraform.io/docs/index.html
- Kubernetes Documentation: https://kubernetes.io/docs/home/
- Ansible Documentation: https://docs.ansible.com/ansible/latest/index.html

By mastering these tools, you'll be better equipped to streamline your DevOps practices, manage infrastructure as code, and automate various aspects of your software development lifecycle. Always exercise caution and test your actions in controlled environments before applying them to production systems.