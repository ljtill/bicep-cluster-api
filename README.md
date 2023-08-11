# Cluster API

This repository provides the source code for setting up Cluster API on Microsoft Azure using Bicep and Flux: You can use this repository to create a fully automated and scalable workflow for deploying and managing Kubernetes clusters on Azure.

The purpose of the repository is to:

- Deploy the management cluster with Bicep
- Bootstrap it with Flux to pull in the Kubernetes manifests and apply them
- Install Cluster API on top of the management cluster
- Start deploying additional AKS clusters using Cluster API

Through the use of Flux, we’re able to deploy workload clusters quickly after pull requests are merged. You can use this repository as a template or a reference for your own Cluster API projects on Azure.

_Please note this repository is under development and subject to change._

## Getting Started

### Deployment

```bash
az deployment sub create \
  --name '' \
  --location '' \
  --template-file './resources/main.bicep' \
  --parameters './resources/main.bicepparam'
```

```powershell
New-AzSubscriptionDeployment `
  -Name "" `
  -Location "" `
  -TemplateFile "./resources/main.bicep" `
  -TemplateParameterFile "./resources/main.bicepparam"
```

### Stacks

```bash
az stack sub create \
  --name '' \
  --delete-all \
  --template-file './resources/main.bicep' \
  --parameters './resources/main.bicepparam' \
  --location uksouth \
  --deny-settings-mode None
```

```bash
az stack sub delete \
  --name '' \
  --delete-all \
  --yes
```