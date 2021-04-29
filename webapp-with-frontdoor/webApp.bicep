param appPlanName string
param skuName string = 'B1'
param appName string
param location string = resourceGroup().location
param frontdoorId string

resource appServicePlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: appPlanName
  location: location
  kind: 'linux'
  sku: {
    name: skuName
  }
  properties: {
    reserved: true
  }
}

resource appService 'Microsoft.Web/sites@2020-06-01' = {
  name: appName
  location: location
  kind: 'web'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    siteConfig: {
      alwaysOn: true
      http20Enabled: true
      ftpsState: 'Disabled'

      linuxFxVersion: 'DOCKER|inanimate/echo-server'

      // https://docs.microsoft.com/en-us/azure/frontdoor/front-door-faq#how-do-i-lock-down-the-access-to-my-backend-to-only-azure-front-door-
      // https://docs.microsoft.com/en-us/azure/app-service/networking-features#access-restriction-rules-based-on-service-tags
      ipSecurityRestrictions: [
        {
          name: 'FrontDoor'
          description: 'Azure Front Door filtering'
          ipAddress: 'AzureFrontDoor.Backend'
          action: 'Allow'
          tag: 'ServiceTag'
          priority: 100
          headers: {
            'X-Azure-FDID': [
              frontdoorId
            ]
          }
        }
      ]
    }
    serverFarmId: appServicePlan.id
    httpsOnly: true
    clientAffinityEnabled: false
  }
}

output id string = appServicePlan.id
output name string = appService.name
