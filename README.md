# Kubernetes

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
