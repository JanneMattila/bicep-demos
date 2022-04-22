param appPlanName string
param skuName string = 'B1'
param appName string
param location string = resourceGroup().location

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

      linuxFxVersion: 'DOCKER|jannemattila/catch-the-banana'
    }
    serverFarmId: appServicePlan.id
    httpsOnly: false
    clientAffinityEnabled: false
  }
}

output id string = appServicePlan.id
output name string = appService.name
