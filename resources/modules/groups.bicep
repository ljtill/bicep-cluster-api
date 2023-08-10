// ------
// Scopes
// ------

targetScope = 'subscription'

// ---------
// Resources
// ---------

resource services 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: settings.resourceGroups.services.name
  location: settings.resourceGroups.services.location
  properties: {}
  tags: settings.resourceGroups.services.tags
}

resource management 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: settings.resourceGroups.management.name
  location: settings.resourceGroups.management.location
  properties: {}
  tags: settings.resourceGroups.management.tags
}

resource workloads 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: settings.resourceGroups.workloads.name
  location: settings.resourceGroups.workloads.location
  properties: {}
  tags: settings.resourceGroups.workloads.tags
}

// ----------
// Parameters
// ----------

param defaults object
param settings object
