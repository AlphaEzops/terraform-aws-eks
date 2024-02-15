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

[GUIDE DEV](https://github.com/ArthurMaverick/devops_project/tree/main/dev) **|** [STAGE GUIDE](https://github.com/ArthurMaverick/devops_project/tree/main/stage) **|** [PROD GUIDE](https://github.com/ArthurMaverick/devops_project/tree/main/prod)
**Folder structure**
![](https://github.com/ArthurMaverick/devops_project/blob/main/docs/repo-structure-folder.gif)
 
_only the dev environment was created for demo purposes so follow the documentation of [DEV GUIA](https://github.com/ArthurMaverick/devops_project/tree/main/dev)_

## 3. Network
Overview of the infrastructure created by terraform:

- A network was created with 6 subnets (3 public and 3 private) in 3 different availability zones.
- The traffic for the private network is routed through a NAT gateway.
- The traffic for the public network is routed through an internet gateway.
- Security groups were created to allow traffic between the subnets and to allow inbound and outbound network traffic.

![](https://github.com/ArthurMaverick/devops_project/blob/main/docs/network.gif)

## 4. EKS Cluster

- A Kubernetes cluster was created with 4 nodes divided into 2 node groups.
- Each node group is in a different availability zone, ensuring high availability.
- Services were created with high availability in mind.
- Nginx ingress controller was installed to manage incoming traffic.
- Prometheus was installed to collect cluster metrics.
- Grafana was installed to visualize the metrics collected by Prometheus.
- ArgoCD was installed to manage cluster deployments.


![](https://github.com/ArthurMaverick/devops_project/blob/main/docs/cluster.gif)

## 5. Pipeline
- A pipeline was created to automate the application deployment.
- The pipeline was set up using Jenkins jobs and CodeBuild.
- The pipeline is triggered by a GitHub webhook.
- The pipeline builds the Docker image of the application and deploys it to the Kubernetes cluster.
- The pipeline deploys the application to a specific namespace.

![](https://github.com/ArthurMaverick/devops_project/blob/main/docs/pipeline.gif)

## 6. Conclusion

Congratulations! You've successfully installed and set up a suite of powerful tools commonly used in DevOps workflows. With AWS CLI, Terraform, kubectl, and Ansible at your disposal, you can manage infrastructure, provision resources, orchestrate containers, and automate configurations effectively.

Remember to refer to the official documentation and guides for each tool to learn more about their features, usage, and best practices:

- AWS CLI Documentation: https://aws.amazon.com/cli/
- Terraform Documentation: https://www.terraform.io/docs/index.html
- Kubernetes Documentation: https://kubernetes.io/docs/home/
- Ansible Documentation: https://docs.ansible.com/ansible/latest/index.html

By mastering these tools, you'll be better equipped to streamline your DevOps practices, manage infrastructure as code, and automate various aspects of your software development lifecycle. Always exercise caution and test your actions in controlled environments before applying them to production systems.