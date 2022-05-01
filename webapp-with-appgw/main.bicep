param password string = '<your-password-here>'
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
        name: 'appGatewayFrontendPort-http'
        properties: {
          port: 80
        }
      }
      {
        name: 'appGatewayFrontendPort-https'
        properties: {
          port: 443
        }
      }
    ]
    sslCertificates: [
      {
        name: 'cert'
        properties: {
          data: loadFileAsBase64('./cert.pfx')
          password: password
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
          protocol: 'Https'
          pickHostNameFromBackendHttpSettings: true
          path: '/'
          interval: 30
          timeout: 30
          port: 443
          match: {
            statusCodes: [
              '200'
            ]
          }
        }
      }
    ]
    rewriteRuleSets: [
      {
        name: 'add-forwarded-host-header'
        properties: {
          rewriteRules: [
            {
              ruleSequence: 100
              name: 'add-forwarded-host-header'
              actionSet: {
                requestHeaderConfigurations: [
                  {
                    headerName: 'X-Forwarded-Host'
                    headerValue: '{var_host}'
                  }
                ]
              }
            }
          ]
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'appGatewayBackendHttpSettings'
        properties: {
          port: 443
          protocol: 'Https'
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
        name: 'appGatewayHttpListener-http'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayName, 'appGatewayFrontendIP')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayName, 'appGatewayFrontendPort-http')
          }
          protocol: 'Http'
        }
      }
      {
        name: 'appGatewayHttpListener-https'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayName, 'appGatewayFrontendIP')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayName, 'appGatewayFrontendPort-https')
          }
          sslCertificate: {
            id: resourceId('Microsoft.Network/applicationGateways/sslCertificates', applicationGatewayName, 'cert')
          }
          protocol: 'Https'
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
          defaultRewriteRuleSet: {
            id: resourceId('Microsoft.Network/applicationGateways/rewriteRuleSets', applicationGatewayName, 'add-forwarded-host-header')
          }
          pathRules: [
            {
              name: '${appName1}path'
              properties: {
                paths: [
                  '/app1*'
                ]
                backendAddressPool: {
                  id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, appName1)
                }
                backendHttpSettings: {
                  id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGatewayName, 'appGatewayBackendHttpSettings')
                }
                rewriteRuleSet: {
                  id: resourceId('Microsoft.Network/applicationGateways/rewriteRuleSets', applicationGatewayName, 'add-forwarded-host-header')
                }
              }
            }
            {
              name: '${appName2}path'
              properties: {
                paths: [
                  '/app2*'
                ]
                backendAddressPool: {
                  id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, appName2)
                }
                backendHttpSettings: {
                  id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGatewayName, 'appGatewayBackendHttpSettings')
                }
                rewriteRuleSet: {
                  id: resourceId('Microsoft.Network/applicationGateways/rewriteRuleSets', applicationGatewayName, 'add-forwarded-host-header')
                }
              }
            }
          ]
        }
      }
    ]
    redirectConfigurations: [
      {
        name: 'to-https'
        properties: {
          redirectType: 'Permanent'
          includePath: true
          includeQueryString: true
          targetListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, 'appGatewayHttpListener-https')
          }
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'https-rule'
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, 'appGatewayHttpListener-http')
          }
          redirectConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/redirectConfigurations', applicationGatewayName, 'to-https')
          }
        }
      }
      {
        name: 'backend-rule'
        properties: {
          ruleType: 'PathBasedRouting'
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, 'appGatewayHttpListener-https')
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
    image: 'DOCKER|jannemattila/webapp-auth:1.0.7'
    customPath: '/app1'
    proxyIp: publicIP.properties.ipAddress
    proxyHost: publicIP.properties.dnsSettings.fqdn
    location: location1
  }
}

module webApp2 './webApp.bicep' = {
  name: 'webApp2'
  params: {
    appPlanName: 'appServicePlan2'
    appName: appName2
    image: 'DOCKER|jannemattila/webapp-auth:1.0.7'
    customPath: '/app2'
    proxyIp: publicIP.properties.ipAddress
    proxyHost: publicIP.properties.dnsSettings.fqdn
    location: location2
  }
}

output appGateway string = publicIP.properties.dnsSettings.fqdn
