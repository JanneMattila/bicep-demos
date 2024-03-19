param spokeName string
param vnetAddressSpace string
param subnetAddressSpace string
param hubName string
param hubId string
param location string

var vnetName = 'vnet-${spokeName}'

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2019-11-01' = {
  name: 'nsg-${spokeName}-front'
  location: location
  properties: {
    securityRules: []
  }
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressSpace
      ]
    }
    subnets: [
      {
        name: 'snet-default'
        properties: {
          addressPrefix: subnetAddressSpace
          networkSecurityGroup: {
            id: networkSecurityGroup.id
          }
          delegations: [
            {
              name: 'ACIDelegation'
              properties: {
                serviceName: 'Microsoft.ContainerInstance/containerGroups'
              }
            }
          ]
        }
      }
    ]
  }
}

resource aci 'Microsoft.ContainerInstance/containerGroups@2023-05-01' = {
  name: 'aci-${spokeName}'
  location: location
  properties: {
    containers: [
      {
        name: 'webapp-network-tester'
        properties: {
          image: 'jannemattila/webapp-network-tester:1.0.69'
          environmentVariables: [
            {
              name: 'ASPNETCORE_URLS'
              value: 'http://*:80'
            }
          ]
          ports: [
            {
              port: 80
            }
          ]
          resources: {
            requests: {
              cpu: 1
              memoryInGB: 1
            }
          }
        }
      }
    ]
    restartPolicy: 'OnFailure'
    osType: 'Linux'
    ipAddress: {
      type: 'Private'
      ports: [
        {
          protocol: 'TCP'
          port: 80
        }
      ]
    }
    subnetIds: [
      {
        id: virtualNetwork.properties.subnets[0].id
      }
    ]
  }
}

resource spokeToHubPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-09-01' = {
  name: 'spoke-to-hub'
  parent: virtualNetwork
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    remoteVirtualNetwork: {
      id: hubId
    }
  }
}

resource hubToSpokePeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-09-01' = {
  name: '${hubName}/hub-to-${vnetName}'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    remoteVirtualNetwork: {
      id: virtualNetwork.id
    }
  }
}
