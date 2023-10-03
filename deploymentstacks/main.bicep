param location string = resourceGroup().location

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: 'vnet-one'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    // This deployment will remove any existing subnets and replace them with the ones defined here.
    // https://github.com/Azure/azure-quickstart-templates/issues/2786
    subnets: [
      {
        name: 'snet-1'
        properties: {
          addressPrefix: '10.0.0.0/24'
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Disabled'
        }
      }
      {
        name: 'snet-2'
        properties: {
          addressPrefix: '10.0.1.0/24'
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Disabled'
        }
      }
    ]
  }
}

// resource subnet1 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' = {
//   name: 'snet-1'
//   parent: virtualNetwork
//   properties: {
//     addressPrefix: '10.0.0.0/24'
//     privateEndpointNetworkPolicies: 'Disabled'
//     privateLinkServiceNetworkPolicies: 'Disabled'
//   }
// }

// resource subnet2 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' = {
//   name: 'snet-2'
//   parent: virtualNetwork
//   properties: {
//     addressPrefix: '10.0.1.0/24'
//     privateEndpointNetworkPolicies: 'Disabled'
//     privateLinkServiceNetworkPolicies: 'Disabled'
//   }
// }
