param name string
param location string
param subnetId string
param username string
@secure()
param password string

resource vm 'Microsoft.Compute/virtualMachines@2023-09-01' = {
  name: 'vm-${name}'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B2s'
    }
    osProfile: {
      computerName: 'vm-${name}'
      adminUsername: username
      adminPassword: password
    }
    storageProfile: {
      imageReference: {
        publisher: 'canonical'
        offer: '0001-com-ubuntu-server-focal'
        sku: '20_04-lts-gen2'
        version: 'latest'
      }
      osDisk: {
        name: 'vm_${name}OSDisk'
        caching: 'ReadWrite'
        createOption: 'FromImage'
        diskSizeGB: 32
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
      }
    }
    networkProfile: {
      networkApiVersion: '2023-09-01'
      networkInterfaceConfigurations: [
        {
          name: 'nic-vm-${name}'
          properties: {
            ipConfigurations: [
              {
                name: 'ipconfig1'
                properties: {
                  subnet: {
                    id: subnetId
                  }
                  publicIPAddressConfiguration: {
                    name: 'publicipconfig'
                    sku: {
                      name: 'Standard'
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
