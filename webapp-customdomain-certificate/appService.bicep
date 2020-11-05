param appName string
param appServicePlanId string
param location string = resourceGroup().location

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
    }
    serverFarmId: appServicePlanId
    httpsOnly: true
    clientAffinityEnabled: false
  }
}

output id string = appService.id
