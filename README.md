# Kubernetes

### Getting Started

Before deploying the Kubernetes resources, the parameters file `src/parameters/main.json` needs to be updated.

#### Using locally with Azure CLI

```bash
az deployment sub validate \
    --name 'Microsoft.Bicep' \
    --location 'uksouth' \
    --template-file './src/main.bicep' \
    --parameters \
      '@./src/parameters/main.json'
```
