// ------
// Scopes
// ------

targetScope = 'subscription'

// -------
// Modules
// -------

// Resource Groups
module groups './modules/groups.bicep' = {
  name: 'Microsoft.ResourceGroups'
  scope: subscription()
  params: {
    defaults: defaults
    settings: settings
  }
}

// Resources - Clusters
module workloadClusters './modules/clusters/workloads/resources.bicep' = [for (cluster, count) in settings.resourceGroups.workloads.clusters: {
  name: 'Microsoft.Resources.Workloads.${count}'
  scope: resourceGroup(settings.resourceGroups.workloads.name)
  params: {
    defaults: defaults
    settings: settings
    clusterName: cluster.name
  }
  dependsOn: [
    groups
  ]
}]
module managementCluster './modules/clusters/management/resources.bicep' = {
  name: 'Microsoft.Resources.Management'
  scope: resourceGroup(settings.resourceGroups.management.name)
  params: {
    defaults: defaults
    settings: settings
  }
  dependsOn: [
    groups
  ]
}

// Resources - Services
// module services './modules/services/resources.bicep' = {
//   name: 'Microsoft.Resources.Services'
//   scope: resourceGroup(settings.resourceGroups.services.name)
//   params: {
//     defaults: defaults
//     settings: settings
//   }
//   dependsOn: [
//     groups
//   ]
// }

// ---------
// Variables
// ---------

var defaults = loadJsonContent('defaults.json')

// ----------
// Parameters
// ----------

param settings object
