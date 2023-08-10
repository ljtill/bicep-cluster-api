using './main.bicep'

param settings = {
  subscriptionId: ''
  resourceGroups: {
    services: {
      name: 'Services'
      location: ''
      resources: {
        managedIdentity: {
          name: ''
        }
        containerRegistry: {
          name: ''
        }
      }
      tags: {}
    }
    management: {
      name: 'Management'
      location: ''
      resources: {
        containerService: {
          name: ''
          node: 'Internal'
        }
      }
      tags: {}
    }
    workloads: {
      name: 'Workloads'
      location: ''
      tags: {}
    }
  }
}
