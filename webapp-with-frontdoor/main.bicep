param appName1 string = 'contoso00000000010'
param appName2 string = 'contoso00000000011'
param location1 string = 'north europe'
param location2 string = 'west europe'

param frontDoorName string = 'contoso0000000001'

var frontendEndpoint1hostName = '${frontDoorName}.azurefd.net'
var healthProbe1Name = '${frontDoorName}-healthProbe1'
var frontendEndpoint1Name = '${frontDoorName}-frontendEndpoint1'
var backendPool1Name = '${frontDoorName}-backendPool1'
var loadBalancing1Name = '${frontDoorName}-loadBalancing1'
var routingRule1Name = '${frontDoorName}-routingRule1'

var webAppUri1 = '${appName1}.azurewebsites.net'
var webAppUri2 = '${appName2}.azurewebsites.net'

var frontDoorId = reference(frontDoorName, '2020-05-01', 'Full').properties.frontdoorId

module webApp1 './webApp.bicep' = {
  name: 'webApp1'
  params: {
    appPlanName: 'appServicePlan1'
    appName: appName1
    location: location1
    frontdoorId: frontDoorId
  }
}

module webApp2 './webApp.bicep' = {
  name: 'webApp2'
  params: {
    appPlanName: 'appServicePlan2'
    appName: appName2
    location: location2
    frontdoorId: frontDoorId
  }
}

resource frontDoor 'Microsoft.Network/frontDoors@2020-05-01' = {
  name: frontDoorName
  location: 'global'
  properties: {
    friendlyName: frontDoorName
    enabledState: 'Enabled'
    frontendEndpoints: [
      {
        name: frontendEndpoint1Name
        properties: {
          hostName: frontendEndpoint1hostName
          sessionAffinityEnabledState: 'Disabled'
          sessionAffinityTtlSeconds: 0
        }
      }
    ]
    backendPoolsSettings: {
      enforceCertificateNameCheck: 'Enabled'
      sendRecvTimeoutSeconds: 30
    }
    backendPools: [
      {
        name: backendPool1Name
        properties: {
          backends: [
            {
              address: webAppUri1
              backendHostHeader: webAppUri1
              enabledState: 'Enabled'
              httpPort: 80
              httpsPort: 443
              priority: 1
              weight: 50
            }
            {
              address: webAppUri2
              backendHostHeader: webAppUri2
              enabledState: 'Enabled'
              httpPort: 80
              httpsPort: 443
              priority: 1
              weight: 50
            }
          ]
          healthProbeSettings: {
            id: resourceId('Microsoft.Network/frontDoors/healthProbeSettings', frontDoorName, healthProbe1Name)
          }
          loadBalancingSettings: {
            id: resourceId('Microsoft.Network/frontDoors/LoadBalancingSettings', frontDoorName, loadBalancing1Name)
          }
        }
      }
    ]
    healthProbeSettings: [
      {
        name: healthProbe1Name
        properties: {
          intervalInSeconds: 30
          path: '/'
          protocol: 'Https'
        }
      }
    ]
    loadBalancingSettings: [
      {
        name: loadBalancing1Name
        properties: {
          additionalLatencyMilliseconds: 0
          sampleSize: 4
          successfulSamplesRequired: 2
        }
      }
    ]
    routingRules: [
      {
        name: routingRule1Name
        properties: {
          frontendEndpoints: [
            {
              id: resourceId('Microsoft.Network/frontDoors/FrontendEndpoints', frontDoorName, frontendEndpoint1Name)
            }
          ]
          acceptedProtocols: [
            'Http'
            'Https'
          ]
          patternsToMatch: [
            '/*'
          ]
          enabledState: 'Enabled'
          routeConfiguration: {
            '@odata.type': '#Microsoft.Azure.FrontDoor.Models.FrontdoorForwardingConfiguration'
            forwardingProtocol: 'HttpsOnly'
            backendPool: {
              id: resourceId('Microsoft.Network/frontDoors/BackendPools', frontDoorName, backendPool1Name)
            }
          }
        }
      }
    ]
  }
}