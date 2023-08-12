// ------
// Scopes
// ------

targetScope = 'resourceGroup'

// ---------
// Resources
// ---------

// Managed Identity
resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: clusterName
  location: resourceGroup().location
}

// Role Assignment
resource assignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(identity.id)
  scope: resourceGroup()
  properties: {
    principalId: identity.properties.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', definitionIds.Owner)
  }
}

// ---------
// Variables
// ---------

var definitionIds = {
  Owner: '8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
}

// ----------
// Parameters
// ----------

param defaults object
param settings object

param clusterName string
