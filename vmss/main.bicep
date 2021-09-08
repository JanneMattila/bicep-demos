param adminUsername string = 'azureuser'

@secure()
param adminPassword string

param location string = 'north europe'

resource vnet 'Microsoft.Network/virtualNetworks@2018-10-01' = {
  name: 'vmss-vnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'front-subnet'
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
      {
        name: 'backend-subnet'
        properties: {
          addressPrefix: '10.0.1.0/24'
        }
      }
    ]
  }
}

resource vmss 'Microsoft.Compute/virtualMachineScaleSets@2021-04-01' = {
  name: 'vmss'
  location: location
  sku: {
    capacity: 3
    name: 'Standard_D4d_v4'
  }
  zones: [
    '1'
    '2'
    '3'
  ]
  properties: {
    overprovision: true
    zoneBalance: true
    upgradePolicy: {
      mode: 'Manual'
    }
    virtualMachineProfile: {
      storageProfile: {
        osDisk: {
          osType: 'Linux'
          createOption: 'FromImage'
          caching: 'ReadOnly'
          diffDiskSettings: {
            option: 'Local'
          }
        }
        imageReference: {
          publisher: 'Canonical'
          offer: 'UbuntuServer'
          sku: '16.04-LTS'
          version: 'latest'
        }
      }
      osProfile: {
        computerNamePrefix: 'vmss'
        adminUsername: adminUsername
        adminPassword: adminPassword
      }
      networkProfile: {
        networkInterfaceConfigurations: [
          {
            name: 'nic'
            properties: {
              primary: true
              enableAcceleratedNetworking: true
              ipConfigurations: [
                {
                  name: 'public1'
                  properties: {
                    subnet: {
                      id: '${vnet.properties.subnets[0].id}'
                    }
                    publicIPAddressConfiguration: {
                      name: 'pip'
                      sku: {
                        name: 'Standard'
                      }
                      properties: {
                        idleTimeoutInMinutes: 15
                        ipTags: [
                          {
                            ipTagType: 'RoutingPreference'
                            tag: 'Internet'
                          }
                        ]
                      }
                    }
                  }
                }
              ]
            }
          }
        ]
      }
    }
  }
}
