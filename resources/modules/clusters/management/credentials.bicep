// ------
// Scopes
// ------

targetScope = 'resourceGroup'

// ---------
// Resources
// ---------

resource credential 'Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials@2023-01-31' = {
  name: settings.resourceGroups.management.resources.containerService.name
  parent: identity
  properties: {
    audiences: [
      'api://AzureADTokenExchange'
    ]
    issuer: cluster.properties.oidcIssuerProfile.issuerURL
    subject: 'system:serviceaccount:capi-azure-system:capz-manager'
  }
}

// ---------
// Resources
// ---------

resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: identityName
}

resource cluster 'Microsoft.ContainerService/managedClusters@2023-06-02-preview' existing = {
  name: clusterName
  scope: resourceGroup(settings.resourceGroups.management.name)
}

// ----------
// Parameters
// ----------

param defaults object
param settings object

param identityName string
param clusterName string
