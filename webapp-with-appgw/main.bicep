param appName string = 'contoso00000000001'
param appName1 string = 'contoso00000000010'
param appName2 string = 'contoso00000000011'
param location1 string = 'north europe'
param location2 string = 'west europe'

param applicationGatewayName string = 'contoso0000000001'

var webAppUri1 = '${appName1}.azurewebsites.net'
var webAppUri2 = '${appName2}.azurewebsites.net'

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: 'vnet-appgw'
  location: location1
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/8'
      ]
    }
    subnets: [
      {
        name: 'snet-appgw'
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
    ]
  }
}

resource publicIP 'Microsoft.Network/publicIPAddresses@2020-06-01' = {
  name: 'pip-appgw'
  location: location1
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    dnsSettings: {
      domainNameLabel: appName
    }
  }
}

resource applicationGateway 'Microsoft.Network/applicationGateways@2020-06-01' = {
  name: applicationGatewayName
  location: location1
  properties: {
    enableHttp2: true
    sku: {
      name: 'Standard_v2'
      tier: 'Standard_v2'
      capacity: 1
    }
    gatewayIPConfigurations: [
      {
        name: 'appGatewayIpConfig'
        properties: {
          subnet: {
            id: virtualNetwork.properties.subnets[0].id
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: 'appGatewayFrontendIP'
        properties: {
          publicIPAddress: {
            id: publicIP.id
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'appGatewayFrontendPort'
        properties: {
          port: 80
        }
      }
    ]
    backendAddressPools: [
      {
        name: appName1
        properties: {
          backendAddresses: [
            {
              fqdn: webAppUri1
            }
          ]
        }
      }
      {
        name: appName2
        properties: {
          backendAddresses: [
            {
              fqdn: webAppUri2
            }
          ]
        }
      }
    ]
    probes: [
      {
        name: 'probe'
        properties: {
          protocol: 'Http'
          pickHostNameFromBackendHttpSettings: true
          path: '/'
          interval: 30
          timeout: 30
          port: 80
          match: {
            statusCodes: [
              '200'
            ]
          }
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'appGatewayBackendHttpSettings'
        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: true
          probeEnabled: true
          probe: {
            id: resourceId('Microsoft.Network/applicationGateways/probes', applicationGatewayName, 'probe')
          }
        }
      }
    ]
    httpListeners: [
      {
        name: 'appGatewayHttpListener'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayName, 'appGatewayFrontendIP')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayName, 'appGatewayFrontendPort')
          }
          protocol: 'Http'
        }
      }
    ]
    urlPathMaps: [
      {
        name: 'paths'
        properties: {
          defaultBackendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, appName1)
          }
          defaultBackendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGatewayName, 'appGatewayBackendHttpSettings')
          }
          pathRules: [
            {
              name: '${appName1}path'
              properties: {
                paths: [
                  '/app1/*'
                ]
                backendAddressPool: {
                  id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, appName1)
                }
                backendHttpSettings: {
                  id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGatewayName, 'appGatewayBackendHttpSettings')
                }
              }
            }
            {
              name: '${appName2}path'
              properties: {
                paths: [
                  '/app2/*'
                ]
                backendAddressPool: {
                  id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, appName2)
                }
                backendHttpSettings: {
                  id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGatewayName, 'appGatewayBackendHttpSettings')
                }
              }
            }
          ]
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'rules'
        properties: {
          ruleType: 'PathBasedRouting'
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, 'appGatewayHttpListener')
          }
          urlPathMap: {
            id: resourceId('Microsoft.Network/applicationGateways/urlPathMaps', applicationGatewayName, 'paths')
          }
        }
      }
    ]
  }
}

module webApp1 './webApp.bicep' = {
  name: 'webApp1'
  params: {
    appPlanName: 'appServicePlan1'
    appName: appName1
    location: location1
  }
}

module webApp2 './webApp.bicep' = {
  name: 'webApp2'
  params: {
    appPlanName: 'appServicePlan2'
    appName: appName2
    location: location2
  }
}

output appGateway string = publicIP.properties.dnsSettings.fqdn
