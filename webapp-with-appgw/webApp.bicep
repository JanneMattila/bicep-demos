param appPlanName string
param skuName string = 'B1'
param appName string
param image string
param customPath string
param proxyIp string
param proxyHost string
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
      ipSecurityRestrictions: [
        {
          action: 'Allow'
          name: 'AppGateway'
          priority: 100
          ipAddress: '${proxyIp}/32'
        }
      ]

      alwaysOn: true
      http20Enabled: true
      ftpsState: 'Disabled'

      linuxFxVersion: image

      appSettings: [
        {
          name: 'AzureAd__Authority'
          value: '${environment().authentication.loginEndpoint}${environment().authentication.tenant}'
        }
        {
          name: 'AzureAd__ClientId'
          value: '<guid here>'
        }
        {
          name: 'AzureAd__ClientSecret'
          value: '<secret here>'
        }
        {
          name: 'CUSTOM_PATH'
          value: customPath
        }
        {
          name: 'CUSTOM_ALLOW_ALL_PROXIES'
          value: 'true'
        }
        {
          name: 'CUSTOM_ALLOWED_HOST'
          value: proxyHost
        }
      ]
    }
    serverFarmId: appServicePlan.id
    httpsOnly: false
    clientAffinityEnabled: false
  }
}

output id string = appServicePlan.id
output name string = appService.name
