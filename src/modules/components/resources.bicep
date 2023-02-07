// ------
// Scopes
// ------

targetScope = 'resourceGroup'

// ---------
// Resources
// ---------

// Network

resource securityGroup 'Microsoft.Network/networkSecurityGroups@2022-07-01' = {
  name: settings.resources.securityGroup.name
  location: settings.resourceGroup.location
  properties: {
    securityRules: [for securityRule in settings.resources.securityGroup.rules: {
      name: securityRule.name
      properties: {
        access: securityRule.access
        direction: securityRule.direction
        protocol: securityRule.protocol
        priority: securityRule.priority
        sourceAddressPrefix: securityRule.sourceAddressPrefix
        sourcePortRange: securityRule.sourcePortRange
        destinationAddressPrefix: securityRule.destinationAddressPrefix
        destinationPortRange: securityRule.destinationPortRange
      }
    }]
  }
}
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2022-07-01' = {
  name: settings.resources.virtualNetwork.name
  location: settings.resourceGroup.location
  properties: {
    addressSpace: {
      addressPrefixes: [ settings.resources.virtualNetwork.addressPrefix ]
    }
    subnets: [
      {
        name: settings.resources.virtualNetwork.subnet.name
        properties: {
          addressPrefix: settings.resources.virtualNetwork.subnet.addressPrefix
          networkSecurityGroup: {
            id: securityGroup.id
          }
        }
      }
    ]
  }
}
resource ipAddress 'Microsoft.Network/publicIPAddresses@2022-07-01' = {
  name: settings.resources.ipAddress.name
  location: settings.resourceGroup.location
  properties: {
    publicIPAllocationMethod: 'Static'
    deleteOption: 'Delete'
  }
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  zones: [
    '1'
    '2'
    '3'
  ]
}
resource loadBalancer 'Microsoft.Network/loadBalancers@2022-07-01' = {
  name: settings.resources.loadBalancer.name
  location: settings.resourceGroup.location
  properties: {
    frontendIPConfigurations: [
      {
        name: 'default'
        properties: {
          publicIPAddress: {
            id: ipAddress.id
          }
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'inbound'
        properties: {
          loadBalancerBackendAddresses: [
            {
              name: 'default'
              properties: {
                virtualNetwork: {
                  id: virtualNetwork.id
                }
              }
            }
          ]
        }
      }
      {
        name: 'outbound'
        properties: {
          loadBalancerBackendAddresses: [
            {
              name: 'default'
              properties: {
                virtualNetwork: {
                  id: virtualNetwork.id
                }
                subnet: {
                  id: resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetwork.name, settings.resources.virtualNetwork.subnet.name)
                }
              }
            }
          ]
        }
      }
    ]
    inboundNatRules: [for networkInterface in settings.resources.networkInterfaces: {
      name: networkInterface.name
      properties: {
        frontendIPConfiguration: {
          id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', settings.resources.loadBalancer.name, 'default')
        }
        backendPort: 22
        frontendPort: networkInterface.externalPort
        protocol: 'Tcp'
      }
    }]
    loadBalancingRules: []
    outboundRules: [
      {
        name: 'default'
        properties: {
          frontendIPConfigurations: [
            {
              id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', settings.resources.loadBalancer.name, 'default')
            }
          ]
          backendAddressPool: {
            id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', settings.resources.loadBalancer.name, 'outbound')
          }
          protocol: 'All'
        }
      }
    ]
    probes: []
  }
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
}
resource networkInterfaces 'Microsoft.Network/networkInterfaces@2022-07-01' = [for (networkInterface, index) in settings.resources.networkInterfaces: {
  name: networkInterface.name
  location: settings.resourceGroup.location
  properties: {
    enableAcceleratedNetworking: true
    ipConfigurations: [
      {
        name: 'default'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetwork.name, settings.resources.virtualNetwork.subnet.name)
          }
          loadBalancerInboundNatRules: [
            {
              id: loadBalancer.properties.inboundNatRules[index].id
            }
          ]
          loadBalancerBackendAddressPools: [
            {
              id: loadBalancer.properties.backendAddressPools[0].id
            }
            {
              id: loadBalancer.properties.backendAddressPools[1].id
            }
          ]
        }
      }
    ]
  }
}]

// Compute

resource virtualMachines 'Microsoft.Compute/virtualMachines@2022-11-01' = [for (virtualMachine, index) in settings.resources.virtualMachines: {
  name: virtualMachine.name
  location: settings.resourceGroup.location
  properties: {
    hardwareProfile: {
      vmSize: virtualMachine.size
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: '0001-com-ubuntu-server-jammy'
        sku: '22_04-lts-gen2'
        version: 'latest'
      }
      osDisk: {
        name: virtualMachine.osDisk.name
        caching: 'ReadWrite'
        createOption: 'FromImage'
        deleteOption: 'Delete'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterfaces[index].id
        }
      ]
    }
    osProfile: {
      computerName: virtualMachine.name
      adminUsername: username
      linuxConfiguration: {
        ssh: {
          publicKeys: [
            {
              keyData: keydata
              path: '/home/${username}/.ssh/authorized_keys'
            }
          ]
        }
      }
    }
    diagnosticsProfile: {}
  }
  zones: [
    virtualMachine.zone
  ]
  tags: {
    Type: virtualMachine.type
  }
}]

// ----------
// Parameters
// ----------

param defaults object
param settings object

@secure()
param username string
@secure()
param keydata string
