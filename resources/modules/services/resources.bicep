// ------
// Scopes
// ------

targetScope = 'resourceGroup'

// ---------
// Resources
// ---------

// Container Registry
resource registry 'Microsoft.ContainerRegistry/registries@2023-06-01-preview' = {
  name: resources.containerRegistry.name
  location: resourceGroup().location
  sku: {
    name: 'Standard'
  }
}

// Role Assignment
resource assignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(identity.id)
  scope: registry
  properties: {
    principalId: identity.properties.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', definitionIds.AcrPull)
  }
}

// ---------
// Resources
// ---------

resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: settings.resourceGroups.management.resources.managedIdentity.name
  scope: resourceGroup(settings.resourceGroups.management.name)
}

// ---------
// Variables
// ---------

var resources = settings.resourceGroups.services.resources
var definitionIds = {
  AcrPull: '7f951dda-4ed3-4680-a7ca-43fe172d538d'
}

// ----------
// Parameters
// ----------

param defaults object
param settings object
