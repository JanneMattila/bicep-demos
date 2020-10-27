param storageAccountName string = 'pl100000001'

param location string = resourceGroup().location

param suffix string = '001'
param addressPrefix string = '10.0.0.0/15'

var vnetName = 'vnet-${suffix}'

resource vnet 'Microsoft.Network/virtualNetworks@2018-10-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    enableVmProtection: false
    enableDdosProtection: false
    subnets: [
      {
        name: 'subnet001'
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
      {
        name: 'subnet002'
        properties: {
          addressPrefix: '10.0.1.0/24'
        }
      }
    ]
  }
}

resource storageAccountResource 'Microsoft.Storage/storageAccounts@2019-06-01' = {
    name: storageAccountName
    location: location
    kind: 'Storage'
    sku: {
        name: 'Standard_LRS'
    }
}

output storage object = storageAccountResource
output storageId string = storageAccountResource.id
output storageKeys object = listKeys(storageAccountResource.id, '2019-06-01')

// Return primary key of storage account
output storagePrimaryKey string = listKeys(storageAccountResource.id, '2019-06-01').keys[0].value

output storageBlobEndpoint string = storageAccountResource.properties.primaryEndpoints.blob