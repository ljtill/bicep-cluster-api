// ------
// Scopes
// ------

targetScope = 'resourceGroup'

// ---------
// Resources
// ---------

// Managed Identity
resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: resources.managedIdentity.name
  location: resourceGroup().location
}

// Kubernetes Service
resource managedCluster 'Microsoft.ContainerService/managedClusters@2023-06-02-preview' = {
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

// Flux
resource flux 'Microsoft.KubernetesConfiguration/extensions@2023-05-01' = {
  name: 'flux'
  scope: managedCluster
  properties: {
    extensionType: 'Microsoft.Flux'
    autoUpgradeMinorVersion: true
  }
}
resource management 'Microsoft.KubernetesConfiguration/fluxConfigurations@2023-05-01' = {
  name: 'management'
  scope: managedCluster
  properties: {
    scope: 'cluster'
    namespace: 'cluster-config'
    sourceKind: 'GitRepository'
    kustomizations: {
      'cert-manager': {
        path: 'manifests/cert-manager'
        timeoutInSeconds: 600
        syncIntervalInSeconds: 600
        retryIntervalInSeconds: 600
        force: false
        prune: true
        dependsOn: []
      }
      'cluster-api-operator': {
        path: 'manifests/cluster-api-operator'
        timeoutInSeconds: 600
        syncIntervalInSeconds: 600
        retryIntervalInSeconds: 600
        force: false
        prune: true
        dependsOn: [
          'cert-manager'
        ]
      }
      'cluster-api': {
        path: 'manifests/cluster-api'
        timeoutInSeconds: 600
        syncIntervalInSeconds: 600
        retryIntervalInSeconds: 600
        force: false
        prune: true
        dependsOn: [
          'cluster-api-operator'
        ]
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
resource workloads 'Microsoft.KubernetesConfiguration/fluxConfigurations@2023-05-01' = [for cluster in settings.resourceGroups.workloads.clusters: {
  name: 'workloads-${cluster.location}'
  scope: managedCluster
  properties: {
    scope: 'cluster'
    namespace: 'cluster-config'
    sourceKind: 'GitRepository'
    kustomizations: {
      'cluster-api': {
        path: 'clusters/workloads/${cluster.location}'
        timeoutInSeconds: 600
        syncIntervalInSeconds: 600
        retryIntervalInSeconds: 600
        force: false
        prune: true
        dependsOn: []
        postBuild: {
          substituteFrom: [
            {
              kind: 'ConfigMap'
              name: 'workloads-global'
            }
            {
              kind: 'ConfigMap'
              name: 'workloads-${cluster.location}'
            }
          ]
        }
      }
    }
    gitRepository: {
      repositoryRef: {
        branch: 'main'
      }
      url: 'https://github.com/ljtill/bicep-cluster-api.git'
    }
  }
  dependsOn: [
    management
  ]
}]

// -------
// Modules
// -------

// Global
module manifest './manifests/global.bicep' = {
  name: 'Kubernetes'
  params: {
    defaults: defaults
    settings: settings
    kubeConfig: managedCluster.listClusterAdminCredential().kubeconfigs[0].value
  }
}

// Workloads
module credentials './credentials.bicep' = [for (cluster, count) in settings.resourceGroups.workloads.clusters: {
  name: 'Microsoft.ManagedIdentity.${count}'
  scope: resourceGroup(settings.resourceGroups.workloads.name)
  params: {
    defaults: defaults
    settings: settings
    identityName: cluster.name
    clusterName: resources.containerService.name
  }
}]
module manifests './manifests/cluster.bicep' = [for (workloadCluster, count) in settings.resourceGroups.workloads.clusters: {
  name: 'Kubernetes.${count}'
  params: {
    defaults: defaults
    settings: settings
    kubeConfig: managedCluster.listClusterAdminCredential().kubeconfigs[0].value
    clusterName: workloadCluster.name
    clusterLocation: workloadCluster.location
  }
}]

// ---------
// Variables
// ---------

var resources = settings.resourceGroups.management.resources

// ----------
// Parameters
// ----------

param defaults object
param settings object
