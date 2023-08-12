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

resource namespace 'core/Namespace@v1' = {
  metadata: {
    name: 'cluster-config'
  }
}

resource configMap 'core/ConfigMap@v1' = {
  metadata: {
    name: 'workloads-global'
    namespace: 'cluster-config'
  }
  data: {
    tenant_id: tenant().tenantId
    subscription_id: subscription().subscriptionId
    resource_group: settings.resourceGroups.workloads.name
    public_key: settings.resourceGroups.workloads.publicKey
  }
}

// ----------
// Parameters
// ----------

param defaults object
param settings object

@secure()
param kubeConfig string
