# Cluster API

This repository contains the platform components for deploying Cluster API resources on Microsoft Azure with kubeadm tooling.

Provisioning three system nodes, and two user nodepools across availability zones. This is an alternative approach to running Kubernetes on Azure.

### Getting Started

Before deploying the Kubernetes resources, the parameters file `src/parameters/main.json` needs to be updated.

#### Using locally with Azure CLI

```bash
az deployment sub create \
    --name 'Microsoft.Bicep' \
    --location 'uksouth' \
    --template-file './src/main.bicep' \
    --parameters \
      '@./src/parameters/main.json' \
    --parameters \
      username='replace' \
      keydata=@/home/replace/.ssh/id_rsa.pub
```
