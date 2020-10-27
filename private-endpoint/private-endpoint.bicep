param storageId string
param subnetId string

param location string = resourceGroup().location

resource privateEndpointResource 'Microsoft.Network/privateEndpoints@2020-05-01' = {
    name: 'privatelink-to-table'
    location: location
    properties: {
      privateLinkServiceConnections: [
        {
          name: 'privatelink-to-table'
          properties: {
            privateLinkServiceId: storageId
            groupIds: [
              'table'
            ]
          }
        }
      ]
      subnet: {
        id: subnetId
      }
    }
}


var nicId = privateEndpointResource.properties.networkInterfaces[0].id
output nic string = substring(nicId, lastIndexOf(nicId, '/') + 1)
