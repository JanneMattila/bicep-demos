param appName string = 'contoso00000000020'
param location string = 'north europe'

resource appServicePlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: 'asp'
  location: location
  kind: 'linux'
  sku: {
    name: 'S1'
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

      linuxFxVersion: 'DOCKER|jannemattila/webapp-update:1.0.1'
      appSettings: [
        {
          name: 'AppEnvironment'
          value: 'Banana'
        }
      ]
    }
    serverFarmId: appServicePlan.id
    httpsOnly: true
    clientAffinityEnabled: false
  }
}

resource slot 'Microsoft.Web/sites/slots@2020-06-01' = {
  name: '${appName}/staging'
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

      linuxFxVersion: 'DOCKER|jannemattila/webapp-update::1.0.1'
      appSettings: [
        {
          name: 'AppEnvironment'
          value: 'Orange'
        }
      ]
    }
    serverFarmId: appServicePlan.id
    httpsOnly: true
    clientAffinityEnabled: false
  }
}