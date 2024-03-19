param username string
@secure()
param password string

param hub1location string = 'swedencentral'
param hub2location string = 'westus3'

var hub1Spokes = [
  {
    name: 'spoke001'
    vnetAddressSpace: '10.1.0.0/22'
    subnetAddressSpace: '10.1.0.0/24'
  }
  {
    name: 'spoke002'
    vnetAddressSpace: '10.2.0.0/22'
    subnetAddressSpace: '10.2.0.0/24'
  }
]

var hub2Spokes = [
  {
    name: 'spoke003'
    vnetAddressSpace: '10.4.0.0/22'
    subnetAddressSpace: '10.4.0.0/24'
  }
  {
    name: 'spoke004'
    vnetAddressSpace: '10.5.0.0/22'
    subnetAddressSpace: '10.5.0.0/24'
  }
]

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2019-11-01' = {
  name: 'nsg-hub1-front'
  location: hub1location
  properties: {
    securityRules: [
      {
        name: 'allow-ssh'
        properties: {
          access: 'Allow'
          direction: 'Inbound'
          protocol: 'Tcp'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '10.0.0.0/8'
          destinationPortRange: '22'
          priority: 100
          description: 'Allow SSH'
        }
      }
    ]
  }
}

resource virtualNetwork1 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: 'vnet-hub1'
  location: hub1location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'snet-default'
        properties: {
          addressPrefix: '10.0.0.0/24'
          networkSecurityGroup: {
            id: networkSecurityGroup.id
          }
        }
      }
    ]
  }
}

module spokeDeployments1 'spoke.bicep' = [
  for (spoke, i) in hub1Spokes: {
    name: '${spoke.name}-deployment'
    params: {
      spokeName: spoke.name
      hubName: virtualNetwork1.name
      hubId: virtualNetwork1.id
      location: virtualNetwork1.location

      vnetAddressSpace: spoke.vnetAddressSpace
      subnetAddressSpace: spoke.subnetAddressSpace
    }
  }
]

resource networkSecurityGroup2 'Microsoft.Network/networkSecurityGroups@2019-11-01' = {
  name: 'nsg-hub2-front'
  location: hub2location
  properties: {
    securityRules: [
      {
        name: 'allow-ssh'
        properties: {
          access: 'Allow'
          direction: 'Inbound'
          protocol: 'Tcp'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '10.3.0.0/16'
          destinationPortRange: '22'
          priority: 100
          description: 'Allow SSH'
        }
      }
    ]
  }
}

resource virtualNetwork2 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: 'vnet-hub2'
  location: hub2location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.3.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'snet-default'
        properties: {
          addressPrefix: '10.3.0.0/24'
          networkSecurityGroup: {
            id: networkSecurityGroup2.id
          }
        }
      }
    ]
  }
}

module spokeDeployments2 'spoke.bicep' = [
  for (spoke, i) in hub2Spokes: {
    name: '${spoke.name}-deployment'
    params: {
      spokeName: spoke.name
      hubName: virtualNetwork2.name
      hubId: virtualNetwork2.id
      location: virtualNetwork2.location

      vnetAddressSpace: spoke.vnetAddressSpace
      subnetAddressSpace: spoke.subnetAddressSpace
    }
  }
]

resource hub1ToHub2Peering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-09-01' = {
  name: '${virtualNetwork1.name}-to-${virtualNetwork2.name}'
  parent: virtualNetwork1
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    remoteVirtualNetwork: {
      id: virtualNetwork2.id
    }
  }
}

resource hub2ToHub1Peering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-09-01' = {
  name: '${virtualNetwork2.name}-to-${virtualNetwork1.name}'
  parent: virtualNetwork2
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    remoteVirtualNetwork: {
      id: virtualNetwork1.id
    }
  }
}

module vm1 'vm.bicep' = {
  name: 'vm1'
  params: {
    name: hub1location
    location: hub1location
    username: username
    password: password
    subnetId: virtualNetwork1.properties.subnets[0].id
  }
}

module vm2 'vm.bicep' = {
  name: 'vm2'
  params: {
    name: hub2location
    location: hub2location
    username: username
    password: password
    subnetId: virtualNetwork2.properties.subnets[0].id
  }
}
