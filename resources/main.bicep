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
  scope: subscription(settings.subscriptionId)
  params: {
    defaults: defaults
    settings: settings
  }
}

// Resources
module services './modules/services/resources.bicep' = {
  name: 'Microsoft.Resources.Services'
  scope: resourceGroup(settings.resourceGroups.services.name)
  params: {
    defaults: defaults
    settings: settings
  }
  dependsOn: [
    groups
  ]
}

module clusters './modules/clusters/resources.bicep' = {
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

// ---------
// Variables
// ---------

var defaults = loadJsonContent('defaults.json')

// ----------
// Parameters
// ----------

param settings object
