param subnets array
param location string = resourceGroup().location

resource routeTable 'Microsoft.Network/routeTables@2024-01-01' = {
  name: 'rt-main'
  location: location
  properties: {
    disableBgpRoutePropagation: false
    routes: [
      {
        name: 'to-nva'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: '10.10.10.10'
        }
      }
    ]
  }
}

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2024-01-01' = {
  name: 'nsg-main'
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowSSHFromSingleIP'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: '11.22.33.44/32'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
    ]
  }
}

var extraSubnetConfigurations = [
  {
    routeTable: {
      id: routeTable.id
    }
    networkSecurityGroup: null
  }
  {
    routeTable: null
    networkSecurityGroup: {
      id: networkSecurityGroup.id
    }
  }
  {
    routeTable: {
      id: routeTable.id
    }
    networkSecurityGroup: {
      id: networkSecurityGroup.id
    }
  }
]

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: 'vnet-main'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      for (subnet, i) in subnets: {
        name: subnet.name
        properties: {
          // Coming from the input parameter
          addressPrefix: subnet.addressPrefix
          serviceEndpoints: subnet.serviceEndpoints

          // Defined inline
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Disabled'

          // Coming from the extra configurations
          routeTable: extraSubnetConfigurations[i].routeTable
          networkSecurityGroup: extraSubnetConfigurations[i].networkSecurityGroup
        }
      }
    ]
  }
}
