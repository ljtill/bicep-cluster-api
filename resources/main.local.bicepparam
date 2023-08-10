using './main.bicep'

param settings = {
  subscriptionId: '27b89973-333c-4ef0-a154-60388afc55e4'
  resourceGroups: {
    services: {
      name: 'Services'
      location: 'uksouth'
      resources: {
        managedIdentity: {
          name: 'mscae'
        }
        containerRegistry: {
          name: 'mscae'
        }
      }
      tags: {}
    }
    management: {
      name: 'Management'
      location: 'uksouth'
      resources: {
        containerService: {
          name: 'mscae'
          node: 'Internal'
        }
      }
      tags: {}
    }
    workloads: {
      name: 'Workloads'
      location: 'uksouth'
      tags: {}
    }
  }
}
