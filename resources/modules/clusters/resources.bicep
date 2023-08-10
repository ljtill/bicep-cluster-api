// ------
// Scopes
// ------

targetScope = 'resourceGroup'

// ---------
// Resources
// ---------

// Kubernetes Service
resource cluster 'Microsoft.ContainerService/managedClusters@2023-06-02-preview' = {
  name: resources.containerService.name
  location: resourceGroup().location
  sku: {
    name: 'Base'
    tier: 'Standard'
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identity.id}': {}
    }
  }
  properties: {
    dnsPrefix: resources.containerService.name
    nodeResourceGroup: resources.containerService.node
    agentPoolProfiles: [
      {
        name: 'system'
        count: 3
        vmSize: 'Standard_D4ds_v5'
        osType: 'Linux'
        mode: 'System'
        availabilityZones: [
          '1'
          '2'
          '3'
        ]
        tags: {}
      }
      {
        name: 'user'
        count: 3
        vmSize: 'Standard_D8ds_v5'
        osType: 'Linux'
        mode: ''
        availabilityZones: [
          '1'
          '2'
          '3'
        ]
        tags: {}
      }
    ]
    autoUpgradeProfile: {
      upgradeChannel: 'patch'
    }
    oidcIssuerProfile: {
      enabled: true
    }
    servicePrincipalProfile: {
      clientId: 'msi'
    }
  }
}

resource flux 'Microsoft.KubernetesConfiguration/extensions@2023-05-01' = {
  name: 'flux'
  scope: cluster
  properties: {
    extensionType: 'Microsoft.Flux'
    autoUpgradeMinorVersion: true
  }
}

resource configuration 'Microsoft.KubernetesConfiguration/fluxConfigurations@2022-11-01' = {
  name: 'flux-system'
  scope: cluster
  properties: {
    scope: 'namespace'
    namespace: 'flux-system'
    sourceKind: 'GitRepository'
    kustomizations: {
      base: {
        path: 'clusters/management'
        timeoutInSeconds: 600
        syncIntervalInSeconds: 600
        retryIntervalInSeconds: 600
        force: false
        prune: false
        dependsOn: []
      }
    }
    gitRepository: {
      repositoryRef: {
        branch: 'main'
      }
      url: 'https://github.com/ljtill/bicep-cluster-api.git'
    }
  }
}

// ---------
// Resources
// ---------

resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: settings.resourceGroups.services.resources.managedIdentity.name
  scope: resourceGroup(settings.resourceGroups.services.name)
}

// ----------
// Parameters
// ----------

var resources = settings.resourceGroups.management.resources

// ----------
// Parameters
// ----------

param defaults object
param settings object
