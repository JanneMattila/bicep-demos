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

resource virtualNetwork1 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: 'vnet-hub1'
  location: 'swedencentral'
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: []
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

resource virtualNetwork2 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: 'vnet-hub2'
  location: 'westus3'
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.3.0.0/16'
      ]
    }
    subnets: []
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
