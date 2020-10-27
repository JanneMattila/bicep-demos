param location string = resourceGroup().location

param storageAccountName string = 'pl100000002'
param suffix string = '001'
param addressPrefix string = '10.0.0.0/15'

var vnetName = 'vnet-${suffix}'
var privateDNSZoneName = 'privatelink.table.${environment().suffixes.storage}'

// Private DNS Zone
resource privateDNSZoneResource 'Microsoft.Network/privateDnsZones@2018-09-01'= {
  name: privateDNSZoneName
  location: 'global'
}

// Link Private DNS Zone to VNET
resource privateDNSZoneLinkToVNETResource 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-01-01' = {
  name: '${privateDNSZoneName}/${privateDNSZoneName}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetResource.id
    }
  }
}

resource vnetResource 'Microsoft.Network/virtualNetworks@2018-10-01' = {
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
  properties: {
    networkAcls: {
      defaultAction: 'Deny'
    }
  }
}

resource privateEndpointResource 'Microsoft.Network/privateEndpoints@2020-05-01' = {
    name: 'privatelink-to-table'
    location: location
    properties: {
      privateLinkServiceConnections: [
        {
          name: 'privatelink-to-table'
          properties: {
            privateLinkServiceId: storageAccountResource.id
            groupIds: [
              'table'
            ]
          }
        }
      ]
      subnet: {
        // Place to subnet: subnet003-private-endpoint
        id: vnetResource.properties.subnets[2].id
      }
    }
}

resource privateDNSZoneGroupsResource 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-03-01' = {
    name: '${privateEndpointResource.name}/storagednszonegroup'
    location: location
    properties: {
      privateDnsZoneConfigs: [
        {
          name: 'storageConfig'
          properties: {
            privateDnsZoneId: privateDNSZoneResource.id
          }
        }
      ]
    }
}

output storage object = storageAccountResource
output privateEndpoint object = privateEndpointResource
output privateDNSZoneGroups object = privateDNSZoneGroupsResource
output privateEndpointNIC string = privateEndpointResource.properties.networkInterfaces[0].id
