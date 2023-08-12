// -------
// Imports
// -------

import 'kubernetes@1.0.0' with {
  namespace: 'default'
  kubeConfig: kubeConfig
} as k8s

// ---------
// Resources
// ---------

resource configMap 'core/ConfigMap@v1' = {
  metadata: {
    name: 'workloads-${clusterLocation}'
    namespace: 'cluster-config'
  }
  data: {
    cluster_name: clusterName
    cluster_location: clusterLocation
    client_id: identity.properties.clientId
  }
}

// ---------
// Resources
// ---------

resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: clusterName
  scope: resourceGroup(settings.resourceGroups.workloads.name)
}

// ----------
// Parameters
// ----------

param defaults object
param settings object

@secure()
param kubeConfig string

param clusterName string
param clusterLocation string
