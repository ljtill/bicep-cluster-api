using './main.bicep'

param settings = {
  resourceGroups: {
    services: {
      name: 'Services'
      location: 'uksouth'
      resources: {
        containerRegistry: {
          name: ''
        }
      }
      tags: {}
    }
    management: {
      name: 'Management'
      location: 'uksouth'
      resources: {
        managedIdentity: {
          name: ''
        }
        containerService: {
          name: ''
          node: 'Internal'
        }
      }
      tags: {}
    }
    workloads: {
      name: 'Workloads'
      location: 'uksouth'
      publicKey: ''
      clusters: [
        {
          name: ''
          location: 'northeurope'
        }
        {
          name: ''
          location: 'westeurope'
        }
      ]
      tags: {}
    }
  }
}
