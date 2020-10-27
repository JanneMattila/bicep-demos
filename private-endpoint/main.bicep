param storageAccountName string = 'pl100000001'

param location string = resourceGroup().location

param suffix string = '001'
param addressPrefix string = '10.0.0.0/15'

var vnetName = 'vnet-${suffix}'
var privateDNSZoneName = 'privatelink.table.core.windows.net'

resource privateDNSZone 'Microsoft.Network/privateDnsZones@2018-09-01'= {
  name: privateDNSZoneName
  location: 'global'
}

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
      {
        name: 'subnet003-private-endpoint'
        properties: {
          addressPrefix: '10.0.2.0/24'
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
    ]
  }
}

resource storageAccountResource 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  sku: {
      name: 'Standard_LRS'
  }
}

resource privateEndpointNIC 'Microsoft.Network/networkInterfaces@2020-05-01' = {
  name: 'privatelink-to-table-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'table-table.privateEndpoint'
        properties: {
          privateIPAddress: '10.0.2.4'
          subnet: {
            id: vnet.properties.subnets[2].id
          }
        }
      }
    ]
  }
}

resource privateLink 'Microsoft.Network/privateEndpoints@2020-05-01' = {
    name: 'privatelink-to-table'
    location: location
    properties: {
      privateLinkServiceConnections: [
        {
          name: 'my-privatelink-to-table'
          properties: {
            privateLinkServiceId: storageAccountResource.id
            groupIds: [
              'table'
            ]
          }
        }
      ]
      subnet: {
        id: vnet.properties.subnets[2].id
      }
    }
}

output storage object = storageAccountResource
output storageId string = storageAccountResource.id
output storageKeys object = listKeys(storageAccountResource.id, '2019-06-01')

// Return primary key of storage account
output storagePrimaryKey string = listKeys(storageAccountResource.id, '2019-06-01').keys[0].value

output storageBlobEndpoint string = storageAccountResource.properties.primaryEndpoints.blob